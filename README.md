# name-generator
A random character name generator for sci-fi/fantasy settings.

### Usage
This application requires Python 3.6 or later.

It is recommended to run the name generator with ANSI colors enabled, if supported, and to load the included basic initialization file. The `colorama` package is used for cross-platform ANSI support, but it isn't required on platforms where ANSI codes are natively supported.

On Unix platforms: `./namegen.py -ciw init.txt`

On MS Windows: `python3 ./namegen.py -ci init.txt`

## Languages
Language files specify the generation of names using a probabilistic
context-free grammar.

## Language Transforms
Additional output can be added to the generated names using "Transforms."
Transforms are specified in files similarly to languages. When multiple
transforms are active, they are applied sucessively to the generated output
in order of increasing priority.

## PCFG Specifier Language Specification

A string is a "name" if and only if it is comprised only of lowercase
alphanumeric ASCII characters and dashes, and begins with a lowercase
letter.


At the start of the file are any number of lines beginning with `!`.
These comprise the header. Each line of the header looks like the following:

```
!field: value
```

This defines a header property `field` with value `value`.
Field names must be names as specified above. Leading and trailing
spaces are
trimmed from the value string. Header lines must not be indented. Blank
lines
are allowed in the header, though all header lines must appear before all
forms.

The fields usually defined include: encoding (`utf-8` if not specified),
name, author, description, root (the name of the tag of the root form),
and input (the name of a tag to insert into a transform, optional).


After the header lines, the file is comprised of form entries which
look something like:

```
form-tag:
  expansion1
  expansion2
  2 expansion3
  1.5 expansion4
```

Form tags must be names.

A form must have at least one expansion. If a form has exactly one
expansion;
if so, that expansion may appear on the same line as the form tag after
the colon. Otherwise, all expansions must be listed on individual
lines following the form tag, each indented by any amount of spaces
(no tabs).

An expansion entry defines a weight and the form expansion itself. If the
entry begins with a number (integer or decimal numeral), that is used as
the weight, and the rest of the line (spaces trimmed) is the form expansion.
If no explicit weight is given, the weight for the line defaults to 1.

If a form tag has one expansion, that expansion cannot be a form tag.


A form expansion may be any of the following:

 1. A bare literal: `literal text`.
    Spaces are trimmed from the edges of the string. The string must be
    nonempty, and cannot contain any of the following characters:
    `$`, `:`, `[`, `]`, `!`, `"`, tabs, and numerals.

 2. A quoted literal: `"literal text"`.
    The content may not contain backslashes or double-quotes.

 3. A concatenation of form expansions: `[form1 form2 form3]`.
    The forms to concatenate may be bare literals, quoted literals,
    or form tags. Forms are delimited by spaces.

 4. A form tag: `$form-tag`.
    The form tag must refer to a form listed in the file, or to an input
    tag defined in the header.


Anywhere in the file, a `#` character is accepted. The `#` and all following
characters on the line are ignored by the parser.