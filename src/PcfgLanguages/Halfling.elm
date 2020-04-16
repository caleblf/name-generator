module PcfgLanguages.Halfling exposing (halfling)

import Pcfg exposing (Language, literalForm, concatForms, pickWeightedForm)


halfling : Language
halfling =
  { name = "Halfling"
  , description = "Hobbit names"
  , priority = 2
  , generator = root
  }


root = pickWeightedForm
  [ (1.0, concatForms [start, end])
  , (1.0, concatForms [onset, connector, coda])
  ]

start = pickWeightedForm
  [ (1.0, concatForms [v, tc])
  , (1.0, syllable)
  , (1.0, chunk)
  ]

end = pickWeightedForm
  [ (1.0, concatForms [v, tc])
  , (1.0, v)
  , (1.0, syllable)
  , (1.0, chunk)
  ]

syllable = concatForms [c, v, tc]

onset = pickWeightedForm
  [ (1.0, v)
  , (1.0, concatForms [c, v])
  ]

coda = pickWeightedForm
  [ (5.0, v)
  , (5.0, concatForms [v, tc])
  , (2.0, literalForm "y")
  ]

chunk = pickWeightedForm
  [ (1.0, literalForm "sam")
  , (1.0, literalForm "wise")
  , (1.0, literalForm "gam")
  , (1.0, literalForm "gee")
  , (1.0, literalForm "ben")
  , (1.0, literalForm "drew")
  , (1.0, literalForm "took")
  , (1.0, literalForm "brook")
  , (1.0, literalForm "hill")
  , (1.0, literalForm "half")
  , (1.0, literalForm "mill")
  , (1.0, literalForm "wood")
  , (1.0, literalForm "ton")
  ]

connector = pickWeightedForm
  [ (1.0, literalForm "rd")
  , (2.0, literalForm "rr")
  , (2.0, literalForm "gg")
  , (2.0, literalForm "pp")
  , (1.0, literalForm "rt")
  , (1.0, literalForm "tr")
  , (1.0, literalForm "d")
  , (1.0, literalForm "lb")
  , (1.0, literalForm "lt")
  , (1.0, literalForm "ln")
  , (1.0, literalForm "lm")
  , (1.0, literalForm "mm")
  , (1.0, literalForm "nn")
  , (1.0, literalForm "cl")
  , (2.0, literalForm "sh")
  , (1.0, literalForm "sw")
  , (1.0, literalForm "vl")
  , (1.0, literalForm "lv")
  , (1.0, literalForm "cr")
  , (1.0, literalForm "sn")
  , (1.0, literalForm "sp")
  , (1.0, literalForm "pl")
  , (1.0, literalForm "pr")
  , (1.0, literalForm "fr")
  , (1.0, literalForm "st")
  , (1.0, literalForm "th")
  , (1.0, literalForm "rl")
  , (1.0, literalForm "fl")
  , (1.0, literalForm "nd")
  , (1.0, literalForm "ld")
  , (1.0, literalForm "gl")
  , (1.0, literalForm "ff")
  , (1.0, literalForm "ll")
  ]

tc = pickWeightedForm
  [ (1.0, literalForm "r")
  , (1.0, literalForm "s")
  , (1.0, literalForm "d")
  , (1.0, literalForm "g")
  , (1.0, literalForm "l")
  , (3.0, literalForm "n")
  , (3.0, literalForm "m")
  ]

c = pickWeightedForm
  [ (1.0, literalForm "w")
  , (1.0, literalForm "r")
  , (1.0, literalForm "t")
  , (1.0, literalForm "tr")
  , (1.0, literalForm "th")
  , (1.0, literalForm "y")
  , (1.0, literalForm "p")
  , (1.0, literalForm "pl")
  , (1.0, literalForm "s")
  , (1.0, literalForm "sh")
  , (1.0, literalForm "st")
  , (1.0, literalForm "sm")
  , (1.0, literalForm "sn")
  , (1.0, literalForm "sl")
  , (1.0, literalForm "d")
  , (1.0, literalForm "dr")
  , (1.0, literalForm "f")
  , (1.0, literalForm "fr")
  , (1.0, literalForm "fl")
  , (1.0, literalForm "g")
  , (1.0, literalForm "gr")
  , (1.0, literalForm "gl")
  , (1.0, literalForm "h")
  , (1.0, literalForm "j")
  , (1.0, literalForm "k")
  , (1.0, literalForm "l")
  , (1.0, literalForm "c")
  , (1.0, literalForm "cr")
  , (1.0, literalForm "cl")
  , (1.0, literalForm "v")
  , (1.0, literalForm "b")
  , (1.0, literalForm "br")
  , (1.0, literalForm "bl")
  , (1.0, literalForm "n")
  , (1.0, literalForm "m")
  ]

v = pickWeightedForm
  [ (3.0, literalForm "a")
  , (3.0, literalForm "i")
  , (3.0, literalForm "o")
  , (1.0, literalForm "u")
  , (1.0, literalForm "ia")
  ]
