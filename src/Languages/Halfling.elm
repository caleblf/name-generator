module Halfling exposing (halfling)

import Language exposing (Language, Form, lit, cat, pick, u, p)


halfling : Language
halfling =
  { name = "Halfling"
  , generator = root
  }


root _ = pick
  [ (1.0, cat [start, end])
  , (1.0, cat [onset, connector, coda])
  ]

start _ = pick
  [ (1.0, cat [v, tc])
  , (1.0, syllable)
  , (1.0, chunk)
  ]

end _ = pick
  [ (1.0, cat [v, tc])
  , (1.0, v)
  , (1.0, syllable)
  , (1.0, chunk)
  ]

syllable = cat [c, v, tc]

onset _ = pick
  [ (1.0, v)
  , (1.0, cat [c, v])
  ]

coda _ = pick
  [ (5.0, v)
  , (5.0, cat [v, tc])
  , (2.0, lit "y")
  ]

chunk _ = pick
  [ (1.0, lit "sam")
  , (1.0, lit "wise")
  , (1.0, lit "gam")
  , (1.0, lit "gee")
  , (1.0, lit "ben")
  , (1.0, lit "drew")
  , (1.0, lit "took")
  , (1.0, lit "brook")
  , (1.0, lit "hill")
  , (1.0, lit "half")
  , (1.0, lit "mill")
  , (1.0, lit "wood")
  , (1.0, lit "ton")
  ]

connector _ = pick
  [ (1.0, lit "rd")
  , (2.0, lit "rr")
  , (2.0, lit "gg")
  , (2.0, lit "pp")
  , (1.0, lit "rt")
  , (1.0, lit "tr")
  , (1.0, lit "d")
  , (1.0, lit "lb")
  , (1.0, lit "lt")
  , (1.0, lit "ln")
  , (1.0, lit "lm")
  , (1.0, lit "mm")
  , (1.0, lit "nn")
  , (1.0, lit "cl")
  , (2.0, lit "sh")
  , (1.0, lit "sw")
  , (1.0, lit "vl")
  , (1.0, lit "lv")
  , (1.0, lit "cr")
  , (1.0, lit "sn")
  , (1.0, lit "sp")
  , (1.0, lit "pl")
  , (1.0, lit "pr")
  , (1.0, lit "fr")
  , (1.0, lit "st")
  , (1.0, lit "th")
  , (1.0, lit "rl")
  , (1.0, lit "fl")
  , (1.0, lit "nd")
  , (1.0, lit "ld")
  , (1.0, lit "gl")
  , (1.0, lit "ff")
  , (1.0, lit "ll")
  ]

tc _ = pick
  [ (1.0, lit "r")
  , (1.0, lit "s")
  , (1.0, lit "d")
  , (1.0, lit "g")
  , (1.0, lit "l")
  , (3.0, lit "n")
  , (3.0, lit "m")
  ]

c _ = pick
  [ (1.0, lit "w")
  , (1.0, lit "r")
  , (1.0, lit "t")
  , (1.0, lit "tr")
  , (1.0, lit "th")
  , (1.0, lit "y")
  , (1.0, lit "p")
  , (1.0, lit "pl")
  , (1.0, lit "s")
  , (1.0, lit "sh")
  , (1.0, lit "st")
  , (1.0, lit "sm")
  , (1.0, lit "sn")
  , (1.0, lit "sl")
  , (1.0, lit "d")
  , (1.0, lit "dr")
  , (1.0, lit "f")
  , (1.0, lit "fr")
  , (1.0, lit "fl")
  , (1.0, lit "g")
  , (1.0, lit "gr")
  , (1.0, lit "gl")
  , (1.0, lit "h")
  , (1.0, lit "j")
  , (1.0, lit "k")
  , (1.0, lit "l")
  , (1.0, lit "c")
  , (1.0, lit "cr")
  , (1.0, lit "cl")
  , (1.0, lit "v")
  , (1.0, lit "b")
  , (1.0, lit "br")
  , (1.0, lit "bl")
  , (1.0, lit "n")
  , (1.0, lit "m")
  ]

v _ = pick
  [ (3.0, lit "a")
  , (3.0, lit "i")
  , (3.0, lit "o")
  , (1.0, lit "u")
  , (1.0, lit "ia")
  ]
