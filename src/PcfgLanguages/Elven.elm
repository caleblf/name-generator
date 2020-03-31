module PcfgLanguages.Elven exposing (elven)

import Pcfg exposing (Language, literalForm, concatForms, pickWeightedForm)


elven : Language
elven =
  { name = "Elven"
  , description = "Elf names"
  , priority = 2
  , generator = root
  }


root = concatForms [start, mid, end]

start _ = pickWeightedForm
  [ (1.0, concatForms [v, tc])
  , (1.0, syllable)
  ]

mid _ = pickWeightedForm
  [ (1.0, empty)
  , (2.0, syllable)
  , (4.0, concatForms [v, tc])
  ]

syllable = concatForms [c, v, tc]

end _ = pickWeightedForm
  [ (3.0, concatForms [v, tc])
  , (2.0, v)
  ]

empty = literalForm ""

tc _ = pickWeightedForm
  [ (1.0, literalForm "l")
  , (1.0, literalForm "r")
  , (1.0, literalForm "n")
  , (1.0, literalForm "m")
  ]

c _ = pickWeightedForm
  [ (1.0, literalForm "l")
  , (1.0, literalForm "r")
  , (1.0, literalForm "n")
  , (1.0, literalForm "m")
  , (1.0, literalForm "v")
  , (1.0, literalForm "p")
  , (1.0, literalForm "c")
  , (1.0, literalForm "s")
  , (1.0, literalForm "d")
  , (1.0, literalForm "f")
  , (1.0, literalForm "g")
  , (1.0, literalForm "z")
  , (1.0, literalForm "b")
  ]

v _ = pickWeightedForm
  [ (3.0, literalForm "a")
  , (3.0, literalForm "i")
  , (3.0, literalForm "e")
  , (2.0, literalForm "ia")
  , (2.0, literalForm "io")
  , (1.0, literalForm "ai")
  , (1.0, literalForm "o")
  , (1.0, literalForm "u")
  ]
