#!/usr/bin/env python3
"""Conversion script for language files."""

import sys

if (sys.version_info.major, sys.version_info.minor) < (3, 6):
    print('Python version not supported (3.6 or later required)', file=sys.stderr)
    sys.exit(1)

try:
    import yaml
except ImportError:
    print('Missing third party dependency: `pyyaml`', file=sys.stderr)
    sys.exit(1)

import os
import argparse
import pathlib


def get_yaml_data(file):
    try:
        with open(file, 'r') as f:
            return yaml.load(f)
    except yaml.error.YAMLError as e:
        raise ValueError('Improperly formatted YAML file') from e
    except OSError as e:
        raise ValueError('File not found or unreadable') from e


def elmify_language(module_name, data):
    """Elmify a language from YAML data. Outputs a string file body"""
    try:
        name = data['name']
        kind = data['kind']
        root = data['root']
        forms = data.get('forms', {})
    except KeyError as e:
        raise ValueError(f'Missing required field: {e.args[0]}')

    if not kind == 'language':
        raise ValueError('Not a language')
    if not isinstance(name, str):
        raise ValueError('Non-string language name')
    if not name.isidentifier():
        raise ValueError('Invalid language name')
    if not isinstance(forms, dict):
        raise ValueError('Tagged forms table not a dictionary')

    def canonize_tag(tag):
        """Return a canonized version of the given tag.
        The result is a valid Elm identifier.
        """
        if '_' in tag:
            raise ValueError(f'Invalid tag: {tag}')
        tag = tag.replace('-', '_')
        if tag in {module_name, 'lit', 'cat', 'u', 'p', 'pick'}:
            raise ValueError(f'Invalid tag: {tag}')
        if tag[0].isupper() or not tag[0].isalpha() or not tag.isidentifier():
            raise ValueError(f'Invalid tag: {tag}')
        return tag

    def elmify_exp(exp):
        if exp.startswith('('):  # concatenation
            if not exp.endswith(')'):
                raise ValueError(f'Unmatched parenthesis in form expression: {exp}')
            return f'cat [{", ".join(map(elmify_exp, exp[1:-1].split()))}]'
        if exp.startswith('$'):  # tag
            if exp[1:] not in forms:
                raise ValueError(f'Unknown tag in form expression: {exp}')
            return canonize_tag(exp[1:])
        return f'lit "{exp}"'

    def elmify_probabilistic_form_clause(s):
        if s is None:
            raise ValueError('Empty form clause')
        if not isinstance(s, str):
            raise ValueError('Non-string form clause')
        elements = s.split(maxsplit=1)
        try:
            odds = int(elements[0])
            subexp = elements[1]
        except (ValueError, IndexError):
            odds = 1
            subexp = s.strip()
        return f'({odds}, {elmify_exp(subexp)})'

    def elmify_tagged_probabilistic(tag, clauses):
        line_sep = "\n  , "
        return (f'{tag} _ = pick\n  [ '
                f'{line_sep.join(map(elmify_probabilistic_form_clause, clauses))}\n  ]')

    def elmify_tagged(tag, v):
        if isinstance(v, list):
            return elmify_tagged_probabilistic(tag, v)
        if not isinstance(v, str):
            raise ValueError('Non-string form expression in tag')
        if v.startswith('$'):  # tag
            raise ValueError(f'Tag at top level in tagged form expression: {v}')
        return f'{tag} = {elmify_exp(v)}'

    elm_definitions = [elmify_tagged(canonize_tag(tag), v)
                       for tag, v in forms.items()]

    line_sep = '\n\n'
    return f'''module {module_name.capitalize()} exposing ({module_name})

import Language exposing (Language, Form, lit, cat, pick, u, p)


{module_name} : Language
{module_name} =
  {{ name = "{name}"
  , generator = {elmify_exp(root)}
  }}


{line_sep.join(elm_definitions)}
'''


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file',
                        type=str,
                        help='YAML language file to convert')
    parser.add_argument('-o', '--outdir',
                        type=str,
                        required=True,
                        help='location to place Elm output')
    parser.add_argument('-q', '--quiet',
                        action='store_true',
                        help='suppress success confirmation messages')
    args = parser.parse_args()

    infile = pathlib.Path(args.file)
    outdir = pathlib.Path(args.outdir)

    if not outdir.is_dir():
        print(f'Not a directory: {outdir}', file=sys.stderr)
        exit(1)

    print(f'Reading YAML language file: {infile}')
    yaml_data = get_yaml_data(infile)

    print(f'Converting to Elm...')
    module_name = infile.stem
    if module_name[0].isupper() or not module_name.isidentifier():
        print(f'Cannot construct Elm name from filename: {module_name}', file=sys.stderr)
        exit(1)

    elm_text = elmify_language(module_name, yaml_data)

    outfile = outdir / (module_name.capitalize() + '.elm')

    print(f'Writing Elm language file: {outfile}')
    with open(outfile, 'w') as f:
        f.write(elm_text)
