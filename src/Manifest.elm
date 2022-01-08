module Manifest exposing (..)

import Json.Decode as Dec

import Transform
import Language


type alias Manifest =
  { languageGroups : List Language.LanguageGroup
  , transforms : List Transform.TransformSpec
  }


decoder : Dec.Decoder Manifest
decoder =
  Dec.map2 Manifest
    (Dec.field "languageGroups"
      (Dec.list
        <| Dec.map2
            Language.LanguageGroup
            (Dec.field "name" Dec.string)
            (Dec.field "languages"
              (Dec.list
                <| Dec.map3
                    (\name description url ->
                      { metadata =
                          { name = name
                          , description = description
                          }
                      , setupSpec = Language.UrlLanguageSetup url
                      }
                    )
                    (Dec.field "name" Dec.string)
                    (Dec.field "description" Dec.string)
                    (Dec.field "url" Dec.string)
              )
            )
      )
    )
    (Dec.field "transforms"
      (Dec.list
        <| Dec.map4
            Transform.TransformSpec
            (Dec.field "name" Dec.string)
            (Dec.field "description" Dec.string)
            (Dec.field "priority" Dec.int)
            (Dec.field "url" Dec.string)
      )
    )


empty : Manifest
empty =
  { languageGroups = []
  , transforms = []
  }
