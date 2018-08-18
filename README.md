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

## Metalanguages
Additional output can be added to the generated names using "Metalanguages."
Metalanguages are specified in files similarly to languages. When multiple
metalanguages are active, they are applied sucessively to the generated output
in order of increasing priority.

