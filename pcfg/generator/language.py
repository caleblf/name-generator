import itertools
import random


class Form:
    """Abstract base class for grammatical forms."""

    def express(self):
        """Return a string expression of the form."""
        raise NotImplemented


class LiteralForm(Form):
    """Literal form."""

    def __init__(self, value):
        self.value = value

    def express(self):
        return self.value


class ConcatenativeForm(Form):
    """Form which expresses as a concatenation of subforms."""

    def __init__(self, forms):
        self.set_forms(forms)

    def set_forms(self, forms):
        self.forms = forms

    def express(self):
        return ''.join(f.express() for f in self.forms)


class ProbabilisticForm(Form):
    """Form which may express as any of its subforms.

    Requires the following initialization parameters:
        forms : list/tuple of Form, the forms which may be expressed by this form
        rel_odds : list/tuple of int, the relative odds of each form being expressed

    forms and rel_odds must be the same length.
    """

    def __init__(self, forms, rel_odds):
        self.set_forms(forms, rel_odds)

    def set_forms(self, forms, rel_odds):
        if len(forms) != len(rel_odds):
            raise ValueError("Mismatch in length of forms and rel_odds")
        self.forms = forms
        self.rel_odds = rel_odds

    def express(self):
        return random.choice(list(itertools.chain.from_iterable(
            itertools.repeat(f, n) for f, n in zip(self.forms, self.rel_odds)
        ))).express()


class Language:
    """A language in which words can be built.

    Has the following properties:
        name : str, the name of the language
        grammar : Form
    """

    def __init__(self, name, grammar):
        self.name = name
        self.grammar = grammar

    def generate(self):
        return self.grammar.express().capitalize()
