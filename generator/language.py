import itertools
import random


def capitalize_words(s):
    """Capitalize each space-delimited word in a string."""
    return ' '.join(w.capitalize() for w in s.split())


class Form:
    """Abstract base class for grammatical forms."""

    def __repr__(self):
        return f'{self.__class__.__name__}()'

    def express(self):
        """Return a string expression of the form."""
        raise NotImplemented


class LiteralForm(Form):
    """Literal form."""

    def __init__(self, value):
        self.value = value

    def __repr__(self):
        return f'{self.__class__.__name__}({self.value!r})'

    def express(self):
        return self.value


class VariableForm(LiteralForm):
    """A form whose value may be changed externally.
    Used in metalanguages for nesting.
    """

    def set(self, data):
        self.value = data


class TagForm(Form):
    """A form whose value is that of a form at a certain key in a table."""

    def __init__(self, tag, forms):
        self.tag = tag
        self.forms = forms

    def __repr__(self):
        return f'{self.__class__.__name__}({self.tag!r}, {self.forms!r})'

    def express(self):
        return self.forms[self.tag].express()


class ConcatenativeForm(Form):
    """Form which expresses as a concatenation of subforms."""

    def __init__(self, forms):
        self.set_forms(forms)

    def __repr__(self):
        return f'{self.__class__.__name__}({self.forms!r})'

    def set_forms(self, forms):
        self.forms = forms

    def express(self):
        return ''.join(f.express() for f in self.forms)


class ProbabilisticForm(Form):
    """Form which may express as any of its subforms.

    Requires the following initialization parameters:
        forms : sequence of Form, the forms which may be expressed by this form
        weights : sequence of int, the relative odds of expressing each form

    forms and rel_odds must be the same length.
    """

    def __init__(self, forms, weights):
        self.set_forms(forms, weights)

    def __repr__(self):
        return f'{self.__class__.__name__}({self.forms!r}, ...)'

    def set_forms(self, forms, weights):
        if len(forms) != len(weights):
            raise ValueError("Mismatch in number of forms and weights")
        self.forms = forms
        self.cum_weights = list(itertools.accumulate(weights))

    def express(self):
        return random.choices(self.forms, cum_weights=self.cum_weights)[0].express()


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
        return capitalize_words(self.grammar.express())


class Metalanguage:
    """A grammar including variable forms.

    Has the following properties:
        name : str, the name of the metalanguage
        grammar : Form
        priority : int, the priority that this language should be generated at
        variable_form : VariableForm, the variable form which may be modified
    """

    def __init__(self, name, grammar, priority, variable_form):
        self.name = name
        self.grammar = grammar
        self.priority = priority
        self.variable_form = variable_form

    def generate(self, data):
        self.variable_form.set(data)
        return self.grammar.express()
