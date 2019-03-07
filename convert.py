#!/usr/bin/env python3
"""Conversion script for language files."""

import sys
import argparse
import pathlib
import itertools
import textwrap

from generator import pcfgparse


def elmify_definitions(module_name, forms):

    def canonize_tag(tag):
        """Return a canonized version of the given tag.
        The result is a valid Elm identifier.
        """
        if tag == module_name:
            raise ValueError(f'Invalid tag: {tag}')
        return tag.replace('-', '_')

    def elmify_literal(content):
        return f'literalForm "{content}"'

    def elmify_concatenation(elements):
        return f'concatForms [{", ".join(map(elmify_exp, elements))}]'

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
            return (f'{tag} _ = pickWeightedForm\n  [ ' +
                    line_sep.join(itertools.starmap(
                        elmify_probabilistic_form_entry,
                        entries
                    )) +
                    '\n  ]')

    return [elmify_form(canonize_tag(tag), v)
            for tag, v in forms.items() if v is not None]


def elmify_transform(module_name, data):
    """Elmify a language trasnform from PCFG data. Outputs a string file body"""
    header = data.header

    try:
        name = header['name']
        description = header['description'].replace('"', r'\"')
        input_tag = header['input']
        output_tag = header['output']
        priority = int(header['priority'])
    except KeyError as e:
        raise ValueError(f'Missing required header field: {e.args[0]}')
    except ValueError:
        raise ValueError(f'Non-integer priority: {priority}')

    if not name.isidentifier():
        raise ValueError('Invalid language name')

    data.forms[input_tag] = None

    elm_definitions = elmify_definitions(module_name, data.forms)

    def canonize_tag(tag):
        """Return a canonized version of the given tag.
        The result is a valid Elm identifier.
        """
        if tag == module_name:
            raise ValueError(f'Invalid tag: {tag}')
        return tag.replace('-', '_')

    line_sep = '\n\n'
    return f'''module Transforms.{module_name.capitalize()} exposing ({module_name})

import Pcfg exposing (Transform, literalForm, concatForms, pickWeightedForm)


{module_name} : Transform
{module_name} =
  {{ name = "{name}"
  , description = "{description}"
  , priority = {priority}
  , transform = transformName
  }}


transformName {canonize_tag(input_tag)} =
  let {textwrap.indent(line_sep.join(elm_definitions), '      ')[6:]}
  in {canonize_tag(output_tag)}
'''


def elmify_language(module_name, data):
    """Elmify a language from PCFG data. Outputs a string file body"""
    header = data.header

    try:
        name = header['name']
        description = header['description'].replace('"', r'\"')
        root_tag = header['root']
    except KeyError as e:
        raise ValueError(f'Missing required header field: {e.args[0]}')

    if not name.isidentifier():
        raise ValueError('Invalid language name')

    elm_definitions = elmify_definitions(module_name, data.forms)

    def canonize_tag(tag):
        """Return a canonized version of the given tag.
        The result is a valid Elm identifier.
        """
        if tag == module_name:
            raise ValueError(f'Invalid tag: {tag}')
        return tag.replace('-', '_')

    line_sep = '\n\n'
    return f'''module Languages.{module_name.capitalize()} exposing ({module_name})

import Pcfg exposing (Language, literalForm, concatForms, pickWeightedForm)


{module_name} : Language
{module_name} =
  {{ name = "{name}"
  , description = "{description}"
  , generator = {canonize_tag(root_tag)}
  }}


{line_sep.join(elm_definitions)}
'''


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file',
                        type=str,
                        help='PCFG language file to convert')
    parser.add_argument('-o', '--outdir',
                        type=str,
                        required=True,
                        help='Elm source directory in which to place output'
                             '(output is placed in subdirectories)')
    parser.add_argument('-q', '--quiet',
                        action='store_true',
                        help='suppress success confirmation messages')
    args = parser.parse_args()

    infile = pathlib.Path(args.file)
    outdir = pathlib.Path(args.outdir)

    if not outdir.is_dir():
        print(f'Not a directory: {outdir}', file=sys.stderr)
        exit(1)

    print(f'Reading PCFG language file: {infile}')
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

    if 'root' in data.header:
        elm_text = elmify_language(module_name, data)
        outfile = outdir / "Languages" / (module_name.capitalize() + '.elm')
    else:
        elm_text = elmify_transform(module_name, data)
        outfile = outdir / "Transforms" / (module_name.capitalize() + '.elm')

    print(f'Writing Elm PCFG file: {outfile}')
    with open(outfile, 'w') as f:
        f.write(elm_text)
