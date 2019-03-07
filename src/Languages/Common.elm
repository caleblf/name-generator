module Languages.Common exposing (common)

import Pcfg exposing (Language, literalForm, concatForms, pickWeightedForm)


common : Language
common =
  { name = "Common"
  , description = "Fantasy European human names"
  , generator = name
  }


name _ = pickWeightedForm
  [ (3.0, name_3)
  , (7.0, name_2)
  , (4.0, name_1)
  ]

name_4 _ = pickWeightedForm
  [ (1.0, v_name_4)
  , (1.0, concatForms [c_long, v_name_4])
  , (1.0, ch_name_4)
  ]

name_3 _ = pickWeightedForm
  [ (1.0, v_name_3)
  , (2.0, concatForms [c_long, v_name_3])
  , (2.0, ch_name_3)
  ]

name_2 _ = pickWeightedForm
  [ (1.0, v_name_2)
  , (2.0, concatForms [c_long, v_name_2])
  , (2.0, ch_name_2)
  ]

name_1 _ = pickWeightedForm
  [ (1.0, concatForms [c_long, v])
  , (1.0, concatForms [v, c_end])
  , (3.0, concatForms [c_long, v, c_end])
  ]

v_name_4 _ = pickWeightedForm
  [ (1.0, concatForms [v, v_v, v_name_3])
  , (1.0, concatForms [v, v_ch, ch_name_3])
  ]

v_name_3 _ = pickWeightedForm
  [ (1.0, concatForms [v, v_v, v_name_2])
  , (1.0, concatForms [v, v_ch, ch_name_2])
  ]

v_name_2 _ = pickWeightedForm
  [ (1.0, concatForms [v, v_v, v_name_1])
  , (1.0, concatForms [v, v_ch, ch_name_1])
  ]

v_name_1 _ = pickWeightedForm
  [ (1.0, concatForms [v, c_end])
  , (1.0, v)
  ]

ch_name_4 _ = pickWeightedForm
  [ (1.0, concatForms [chunk, ch_v, v_name_3])
  , (1.0, concatForms [chunk, ch_ch, ch_name_3])
  ]

ch_name_3 _ = pickWeightedForm
  [ (1.0, concatForms [chunk, ch_v, v_name_2])
  , (1.0, concatForms [chunk, ch_ch, ch_name_2])
  ]

ch_name_2 _ = pickWeightedForm
  [ (1.0, concatForms [chunk, ch_v, v_name_1])
  , (1.0, concatForms [chunk, ch_ch, ch_name_1])
  ]

ch_name_1 = concatForms [end_chunk]

v_v = link

v_ch _ = pickWeightedForm
  [ (1.0, tc)
  , (1.0, literalForm "")
  ]

ch_v _ = pickWeightedForm
  [ (1.0, c)
  , (1.0, literalForm "")
  ]

ch_ch = literalForm ""

chunk _ = pickWeightedForm
  [ (1.0, literalForm "jax")
  , (1.0, literalForm "ald")
  , (1.0, literalForm "art")
  , (1.0, literalForm "ulf")
  , (1.0, literalForm "walt")
  , (1.0, literalForm "hild")
  , (1.0, literalForm "os")
  , (1.0, literalForm "thur")
  , (1.0, literalForm "gwin")
  , (1.0, literalForm "gwid")
  , (1.0, literalForm "al")
  , (1.0, literalForm "wil")
  , (1.0, literalForm "bil")
  , (1.0, literalForm "win")
  , (1.0, literalForm "don")
  , (1.0, literalForm "quen")
  , (1.0, literalForm "quin")
  , (1.0, literalForm "ash")
  , (1.0, literalForm "mir")
  , (1.0, literalForm "orn")
  , (1.0, literalForm "ild")
  , (1.0, literalForm "ian")
  , (1.0, literalForm "ray")
  , (1.0, literalForm "ing")
  , (1.0, literalForm "elt")
  ]

end_chunk _ = pickWeightedForm
  [ (1.0, end_chunk_f)
  , (1.0, end_chunk_m)
  ]

end_chunk_f _ = pickWeightedForm
  [ (1.0, literalForm "sdottir")
  , (4.0, literalForm "ia")
  , (3.0, literalForm "a")
  , (2.0, literalForm "sha")
  , (2.0, literalForm "illa")
  , (2.0, literalForm "ie")
  , (2.0, literalForm "iel")
  , (2.0, literalForm "ara")
  , (1.0, literalForm "issa")
  , (1.0, literalForm "een")
  , (1.0, literalForm "ita")
  , (1.0, literalForm "ina")
  , (1.0, literalForm "ra")
  , (1.0, literalForm "na")
  , (1.0, literalForm "ene")
  , (1.0, literalForm "rine")
  , (1.0, literalForm "lene")
  , (1.0, literalForm "ula")
  , (1.0, literalForm "yssa")
  , (1.0, literalForm "ima")
  , (1.0, literalForm "essa")
  , (1.0, literalForm "grid")
  , (1.0, literalForm "ythe")
  , (1.0, literalForm "quith")
  , (1.0, literalForm "frith")
  , (1.0, literalForm "wen")
  ]

