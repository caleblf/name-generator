module Elven exposing (elven)

import Language exposing (Language, Form, lit, cat, pick, u, p)


elven : Language
elven =
  { name = "Elven"
  , generator = root
  }

root = cat [start, mid, end]


start _ = pick
  [ (1, cat [v, tc])
  , (1, syllable)
  ]

mid _ = pick
  [ (1, empty)
  , (2, syllable)
  , (4, cat [v, tc])
  ]

syllable = cat [c, v, tc]

end _ = pick
  [ (3, cat [v, tc])
  , (2, v)
  ]

empty = lit ""

tc _ = pick -- repeatable syllable-terminating consonants
  [ u "l"
  , u "r"
  , u "n"
  , u "m"
  ]
c _ = pick -- all consonants
  [ u "l"
  , u "r"
  , u "n"
  , u "m"
  , u "v"
  , u "p"
  , u "c"
  , u "s"
  , u "d"
  , u "f"
  , u "g"
  , u "z"
  , u "b"
  ]
v _ = pick -- all vowels
  [ p 3 "a"
  , p 3 "i"
  , p 3 "e"
  , p 2 "ia"
  , p 2 "io"
  , p 1 "ai"
  , p 1 "o"
  , p 1 "u"
  ]
