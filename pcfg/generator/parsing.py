"""Parser for language files."""

import yaml

from generator import language

# TODO use weak references for better garbage collecting with disconnected languages


def unzip(l):
    return zip(*l)


def make_form_placeholder(v):
    if isinstance(v, list):
        return language.ProbabilisticForm([], [])
    if v.startswith('('): # concatenation
        if not v.endswith(')'):
            raise ValueError('Unmatched parenthesis in form expression: %s' % v)
        return language.ConcatenativeForm([])
    if v.startswith('$'): # tag
        raise ValueError('Tag at top level in form expression: %s' % v)
    # literal
    return language.LiteralForm(v)


def load_from_file(filename):
    """Load a language from a file."""
    try:
        with open(filename, 'r') as f:
            data = yaml.load(f)
    except yaml.error.YAMLError as e:
        raise ValueError('Improperly formatted YAML file') from e
    name = data['name'];
    tagged_forms = {k: make_form_placeholder(v) for k, v in data['forms'].items()}

    def parse_form_exp(exp):
        if exp.startswith('('): # concatenation
            if not exp.endswith(')'):
                raise ValueError('Unmatched parenthesis in form expression: %s' % exp)
            return language.ConcatenativeForm([
                parse_form_exp(s)
                for s in exp[1:-1].split()
            ])
        if exp.startswith('$'): # tag
            try:
                return tagged_forms[exp[1:]]
            except KeyError:
                raise ValueError('Unknown key in form expression: %s' % exp)
        # literal
        return language.LiteralForm(exp)

    def parse_probabilistic_form_clause(s):
        elements = s.split(maxsplit=1)
        try:
            odds = int(elements[0])
            return parse_form_exp(elements[1]), odds
        except ValueError:
            return parse_form_exp(s.strip()), 1

    # parse root form
    root_form = parse_form_exp(data['root'])

    # parse tagged forms
    for tag, form in tagged_forms.items():
        if isinstance(form, language.ProbabilisticForm):
            form.set_forms(*unzip(map(
                parse_probabilistic_form_clause,
                data['forms'][tag])))
        elif isinstance(form, language.ConcatenativeForm):
            form.set_forms(parse_form_exp(data['forms'][tag]).forms)

    return language.Language(name, root_form)
