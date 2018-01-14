"""Command-line interface for the name generator."""

import sys
import os


from generator import parsing


credit_blurb = """
PCFG Name Generator v1.0
By Iguanotron
2018-01-13
"""

help_blurb = """Commands:

help
\tDisplay this text
exit
\tExit session
list
\tList the currently loaded languages
load <filename>
\tLoad the specified language file from ./languages
build <language_key_or_name> [amount]
\tGenerate names from a language"""


def init():
    print(credit_blurb)
    print(help_blurb)

    languages_by_name = {}
    language_list = []

    def help_command():
        print(help_blurb)
    
    def exit_command():
        print('Exiting...')
        sys.exit()
    
    def list_command():
        print('Languages loaded:')
        for i, language in enumerate(language_list):
            print('%d\t%s' % (i, language.name))
    
    def load_command(filename):
        if '.' not in filename:
            filename += '.yaml'
        print('Loading from %s...' % filename)
        try:
            language = parsing.load_from_file(os.path.join(
                os.path.dirname(os.path.dirname(__file__)),
                'languages',
                filename
            ))
        except OSError:
            print('Could not read from file: %s' % filename)
            return
        except ValueError as e:
            print('Error parsing language file: %s' % e.args[0])
            return
        print('Successfully loaded %s (%d)' % (language.name, len(language_list)))
        language_list.append(language)
        languages_by_name[language.name.casefold()] = language
    
    def build_command(lang_key, amt=1):
        try:
            language = language_list[int(lang_key)]
        except (ValueError, IndexError):
            try:
                language = languages_by_name[lang_key.casefold()]
            except KeyError:
                print('Language not recognized: %s' % lang_key)
                return
        try:
            amt = int(amt)
        except ValueError:
            print('Invalid amount (must be a positive integer): %s' % amt)
        if amt <= 0:
            print('Invalid amount (must be a positive integer): %s' % amt)
        print('Building %d from %s:' % (amt, language.name))
        for i in range(amt):
            print(language.generate())

    while True:
        try:
            tokens = input('> ').split()
        except EOFError:
            print()
            exit_command()
            tokens = None
        if not tokens:
            continue
        cmd = tokens[0]
        num_args = len(tokens) - 1

        if cmd in ('h', 'help'):
            help_command()
        elif cmd in ('e', 'exit'):
            if num_args == 0:
                exit_command()
            else:
                print('Too many arguments (expected 0, got %d)' % num_args)
        elif cmd in ('l', 'list'):
            if num_args == 0:
                list_command()
            else:
                print('Too many arguments (expected 0, got %d)' % num_args)
        elif cmd in ('L', 'load'):
            if num_args == 1:
                load_command(tokens[1])
            else:
                print('Too %s arguments (expected 1, got %d)'
                      % ('few' if num_args < 1 else 'many', num_args))
        elif cmd in ('b', 'build'):
            if num_args == 1:
                build_command(tokens[1])
            elif num_args == 2:
                build_command(tokens[1], tokens[2])
            else:
                print('Too %s arguments (expected 1 or 2, got %d)'
                      % ('few' if num_args < 1 else 'many', num_args))
        else:
            print('Command not recognized; try `help` for a list of valid commands')
        