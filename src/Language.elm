module Language exposing (Model, Msg, init, update, viewSettings, languageGenerator)

import List
import List.Extra
import Random
import Http
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Encode as Enc
import Parser exposing (Parser)

import Pcfg
import Markov
import ParserError


-- INTERFACE


languageGenerator : Model -> Random.Generator String
languageGenerator model =
  case model.activeLanguage.generator of
    StaticGenerator generator -> generator
    FromCustomExamples ->
      Markov.generatorFromExamples 1 <| String.words <| model.customExamples



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
  , setupSpec : LanguageSetup
  }

type LanguageSetup
  = PcfgLanguageSetup
      { url : String }
  | MarkovLanguageSetup
      { url : String }
  | CustomMarkovLanguageSetup
  | DummyLanguageSetup

emptyLanguageSpec : LanguageSpec
emptyLanguageSpec =
  { metadata = emptyLanguage.metadata
  , setupSpec = DummyLanguageSetup
  }


allLanguageGroups : List LanguageGroup
allLanguageGroups =
  [ { name = "Fantasy"
    , languages =
        [ { metadata =
              { name = "Common"
              , description = "Generic fantasy names"
              }
          , setupSpec = MarkovLanguageSetup { url = "languages/markov/common.txt" }
          }
        , { metadata =
              { name = "Nickname"
              , description = "Melodramatic nicknames"
              }
          , setupSpec = PcfgLanguageSetup { url = "languages/pcfg/nickname.pcfg" }
          }
        , { metadata =
              { name = "Elven"
              , description = "Fantasy elf names"
              }
          , setupSpec = PcfgLanguageSetup { url = "languages/pcfg/elven.pcfg" }
          }
        , { metadata =
              { name = "Halfling"
              , description = "Fantasy halfling/hobbit names"
              }
          , setupSpec = PcfgLanguageSetup { url = "languages/pcfg/halfling.pcfg" }
          }
        , { metadata =
              { name = "Dwarven"
              , description = "Fantasy dwarf names"
              }
          , setupSpec = PcfgLanguageSetup { url = "languages/pcfg/dwarven.pcfg" }
          }
        , { metadata =
              { name = "Orcish"
              , description = "Fantasy orc names"
              }
          , setupSpec = PcfgLanguageSetup { url = "languages/pcfg/orcish.pcfg" }
          }
        , { metadata =
              { name = "Fiendish"
              , description = "Demonic-sounding names"
              }
          , setupSpec = PcfgLanguageSetup { url = "languages/pcfg/fiendish.pcfg" }
          }
        ]
    }
  , { name = "History and Literature"
    , languages =
        [ { metadata =
              { name = "Roman"
              , description = "Ancient Roman names"
              }
          , setupSpec = MarkovLanguageSetup { url = "languages/markov/roman.txt" }
          }
        , { metadata =
              { name = "Arthurian"
              , description = "Names reminiscent of Arthurian legend"
              }
          , setupSpec = MarkovLanguageSetup { url = "languages/markov/arthurian.txt" }
          }
        ]
    }
  , { name = "Places and Organizations"
    , languages =
        [ { metadata =
              { name = "Town"
              , description = "Generic city/town names"
              }
          , setupSpec = PcfgLanguageSetup { url = "languages/pcfg/town.pcfg" }
          }
        , { metadata =
              { name = "Organization"
              , description = "Names for organizations and orders"
              }
          , setupSpec = PcfgLanguageSetup { url = "languages/pcfg/organization.pcfg" }
          }
        ]
    }
  , { name = "Configurable"
    , languages =
        [ customMarkovLanguageSpec ]
    }
  ]


customMarkovLanguageSpec : LanguageSpec
customMarkovLanguageSpec =
  { metadata =
      { name = "Custom Markov Input"
      , description = "Customizable Markov name generator"
      }
  , setupSpec = CustomMarkovLanguageSetup
  }

loadLangauge : LanguageIndex -> LanguageSpec -> (Language, Cmd Msg)
loadLangauge index { metadata, setupSpec } =
  case setupSpec of
    PcfgLanguageSetup { url } ->
      ( loadingLanguage
      , loadGeneratorFromUrl url (Parser.map .generator Pcfg.language)
          |> Cmd.map
              (\generator ->
                LoadedLanguage index
                  { metadata = metadata
                  , generator = generator
                  })
      )
    MarkovLanguageSetup { url } ->
      ( loadingLanguage
      , loadGeneratorFromUrl url Markov.generator
          |> Cmd.map
              (\generator ->
                LoadedLanguage index
                  { metadata = metadata
                  , generator = generator
                  })
      )
    CustomMarkovLanguageSetup ->
      ( { metadata = metadata
        , generator = FromCustomExamples
        }
      , Cmd.none
      )
    DummyLanguageSetup ->
      ( { metadata = metadata
        , generator = emptyLanguage.generator
        }
      , Cmd.none
      )

loadGeneratorFromUrl : String -> Parser (Random.Generator String) -> Cmd LanguageGenerator
loadGeneratorFromUrl url parser =
  Http.get
    { url = url
    , expect =
        Http.expectString
        (\result ->
          case result of
            Ok body ->
              case Parser.run parser body of
                Ok generator ->
                  StaticGenerator generator
                Err deadEnds ->
                  StaticGenerator
                    <| Random.constant
                    <| String.concat
                        [ "Error parsing "
                        , url
                        , ": "
                        , ParserError.deadEndsToString deadEnds
                        ]
            Err httpError ->
              StaticGenerator
                <| Random.constant
                <| "Error accessing " ++ url
        )
    }



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
