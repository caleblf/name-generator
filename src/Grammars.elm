module Grammars exposing ( languages
                         , transforms
                         , languagesByName
                         , transformsByName
                         , dummyLanguage
                         , defaultLanguage
                         )

import Dict exposing (Dict)
import Random

import Pcfg exposing (Language, Transform)

import Manifest

languages = Manifest.languages
transforms = Manifest.transforms

dummyLanguage : Language
dummyLanguage =
  { name = "..."
  , description = ""
  , generator = (\_ -> Random.constant "...")
  }

defaultLanguage : Language
defaultLanguage = Maybe.withDefault dummyLanguage <| List.head languages


languagesByName : Dict String Language
languagesByName =
  Dict.fromList <| List.map (\language -> (language.name, language)) languages

transformsByName : Dict String Transform
transformsByName =
  Dict.fromList <| List.map (\transform -> (transform.name, transform)) transforms
