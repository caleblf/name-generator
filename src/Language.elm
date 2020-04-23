module Language exposing (Model, Msg, init, update, viewSettings, languageGenerator)

import List
import List.Extra
import Random
import Http
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Encode as Enc

import Pcfg
import Markov

import PcfgLanguages.Nickname
import PcfgLanguages.Elven
import PcfgLanguages.Halfling
import PcfgLanguages.Dwarven
import PcfgLanguages.Common
import PcfgLanguages.Orcish
import PcfgLanguages.Fiendish
import PcfgLanguages.Town
import PcfgLanguages.Organization



-- INTERFACE


languageGenerator : Model -> Random.Generator String
languageGenerator model =
  case model.activeLanguage.generator of
    StaticGenerator generator -> generator
    FromCustomExamples ->
      Markov.generatorFromExamples <| String.words <| model.customExamples



-- MODEL


type alias Model =
  { activeLanguageIndex : LanguageIndex
  , activeLanguage : Language
  , customExamples : String  -- only visible when in user Markov mode
  }


init : (Model, Cmd Msg)
init =
  let
    defaultInit =
      ( { activeLanguageIndex = (-1, -1)
        , activeLanguage = emptyLanguage
        , customExamples = ""
        }
      , Cmd.none
      )
  in
    case List.head allLanguageGroups of
      Nothing -> defaultInit
      Just languageGroup ->
        case List.head languageGroup.languages of
          Nothing -> defaultInit
          Just languageSpec ->
            let
              (language, loadCmd) = loadLangauge (0, 0) languageSpec
            in
              ( { activeLanguageIndex = (0, 0)
                , activeLanguage = language
                , customExamples = ""
                }
              , loadCmd
              )


type alias LanguageMetadata =
  { name : String
  , description : String
  }

type alias Language =
  { metadata : LanguageMetadata
  , generator : LanguageGenerator
  }


type LanguageGenerator
  = StaticGenerator (Random.Generator String)
  | FromCustomExamples


emptyLanguage : Language
emptyLanguage =
  { metadata =
      { name = "Empty Language"
      , description = "An empty language"
      }
  , generator = StaticGenerator <| Random.constant ""
  }

loadingLanguage : Language
loadingLanguage =
  { metadata =
      { name = "Loading..."
      , description = "Loading..."
      }
  , generator = StaticGenerator <| Random.constant "Loading..."
  }



-- UPDATE


type Msg
  = SelectLanguage LanguageIndex LanguageSpec
  | LoadedLanguage LanguageIndex Language
  | SetExamples String  -- Custom Markov only

type alias LanguageIndex = (Int, Int)

update : Msg -> Model -> (Model, Cmd Msg)
update msg ({ activeLanguageIndex, activeLanguage, customExamples } as model) =
  case msg of
    SelectLanguage index languageSpec ->
      let
        (language, loadCmd) = loadLangauge index languageSpec
      in
        ( { model
          | activeLanguageIndex = index
          , activeLanguage = language
          }
        , loadCmd
        )
    LoadedLanguage index language ->
      ( { model
        | activeLanguageIndex = index
        , activeLanguage = language
        }
      , Cmd.none
      )
    SetExamples examples ->
      ( { model | customExamples = examples }
      , Cmd.none
      )



-- LANGUAGE MANIFEST


type alias LanguageGroup =
  { name : String
  , languages : List LanguageSpec
  }


type alias LanguageSpec =
  { metadata : LanguageMetadata
  , setupData : LanguageSetup
  }

type LanguageSetup
  = PcfgLanguageSetup
      { generator : Random.Generator String }
  | MarkovLanguageSetup
      { filePath : String }
  | CustomMarkovLanguageSetup

emptyLanguageSpec : LanguageSpec
emptyLanguageSpec =
  { metadata = emptyLanguage.metadata
  , setupData = PcfgLanguageSetup { generator = Random.constant "" }
  }


allLanguageGroups : List LanguageGroup
allLanguageGroups =
  [ { name = "Fantasy"
    , languages =
        [ { metadata =
              { name = "Common" ++ " (Markov)"
              , description = "Generic fantasy names"
              }
            , setupData = MarkovLanguageSetup { filePath = "examples/common.txt" }
            }
          , fromPcfgSpec PcfgLanguages.Nickname.nickname
          , fromPcfgSpec PcfgLanguages.Elven.elven
          , fromPcfgSpec PcfgLanguages.Halfling.halfling
          , fromPcfgSpec PcfgLanguages.Dwarven.dwarven
          --, fromPcfgSpec PcfgLanguages.Common.common
          , fromPcfgSpec PcfgLanguages.Orcish.orcish
          , fromPcfgSpec PcfgLanguages.Fiendish.fiendish
          ]
    }
  , { name = "History and Literature"
    , languages =
        [ { metadata =
              { name = "Roman" ++ " (Markov)"
              , description = "Ancient Roman names"
              }
          , setupData = MarkovLanguageSetup { filePath = "examples/roman.txt" }
          }
        , { metadata =
              { name = "Arthurian" ++ " (Markov)"
              , description = "Names reminiscent of Arthurian legend"
              }
          , setupData = MarkovLanguageSetup { filePath = "examples/arthurian.txt" }
          }
        ]
    }
  , { name = "Places and Organizations"
    , languages =
        [ fromPcfgSpec PcfgLanguages.Town.town
        , fromPcfgSpec PcfgLanguages.Organization.organization
        ]
    }
  , { name = "Configurable"
    , languages =
        [ customMarkovLanguageSpec ]
    }
  ]


