module Languages.Fiendish exposing (fiendish)

import Pcfg exposing (Language, literalForm, concatForms, pickWeightedForm)


fiendish : Language
fiendish =
  { name = "Fiendish"
  , description = "Strange names"
  , priority = 3
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
  , (2.0, literalForm "'")
  ]

v _ = pickWeightedForm
  [ (3.0, literalForm "a")
  , (3.0, literalForm "i")
  , (3.0, literalForm "e")
  , (3.0, literalForm "o")
  , (3.0, literalForm "u")
  , (1.0, literalForm "aa")
  , (1.0, literalForm "uu")
  ]

tc _ = pickWeightedForm
  [ (2.0, literalForm "k")
  , (2.0, literalForm "r")
  , (2.0, literalForm "t")
  , (2.0, literalForm "n")
  , (2.0, literalForm "g")
  , (2.0, literalForm "l")
  , (2.0, literalForm "x")
  , (2.0, literalForm "th")
  , (1.0, literalForm "rg")
  , (1.0, literalForm "h")
  , (1.0, literalForm "f")
  , (1.0, literalForm "m")
  , (1.0, literalForm "tch")
  , (1.0, literalForm "ss")
  , (1.0, literalForm "z")
  ]

c _ = pickWeightedForm
  [ (2.0, literalForm "g")
  , (2.0, literalForm "n")
  , (2.0, literalForm "l")
  , (2.0, literalForm "f")
  , (2.0, literalForm "p")
  , (2.0, literalForm "y")
  , (2.0, literalForm "v")
  , (2.0, literalForm "z")
  , (2.0, literalForm "b")
  , (2.0, literalForm "k")
  , (2.0, literalForm "t")
  , (2.0, literalForm "d")
  , (1.0, literalForm "w")
  , (1.0, literalForm "th")
  , (1.0, literalForm "tch")
  ]
