module Languages.Common exposing (common)

import Pcfg exposing (Language, literalForm, concatForms, pickWeightedForm)


common : Language
common =
  { name = "Common"
  , description = "Generic fantasy European human names"
  , priority = 0
  , generator = name
  }


name _ = pickWeightedForm
  [ (1.0, name_single)
  , (1.0, name_double)
  ]

name_single _ = pickWeightedForm
  [ (4.0, element)
  , (1.0, concatForms [onset_initial, v_chunk_final])
  ]

name_double _ = pickWeightedForm
  [ (2.0, concatForms [element_c, element])
  , (2.0, concatForms [chunk_initial, element])
  , (1.0, concatForms [element, c_chunk_final])
  , (1.0, concatForms [element_c, v_chunk_final])
  ]

element_c _ = pickWeightedForm
  [ (1.0, concatForms [syllable_initial, syllable, syllable, coda_final])
  , (2.0, concatForms [syllable_initial, syllable, coda_final])
  , (2.0, concatForms [syllable_initial, coda_final])
  ]

element _ = pickWeightedForm
  [ (1.0, concatForms [syllable_initial, syllable, syllable_final])
  , (2.0, concatForms [syllable_initial, syllable_final])
  , (2.0, concatForms [syllable_only])
  ]

syllable = concatForms [onset, nucleus]

syllable_initial _ = pickWeightedForm
  [ (3.0, concatForms [onset_initial, nucleus])
  , (2.0, nucleus_initial)
  ]

syllable_final _ = pickWeightedForm
  [ (1.0, concatForms [onset, nucleus, coda_final])
  , (1.0, concatForms [onset, nucleus_final])
  ]

syllable_only _ = pickWeightedForm
  [ (3.0, concatForms [onset_initial, nucleus, coda_final])
  , (1.0, concatForms [onset_initial, nucleus_final])
  , (1.0, concatForms [nucleus_initial, coda_final])
  ]

chunk_initial _ = pickWeightedForm
  [ (1.0, literalForm "mad")
  , (1.0, literalForm "jax")
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
  , (1.0, literalForm "ray")
  , (1.0, literalForm "ing")
  , (1.0, literalForm "ol")
  ]

c_chunk_final _ = pickWeightedForm
  [ (1.0, c_chunk_final_f)
  , (1.0, c_chunk_final_m)
  ]

v_chunk_final _ = pickWeightedForm
  [ (1.0, v_chunk_final_f)
  , (1.0, v_chunk_final_m)
  ]

c_chunk_final_f _ = pickWeightedForm
  [ (1.0, literalForm "sdottir")
  , (1.0, literalForm "sha")
  , (1.0, literalForm "ra")
  , (1.0, literalForm "na")
  , (1.0, literalForm "va")
  , (1.0, literalForm "ma")
  , (1.0, literalForm "di")
  , (1.0, literalForm "li")
  , (1.0, literalForm "rine")
  , (1.0, literalForm "lene")
  , (1.0, literalForm "grid")
  , (1.0, literalForm "quith")
  , (1.0, literalForm "frith")
  , (1.0, literalForm "wen")
  ]

v_chunk_final_f _ = pickWeightedForm
  [ (4.0, literalForm "ia")
  , (3.0, literalForm "a")
  , (2.0, literalForm "illa")
  , (2.0, literalForm "ie")
  , (2.0, literalForm "iel")
  , (2.0, literalForm "ara")
  , (1.0, literalForm "issa")
  , (1.0, literalForm "een")
  , (1.0, literalForm "ita")
  , (1.0, literalForm "ina")
  , (1.0, literalForm "ene")
  , (1.0, literalForm "ula")
  , (1.0, literalForm "yssa")
  , (1.0, literalForm "ima")
  , (1.0, literalForm "essa")
  , (1.0, literalForm "ythe")
  , (1.0, literalForm "y")
  ]

c_chunk_final_m _ = pickWeightedForm
  [ (1.0, literalForm "sson")
  , (1.0, literalForm "son")
  , (1.0, literalForm "ton")
  , (1.0, literalForm "drew")
  , (1.0, literalForm "wild")
  , (1.0, literalForm "mund")
  , (1.0, literalForm "wulf")
  , (1.0, literalForm "noth")
  , (1.0, literalForm "ric")
  , (1.0, literalForm "thur")
  , (1.0, literalForm "win")
  , (1.0, literalForm "don")
  , (1.0, literalForm "nulf")
  , (1.0, literalForm "ray")
  , (1.0, literalForm "fred")
  , (1.0, literalForm "orne")
  , (1.0, literalForm "gold")
  , (1.0, literalForm "gar")
  , (1.0, literalForm "der")
  ]

v_chunk_final_m _ = pickWeightedForm
  [ (1.0, literalForm "on")
  , (1.0, literalForm "er")
  , (1.0, literalForm "art")
  , (1.0, literalForm "ic")
  , (1.0, literalForm "us")
  , (1.0, literalForm "ius")
  , (1.0, literalForm "ulf")
  , (1.0, literalForm "ald")
  , (1.0, literalForm "or")
  , (1.0, literalForm "ar")
  , (1.0, literalForm "ax")
  , (1.0, literalForm "orn")
  , (1.0, literalForm "ild")
  , (1.0, literalForm "ian")
  , (1.0, literalForm "awn")
  , (1.0, literalForm "ed")
  , (1.0, literalForm "an")
  ]

onset _ = pickWeightedForm
  [ (6.0, tc)
  , (6.0, c)
  ]

coda _ = pickWeightedForm
  [ (15.0, tc)
  , (1.0, literalForm "ll")
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

coda_final _ = pickWeightedForm
  [ (15.0, tc)
  , (1.0, literalForm "ll")
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

onset_initial _ = pickWeightedForm
  [ (29.0, c)
  , (1.0, literalForm "sm")
  , (1.0, literalForm "sn")
  , (1.0, literalForm "gl")
  , (1.0, literalForm "cr")
  , (1.0, literalForm "pr")
  , (1.0, literalForm "thr")
  ]

nucleus _ = pickWeightedForm
  [ (5.0, literalForm "e")
  , (5.0, literalForm "u")
  , (5.0, literalForm "i")
  , (5.0, literalForm "o")
  , (7.0, literalForm "a")
  , (1.0, literalForm "ee")
  , (1.0, literalForm "ai")
  ]

nucleus_initial _ = pickWeightedForm
  [ (3.0, literalForm "a")
  , (3.0, literalForm "e")
  , (3.0, literalForm "i")
  , (3.0, literalForm "o")
  , (2.0, literalForm "u")
  , (1.0, literalForm "ae")
  ]

nucleus_final _ = pickWeightedForm
  [ (5.0, literalForm "a")
  , (2.0, literalForm "e")
  , (4.0, literalForm "i")
  , (5.0, literalForm "o")
  , (3.0, literalForm "ia")
  , (2.0, literalForm "io")
  , (1.0, literalForm "oa")
  , (1.0, literalForm "ie")
  ]