end_chunk_m _ = pickWeightedForm
  [ (1.0, literalForm "sson")
  , (1.0, literalForm "son")
  , (1.0, literalForm "on")
  , (1.0, literalForm "art")
  , (1.0, literalForm "ton")
  , (1.0, literalForm "drew")
  , (1.0, literalForm "wild")
  , (1.0, literalForm "mund")
  , (1.0, literalForm "wulf")
  , (1.0, literalForm "noth")
  , (1.0, literalForm "ric")
  , (1.0, literalForm "ic")
  , (1.0, literalForm "us")
  , (1.0, literalForm "ius")
  , (1.0, literalForm "ulf")
  , (1.0, literalForm "ald")
  , (1.0, literalForm "thur")
  , (1.0, literalForm "or")
  , (1.0, literalForm "ar")
  , (1.0, literalForm "win")
  , (1.0, literalForm "don")
  , (1.0, literalForm "nulf")
  , (1.0, literalForm "ax")
  , (1.0, literalForm "orn")
  , (1.0, literalForm "ild")
  , (1.0, literalForm "ian")
  , (1.0, literalForm "ray")
  , (1.0, literalForm "awn")
  , (1.0, literalForm "ed")
  , (1.0, literalForm "fred")
  , (1.0, literalForm "orne")
  , (1.0, literalForm "gold")
  , (1.0, literalForm "gar")
  ]

link _ = pickWeightedForm
  [ (6.0, tc)
  , (6.0, c)
  , (4.0, concatForms [tc, c])
  , (1.0, literalForm "ll")
  , (1.0, literalForm "rr")
  , (1.0, literalForm "rg")
  , (1.0, literalForm "ng")
  , (1.0, literalForm "ck")
  , (1.0, literalForm "ld")
  , (1.0, literalForm "x")
  , (1.0, literalForm "'")
  ]

c_end _ = pickWeightedForm
  [ (15.0, tc)
  , (1.0, literalForm "ll")
  , (1.0, literalForm "rr")
  , (1.0, literalForm "nn")
  , (1.0, literalForm "pp")
  , (1.0, literalForm "rn")
  , (1.0, literalForm "st")
  , (1.0, literalForm "th")
  , (1.0, literalForm "sk")
  , (1.0, literalForm "ld")
  , (1.0, literalForm "lf")
  , (1.0, literalForm "ng")
  , (1.0, literalForm "rk")
  , (1.0, literalForm "ck")
  , (1.0, literalForm "x")
  ]

tc _ = pickWeightedForm
  [ (2.0, literalForm "r")
  , (2.0, literalForm "t")
  , (2.0, literalForm "s")
  , (2.0, literalForm "d")
  , (2.0, literalForm "l")
  , (2.0, literalForm "b")
  , (2.0, literalForm "n")
  , (2.0, literalForm "m")
  , (1.0, literalForm "p")
  , (1.0, literalForm "g")
  , (1.0, literalForm "th")
  , (1.0, literalForm "sh")
  ]

c _ = pickWeightedForm
  [ (2.0, literalForm "d")
  , (2.0, literalForm "r")
  , (2.0, literalForm "t")
  , (2.0, literalForm "p")
  , (2.0, literalForm "s")
  , (2.0, literalForm "f")
  , (2.0, literalForm "j")
  , (2.0, literalForm "k")
  , (2.0, literalForm "l")
  , (2.0, literalForm "c")
  , (2.0, literalForm "v")
  , (2.0, literalForm "b")
  , (2.0, literalForm "n")
  , (2.0, literalForm "m")
  , (2.0, literalForm "g")
  , (1.0, literalForm "w")
  , (1.0, literalForm "tr")
  , (1.0, literalForm "th")
  , (1.0, literalForm "y")
  , (1.0, literalForm "sh")
  , (1.0, literalForm "st")
  , (1.0, literalForm "sl")
  , (1.0, literalForm "sp")
  , (1.0, literalForm "sc")
  , (1.0, literalForm "dr")
  , (1.0, literalForm "fr")
  , (1.0, literalForm "gr")
  , (1.0, literalForm "h")
  , (1.0, literalForm "z")
  , (1.0, literalForm "ch")
  , (1.0, literalForm "cl")
  , (1.0, literalForm "br")
  , (1.0, literalForm "bl")
  ]

c_long _ = pickWeightedForm
  [ (29.0, c)
  , (1.0, literalForm "sm")
  , (1.0, literalForm "sn")
  , (1.0, literalForm "scr")
  , (1.0, literalForm "spr")
  , (1.0, literalForm "gl")
  , (1.0, literalForm "hr")
  , (1.0, literalForm "cr")
  , (1.0, literalForm "pr")
  , (1.0, literalForm "thr")
  ]

v _ = pickWeightedForm
  [ (2.0, literalForm "e")
  , (2.0, literalForm "u")
  , (2.0, literalForm "i")
  , (2.0, literalForm "o")
  , (2.0, literalForm "a")
  , (2.0, literalForm "y")
  , (1.0, literalForm "ia")
  , (1.0, literalForm "io")
  ]
