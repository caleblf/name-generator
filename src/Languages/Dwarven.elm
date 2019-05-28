module Languages.Dwarven exposing (dwarven)

import Pcfg exposing (Language, literalForm, concatForms, pickWeightedForm)


dwarven : Language
dwarven =
  { name = "Dwarven"
  , description = "Dwarf language"
  , priority = 2
  , generator = name
  }


name _ = pickWeightedForm
  [ (1.0, name_3)
  , (3.0, name_2)
  , (2.0, name_1)
  ]

name_3 _ = pickWeightedForm
  [ (1.0, v_name_3)
  , (1.0, concatForms [c, v_name_3])
  ]

name_2 _ = pickWeightedForm
  [ (1.0, v_name_2)
  , (1.0, concatForms [c, v_name_2])
  ]

name_1 _ = pickWeightedForm
  [ (1.0, concatForms [v, tc])
  , (1.0, concatForms [c, v, tc])
  ]

v_name_3 = concatForms [v, link, v_name_2]

v_name_2 = concatForms [v, link, v_name_1]

v_name_1 _ = pickWeightedForm
  [ (3.0, concatForms [v, tc])
  , (1.0, v)
  ]

link _ = pickWeightedForm
  [ (3.0, tc)
  , (2.0, concatForms [tc, c])
  , (1.0, literalForm "'")
  ]

v _ = pickWeightedForm
  [ (2.0, literalForm "a")
  , (2.0, literalForm "i")
  , (2.0, literalForm "o")
  , (3.0, literalForm "u")
  , (1.0, literalForm "ai")
  , (1.0, literalForm "ia")
  , (1.0, literalForm "oi")
  , (1.0, literalForm "eo")
  , (1.0, literalForm "ua")
  ]

tc _ = pickWeightedForm
  [ (1.0, literalForm "r")
  , (1.0, literalForm "t")
  , (1.0, literalForm "d")
  , (1.0, literalForm "f")
  , (1.0, literalForm "g")
  , (1.0, literalForm "k")
  , (1.0, literalForm "l")
  , (1.0, literalForm "z")
  , (1.0, literalForm "x")
  , (1.0, literalForm "v")
  , (1.0, literalForm "n")
  , (1.0, literalForm "m")
  , (1.0, literalForm "rt")
  , (1.0, literalForm "th")
  , (1.0, literalForm "sh")
  ]

c _ = pickWeightedForm
  [ (1.0, literalForm "w")
  , (1.0, literalForm "r")
  , (1.0, literalForm "t")
  , (1.0, literalForm "p")
  , (1.0, literalForm "s")
  , (1.0, literalForm "d")
  , (1.0, literalForm "f")
  , (1.0, literalForm "g")
  , (1.0, literalForm "h")
  , (1.0, literalForm "k")
  , (1.0, literalForm "l")
  , (1.0, literalForm "z")
  , (1.0, literalForm "v")
  , (1.0, literalForm "b")
  , (1.0, literalForm "n")
  , (1.0, literalForm "m")
  , (1.0, literalForm "tr")
  , (1.0, literalForm "gr")
  , (1.0, literalForm "dv")
  , (1.0, literalForm "th")
  , (1.0, literalForm "thr")
  , (1.0, literalForm "dr")
  , (1.0, literalForm "br")
  ]
