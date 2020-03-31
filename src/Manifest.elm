module Manifest exposing (pcfgLanguages, pcfgTransforms,
                          markovLanguages, MarkovLanguageSpec)

import Pcfg

import PcfgLanguages.Nickname exposing (nickname)
import PcfgLanguages.Elven exposing (elven)
import PcfgLanguages.Halfling exposing (halfling)
import PcfgLanguages.Dwarven exposing (dwarven)
import PcfgLanguages.Common exposing (common)
import PcfgLanguages.Orcish exposing (orcish)
import PcfgLanguages.Fiendish exposing (fiendish)
import PcfgLanguages.Town exposing (town)

import PcfgTransforms.Title exposing (title)
import PcfgTransforms.Profession exposing (profession)
import PcfgTransforms.Domains exposing (domains)


pcfgLanguages : List Pcfg.Language
pcfgLanguages =
  List.sortBy .priority
    [ nickname
    , elven
    , halfling
    , dwarven
    , common
    , orcish
    , fiendish
    , town
    ]

pcfgTransforms : List Pcfg.Transform
pcfgTransforms =
  List.sortBy .priority
    [ title
    , profession
    , domains
    ]


type alias MarkovLanguageSpec =
  { name : String
  , description : String
  , priority : Int
  , filePath : String
  }


markovLanguages : List MarkovLanguageSpec
markovLanguages =
  [ { name = "Roman"
    , description = "Roman-sounding names"
    , priority = 2
    , filePath = "/examples/roman.txt"
    }
  , { name = "Arthurian"
    , description = "Names with an Arthurian vibe"
    , priority = 3
    , filePath = "/examples/arthurian.txt"
    }
  , { name = "Common"
    , description = "Fantasy common-tongue names. Good for humans"
    , priority = 0
    , filePath = "/examples/common.txt"
    }
  ]
