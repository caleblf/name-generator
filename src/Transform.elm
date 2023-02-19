module Transform exposing (Model, Msg, TransformSpec, applyTransforms, init, update, viewSettings)

import Dict exposing (Dict)
import GeneratorParser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import List
import Loading
import Parser
import ParserError
import Random



-- INTERFACE


applyTransforms : Model -> Random.Generator String -> Random.Generator String
applyTransforms { transformSpecs, transformStates } generator =
    let
        transforms : List Transform
        transforms =
            List.filterMap identity <|
                List.indexedMap
                    (\index _ ->
                        Maybe.andThen
                            (\{ active, maybeTransform } ->
                                if active then
                                    maybeTransform

                                else
                                    Nothing
                            )
                            (Dict.get index transformStates)
                    )
                    transformSpecs
    in
    List.foldl identity generator transforms



-- MODEL


type alias Model =
    { transformSpecs : List TransformSpec
    , transformStates : Dict Int TransformState -- by index in transformSpecs
    }


type alias TransformState =
    { active : Bool
    , maybeTransform : Maybe Transform -- Nothing if not loaded yet
    }


init : List TransformSpec -> ( Model, Cmd Msg )
init transformSpecs =
    let
        sortedTransformSpecs =
            List.sortBy .priority transformSpecs
    in
    ( { transformSpecs = sortedTransformSpecs
      , transformStates =
            Dict.fromList <|
                List.indexedMap
                    (\index _ ->
                        ( index, { active = False, maybeTransform = Nothing } )
                    )
                    sortedTransformSpecs
      }
    , loadTransforms sortedTransformSpecs
    )


type alias Transform =
    Random.Generator String -> Random.Generator String



-- UPDATE


type Msg
    = ToggleTransformAtIndexTo Int Bool
    | LoadedTransform Int Transform


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ transformStates } as model) =
    case msg of
        ToggleTransformAtIndexTo index activeState ->
            ( { model
                | transformStates =
                    Dict.update index
                        (\maybeState ->
                            case maybeState of
                                Nothing ->
                                    maybeState

                                -- Can't happen
                                Just state ->
                                    Just { state | active = activeState }
                        )
                        transformStates
              }
            , Cmd.none
            )

        LoadedTransform index transform ->
            ( { model
                | transformStates =
                    Dict.update index
                        (\maybeState ->
                            case maybeState of
                                Nothing ->
                                    maybeState

                                -- Can't happen
                                Just state ->
                                    Just { state | maybeTransform = Just transform }
                        )
                        transformStates
              }
            , Cmd.none
            )



-- TRANSFORM MANIFEST


type alias TransformSpec =
    { name : String
    , description : String
    , priority : Int -- how early it should be applied (smallest first)
    , url : String
    }


loadTransforms : List TransformSpec -> Cmd Msg
loadTransforms transformSpecs =
    Cmd.batch <|
        List.indexedMap
            (\index transformSpec ->
                loadTransformFromUrl transformSpec.url
                    |> Cmd.map
                        (\transform ->
                            LoadedTransform index transform
                        )
            )
            transformSpecs


loadTransformFromUrl : String -> Cmd Transform
loadTransformFromUrl url =
    let
        handleResponse body =
            case Parser.run GeneratorParser.transform body of
                Ok transform ->
                    transform

                Err deadEnds ->
                    (always << Random.constant) <|
                        String.concat
                            [ "Error parsing "
                            , url
                            , ": "
                            , ParserError.deadEndsToString deadEnds
                            ]
    in
    Loading.loadFromUrl
        url
        { handleResponse = handleResponse
        , handleErrorMessage = always << Random.constant
        }



-- VIEW


viewSettings : Model -> Html Msg
viewSettings { transformSpecs, transformStates } =
    Html.div [ Attr.class "transform-selector" ] <|
        List.indexedMap (transformToggle transformStates) transformSpecs


transformToggle : Dict Int TransformState -> Int -> TransformSpec -> Html Msg
transformToggle transformStates index transformSpec =
    Html.div
        [ Attr.class "transform-entry" ]
        [ Html.label
            [ Attr.title transformSpec.description ]
            [ Html.input
                [ Attr.type_ "checkbox"
                , Attr.checked <|
                    .active <|
                        Maybe.withDefault
                            -- Won't happen
                            { active = False
                            , maybeTransform = Nothing
                            }
                        <|
                            Dict.get index transformStates
                , Events.onCheck <| ToggleTransformAtIndexTo index
                ]
                []
            , Html.text transformSpec.name
            ]
        ]
