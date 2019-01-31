import Browser
import Html exposing (Html)
import Html.Events
import Html.Attributes
import Random
import Dict

import Language
import Generator
import Manifest


-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL


type alias Model =
  { names : List String
  , toGenerate : Int
  , selectedLanguage : Language.Language
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( { names = []
    , toGenerate = 10
    , selectedLanguage = Manifest.defaultLanguage
    }
  , Cmd.none
  )



-- UPDATE


type Msg
  = Generate
  | NewNames (List String)
  | SelectLanguage String
  | SetAmount Int


update : Msg -> Model -> (Model, Cmd Msg)
update msg ({ names, toGenerate, selectedLanguage } as model) =
  case msg of
    Generate ->
      ( model
      , Random.generate NewNames <| Generator.nameList toGenerate selectedLanguage
      )
    NewNames newNames ->
      ( { model | names = newNames }
      , Cmd.none
      )
    SelectLanguage languageName ->
      ( case Dict.get languageName Manifest.languagesByName of
          Nothing -> model
          Just language -> { model | selectedLanguage = language }
      , Cmd.none
      )
    SetAmount newAmount ->
      ( { model | toGenerate = newAmount }
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  Html.div []
    [ viewNames model.names
    , Html.button [ Html.Events.onClick Generate ] [ Html.text "Generate" ]
    , amountSelector model.toGenerate
    , viewLanguageSelector model.selectedLanguage.name
    ]


viewNames : List String -> Html Msg
viewNames =
  Html.div []
    << List.map (Html.div [] << List.singleton << Html.text)


amountSelector : Int -> Html Msg
amountSelector amount =
  Html.input
    [ Html.Attributes.type_ "number"
    , Html.Attributes.min "1"
    , Html.Attributes.max "512"
    , Html.Attributes.placeholder "1"
    , Html.Attributes.value <| String.fromInt amount
    , Html.Events.onInput <| String.toInt >> Maybe.withDefault 0 >> SetAmount
    ]
    []


viewLanguageSelector : String -> Html Msg
viewLanguageSelector activeLanguageName =
  Html.select [ Html.Events.onInput SelectLanguage ]
    <| List.map (.name >> Html.text >> List.singleton >> Html.option []) Manifest.languages

languageOption : Language.Language -> Html Msg
languageOption language =
  Html.option [ Html.Attributes.value language.name ] [ Html.text language.name ]
