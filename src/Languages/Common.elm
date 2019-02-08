module Languages.Common exposing (common)

import Language exposing (Language, Form, lit, cat, pick, u, p)


common : Language
common =
  { name = "Common"
  , generator = name
  }


name _ = pick
  [ (1.0, name_4)
  , (3.0, name_3)
  , (6.0, name_2)
  , (4.0, name_1)
  ]

name_4 _ = pick
  [ (1.0, v_name_4)
  , (1.0, cat [c_long, v_name_4])
  , (1.0, ch_name_4)
  ]

name_3 _ = pick
  [ (1.0, v_name_3)
  , (2.0, cat [c_long, v_name_3])
  , (2.0, ch_name_3)
  ]

name_2 _ = pick
  [ (1.0, v_name_2)
  , (2.0, cat [c_long, v_name_2])
  , (2.0, ch_name_2)
  ]

name_1 _ = pick
  [ (1.0, cat [c_long, v])
  , (1.0, cat [v, c_end])
  , (3.0, cat [c_long, v, c_end])
  ]

v_name_4 _ = pick
  [ (1.0, cat [v, v_v, v_name_3])
  , (1.0, cat [v, v_ch, ch_name_3])
  ]

v_name_3 _ = pick
  [ (1.0, cat [v, v_v, v_name_2])
  , (1.0, cat [v, v_ch, ch_name_2])
  ]

v_name_2 _ = pick
  [ (1.0, cat [v, v_v, v_name_1])
  , (1.0, cat [v, v_ch, ch_name_1])
  ]

v_name_1 _ = pick
  [ (1.0, cat [v, c_end])
  , (1.0, v)
  ]

ch_name_4 _ = pick
  [ (1.0, cat [chunk, ch_v, v_name_3])
  , (1.0, cat [chunk, ch_ch, ch_name_3])
  ]

ch_name_3 _ = pick
  [ (1.0, cat [chunk, ch_v, v_name_2])
  , (1.0, cat [chunk, ch_ch, ch_name_2])
  ]

ch_name_2 _ = pick
  [ (1.0, cat [chunk, ch_v, v_name_1])
  , (1.0, cat [chunk, ch_ch, ch_name_1])
  ]

ch_name_1 = cat [end_chunk]

v_v = link

v_ch _ = pick
  [ (1.0, tc)
  , (1.0, lit "")
  ]

ch_v _ = pick
  [ (1.0, c)
  , (1.0, lit "")
  ]

ch_ch = lit ""

chunk _ = pick
  [ (1.0, lit "jax")
  , (1.0, lit "fred")
  , (1.0, lit "ald")
  , (1.0, lit "art")
  , (1.0, lit "ulf")
  , (1.0, lit "walt")
  , (1.0, lit "hild")
  , (1.0, lit "os")
  , (1.0, lit "thur")
  , (1.0, lit "gwin")
  , (1.0, lit "gwid")
  , (1.0, lit "al")
  , (1.0, lit "wil")
  , (1.0, lit "bil")
  , (1.0, lit "win")
  , (1.0, lit "don")
  , (1.0, lit "quen")
  , (1.0, lit "quin")
  , (1.0, lit "ash")
  , (1.0, lit "mir")
  , (1.0, lit "orn")
  , (1.0, lit "ild")
  , (1.0, lit "ian")
  , (1.0, lit "ray")
  , (1.0, lit "ing")
  ]

end_chunk _ = pick
  [ (1.0, end_chunk_f)
  , (1.0, end_chunk_m)
  ]

end_chunk_f _ = pick
  [ (1.0, lit "sdottir")
  , (4.0, lit "ia")
  , (3.0, lit "a")
  , (2.0, lit "sha")
  , (2.0, lit "illa")
  , (2.0, lit "ie")
  , (2.0, lit "iel")
  , (2.0, lit "ara")
  , (1.0, lit "issa")
  , (1.0, lit "een")
  , (1.0, lit "ita")
  , (1.0, lit "ina")
  , (1.0, lit "ice")
  , (1.0, lit "ra")
  , (1.0, lit "na")
  , (1.0, lit "ene")
  , (1.0, lit "rine")
  , (1.0, lit "lene")
  , (1.0, lit "ula")
  , (1.0, lit "yssa")
  , (1.0, lit "ima")
  , (1.0, lit "essa")
  , (1.0, lit "grid")
  , (1.0, lit "ythe")
  , (1.0, lit "quith")
  , (1.0, lit "frith")
  , (1.0, lit "wen")
  ]

