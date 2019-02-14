module Languages.Fiendish exposing (fiendish)

import Language exposing (Language, Form, lit, cat, pick, u, p)


fiendish : Language
fiendish =
  { name = "Fiendish"
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
  , (2.0, lit "'")
  ]

v _ = pick
  [ (3.0, lit "a")
  , (3.0, lit "i")
  , (3.0, lit "e")
  , (3.0, lit "o")
  , (3.0, lit "u")
  , (1.0, lit "aa")
  , (1.0, lit "uu")
  ]

tc _ = pick
  [ (2.0, lit "k")
  , (2.0, lit "r")
  , (2.0, lit "t")
  , (2.0, lit "n")
  , (2.0, lit "g")
  , (2.0, lit "l")
  , (2.0, lit "x")
  , (2.0, lit "th")
  , (1.0, lit "rg")
  , (1.0, lit "h")
  , (1.0, lit "f")
  , (1.0, lit "m")
  , (1.0, lit "tch")
  , (1.0, lit "ss")
  , (1.0, lit "z")
  ]

c _ = pick
  [ (2.0, lit "g")
  , (2.0, lit "n")
  , (2.0, lit "l")
  , (2.0, lit "f")
  , (2.0, lit "p")
  , (2.0, lit "y")
  , (2.0, lit "v")
  , (2.0, lit "z")
  , (2.0, lit "b")
  , (2.0, lit "k")
  , (2.0, lit "t")
  , (2.0, lit "d")
  , (1.0, lit "w")
  , (1.0, lit "th")
  , (1.0, lit "tch")
  ]
