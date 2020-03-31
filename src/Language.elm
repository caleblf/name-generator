module Language exposing (Model, Msg, init, update, viewSettings, languageGenerator)

import List
import List.Extra
import Random
import Http
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events

import Pcfg
import Markov
import Manifest



-- INTERFACE


languageGenerator : Model -> Random.Generator String
languageGenerator = .activeLanguage >> .generator



-- MODEL


type alias Model =
  { activeLanguageIndex : Int
  , activeLanguage : Language
  }


init : (Model, Cmd Msg)
init =
  case List.head allLanguageSpecs of
    Nothing ->
      ( { activeLanguageIndex = -1
        , activeLanguage = emptyLanguage
        }
      , Cmd.none
      )
    Just languageSpec ->
      let
        (language, loadCmd) = loadLangauge 0 languageSpec
      in
        ( { activeLanguageIndex = 0
          , activeLanguage = language
          }
        , loadCmd
        )


type alias LanguageMetadata =
  { name : String
  , description : String
  , priority : Int  -- how early in the list it should appear
  }

type alias Language =
  { metadata : LanguageMetadata
  , generator : Random.Generator String
  }

emptyLanguage : Language
emptyLanguage =
  { metadata =
      { name = "Empty Language"
      , description = "An empty language"
      , priority = -1
      }
  , generator = Random.constant ""
  }

loadingLanguage : Language
loadingLanguage =
  { metadata =
      { name = "Loading..."
      , description = "Loading..."
      , priority = -1
      }
  , generator = Random.constant "Loading..."
  }



-- UPDATE


type Msg
  = SelectLanguage Int LanguageSpec
  | LoadedLanguage Int Language

update : Msg -> Model -> (Model, Cmd Msg)
update msg ({ activeLanguageIndex, activeLanguage } as model) =
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


type alias LanguageSpec =
  { metadata : LanguageMetadata
  , setupData : LanguageSetup
  }

type LanguageSetup
  = PcfgLanguageSetup
      { generator : Random.Generator String }
  | MarkovLanguageSetup
      { filePath : String }

emptyLanguageSpec : LanguageSpec
emptyLanguageSpec =
  { metadata = emptyLanguage.metadata
  , setupData = PcfgLanguageSetup { generator = emptyLanguage.generator }
  }


allLanguageSpecs : List LanguageSpec
allLanguageSpecs =
  List.sortBy (\languageSpec -> languageSpec.metadata.priority)
    <| List.concat
      [ List.map fromPcfgSpec Manifest.pcfgLanguages
      , List.map fromMarkovSpec Manifest.markovLanguages
      ]

fromPcfgSpec : Pcfg.Language -> LanguageSpec
fromPcfgSpec pcfgLanguage =
  { metadata =
      { name = pcfgLanguage.name ++ " (PCFG)"
      , description = pcfgLanguage.description
      , priority = pcfgLanguage.priority
      }
  , setupData = PcfgLanguageSetup { generator = pcfgLanguage.generator () }
  }

fromMarkovSpec : Manifest.MarkovLanguageSpec -> LanguageSpec
fromMarkovSpec markovSpec =
  { metadata =
      { name = markovSpec.name ++ " (Markov)"
      , description = markovSpec.description
      , priority = markovSpec.priority
      }
  , setupData = MarkovLanguageSetup { filePath = markovSpec.filePath }
  }


loadLangauge : Int -> LanguageSpec -> (Language, Cmd Msg)
loadLangauge index { metadata, setupData } =
  case setupData of
    PcfgLanguageSetup { generator } ->
      ( { metadata = metadata
        , generator = generator
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
                      Markov.generatorFromExamples
                        <| String.words
                        <| Result.withDefault "" spaceSeparatedExamples
                  })
          }
      )



-- VIEW


viewSettings : Model -> Html Msg
viewSettings { activeLanguageIndex, activeLanguage } =
  Html.select
    [ Events.onInput
        (\indexString ->
          let
            index = Maybe.withDefault 0 <| String.toInt indexString
          in
            SelectLanguage index
              <| Maybe.withDefault emptyLanguageSpec
              <| List.Extra.getAt index allLanguageSpecs)
    , Attr.class "language-selector"
    , Attr.title activeLanguage.metadata.description
    , Attr.value <| String.fromInt activeLanguageIndex
    ]
    <| List.indexedMap languageOption allLanguageSpecs

languageOption : Int -> LanguageSpec -> Html Msg
languageOption index languageSpec =
  Html.option
    [ Attr.value <| String.fromInt index ]
    [ Html.text languageSpec.metadata.name ]
