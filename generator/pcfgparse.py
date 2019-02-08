"""Parser for .pcfg files."""


class PCFG:

    def __init__(self, *, header, forms):
        self.header = header
        self.forms = forms

    def __repr__(self):
        return (f'{self.__class__.__name__}'
                f'(header={self.header!r}, forms={self.forms!r})')


class FormExpansion:
    """Includes a single-dispatch CPS method that converts forms"""

    def express_as(self, *, literal, concatenation, tag):
        raise NotImplemented

    def __repr__(self):
        return f'{self.__class__.__name__}()'


class Literal(FormExpansion):

    def __init__(self, content):
        self.content = content

    def express_as(self, *, literal, **kwargs):
        return literal(self.content)

    def __repr__(self):
        return f'{self.__class__.__name__}({self.content!r})'


class Concatenation(FormExpansion):

    def __init__(self, elements):
        self.elements = list(elements)

    def express_as(self, *, concatenation, **kwargs):
        return concatenation(self.elements)

    def __repr__(self):
        return f'{self.__class__.__name__}({self.elements!r})'


class FormTag(FormExpansion):

    def __init__(self, tag):
        self.tag = tag

    def express_as(self, *, tag, **kwargs):
        return tag(self.tag)

    def __repr__(self):
        return f'{self.__class__.__name__}({self.tag!r})'


def is_name(s):
    return (s and s[0].isalpha() and s.islower() and
            all(c.isalnum() or c == '-' for c in s))


def read_form_expression(s):
    """Read a form expression as part of a concatenation expression.concatenation

    s is assmed to have whitespace trimmed from both sides.
    """
    if not s:
        raise ValueError('Empty form expression')
    elif s.startswith('"'):
        # quoted literal
        content, quote, rest = s[1:].partition('"')
        if not quote:
            raise ValueError('Mismatched quote')
        if rest:
            raise ValueError('Invalid form expression')
        return Literal(content)
    elif s.startswith('$'):
        # form tag
        tag = s[1:]
        if not is_name(tag):
            raise ValueError('Invalid tag')
        return FormTag(tag)
    elif s.startswith('['):
        # concatenation
        raise ValueError('Nested concatenation')
    else:
        # bare literal
        if any(c in s for c in '#$:[]!"\t') or any(c.isdigit() for c in s):
            raise ValueError('Invalid form expression')
        return Literal(s)


def read_form_case(s):
    """Return a weight and FormExpansion"""
    if s[0].isdigit():
        weight_string, space, s = s.partition(' ')
        if not s:
            raise ValueError('No value given with weight')
        try:
            weight = float(weight_string)
        except ValueError:
            raise ValueError('Invalid weight')
    else:
        weight = 1.0

    if s.startswith('"'):
        # quoted literal
        content, quote, rest = s[1:].partition('"')
        if not quote:
            raise ValueError('Mismatched quote')
        if rest.partition('#')[0].strip(' '):
            raise ValueError('Invalid form expansion')
        return weight, Literal(content)
    elif s.startswith('$'):
        # form tag
        tag = s[1:].partition('#')[0].rstrip(' ')
        if not is_name(tag):
            raise ValueError('Invalid tag')
        return weight, FormTag(tag)
    elif s.startswith('['):
        # concatenation
        content, bracket, rest = s[1:].partition(']')
        if not bracket:
            raise ValueError('Mismatched concatenation bracket')
        if rest.partition('#')[0].strip(' '):
            raise ValueError('Invalid form expansion')
        return weight, Concatenation(map(read_form_expression, content.split(' ')))
    elif s.startswith(' '):
        # syntax error
        raise ValueError('Improperly indented form expansion')
    else:
        # bare string literal
        content = s.partition('#')[0].rstrip(' ')
        if (any(c in content for c in '$:[]!"\t') or any(c.isdigit() for c in content)):
            raise ValueError('Invalid form expression')
        return weight, Literal(content)


def read_lines(lines):
    """Group lines into parts of the file"""
    header = {}
    forms = {}  # {str: [float, FormExpansion]}

    # header
    for i, line in enumerate(lines):
        if not line or line.isspace():
            pass
        elif line.startswith('!'):
            # header line
            field, colon, value = line[1:].partition(':')
            if not colon:
                raise ValueError(f'No colon in header line at line {i + 1}')
            field = field.strip(' ')
            value = value.partition('#')[0].strip(' ')
            if not is_name(field):
                raise ValueError(f'Invalid field name in header at line {i + 1}')
            if not value:
                raise ValueError(f'Empty value in header at line {i + 1}')
            if field in header:
                raise ValueError(f'Field set twice in header at line {i + 1}')
            header[field] = value
        elif line.lstrip(' ').startswith('#'):
            # comment
            pass
        else:
            # header ended
            break

    header_end_index = i
    current_form = None

    # forms
    for i, line in enumerate(lines[header_end_index:]):
        if not line or line.isspace():
            pass
        elif line.startswith('!'):
            # header line
            raise ValueError('Header line found outside of header '
                             f'at line {header_end_index + i + 1}')
        elif line.lstrip(' ').startswith('#'):
            # comment
            pass
        elif line.startswith('  '):
            # indented case
            if current_form is None:
                raise ValueError('No form tag specified before case '
                                 f'at line {header_end_index + i + 1}')
            try:
                forms[current_form].append(read_form_case(line[2:]))
            except ValueError as e:
                raise ValueError(str(e) + f' at line {header_end_index + i + 1}')
        else:
            # form tag
            if current_form is not None and not forms[current_form]:
                raise ValueError('Empty form statement'
                                 f' at line {header_end_index + i + 1}')
            tag, colon, rest = line.partition(':')
            if not colon:
                raise ValueError(f'Tag missing colon at line {header_end_index + i + 1}')
            tag = tag.strip(' ')
            rest = rest.lstrip(' ')
            if not is_name(tag):
                raise ValueError(f'Invalid tag name at line {header_end_index + i + 1}')
            if tag in forms:
                raise ValueError('Form tag specified twice '
                                 f'at line {header_end_index + i + 1}')
            if not rest or rest.startswith('#'):
                # cases on following lines
                current_form = tag
                forms[tag] = []
            else:
                # single case on this line
                current_form = None
                try:
                    forms[tag] = [read_form_case(rest)]
                except ValueError as e:
                    raise ValueError(str(e) + f' at line {header_end_index + i + 1}')

    if current_form is not None and not forms[current_form]:
        raise ValueError(f'Empty form statement at line {len(lines)}')

    # detect singleton form tags in tagged forms
    if any(len(cases) == 1 and isinstance(cases[0], FormTag)
           for cases in forms.values()):
        raise ValueError(f'Tag at top level in tagged form expression')

    return PCFG(header=header, forms=forms)


def read(path):
    """Read the PCFG file at the specified location.
    Params:
        path : str or pathlike
    Return:
        PCFG file structure
    """
    with open(path, 'r') as f:
        return read_lines(f.read().splitlines())
