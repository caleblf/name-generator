#!/usr/bin/env python3

import sys

if (sys.version_info.major, sys.version_info.minor) < (3, 6):
    print('Python version not supported (3.6 or later required)', file=sys.stderr)
    sys.exit(1)

try:
    import yaml
except ImportError:
    print('Missing third party dependency: `pyyaml`', file=sys.stderr)
    sys.exit(1)

import argparse

from generator import interactive


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('commands',
                        type=str,
                        nargs='?',
                        help='Commands to execute')
    parser.add_argument('-i', '--interactive',
                        action='store_true',
                        help='If commands are passed, enter interactive mode '
                             'after executing commands')
    parser.add_argument('-c', '--color',
                        action='store_true',
                        help='Use colored text for names')
    parser.add_argument('-w', '--suppress-warnings',
                        action='store_true',
                        help='Suppress compatibility warnings')
    parser.add_argument('-q', '--quiet',
                        action='store_true',
                        help='Suppress success confirmation messages')
    args = parser.parse_args()

    if args.color:
        try:
            import colorama  # for MS Windows color support
            colorama.init()
        except ImportError:
            if not args.suppress_warnings:
                print('The `colorama` package is required for color output '
                      'support on some platforms. To suppress this warning, '
                      'use the -w flag.', file=sys.stderr)

    interactive.run(**vars(args))
