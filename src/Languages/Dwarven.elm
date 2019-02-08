module Languages.Dwarven exposing (dwarven)

import Language exposing (Language, Form, lit, cat, pick, u, p)


dwarven : Language
dwarven =
  { name = "Dwarven"
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
  [ (1.0, cat [v, tc])
  , (1.0, cat [c, v, tc])
  ]

v_name_3 = cat [v, link, v_name_2]

v_name_2 = cat [v, link, v_name_1]

v_name_1 _ = pick
  [ (3.0, cat [v, tc])
  , (1.0, v)
  ]

link _ = pick
  [ (3.0, tc)
  , (2.0, cat [tc, c])
  , (1.0, lit "'")
  ]

v _ = pick
  [ (2.0, lit "a")
  , (2.0, lit "i")
  , (2.0, lit "o")
  , (3.0, lit "u")
  , (1.0, lit "ei")
  , (1.0, lit "ai")
  , (1.0, lit "ia")
  , (1.0, lit "oi")
  , (1.0, lit "eo")
  , (1.0, lit "ua")
  ]

tc _ = pick
  [ (1.0, lit "r")
  , (1.0, lit "t")
  , (1.0, lit "d")
  , (1.0, lit "f")
  , (1.0, lit "g")
  , (1.0, lit "k")
  , (1.0, lit "l")
  , (1.0, lit "z")
  , (1.0, lit "x")
  , (1.0, lit "v")
  , (1.0, lit "n")
  , (1.0, lit "m")
  , (1.0, lit "rt")
  , (1.0, lit "th")
  , (1.0, lit "sh")
  ]

c _ = pick
  [ (1.0, lit "w")
  , (1.0, lit "r")
  , (1.0, lit "t")
  , (1.0, lit "p")
  , (1.0, lit "s")
  , (1.0, lit "d")
  , (1.0, lit "f")
  , (1.0, lit "g")
  , (1.0, lit "h")
  , (1.0, lit "k")
  , (1.0, lit "l")
  , (1.0, lit "z")
  , (1.0, lit "v")
  , (1.0, lit "b")
  , (1.0, lit "n")
  , (1.0, lit "m")
  , (1.0, lit "tr")
  , (1.0, lit "gr")
  , (1.0, lit "dv")
  , (1.0, lit "th")
  , (1.0, lit "thr")
  , (1.0, lit "dr")
  , (1.0, lit "br")
  ]
