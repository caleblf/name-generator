module Languages.Elven exposing (elven)

import Language exposing (Language, Form, lit, cat, pick, u, p)


elven : Language
elven =
  { name = "Elven"
  , generator = root
  }


root = cat [start, mid, end]

start _ = pick
  [ (1.0, cat [v, tc])
  , (1.0, syllable)
  ]

mid _ = pick
  [ (1.0, empty)
  , (2.0, syllable)
  , (4.0, cat [v, tc])
  ]

syllable = cat [c, v, tc]

end _ = pick
  [ (3.0, cat [v, tc])
  , (2.0, v)
  ]

empty = lit ""

tc _ = pick
  [ (1.0, lit "l")
  , (1.0, lit "r")
  , (1.0, lit "n")
  , (1.0, lit "m")
  ]

c _ = pick
  [ (1.0, lit "l")
  , (1.0, lit "r")
  , (1.0, lit "n")
  , (1.0, lit "m")
  , (1.0, lit "v")
  , (1.0, lit "p")
  , (1.0, lit "c")
  , (1.0, lit "s")
  , (1.0, lit "d")
  , (1.0, lit "f")
  , (1.0, lit "g")
  , (1.0, lit "z")
  , (1.0, lit "b")
  ]

v _ = pick
  [ (3.0, lit "a")
  , (3.0, lit "i")
  , (3.0, lit "e")
  , (2.0, lit "ia")
  , (2.0, lit "io")
  , (1.0, lit "ai")
  , (1.0, lit "o")
  , (1.0, lit "u")
  ]
