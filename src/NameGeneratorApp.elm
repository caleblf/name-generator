module NameGeneratorApp exposing (..)

import Html exposing (Html)
import Html.Events as Events
import Html.Attributes as Attr
import Html.Lazy as Lazy
import File.Download as Download
import Random

import List.Extra



-- MODEL


type alias Model =
  { toGenerate : Int
  , names : List String
  , savedNames : List String
  }


init : (Model, Cmd Msg)
init =
  ( { toGenerate = 10
    , names = []
    , savedNames = []
    }
  , Cmd.none
  )



-- UPDATE


type Msg
  = Generate
  | NewNames (List String)
  | SetAmount Int
  | SaveName String
  | ForgetNameIndex Int
  | ClearSaved
  | ExportSaved


updateFrom : Random.Generator String -> Msg -> Model -> ( Model, Cmd Msg )
updateFrom generator msg ({ toGenerate, names, savedNames } as model) =
  case msg of
    Generate ->
      ( model
      , Random.generate NewNames
          <| Random.list toGenerate generator
      )
    NewNames newNames ->
      ( { model | names = List.filter (not << String.isEmpty) newNames }
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
      ( { model | savedNames = List.Extra.removeAt nameIndex savedNames }
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



-- VIEW


viewApp : (Msg -> msg) -> Model -> List (Html msg) -> Html msg
viewApp msgWrapper ({ toGenerate, names, savedNames } as model) settingsPanels =
  Html.div [ Attr.class "column-container" ]
    [ Html.div [ Attr.class "column" ]
        <| settingsPanels
            ++ [ Html.map msgWrapper <| Lazy.lazy savedNamesPanel savedNames ]
    , Html.map msgWrapper
        <| Html.div [ Attr.class "column" ]
          [ Lazy.lazy generatePanel toGenerate
          , Lazy.lazy namesPanel names
          ]
    ]


generatePanel : Int -> Html Msg
generatePanel toGenerate =
  Html.div
    [ Attr.class "row" ]
    [ generateButton
    , amountSelector toGenerate
    ]

generateButton : Html Msg
generateButton =
  Html.button
    [ Events.onClick Generate
    , Attr.class "generate-button"
    ]
    [ Html.text "Generate" ]

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


savedNamesPanel : List String -> Html Msg
savedNamesPanel names =
  Html.div [ Attr.class "saved-names-panel" ]
    (if List.isEmpty names
    then []
    else
      [ savedNamesList names
      , clearButton
      , exportSavedButton
      ])

clearButton : Html Msg
clearButton =
  Html.button
    [ Events.onClick ClearSaved
    , Attr.class "widget-button"
    ]
    [ Html.text "Clear" ]

exportSavedButton : Html Msg
exportSavedButton =
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
            [ Attr.class "saved-name-entry" ]
            [ forgetNameButton index
            , Html.div
                [ Attr.class "saved-name" ]
                [ Html.text name ]
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

