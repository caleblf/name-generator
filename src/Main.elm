import Browser
import Html exposing (Html)
import Html.Lazy as Lazy
import Html.Events as Events
import Html.Attributes as Attr
import File.Download as Download
import Random
import Dict
import Set exposing (Set)

import Pcfg exposing (Language, Transform)
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
  , selectedLanguage : Language
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
  | ClearSaved
  | ExportSaved


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
    ClearSaved ->
      ( { model | savedNames = [] }
      , Cmd.none
      )
    ExportSaved ->
      ( model
      , Download.string "names.txt" "text/plain" <| String.join "\n" savedNames
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
    [ header
    , Html.div [ Attr.class "column-container" ]
        [ Html.div [ Attr.class "column" ]
            [ Lazy.lazy3 settingsPanel toGenerate selectedLanguage activeTransforms
            , Lazy.lazy savedNamesPanel savedNames
            ]
        , Html.div [ Attr.class "column" ]
            [ generateButton
            , Lazy.lazy namesPanel names
            ]
        ]
    ]

header : Html Msg
header =
  Html.h1 [] [ Html.text "Fantasy Name Generator by Iguanotron" ]

generateButton : Html Msg
generateButton =
  Html.button
    [ Events.onClick Generate
    , Attr.class "generate-button"
    ]
    [ Html.text "Generate" ]


settingsPanel : Int -> Language -> Set String -> Html Msg
settingsPanel toGenerate selectedLanguage activeTransforms =
  Html.div [ Attr.class "settings-panel" ]
    [ Lazy.lazy amountSelector toGenerate
    , Lazy.lazy languageSelector selectedLanguage
    , Lazy.lazy transformSelector
        <| List.map
          (\transform ->
            ( transform
            , Set.member transform.name activeTransforms
            ))
          Manifest.transforms
    ]


savedNamesPanel : List String -> Html Msg
savedNamesPanel names =
  Html.div [ Attr.class "saved-names-panel" ]
    (if List.isEmpty names
    then []
    else
      [ Lazy.lazy savedNamesList names
      , clearButton
      , exportButton
      ])

clearButton : Html Msg
clearButton =
  Html.button
    [ Events.onClick ClearSaved
    , Attr.class "widget-button"
    ]
    [ Html.text "Clear" ]

exportButton : Html Msg
exportButton =
  Html.button
    [ Events.onClick ExportSaved
    , Attr.class "widget-button"
    ]
    [ Html.text "Download" ]


savedNamesList : List String -> Html Msg
savedNamesList =
  Html.div [ Attr.class "saved-names-list" ]
    << List.indexedMap
        (\index name ->
          Html.div
            [ Attr.class "saved-name" ]
            [ forgetNameButton index
            , Html.text name
            ])  

forgetNameButton : Int -> Html Msg
forgetNameButton index =
  Html.button
    [ Events.onClick <| ForgetNameIndex index
    , Attr.class "forget-name-button"
    ]
    [ Html.text "X" ]


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
    [ Attr.class "amount-selector"
    , Attr.type_ "number"
    , Attr.min "1"
    , Attr.max "512"
    , Attr.placeholder "1"
    , Attr.value <| String.fromInt amount
    , Events.onInput
        <| String.toInt >> Maybe.withDefault 0 >> SetAmount
    ]
    []


languageSelector : Language -> Html Msg
languageSelector activeLanguage =
  Html.select
    [ Events.onInput SelectLanguage
    , Attr.class "language-selector"
    , Attr.title activeLanguage.description
    ]
    <| List.map
        (.name >> Html.text >> List.singleton >> Html.option [])
        Manifest.languages

languageOption : Language -> Html Msg
languageOption language =
  Html.option
    [ Attr.value language.name ]
    [ Html.text language.name ]


transformSelector : List (Transform, Bool) -> Html Msg
transformSelector transformState =
  Html.div [ Attr.class "transform-selector" ]
    <| List.map transformEntry transformState

transformEntry : (Transform, Bool) -> Html Msg
transformEntry (transform, active) =
  Html.div
    [ Attr.class "transform-entry"
    , Attr.title transform.description
    ]
    [ Html.label []
        [ Html.input
            [ Attr.type_ "checkbox"
            , Attr.checked active
            , Events.onCheck <| ToggleTransformTo transform.name
            ]
            []
        , Html.text transform.name
        ]
    ]
