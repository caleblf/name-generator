#!/usr/bin/env python3
"""Conversion script for language files."""

import sys
import argparse
import pathlib
import itertools

from generator import pcfgparse


def elmify_language(module_name, data):
    """Elmify a language from YAML data. Outputs a string file body"""
    header = data.header
    forms = data.forms

    try:
        name = header['name']
        root = header['root']
    except KeyError as e:
        raise ValueError(f'Missing required header field: {e.args[0]}')

    if not name.isidentifier():
        raise ValueError('Invalid language name')

    def canonize_tag(tag):
        """Return a canonized version of the given tag.
        The result is a valid Elm identifier.
        """
        if tag in {module_name, 'lit', 'cat', 'u', 'p', 'pick'}:
            raise ValueError(f'Invalid tag: {tag}')
        return tag.replace('-', '_')

    def elmify_literal(content):
        return f'lit "{content}"'

    def elmify_concatenation(elements):
        return f'cat [{", ".join(map(elmify_exp, elements))}]'

    def elmify_form_tag(tag):
        if tag not in forms:
            raise ValueError(f'Unknown tag in form expression: {tag}')
        return canonize_tag(tag)

    def elmify_exp(exp):
        return exp.express_as(
            literal=elmify_literal,
            concatenation=elmify_concatenation,
            tag=elmify_form_tag,
        )

    def elmify_probabilistic_form_entry(weight, value):
        return f'({weight}, {elmify_exp(value)})'

    def elmify_form(tag, entries):
        if len(entries) == 1:
            return f'{tag} = {elmify_exp(entries[0][1])}'
        elif not entries:
            raise ValueError(f'No options for form tag: {tag}')
        else:
            line_sep = "\n  , "
            return (f'{tag} _ = pick\n  [ ' +
                    line_sep.join(itertools.starmap(
                        elmify_probabilistic_form_entry,
                        entries
                    )) +
                    '\n  ]')

    elm_definitions = [elmify_form(canonize_tag(tag), v)
                       for tag, v in forms.items()]

    line_sep = '\n\n'
    return f'''module {module_name.capitalize()} exposing ({module_name})

import Language exposing (Language, Form, lit, cat, pick, u, p)


{module_name} : Language
{module_name} =
  {{ name = "{name}"
  , generator = {root}
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
    try:
        data = pcfgparse.read(infile)
    except ValueError as e:
        print(f'Could not parse language file: {e}')
        exit(1)
    except OSError as e:
        print(f'Could not read language file: {e}')
        exit(1)

    print(f'Converting to Elm...')
    module_name = infile.stem
    if module_name[0].isupper() or not module_name.isidentifier():
        print(f'Cannot construct Elm name from filename: {module_name}', file=sys.stderr)
        exit(1)

    elm_text = elmify_language(module_name, data)

    outfile = outdir / (module_name.capitalize() + '.elm')

    print(f'Writing Elm language file: {outfile}')
    with open(outfile, 'w') as f:
        f.write(elm_text)