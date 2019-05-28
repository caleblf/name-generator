#!/usr/bin/env python3
"""Automatic generation of src/Manifest.elm."""

import sys
import argparse
import pathlib
import textwrap

newline = '\n'


def lang_import_line(name):
    return f'import Languages.{name} exposing ({name.lower()})'


def tform_import_line(name):
    return f'import Transforms.{name} exposing ({name.lower()})'


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source_dir',
                        type=str,
                        help='Elm source directory containing Languages/'
                             'and Transforms/ directories')
    parser.add_argument('-q', '--quiet',
                        action='store_true',
                        help='suppress success confirmation messages')
    args = parser.parse_args()

    src_dir = pathlib.Path(args.source_dir)
    langs_dir = src_dir / 'Languages'
    tforms_dir = src_dir / 'Transforms'
    manifest_file = src_dir / 'Manifest.elm'

    if not src_dir.is_dir():
        print(f'Not a directory: {src_dir}', file=sys.stderr)
        exit(1)
    if not langs_dir.is_dir():
        print(f'Not a directory: {langs_dir}', file=sys.stderr)
        exit(1)
    if tforms_dir.exists() and not tforms_dir.is_dir():
        print(f'Exists but is not a directory: {tforms_dir}', file=sys.stderr)
        exit(1)
    if manifest_file.exists() and not manifest_file.is_file():
        print(f'Exists but is not a file: {tforms_dir}', file=sys.stderr)
        exit(1)

    print(f'Listing directory {langs_dir}')
    try:
        lang_names = [file.stem for file in langs_dir.iterdir()]
    except OSError as e:
        print(f'Error while iterating directory: {e}')
        exit(1)

    if tforms_dir.exists():
        print(f'Listing directory {tforms_dir}')
        try:
            tform_names = [file.stem for file in tforms_dir.iterdir()]
        except OSError as e:
            print(f'Error while iterating directory: {e}')
            exit(1)
    else:
        tform_names = []

    print(f'Building manifest...')
    elm_text = f'''module Manifest exposing (languages, transforms)

import Pcfg exposing (Language, Transform)

{newline.join(lang_import_line(name) for name in lang_names)}

{newline.join(tform_import_line(name) for name in tform_names)}

languages : List Language
languages =
  List.sortBy .priority
    [ {textwrap.indent(newline.join(map(str.lower, lang_names)), '    , ')[6:]}
    ]

transforms : List Transform
transforms =
  List.sortBy .priority
    [ {textwrap.indent(newline.join(map(str.lower, tform_names)), '    , ')[6:]}
    ]
'''

    print(f'Writing manifest to {manifest_file}')
    with open(manifest_file, 'w') as f:
        f.write(elm_text)
