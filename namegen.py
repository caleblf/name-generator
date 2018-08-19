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

import os
import argparse

from generator import interactive


def device_supports_color():
    """Return whether this device supports ANSI color codes.
    Adapted from django.core.management.color.supports_color
    """
    plat = sys.platform
    supported_platform = plat != 'Pocket PC' and (plat != 'win32' or
                                                  'ANSICON' in os.environ)
    is_a_tty = hasattr(sys.stdout, 'isatty') and sys.stdout.isatty()
    return supported_platform and is_a_tty


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('commandfile',
                        type=str,
                        nargs='?',
                        help='file of commands to execute')
    parser.add_argument('-i', '--interactive',
                        action='store_true',
                        help='if commandfile is passed, enter interactive '
                             'mode after executing commands')
    parser.add_argument('-c', '--color',
                        action='store_true',
                        help='use colored text for names (requires '
                             '`colorama` package on Windows)')
    parser.add_argument('-w', '--suppress-warnings',
                        action='store_true',
                        help='suppress compatibility warnings')
    parser.add_argument('-q', '--quiet',
                        action='store_true',
                        help='suppress success confirmation messages')
    args = parser.parse_args()

    if args.color and not device_supports_color():
        try:
            import colorama  # for MS Windows color support
            colorama.init()
        except ImportError:
            if not args.suppress_warnings:
                print('The `colorama` package is required for color output '
                      'support on some platforms. To suppress this warning, '
                      'use the -w flag.', file=sys.stderr)

    interactive.run(**vars(args))
