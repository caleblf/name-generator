module Languages.Common exposing (common)

import Language exposing (Language, Form, lit, cat, pick, u, p)


common : Language
common =
  { name = "Common"
  , generator = name
  }


name _ = pick
  [ (1, name_4)
  , (3, name_3)
  , (6, name_2)
  , (4, name_1)
  ]

name_4 _ = pick
  [ (1, v_name_4)
  , (1, cat [c_long, v_name_4])
  , (1, ch_name_4)
  ]

name_3 _ = pick
  [ (1, v_name_3)
  , (2, cat [c_long, v_name_3])
  , (2, ch_name_3)
  ]

name_2 _ = pick
  [ (1, v_name_2)
  , (2, cat [c_long, v_name_2])
  , (2, ch_name_2)
  ]

name_1 _ = pick
  [ (1, cat [c_long, v])
  , (1, cat [v, c_end])
  , (3, cat [c_long, v, c_end])
  ]

v_name_4 _ = pick
  [ (1, cat [v, v_v, v_name_3])
  , (1, cat [v, v_ch, ch_name_3])
  ]

v_name_3 _ = pick
  [ (1, cat [v, v_v, v_name_2])
  , (1, cat [v, v_ch, ch_name_2])
  ]

v_name_2 _ = pick
  [ (1, cat [v, v_v, v_name_1])
  , (1, cat [v, v_ch, ch_name_1])
  ]

v_name_1 _ = pick
  [ (1, cat [v, c_end])
  , (1, v)
  ]

ch_name_4 _ = pick
  [ (1, cat [chunk, ch_v, v_name_3])
  , (1, cat [chunk, ch_ch, ch_name_3])
  ]

ch_name_3 _ = pick
  [ (1, cat [chunk, ch_v, v_name_2])
  , (1, cat [chunk, ch_ch, ch_name_2])
  ]

ch_name_2 _ = pick
  [ (1, cat [chunk, ch_v, v_name_1])
  , (1, cat [chunk, ch_ch, ch_name_1])
  ]

ch_name_1 _ = pick
  [ (1, cat [end_chunk])
  ]

v_v _ = pick
  [ (1, link)
  ]

v_ch _ = pick
  [ (1, tc)
  , (1, lit "")
  ]

ch_v _ = pick
  [ (1, c)
  , (1, lit "")
  ]

ch_ch _ = pick
  [ (1, lit "")
  ]

chunk _ = pick
  [ (1, lit "jax")
  , (1, lit "fred")
  , (1, lit "ald")
  , (1, lit "art")
  , (1, lit "ulf")
  , (1, lit "walt")
  , (1, lit "hild")
  , (1, lit "os")
  , (1, lit "thur")
  , (1, lit "gwin")
  , (1, lit "gwid")
  , (1, lit "al")
  , (1, lit "wil")
  , (1, lit "bil")
  , (1, lit "win")
  , (1, lit "don")
  , (1, lit "quen")
  , (1, lit "quin")
  , (1, lit "ash")
  , (1, lit "mir")
  , (1, lit "orn")
  , (1, lit "ild")
  , (1, lit "ian")
  , (1, lit "ray")
  , (1, lit "ing")
  ]

end_chunk _ = pick
  [ (1, end_chunk_f)
  , (1, end_chunk_m)
  ]

end_chunk_f _ = pick
  [ (1, lit "sdottir")
  , (4, lit "ia")
  , (3, lit "a")
  , (2, lit "sha")
  , (2, lit "illa")
  , (2, lit "ie")
  , (2, lit "iel")
  , (2, lit "ara")
  , (1, lit "issa")
  , (1, lit "een")
  , (1, lit "ita")
  , (1, lit "ina")
  , (1, lit "ice")
  , (1, lit "ra")
  , (1, lit "na")
  , (1, lit "ene")
  , (1, lit "rine")
  , (1, lit "lene")
  , (1, lit "ula")
  , (1, lit "yssa")
  , (1, lit "ima")
  , (1, lit "essa")
  , (1, lit "grid")
  , (1, lit "ythe")
  , (1, lit "quith")
  , (1, lit "frith")
  , (1, lit "wen")
  ]

