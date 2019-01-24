module Languages.Orcish exposing (orcish)

import Language exposing (Language, Form, lit, cat, pick, u, p)


orcish : Language
orcish =
  { name = "Orcish"
  , generator = name
  }


name _ = pick
  [ (1, name_3)
  , (3, name_2)
  , (2, name_1)
  ]

name_3 _ = pick
  [ (1, v_name_3)
  , (1, cat [c, v_name_3])
  ]

name_2 _ = pick
  [ (1, v_name_2)
  , (1, cat [c, v_name_2])
  ]

name_1 _ = pick
  [ (1, v_name_1)
  , (1, cat [c, v_name_1])
  ]

v_name_3 _ = pick
  [ (1, cat [v, link, v_name_2])
  ]

v_name_2 _ = pick
  [ (1, cat [v, link, v_name_1])
  ]

v_name_1 _ = pick
  [ (1, cat [v, tc])
  ]

link _ = pick
  [ (4, tc)
  , (2, cat [tc, c])
  , (1, lit "'")
  ]

tc _ = pick
  [ (5, lit "r")
  , (1, lit "t")
  , (1, lit "th")
  , (1, lit "s")
  , (1, lit "sh")
  , (1, lit "sk")
  , (1, lit "st")
  , (1, lit "d")
  , (1, lit "f")
  , (6, lit "g")
  , (1, lit "h")
  , (1, lit "k")
  , (1, lit "l")
  , (2, lit "z")
  , (1, lit "b")
  , (2, lit "n")
  , (1, lit "m")
  ]

c _ = pick
  [ (2, lit "r")
  , (1, lit "t")
  , (1, lit "tr")
  , (1, lit "th")
  , (1, lit "y")
  , (1, lit "s")
  , (2, lit "sh")
  , (1, lit "sk")
  , (2, lit "sn")
  , (1, lit "sm")
  , (1, lit "st")
  , (1, lit "sl")
  , (1, lit "d")
  , (1, lit "f")
  , (1, lit "fr")
  , (3, lit "g")
  , (1, lit "gl")
  , (2, lit "gr")
  , (1, lit "h")
  , (1, lit "k")
  , (1, lit "kr")
  , (1, lit "l")
  , (1, lit "z")
  , (1, lit "zh")
  , (1, lit "v")
  , (1, lit "vr")
  , (1, lit "b")
  , (1, lit "br")
  , (1, lit "bl")
  , (2, lit "n")
  , (1, lit "m")
  ]

v _ = pick
  [ (4, lit "u")
  , (4, lit "o")
  , (2, lit "a")
  , (1, lit "ia")
  , (1, lit "au")
  ]
