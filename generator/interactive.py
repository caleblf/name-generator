"""Command-line interface for the name generator."""

import sys
import os
import operator

from generator import parsing


credit_blurb = """
PCFG Name Generator v1.0 (2018-01-13)
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
  \tLoad the specified language file from ./languages
  load-meta <filename>
  open-meta <filename>
  \tLoad the specified metalanguage file from ./metalanguages
  activate <metalanguage_key_or_name>
  \tActivate the specified metalanguage for future builds
  dactivate <metalanguage_key_or_name>
  \tDeactivate the specified metalanguage for future builds
  build <language_key_or_name> [amount]
  \tGenerate names from a language"""

get_metalanguage_priority = operator.attrgetter('priority')


def init(args):
    languages_by_name = {}
    language_list = []
    metalanguages_by_name = {}
    metalanguage_list = []
    active_metalanguages = []

    def help_command():
        print(help_blurb)
    
    def exit_command():
        print('Exiting...')
        sys.exit()
    
    def list_command():
        if language_list:
            print('Languages loaded:')
            for i, language in enumerate(language_list):
                print('%d\t%s' % (i, language.name))
        else:
            print('No languages loaded.')
        if metalanguage_list:
            print('Metalanguages loaded:')
            for i, metalanguage in enumerate(metalanguage_list):
                print('%d\t%s%s' % (
                    i,
                    metalanguage.name,
                    '\t(active)' if metalanguage in active_metalanguages else ''
                ))
        else:
            print('No metalanguages loaded.')
    
    def load_language_command(filename):
        if '.' not in filename:
            filename += '.yaml'
        print('Loading from %s...' % filename)
        try:
            language = parsing.load_language_file(os.path.join(
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

    def load_metalanguage_command(filename):
        if '.' not in filename:
            filename += '.yaml'
        print('Loading from %s...' % filename)
        try:
            metalanguage = parsing.load_metalanguage_file(os.path.join(
                os.path.dirname(os.path.dirname(__file__)),
                'metalanguages',
                filename
            ))
        except OSError:
            print('Could not read from file: %s' % filename)
            return
        except ValueError as e:
            print('Error parsing metalanguage file: %s' % e.args[0])
            return
        print('Successfully loaded %s (%d)' % (metalanguage.name, len(metalanguage_list)))
        metalanguage_list.append(metalanguage)
        metalanguages_by_name[metalanguage.name.casefold()] = metalanguage

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
            if args.color:
                result = '\033[1;36m%s\033[0m' % language.generate()
            else:
                result = language.generate()
            for mlang in active_metalanguages:
                result = mlang.generate(result)
            print(result)

    def activate_command(metalang_key):
        try:
            metalanguage = metalanguage_list[int(metalang_key)]
        except (ValueError, IndexError):
            try:
                metalanguage = metalanguages_by_name[metalang_key.casefold()]
            except KeyError:
                print('Metalanguage not recognized: %s' % metalang_key)
                return
        active_metalanguages.append(metalanguage)
        print('activated %s' % metalanguage.name)
        active_metalanguages.sort(key=get_metalanguage_priority)

    def deactivate_command(metalang_key):
        try:
            metalanguage = metalanguage_list[int(metalang_key)]
        except (ValueError, IndexError):
            try:
                metalanguage = metalanguages_by_name[metalang_key.casefold()]
                active_metalanguages.remove(metalanguage)
            except KeyError:
                print('Metalanguage not recognized: %s' % metalang_key)
                return
            except ValueError:
                print('Metalanguage not active: %s' % metalang_key)
                return
        print('Deactivated %s' % metalanguage.name)

    def execute(command):
        tokens = command.split()
        cmd = tokens[0]
        num_args = len(tokens) - 1

        if cmd in ('h', 'help'):
            help_command()
        elif cmd in ('e', 'exit', 'q', 'quit'):
            if num_args == 0:
                exit_command()
            else:
                print('Too many arguments (expected 0, got %d)' % num_args)
        elif cmd in ('l', 'list'):
            if num_args == 0:
                list_command()
            else:
                print('Too many arguments (expected 0, got %d)' % num_args)
        elif cmd in ('o', 'load', 'open'):
            if num_args == 1:
                load_language_command(tokens[1])
            else:
                print('Too %s arguments (expected 1, got %d)'
                      % ('few' if num_args < 1 else 'many', num_args))
        elif cmd in ('m', 'load-meta', 'open-meta'):
            if num_args == 1:
                load_metalanguage_command(tokens[1])
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
        elif cmd in ('a', 'activate'):
            if num_args == 1:
                activate_command(tokens[1])
            else:
                print('Too %s arguments (expected 1, got %d)'
                      % ('few' if num_args < 1 else 'many', num_args))
        elif cmd in ('d', 'deactivate'):
            if num_args == 1:
                deactivate_command(tokens[1])
            else:
                print('Too %s arguments (expected 1, got %d)'
                      % ('few' if num_args < 1 else 'many', num_args))
        else:
            print('Command not recognized; try `help` for a list of valid commands')

    # parse commands given as argument, if given
    if args.commands:
        try:
            with open(args.commands, 'r') as f:
                for cmd in f:
                    execute(cmd)
        except IOError:
            print('Could not open file: %s' % args.commands, file=sys.stderr)
            exit(2)

    # Run interactive session, if so directed
    if (not args.commands) or args.interactive:
        print(credit_blurb)
        print(help_blurb)
        while True:
            try:
                execute(input('> '))
            except (EOFError, KeyboardInterrupt):
                print()
                exit_command()
