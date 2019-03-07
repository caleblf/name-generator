module Manifest exposing ( languages
                         , transforms
                         , languagesByName
                         , transformsByName
                         , dummyLanguage
                         , defaultLanguage
                         )

import Dict exposing (Dict)
import Random

import Pcfg exposing (Language, Transform)

import Languages.Common exposing (common)
import Languages.Elven exposing (elven)
import Languages.Dwarven exposing (dwarven)
import Languages.Halfling exposing (halfling)
import Languages.Orcish exposing (orcish)
import Languages.Fiendish exposing (fiendish)
import Languages.Nickname exposing (nickname)

import Transforms.Title exposing (title)
import Transforms.Profession exposing (profession)


dummyLanguage : Language
dummyLanguage =
  { name = "..."
  , description = ""
  , generator = (\_ -> Random.constant "...")
  }

defaultLanguage : Language
defaultLanguage = Maybe.withDefault dummyLanguage <| List.head languages


languages : List Language
languages =
  [ common
  , elven
  , dwarven
  , halfling
  , orcish
  , fiendish
  , nickname
  ]

transforms : List Transform
transforms =
  List.sortBy .priority
    [ title
    , profession
    ]


languagesByName : Dict String Language
languagesByName =
  Dict.fromList <| List.map (\language -> (language.name, language)) languages

transformsByName : Dict String Transform
transformsByName =
  Dict.fromList <| List.map (\transform -> (transform.name, transform)) transforms