end_chunk_m _ = pick
  [ (1.0, lit "sson")
  , (1.0, lit "son")
  , (1.0, lit "on")
  , (1.0, lit "art")
  , (1.0, lit "ton")
  , (1.0, lit "drew")
  , (1.0, lit "wild")
  , (1.0, lit "mund")
  , (1.0, lit "wulf")
  , (1.0, lit "noth")
  , (1.0, lit "ric")
  , (1.0, lit "ic")
  , (1.0, lit "us")
  , (1.0, lit "ius")
  , (1.0, lit "ulf")
  , (1.0, lit "ald")
  , (1.0, lit "thur")
  , (1.0, lit "or")
  , (1.0, lit "ar")
  , (1.0, lit "win")
  , (1.0, lit "don")
  , (1.0, lit "nulf")
  , (1.0, lit "ax")
  , (1.0, lit "orn")
  , (1.0, lit "ild")
  , (1.0, lit "ian")
  , (1.0, lit "ray")
  , (1.0, lit "awn")
  , (1.0, lit "ed")
  , (1.0, lit "fred")
  , (1.0, lit "orne")
  , (1.0, lit "gold")
  , (1.0, lit "gar")
  ]

link _ = pick
  [ (6.0, tc)
  , (6.0, c)
  , (4.0, cat [tc, c])
  , (1.0, lit "ll")
  , (1.0, lit "rr")
  , (1.0, lit "rg")
  , (1.0, lit "ng")
  , (1.0, lit "ck")
  , (1.0, lit "ld")
  , (1.0, lit "x")
  , (1.0, lit "'")
  ]

c_end _ = pick
  [ (15.0, tc)
  , (1.0, lit "ll")
  , (1.0, lit "rr")
  , (1.0, lit "nn")
  , (1.0, lit "pp")
  , (1.0, lit "nt")
  , (1.0, lit "nth")
  , (1.0, lit "rn")
  , (1.0, lit "st")
  , (1.0, lit "th")
  , (1.0, lit "sk")
  , (1.0, lit "ld")
  , (1.0, lit "lf")
  , (1.0, lit "ng")
  , (1.0, lit "rk")
  , (1.0, lit "ck")
  , (1.0, lit "x")
  ]

tc _ = pick
  [ (1.0, lit "r")
  , (1.0, lit "t")
  , (1.0, lit "th")
  , (1.0, lit "p")
  , (1.0, lit "s")
  , (1.0, lit "sh")
  , (1.0, lit "d")
  , (1.0, lit "f")
  , (1.0, lit "g")
  , (1.0, lit "l")
  , (1.0, lit "b")
  , (1.0, lit "n")
  , (1.0, lit "m")
  ]

c _ = pick
  [ (1.0, lit "w")
  , (1.0, lit "r")
  , (1.0, lit "t")
  , (1.0, lit "tr")
  , (1.0, lit "th")
  , (1.0, lit "y")
  , (1.0, lit "p")
  , (1.0, lit "s")
  , (1.0, lit "sh")
  , (1.0, lit "st")
  , (1.0, lit "sl")
  , (1.0, lit "sp")
  , (1.0, lit "sc")
  , (1.0, lit "d")
  , (1.0, lit "dr")
  , (1.0, lit "f")
  , (1.0, lit "fr")
  , (1.0, lit "g")
  , (1.0, lit "gr")
  , (1.0, lit "h")
  , (1.0, lit "j")
  , (1.0, lit "k")
  , (1.0, lit "l")
  , (1.0, lit "z")
  , (1.0, lit "c")
  , (1.0, lit "ch")
  , (1.0, lit "cl")
  , (1.0, lit "v")
  , (1.0, lit "b")
  , (1.0, lit "br")
  , (1.0, lit "bl")
  , (1.0, lit "n")
  , (1.0, lit "m")
  ]

c_long _ = pick
  [ (29.0, c)
  , (1.0, lit "sm")
  , (1.0, lit "sn")
  , (1.0, lit "scr")
  , (1.0, lit "spr")
  , (1.0, lit "gl")
  , (1.0, lit "hr")
  , (1.0, lit "cr")
  , (1.0, lit "pr")
  ]

v _ = pick
  [ (2.0, lit "e")
  , (2.0, lit "u")
  , (2.0, lit "i")
  , (2.0, lit "o")
  , (2.0, lit "a")
  , (2.0, lit "y")
  , (1.0, lit "ia")
  , (1.0, lit "io")
  , (1.0, lit "ae")
  , (1.0, lit "ee")
  ]
