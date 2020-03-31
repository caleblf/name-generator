module PcfgLanguages.Orcish exposing (orcish)

import Pcfg exposing (Language, literalForm, concatForms, pickWeightedForm)


orcish : Language
orcish =
  { name = "Orcish"
  , description = "Orc names"
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
  [ (1.0, v_name_1)
  , (1.0, concatForms [c, v_name_1])
  ]

v_name_3 = concatForms [v, link, v_name_2]

v_name_2 = concatForms [v, link, v_name_1]

v_name_1 = concatForms [v, tc]

link _ = pickWeightedForm
  [ (4.0, tc)
  , (2.0, concatForms [tc, c])
  , (1.0, literalForm "'")
  ]

tc _ = pickWeightedForm
  [ (5.0, literalForm "r")
  , (1.0, literalForm "t")
  , (1.0, literalForm "th")
  , (1.0, literalForm "s")
  , (1.0, literalForm "sh")
  , (1.0, literalForm "sk")
  , (1.0, literalForm "st")
  , (1.0, literalForm "d")
  , (1.0, literalForm "f")
  , (6.0, literalForm "g")
  , (1.0, literalForm "h")
  , (1.0, literalForm "k")
  , (1.0, literalForm "l")
  , (2.0, literalForm "z")
  , (1.0, literalForm "b")
  , (2.0, literalForm "n")
  , (1.0, literalForm "m")
  ]

c _ = pickWeightedForm
  [ (2.0, literalForm "r")
  , (1.0, literalForm "t")
  , (1.0, literalForm "tr")
  , (1.0, literalForm "th")
  , (1.0, literalForm "y")
  , (1.0, literalForm "s")
  , (2.0, literalForm "sh")
  , (1.0, literalForm "sk")
  , (2.0, literalForm "sn")
  , (1.0, literalForm "sm")
  , (1.0, literalForm "st")
  , (1.0, literalForm "sl")
  , (1.0, literalForm "d")
  , (1.0, literalForm "f")
  , (1.0, literalForm "fr")
  , (3.0, literalForm "g")
  , (1.0, literalForm "gl")
  , (2.0, literalForm "gr")
  , (1.0, literalForm "h")
  , (1.0, literalForm "k")
  , (1.0, literalForm "kr")
  , (1.0, literalForm "l")
  , (1.0, literalForm "z")
  , (1.0, literalForm "zh")
  , (1.0, literalForm "v")
  , (1.0, literalForm "vr")
  , (1.0, literalForm "b")
  , (1.0, literalForm "br")
  , (1.0, literalForm "bl")
  , (2.0, literalForm "n")
  , (1.0, literalForm "m")
  ]

v _ = pickWeightedForm
  [ (4.0, literalForm "u")
  , (4.0, literalForm "o")
  , (2.0, literalForm "a")
  , (1.0, literalForm "ia")
  , (1.0, literalForm "au")
  ]
