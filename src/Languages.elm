module Languages exposing (languages, languagesByName, dummy, default)

import Dict exposing (Dict)
import Random

import Language exposing (Language)

import Elven


dummy : Language
dummy =
  { name = "..."
  , generator = (\_ -> Random.constant "...")
  }

default : Language
default = Maybe.withDefault dummy <| List.head languages


languages : List Language
languages =
  [ Elven.elven
  ]

languagesByName : Dict String Language
languagesByName =
  Dict.fromList <| List.map (\language -> (language.name, language)) languages
