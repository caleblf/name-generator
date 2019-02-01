import Browser
import Html exposing (Html)
import Html.Events
import Html.Attributes
import Random
import Dict
import Set exposing (Set)

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
  , activeTransforms : Set String
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( { names = []
    , toGenerate = 10
    , selectedLanguage = Manifest.defaultLanguage
    , activeTransforms = Set.empty
    }
  , Cmd.none
  )



-- UPDATE


type Msg
  = Generate
  | NewNames (List String)
  | SelectLanguage String
  | ToggleTransformTo String Bool
  | SetAmount Int


update : Msg -> Model -> (Model, Cmd Msg)
update msg ({ names, toGenerate, selectedLanguage, activeTransforms } as model) =
  case msg of
    Generate ->
      ( model
      , Random.generate NewNames
          <| Random.list toGenerate
          <| Generator.applyTransforms
              (List.filter
                (.name >>
                  (\transformName ->
                    Set.member transformName activeTransforms))
                Manifest.transforms)
              selectedLanguage
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
    ToggleTransformTo transformName active ->
      ( { model
        | activeTransforms =
            (if active then Set.insert else Set.remove)
              transformName
              activeTransforms
        }
      , Cmd.none
      )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view { names, toGenerate, selectedLanguage, activeTransforms } =
  Html.div [ Html.Attributes.class "container" ]
    [ Html.h1 [] [ Html.text "Fantasy Name Generator by Iguanotron" ]
    , Html.button [ Html.Events.onClick Generate ] [ Html.text "Generate" ]
    , Html.div [ Html.Attributes.class "column-container" ]
        [ Html.div [ Html.Attributes.class "column" ]
            [ Html.div [ Html.Attributes.class "settings-panel" ]
              [ amountSelector toGenerate
              , languageSelector selectedLanguage.name
              , transformSelector
                  <| List.map
                    (.name >>
                      (\transformName ->
                        ( transformName
                          , Set.member transformName activeTransforms
                        )))
                    Manifest.transforms
              ]
            ]
        , Html.div [ Html.Attributes.class "column" ]
            [ namesPanel names
            ]
        ]
    ]


namesPanel : List String -> Html Msg
namesPanel =
  Html.div [ Html.Attributes.class "names-panel" ]
    << List.map (Html.div [] << List.singleton << Html.text)


amountSelector : Int -> Html Msg
amountSelector amount =
  Html.input
    [ Html.Attributes.type_ "number"
    , Html.Attributes.min "1"
    , Html.Attributes.max "512"
    , Html.Attributes.placeholder "1"
    , Html.Attributes.value <| String.fromInt amount
    , Html.Events.onInput
        <| String.toInt >> Maybe.withDefault 0 >> SetAmount
    ]
    []


languageSelector : String -> Html Msg
languageSelector activeLanguageName =
  Html.select
    [ Html.Events.onInput SelectLanguage
    , Html.Attributes.class "language-selector"
    ]
    <| List.map
        (.name >> Html.text >> List.singleton >> Html.option [])
        Manifest.languages

languageOption : Language.Language -> Html Msg
languageOption language =
  Html.option
    [ Html.Attributes.value language.name ]
    [ Html.text language.name ]


transformSelector : List (String, Bool) -> Html Msg
transformSelector transformState =
  Html.div [ Html.Attributes.class "transform-selector" ]
    <| List.map transformEntry transformState

transformEntry : (String, Bool) -> Html Msg
transformEntry (transformName, active) =
  Html.div [ Html.Attributes.class "transform-entry" ]
    [ Html.label []
        [ Html.input
            [ Html.Attributes.type_ "checkbox"
            , Html.Attributes.checked active
            , Html.Events.onCheck <| ToggleTransformTo transformName
            ]
            []
        , Html.text transformName
        ]
    ]