end_chunk_m _ = pick
  [ (1, lit "sson")
  , (1, lit "son")
  , (1, lit "on")
  , (1, lit "art")
  , (1, lit "ton")
  , (1, lit "drew")
  , (1, lit "wild")
  , (1, lit "mund")
  , (1, lit "wulf")
  , (1, lit "noth")
  , (1, lit "ric")
  , (1, lit "ic")
  , (1, lit "us")
  , (1, lit "ius")
  , (1, lit "ulf")
  , (1, lit "ald")
  , (1, lit "thur")
  , (1, lit "or")
  , (1, lit "ar")
  , (1, lit "win")
  , (1, lit "don")
  , (1, lit "nulf")
  , (1, lit "ax")
  , (1, lit "orn")
  , (1, lit "ild")
  , (1, lit "ian")
  , (1, lit "ray")
  , (1, lit "awn")
  , (1, lit "ed")
  , (1, lit "fred")
  , (1, lit "orne")
  , (1, lit "gold")
  , (1, lit "gar")
  ]

link _ = pick
  [ (6, tc)
  , (6, c)
  , (4, cat [tc, c])
  , (1, lit "ll")
  , (1, lit "rr")
  , (1, lit "rg")
  , (1, lit "ng")
  , (1, lit "ck")
  , (1, lit "ld")
  , (1, lit "x")
  , (1, lit "'")
  ]

c_end _ = pick
  [ (15, tc)
  , (1, lit "ll")
  , (1, lit "rr")
  , (1, lit "nn")
  , (1, lit "pp")
  , (1, lit "nt")
  , (1, lit "nth")
  , (1, lit "rn")
  , (1, lit "st")
  , (1, lit "th")
  , (1, lit "sk")
  , (1, lit "ld")
  , (1, lit "lf")
  , (1, lit "ng")
  , (1, lit "rk")
  , (1, lit "ck")
  , (1, lit "x")
  ]

tc _ = pick
  [ (1, lit "r")
  , (1, lit "t")
  , (1, lit "th")
  , (1, lit "p")
  , (1, lit "s")
  , (1, lit "sh")
  , (1, lit "d")
  , (1, lit "f")
  , (1, lit "g")
  , (1, lit "l")
  , (1, lit "b")
  , (1, lit "n")
  , (1, lit "m")
  ]

c _ = pick
  [ (1, lit "w")
  , (1, lit "r")
  , (1, lit "t")
  , (1, lit "tr")
  , (1, lit "th")
  , (1, lit "y")
  , (1, lit "p")
  , (1, lit "s")
  , (1, lit "sh")
  , (1, lit "st")
  , (1, lit "sl")
  , (1, lit "sp")
  , (1, lit "sc")
  , (1, lit "d")
  , (1, lit "dr")
  , (1, lit "f")
  , (1, lit "fr")
  , (1, lit "g")
  , (1, lit "gr")
  , (1, lit "h")
  , (1, lit "j")
  , (1, lit "k")
  , (1, lit "l")
  , (1, lit "z")
  , (1, lit "c")
  , (1, lit "ch")
  , (1, lit "cl")
  , (1, lit "v")
  , (1, lit "b")
  , (1, lit "br")
  , (1, lit "bl")
  , (1, lit "n")
  , (1, lit "m")
  ]

c_long _ = pick
  [ (29, c)
  , (1, lit "sm")
  , (1, lit "sn")
  , (1, lit "scr")
  , (1, lit "spr")
  , (1, lit "gl")
  , (1, lit "hr")
  , (1, lit "cr")
  , (1, lit "pr")
  ]

v _ = pick
  [ (2, lit "e")
  , (2, lit "u")
  , (2, lit "i")
  , (2, lit "o")
  , (2, lit "a")
  , (2, lit "y")
  , (1, lit "ia")
  , (1, lit "io")
  , (1, lit "ae")
  , (1, lit "ee")
  ]
