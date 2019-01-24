module Manifest exposing (languages, languagesByName, dummyLanguage, defaultLanguage)

import Dict exposing (Dict)
import Random

import Language exposing (Language)

import Languages.Common exposing (common)
import Languages.Elven exposing (elven)
import Languages.Dwarven exposing (dwarven)
import Languages.Halfling exposing (halfling)
import Languages.Orcish exposing (orcish)


dummyLanguage : Language
dummyLanguage =
  { name = "..."
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
  ]

languagesByName : Dict String Language
languagesByName =
  Dict.fromList <| List.map (\language -> (language.name, language)) languages
