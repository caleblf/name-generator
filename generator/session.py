"""Session state for the name generator."""

import sys
import operator
import pathlib

from generator import language, load


get_transform_priority = operator.attrgetter('priority')


def noop(*args, **kwargs):
    pass


def print_error(*args, **kwargs):
    """Print to stderr."""
    print(*args, file=sys.stderr, **kwargs)


def print_color_error(*args, **kwargs):
    """Print to stderr in color."""
    print_error(*(f'\033[0;31m{arg}\033[0m' for arg in args), **kwargs)


class NameGeneratorSession:

    def __init__(self, *, quiet=False, color=False, **kwargs):
        self.active_language = None
        self.active_transforms = []

        self.languages = {}  # languages by casefolded name
        self.transforms = {}  # transforms by casefolded name

        self.report = noop if quiet else print
        self.error = print_color_error if color else print_error
        self.use_color = color

    @property
    def active_name(self):
        return self.active_language and self.active_language.name

    def load(self, filename):
        """Load languages and/or transforms from a file or directory."""
        path = pathlib.Path(filename)
        if path.exists():
            if path.is_dir():
                # Load all YAML files in this directory
                for p in path.iterdir():
                    if p.suffix == '.pcfg':
                        self._load_file(p)
            else:
                self._load_file(path)
        else:
            self.error(f'File does not exist: {path}')

    def _load_file(self, path):
        """Load a language or transform from a file."""
        try:
            loaded = load.load_file(path)
        except OSError:
            self.error(f'Could not read from file or folder: {path}')
            return
        except ValueError as e:
            self.error(f'Error parsing language file: {e.args[0]}')
            return

        # Don't allow name collisions, even between languages and transforms
        if loaded.name.casefold() in self.languages:
            self.error(f'Tried to load {loaded.name}, but a '
                       'language with this name was already loaded.')
            return
        if loaded.name.casefold() in self.transforms:
            self.error(f'Tried to load {loaded.name}, but a '
                       'transform with this name was already loaded.')
            return

        if isinstance(loaded, language.Language):
            self.report(f'Loaded language: {loaded.name}')
            self.languages[loaded.name.casefold()] = loaded
        else:  # transform
            self.report(f'Loaded transform: {loaded.name}')
            self.transforms[loaded.name.casefold()] = loaded

    def list(self):
        """List loaded languages and transforms to standard output."""
        if self.languages:
            print('Languages loaded:')
            max_name_length = max(len(name) for name in self.languages)
            for lang in self.languages.values():
                print(f'  {lang.name:<{max_name_length}s}' +
                      '\t(active)' * (lang is self.active_language))
        else:
            print('No languages loaded.')

        if self.transforms:
            print('Transforms loaded:')
            max_name_length = max(len(name) for name in self.transforms)
            for mlang in self.transforms.values():
                print(f'  {mlang.name:<{max_name_length}s}' +
                      '\t(active)' * (mlang in self.active_transforms))
        else:
            print('No transforms loaded.')

    def build(self, amt=1):
        """Build a number of names from the active language.
        Print results to standard output."""
        try:
            amt = int(amt)
        except ValueError:
            self.error(f'Invalid amount to build (must be a positive integer): {amt}')
        if amt <= 0:
            self.error(f'Invalid amount to build (must be a positive integer): {amt}')
            return
        if self.active_language is None:
            self.error('No language is active')
            return

        self.report(f'Building {amt} from {self.active_language.name} with ' +
                    ', '.join(mlang.name for mlang in self.active_transforms) + ':')
        for _ in range(amt):
            result = self.active_language.generate()
            if self.use_color:
                result = f'\033[1;36m{result}\033[0m'
            for mlang in self.active_transforms:
                result = mlang.generate(result)
            print(result)

    def activate(self, key):
        """Activate a language or transform by name."""
        try:
            lang = self.languages[key.casefold()]
            if lang is self.active_language:
                self.report(f'Language already active: {lang.name}')
            else:
                self.active_language = lang
                self.report(f'Activated language: {self.active_language.name}')
            return
        except KeyError:
            pass

        try:
            mlang = self.transforms[key.casefold()]
            if mlang in self.active_transforms:
                self.report(f'Transform already active: {mlang.name}')
            else:
                self.active_transforms.append(mlang)
                self.active_transforms.sort(key=get_transform_priority)
                self.report(f'Activated transform: {mlang.name}')
        except KeyError:
            self.error(f'Name not recognized: {key}')

    def deactivate(self, key):
        """Deactivate a language or transform."""
        try:
            lang = self.languages[key.casefold()]
            if self.active_language is None:
                self.report('No language is active')
            elif lang is self.active_language:
                self.active_language = None
                self.report(f'Deactivated language: {lang.name}')
            else:
                self.report(f'Language not active: {lang.name}')
            return
        except KeyError:
            pass

        try:
            mlang = self.transforms[key.casefold()]
            try:
                self.active_transforms.remove(mlang)
                self.report(f'Deactivated transform: {mlang.name}')
            except ValueError:
                self.report(f'Transform not active: {mlang.name}')
        except KeyError:
            self.error(f'Name not recognized: {key}')
