import Browser
import Html exposing (Html)
import Html.Events
import Html.Attributes
import Random
import Dict

import Language
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
  { name : String
  , selectedLanguage : Language.Language
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( { name = "..."
    , selectedLanguage = Manifest.defaultLanguage
    }
  , Cmd.none
  )



-- UPDATE


type Msg
  = Generate
  | NewName String
  | SelectLanguage String


update : Msg -> Model -> (Model, Cmd Msg)
update msg ({ name, selectedLanguage } as model) =
  case msg of
    Generate ->
      ( model
      , Random.generate NewName <| selectedLanguage.generator ()
      )
    NewName newName ->
      ( { model | name = capitalize newName }
      , Cmd.none
      )
    SelectLanguage languageName ->
      ( case Dict.get languageName Manifest.languagesByName of
          Nothing -> model
          Just language -> { model | name = "...", selectedLanguage = language }
      , Cmd.none
      )

capitalize : String -> String
capitalize string =
  String.toUpper (String.left 1 string) ++ String.dropLeft 1 string


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  Html.div []
    [ Html.h1 [] [ Html.text model.name ]
    , Html.button [ Html.Events.onClick Generate ] [ Html.text "Generate" ]
    , viewLanguageSelector model.selectedLanguage.name
    ]


viewLanguageSelector : String -> Html Msg
viewLanguageSelector activeLanguageName =
  Html.select [ Html.Events.onInput SelectLanguage ]
    <| List.map (.name >> Html.text >> List.singleton >> Html.option []) Manifest.languages

languageOption : Language.Language -> Html Msg
languageOption language =
  Html.option [ Html.Attributes.value language.name ] [ Html.text language.name ]
