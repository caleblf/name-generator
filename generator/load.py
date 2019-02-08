"""Language file loader"""

from generator import language
from generator import pcfgparse


def unzip(l):
    return zip(*l)


def load_forms(form_data):
    forms = {}

    def convert_concatenation(elements):
        return language.ConcatenativeForm([convert(elem) for elem in elements])

    def convert_tag(tag):
        if tag not in form_data:
            raise ValueError(f'Unknown tag in form expression: {tag}')
        return language.TagForm(tag=tag, forms=forms)

    def convert(exp):
        return exp.express_as(
            literal=language.LiteralForm,
            concatenation=convert_concatenation,
            tag=convert_tag,
        )

    for tag, cases in form_data.items():
        if not cases:
            pass  # should not happen unless a placeholder is added
        elif len(cases) == 1:
            forms[tag] = convert(cases[0][1])
        else:
            forms[tag] = language.ProbabilisticForm(*unzip(
                (convert(exp), weight) for weight, exp in cases
            ))

    return forms


def load_language(data):
    header = data.header
    form_data = data.forms

    try:
        name = header['name']
        root_tag = header['root']
    except KeyError as e:
        raise ValueError(f'Missing required header field: {e.args[0]}')

    forms = load_forms(form_data)

    return language.Language(name, forms[root_tag])


def load_transform(data):
    header = data.header
    form_data = data.forms

    try:
        name = header['name']
        input_tag = header['input']
        output_tag = header['output']
        priority = int(header['priority'])
    except KeyError as e:
        raise ValueError(f'Missing required header field: {e.args[0]}')
    except ValueError:
        raise ValueError(f'Non-integer priority: {priority}')

    form_data[input_tag] = None

    forms = load_forms(form_data)

    in_form = language.VariableForm('$UNSET')
    out_form = language.TagForm(tag=output_tag, forms=forms)

    forms[input_tag] = in_form

    return language.LanguageTransform(name, out_form, priority, in_form)


def load_file(path):
    data = pcfgparse.read(path)
    header = data.header

    if 'input' in header and 'output' in header and 'priority' in header:
        # transform
        return load_transform(data)
    elif 'root' in header:
        # language
        return load_language(data)
    else:
        raise ValueError(f'Invalid file kind in {path}')
