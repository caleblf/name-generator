import Browser
import Html exposing (Html)
import Html.Lazy as Lazy
import Html.Events as Events
import Html.Attributes as Attr
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
  , savedNames : List String
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( { names = []
    , toGenerate = 10
    , selectedLanguage = Manifest.defaultLanguage
    , activeTransforms = Set.empty
    , savedNames = []
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
  | SaveName String
  | ForgetNameIndex Int
  --| ClearSaved
  --| ExportSaved


update : Msg -> Model -> (Model, Cmd Msg)
update msg ({ names, toGenerate, selectedLanguage, activeTransforms, savedNames } as model) =
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
    ToggleTransformTo transformName active ->
      ( { model
        | activeTransforms =
            (if active then Set.insert else Set.remove)
              transformName
              activeTransforms
        }
      , Cmd.none
      )
    SetAmount newAmount ->
      ( { model | toGenerate = newAmount }
      , Cmd.none
      )
    SaveName name ->
      ( { model | savedNames = name::savedNames }
      , Cmd.none
      )
    ForgetNameIndex nameIndex ->
      ( { model | savedNames = removeAt nameIndex savedNames }
      , Cmd.none
      )


removeAt : Int -> List a -> List a
removeAt index xs =
  case xs of
    [] -> []
    y::ys ->
      if index > 0
      then (::) y <| removeAt (index - 1) ys
      else ys



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view { names, toGenerate, selectedLanguage, activeTransforms, savedNames } =
  Html.div [ Attr.class "container" ]
    [ Html.h1 [] [ Html.text "Fantasy Name Generator by Iguanotron" ]
    , Html.button [ Events.onClick Generate ] [ Html.text "Generate" ]
    , Html.div [ Attr.class "column-container" ]
        [ Html.div [ Attr.class "column" ]
            [ Html.div [ Attr.class "settings-panel" ]
              [ Lazy.lazy amountSelector toGenerate
              , Lazy.lazy languageSelector selectedLanguage.name
              , Lazy.lazy transformSelector
                  <| List.map
                    (.name >>
                      (\transformName ->
                        ( transformName
                          , Set.member transformName activeTransforms
                        )))
                    Manifest.transforms
              ]
            , Lazy.lazy savedNamesPanel savedNames
            ]
        , Html.div [ Attr.class "column" ]
            [ Lazy.lazy namesPanel names
            ]
        ]
    ]


savedNamesPanel : List String -> Html Msg
savedNamesPanel =
  Html.div [ Attr.class "saved-names-panel" ]
    << List.indexedMap
        (\index name ->
          Html.div
            [ Attr.class "saved-name" ]
            [ Html.button
                [ Attr.class "forget-name-button"
                , Events.onClick <| ForgetNameIndex index
                ]
                [ Html.text "X" ]
            , Html.text name
            ])


namesPanel : List String -> Html Msg
namesPanel =
  Html.div [ Attr.class "names-panel" ]
    << List.map
        (Html.div [ Attr.class "generated-name-entry" ]
          << List.singleton
          << (\name ->
              Html.span
                [ Attr.class "generated-name"
                , Events.onClick <| SaveName name
                ]
                [ Html.text name ]))


amountSelector : Int -> Html Msg
amountSelector amount =
  Html.input
    [ Attr.type_ "number"
    , Attr.min "1"
    , Attr.max "512"
    , Attr.placeholder "1"
    , Attr.value <| String.fromInt amount
    , Events.onInput
        <| String.toInt >> Maybe.withDefault 0 >> SetAmount
    ]
    []


languageSelector : String -> Html Msg
languageSelector activeLanguageName =
  Html.select
    [ Events.onInput SelectLanguage
    , Attr.class "language-selector"
    ]
    <| List.map
        (.name >> Html.text >> List.singleton >> Html.option [])
        Manifest.languages

languageOption : Language.Language -> Html Msg
languageOption language =
  Html.option
    [ Attr.value language.name ]
    [ Html.text language.name ]


transformSelector : List (String, Bool) -> Html Msg
transformSelector transformState =
  Html.div [ Attr.class "transform-selector" ]
    <| List.map transformEntry transformState

transformEntry : (String, Bool) -> Html Msg
transformEntry (transformName, active) =
  Html.div [ Attr.class "transform-entry" ]
    [ Html.label []
        [ Html.input
            [ Attr.type_ "checkbox"
            , Attr.checked active
            , Events.onCheck <| ToggleTransformTo transformName
            ]
            []
        , Html.text transformName
        ]
    ]

