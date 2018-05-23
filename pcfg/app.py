#!/usr/bin/env python3

import argparse

from generator import interactive


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('commands', type=str, nargs='?',
                        help='Commands to execute')
    parser.add_argument('-i', action='store_true',
                        help='If commands are passed, enter interactive mode after executing commands')
    args = parser.parse_args()
    interactive.init(args)