fromPcfgSpec : Pcfg.Language -> LanguageSpec
fromPcfgSpec pcfgLanguage =
  { metadata =
      { name = pcfgLanguage.name ++ " (PCFG)"
      , description = pcfgLanguage.description
      }
  , setupData = PcfgLanguageSetup { generator = pcfgLanguage.generator }
  }

customMarkovLanguageSpec : LanguageSpec
customMarkovLanguageSpec =
  { metadata =
      { name = "Custom Markov Input"
      , description = "Customizable Markov name generator"
      }
  , setupData = CustomMarkovLanguageSetup
  }

loadLangauge : LanguageIndex -> LanguageSpec -> (Language, Cmd Msg)
loadLangauge index { metadata, setupData } =
  case setupData of
    PcfgLanguageSetup { generator } ->
      ( { metadata = metadata
        , generator = StaticGenerator generator
        }
      , Cmd.none
      )
    MarkovLanguageSetup { filePath } ->
      ( loadingLanguage
      , Http.get
          { url = filePath
          , expect =
              Http.expectString
              (\spaceSeparatedExamples ->
                LoadedLanguage index
                  { metadata = metadata
                  , generator =
                      StaticGenerator
                        <| Markov.generatorFromExamples
                        <| String.words
                        <| Result.withDefault "" spaceSeparatedExamples
                  })
          }
      )
    CustomMarkovLanguageSetup ->
      ( { metadata = metadata
        , generator = FromCustomExamples
        }
      , Cmd.none
      )



-- VIEW


viewSettings : Model -> Html Msg
viewSettings { activeLanguageIndex, activeLanguage, customExamples } =
  Html.div [ Attr.class "language-settings" ]
    <| case activeLanguage.generator of
        StaticGenerator generator ->
          [ languageSelector activeLanguageIndex activeLanguage ]
        FromCustomExamples ->
          [ languageSelector activeLanguageIndex activeLanguage
          , customExamplesArea customExamples
          ]


customExamplesArea : String -> Html Msg
customExamplesArea customExamples =
  Html.textarea
    [ Attr.class "examples-area"
    , Attr.value customExamples
    , Events.onInput SetExamples
    ]
    []


encodeLanguageIndex : (Int, Int) -> String
encodeLanguageIndex (groupIndex, itemIndex) =
  String.fromInt groupIndex ++ " " ++ String.fromInt itemIndex

decodeLanguageIndex : String -> (Int, Int)
decodeLanguageIndex indexString =
  case String.split " " indexString of
    groupIndexString :: itemIndexString :: [] ->
      ( Maybe.withDefault 0 <| String.toInt groupIndexString
      , Maybe.withDefault 0 <| String.toInt itemIndexString
      )
    _ -> (0, 0)


languageSelector : LanguageIndex -> Language -> Html Msg
languageSelector activeLanguageIndex activeLanguage =
  Html.select
    [ Events.onInput
        (\indexString ->
          let
            (groupIndex, itemIndex) = decodeLanguageIndex indexString
          in
            SelectLanguage (groupIndex, itemIndex)
              <| case List.Extra.getAt groupIndex allLanguageGroups of
                  Nothing -> emptyLanguageSpec
                  Just group ->
                    case List.Extra.getAt itemIndex group.languages of
                      Nothing -> emptyLanguageSpec
                      Just spec -> spec)
    , Attr.class "language-selector"
    , Attr.title activeLanguage.metadata.description
    , Attr.value <| encodeLanguageIndex activeLanguageIndex
    ]
    <| List.indexedMap languageOptionGroup allLanguageGroups

languageOptionGroup : Int -> LanguageGroup -> Html Msg
languageOptionGroup groupIndex languageGroup =
  Html.optgroup [ Attr.property "label" <| Enc.string languageGroup.name ]
    <| List.indexedMap (languageOption groupIndex) languageGroup.languages

languageOption : Int -> Int -> LanguageSpec -> Html Msg
languageOption groupIndex itemIndex languageSpec =
  Html.option
    [ Attr.value <| encodeLanguageIndex (groupIndex, itemIndex) ]
    [ Html.text languageSpec.metadata.name ]
