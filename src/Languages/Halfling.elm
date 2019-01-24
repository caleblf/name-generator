module Languages.Halfling exposing (halfling)

import Language exposing (Language, Form, lit, cat, pick, u, p)


halfling : Language
halfling =
  { name = "Halfling"
  , generator = root
  }


root _ = pick
  [ (1, cat [start, end])
  , (1, cat [onset, connector, coda])
  ]

start _ = pick
  [ (1, cat [v, tc])
  , (1, syllable)
  , (1, chunk)
  ]

end _ = pick
  [ (1, cat [v, tc])
  , (1, v)
  , (1, syllable)
  , (1, chunk)
  ]

syllable = cat [c, v, tc]

onset _ = pick
  [ (1, v)
  , (1, cat [c, v])
  ]

coda _ = pick
  [ (5, v)
  , (5, cat [v, tc])
  , (2, lit "y")
  ]

chunk _ = pick
  [ (1, lit "sam")
  , (1, lit "wise")
  , (1, lit "gam")
  , (1, lit "gee")
  , (1, lit "ben")
  , (1, lit "drew")
  , (1, lit "took")
  , (1, lit "brook")
  , (1, lit "hill")
  , (1, lit "half")
  , (1, lit "mill")
  , (1, lit "wood")
  , (1, lit "ton")
  ]

connector _ = pick
  [ (1, lit "rd")
  , (2, lit "rr")
  , (2, lit "gg")
  , (2, lit "pp")
  , (1, lit "rt")
  , (1, lit "tr")
  , (1, lit "d")
  , (1, lit "lb")
  , (1, lit "lt")
  , (1, lit "ln")
  , (1, lit "lm")
  , (1, lit "mm")
  , (1, lit "nn")
  , (1, lit "cl")
  , (2, lit "sh")
  , (1, lit "sw")
  , (1, lit "vl")
  , (1, lit "lv")
  , (1, lit "cr")
  , (1, lit "sn")
  , (1, lit "sp")
  , (1, lit "pl")
  , (1, lit "pr")
  , (1, lit "fr")
  , (1, lit "st")
  , (1, lit "th")
  , (1, lit "rl")
  , (1, lit "fl")
  , (1, lit "nd")
  , (1, lit "ld")
  , (1, lit "gl")
  , (1, lit "ff")
  , (1, lit "ll")
  ]

tc _ = pick
  [ (1, lit "r")
  , (1, lit "s")
  , (1, lit "d")
  , (1, lit "g")
  , (1, lit "l")
  , (3, lit "n")
  , (3, lit "m")
  ]

c _ = pick
  [ (1, lit "w")
  , (1, lit "r")
  , (1, lit "t")
  , (1, lit "tr")
  , (1, lit "th")
  , (1, lit "y")
  , (1, lit "p")
  , (1, lit "pl")
  , (1, lit "s")
  , (1, lit "sh")
  , (1, lit "st")
  , (1, lit "sm")
  , (1, lit "sn")
  , (1, lit "sl")
  , (1, lit "d")
  , (1, lit "dr")
  , (1, lit "f")
  , (1, lit "fr")
  , (1, lit "fl")
  , (1, lit "g")
  , (1, lit "gr")
  , (1, lit "gl")
  , (1, lit "h")
  , (1, lit "j")
  , (1, lit "k")
  , (1, lit "l")
  , (1, lit "c")
  , (1, lit "cr")
  , (1, lit "cl")
  , (1, lit "v")
  , (1, lit "b")
  , (1, lit "br")
  , (1, lit "bl")
  , (1, lit "n")
  , (1, lit "m")
  ]

v _ = pick
  [ (3, lit "a")
  , (3, lit "i")
  , (3, lit "o")
  , (1, lit "u")
  , (1, lit "ia")
  ]
