"""Command-line interface for the name generator."""

import sys

# enable history for input() on *nix
try:
    import readline
except ImportError:
    pass

from generator import parsing
from generator.session import NameGeneratorSession, print_error, print_color_error, noop


credit_blurb = """
PCFG Name Generator v1.2 (2018-08-18)
By Iguanotron
"""

help_blurb = """Commands:
  help
  \tDisplay this text
  exit
  quit
  \tExit session
  list
  \tList the currently loaded languages and metalanguages
  load <filename>
  open <filename>
  \tLoad the specified file or folder of files
  activate <name>
  \tActivate the specified language or metalanguage for future builds
  deactivate <name>
  \tDeactivate the specified language or metalanguage for future builds
  build [amount]
  \tGenerate names from the active language"""


def print_help():
    print(help_blurb)


def run(**kwargs):
    """Run an interactive name generator session."""
    session = NameGeneratorSession(**kwargs)

    use_color = kwargs.get('color', False)
    error = print_color_error if use_color else print_error
    report = noop if kwargs.get('quiet', False) else print

    def exit_session():
        report('Exiting...')
        sys.exit()

    def validate_num_args(arg_counts_accepted, num_args):
        if num_args in arg_counts_accepted:
            return True

        if len(arg_counts_accepted) <= 2:
            expected = ' or '.join(map(str, arg_counts_accepted))
        else:
            expected = ', '.join([str(n) for n in arg_counts_accepted][:-1]) + f', or {arg_counts_accepted[-1]}'
    
        if all(num_args < n for n in arg_counts_accepted):
            error(f'Too few arguments (expected {expected}, got {num_args})')
        elif all(num_args > n for n in arg_counts_accepted):
            error(f'Too many arguments (expected {expected}, got {num_args})')
        else:
            error(f'Invalid number of arguments (expected {expected}, got {num_args})')
        return False

    command_dispatch_table = [
        (['h', 'help'], [0], print_help),
        (['e', 'q', 'exit', 'quit'], [0], exit_session),
        (['o', 'load', 'open'], [1], session.load),
        (['l', 'list'], [0], session.list),
        (['b', 'build'], [0, 1], session.build),
        (['a', 'activate'], [1], session.activate),
        (['d', 'deactivate'], [1], session.deactivate),
    ]

    def execute(command):
        tokens = command.split()
        if not tokens:
            return
        cmd = tokens[0]
        num_args = len(tokens) - 1

        for commands, arg_counts_accepted, command_func in command_dispatch_table:
            if cmd in commands:
                if not validate_num_args(arg_counts_accepted, num_args):
                    return
                command_func(*tokens[1:])
                return
        error('Command not recognized; try `help` for a list of valid commands')

    # parse prelude if given
    if kwargs.get('commands'):
        try:
            with open(kwargs['commands'], 'r') as f:
                for cmd in f:
                    execute(cmd)
        except IOError:
            error('Could not open file: %s' % kwargs['commands'], file=sys.stderr)
            sys.exit(2)
        except KeyboardInterrupt:
            report('Interrupted')
    else:
        report(credit_blurb)
        report(help_blurb)

    # Run interactive session
    if (not kwargs.get('commands')) or kwargs.get('interactive'):
        while True:
            try:
                execute(input(f'[{session.active_name}]> '))
            except KeyboardInterrupt:
                report()
                report('Interrupted')
            except EOFError:
                report()
                exit_command()
