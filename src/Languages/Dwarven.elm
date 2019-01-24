module Languages.Dwarven exposing (dwarven)

import Language exposing (Language, Form, lit, cat, pick, u, p)


dwarven : Language
dwarven =
  { name = "Dwarven"
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
  [ (1, cat [v, tc])
  , (1, cat [c, v, tc])
  ]

v_name_3 _ = pick
  [ (1, cat [v, link, v_name_2])
  ]

v_name_2 _ = pick
  [ (1, cat [v, link, v_name_1])
  ]

v_name_1 _ = pick
  [ (3, cat [v, tc])
  , (1, v)
  ]

link _ = pick
  [ (3, tc)
  , (2, cat [tc, c])
  , (1, lit "'")
  ]

v _ = pick
  [ (2, lit "a")
  , (2, lit "i")
  , (2, lit "o")
  , (3, lit "u")
  , (1, lit "ei")
  , (1, lit "ai")
  , (1, lit "ia")
  , (1, lit "oi")
  , (1, lit "eo")
  , (1, lit "ua")
  ]

tc _ = pick
  [ (1, lit "r")
  , (1, lit "t")
  , (1, lit "d")
  , (1, lit "f")
  , (1, lit "g")
  , (1, lit "k")
  , (1, lit "l")
  , (1, lit "z")
  , (1, lit "x")
  , (1, lit "v")
  , (1, lit "n")
  , (1, lit "m")
  , (1, lit "rt")
  , (1, lit "th")
  , (1, lit "sh")
  ]

c _ = pick
  [ (1, lit "w")
  , (1, lit "r")
  , (1, lit "t")
  , (1, lit "p")
  , (1, lit "s")
  , (1, lit "d")
  , (1, lit "f")
  , (1, lit "g")
  , (1, lit "h")
  , (1, lit "k")
  , (1, lit "l")
  , (1, lit "z")
  , (1, lit "v")
  , (1, lit "b")
  , (1, lit "n")
  , (1, lit "m")
  , (1, lit "tr")
  , (1, lit "gr")
  , (1, lit "dv")
  , (1, lit "th")
  , (1, lit "thr")
  , (1, lit "dr")
  , (1, lit "br")
  ]
