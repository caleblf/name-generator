module Languages.Orcish exposing (orcish)

import Language exposing (Language, Form, lit, cat, pick, u, p)


orcish : Language
orcish =
  { name = "Orcish"
  , generator = name
  }


name _ = pick
  [ (1.0, name_3)
  , (3.0, name_2)
  , (2.0, name_1)
  ]

name_3 _ = pick
  [ (1.0, v_name_3)
  , (1.0, cat [c, v_name_3])
  ]

name_2 _ = pick
  [ (1.0, v_name_2)
  , (1.0, cat [c, v_name_2])
  ]

name_1 _ = pick
  [ (1.0, v_name_1)
  , (1.0, cat [c, v_name_1])
  ]

v_name_3 = cat [v, link, v_name_2]

v_name_2 = cat [v, link, v_name_1]

v_name_1 = cat [v, tc]

link _ = pick
  [ (4.0, tc)
  , (2.0, cat [tc, c])
  , (1.0, lit "'")
  ]

tc _ = pick
  [ (5.0, lit "r")
  , (1.0, lit "t")
  , (1.0, lit "th")
  , (1.0, lit "s")
  , (1.0, lit "sh")
  , (1.0, lit "sk")
  , (1.0, lit "st")
  , (1.0, lit "d")
  , (1.0, lit "f")
  , (6.0, lit "g")
  , (1.0, lit "h")
  , (1.0, lit "k")
  , (1.0, lit "l")
  , (2.0, lit "z")
  , (1.0, lit "b")
  , (2.0, lit "n")
  , (1.0, lit "m")
  ]

c _ = pick
  [ (2.0, lit "r")
  , (1.0, lit "t")
  , (1.0, lit "tr")
  , (1.0, lit "th")
  , (1.0, lit "y")
  , (1.0, lit "s")
  , (2.0, lit "sh")
  , (1.0, lit "sk")
  , (2.0, lit "sn")
  , (1.0, lit "sm")
  , (1.0, lit "st")
  , (1.0, lit "sl")
  , (1.0, lit "d")
  , (1.0, lit "f")
  , (1.0, lit "fr")
  , (3.0, lit "g")
  , (1.0, lit "gl")
  , (2.0, lit "gr")
  , (1.0, lit "h")
  , (1.0, lit "k")
  , (1.0, lit "kr")
  , (1.0, lit "l")
  , (1.0, lit "z")
  , (1.0, lit "zh")
  , (1.0, lit "v")
  , (1.0, lit "vr")
  , (1.0, lit "b")
  , (1.0, lit "br")
  , (1.0, lit "bl")
  , (2.0, lit "n")
  , (1.0, lit "m")
  ]

v _ = pick
  [ (4.0, lit "u")
  , (4.0, lit "o")
  , (2.0, lit "a")
  , (1.0, lit "ia")
  , (1.0, lit "au")
  ]
