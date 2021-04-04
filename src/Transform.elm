module Transform exposing (Model, Msg, init, update, viewSettings, applyTransforms)

import Dict exposing (Dict)
import List
import List.Extra
import Random
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Http
import Parser

import Pcfg
import ParserDebug



-- INTERFACE


applyTransforms : Model -> Random.Generator String -> Random.Generator String
applyTransforms { transformStates } generator =
  let
    transforms : List Transform
    transforms =
      List.filterMap identity
        <| List.indexedMap
            (\index transformSpec ->
              case Dict.get index transformStates of
                Just { active, maybeTransform } ->
                  if active then maybeTransform else Nothing
                Nothing -> Nothing -- won't happen
            )
            allTransformSpecs
  in
    List.foldl identity generator transforms



-- MODEL


type alias Model =
  { transformStates : Dict Int TransformState -- by index in allTransformSpecs
  }

type alias TransformState =
  { active : Bool
  , maybeTransform : Maybe Transform -- Nothing if not loaded yet
  }


init : (Model, Cmd Msg)
init =
  ( { transformStates =
        Dict.fromList
          <| List.indexedMap
              (\index transformSpec ->
                ( index, { active = False, maybeTransform = Nothing } )
              )
              allTransformSpecs
    }
  , loadAllTransforms
  )


type alias TransformMetadata =
  { name : String
  , description : String
  , priority : Int  -- how early it should be applied (smallest first)
  }

type alias Transform = Random.Generator String -> Random.Generator String



-- UPDATE


type Msg
  = ToggleTransformAtIndexTo Int Bool
  | LoadedTransform Int Transform

update : Msg -> Model -> (Model, Cmd Msg)
update msg ({ transformStates } as model) =
  case msg of
    ToggleTransformAtIndexTo index activeState ->
      ( { model
        | transformStates =
            Dict.update index
              (\maybeState ->
                case maybeState of
                  Nothing -> maybeState -- Can't happen
                  Just state -> Just { state | active = activeState }
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
                  Nothing -> maybeState -- Can't happen
                  Just state ->
                    Just { state | maybeTransform = Just transform }
              )
              transformStates
        }
      , Cmd.none
      )



-- TRANSFORM MANIFEST


type alias TransformSpec =
  { metadata : TransformMetadata
  , url : String
  }


allTransformSpecs : List TransformSpec
allTransformSpecs =
  List.sortBy (.metadata >> .priority)
    [ { metadata = 
        { name = "Title"
        , description = "Heroic titles"
        , priority = 1
        }
      , url = "transforms/title.pcfg"
      }
    , { metadata = 
        { name = "Profession"
        , description = "Medieval professions"
        , priority = 3
        }
      , url = "transforms/profession.pcfg"
      }
    , { metadata = 
        { name = "Divine Domain"
        , description = "Divine domains"
        , priority = 2
        }
      , url = "transforms/domain.pcfg"
      }
    ]


loadAllTransforms : Cmd Msg
loadAllTransforms =
  Cmd.batch
    <| List.indexedMap
        (\index transformSpec ->
          loadTransformFromUrl transformSpec.url
            |> Cmd.map
                (\transform ->
                  LoadedTransform index transform
                )
        )
        allTransformSpecs

loadTransformFromUrl : String -> Cmd Transform
loadTransformFromUrl url =
  Http.get
    { url = url
    , expect =
        Http.expectString
        (\result ->
          case result of
            Ok body ->
              case Parser.run Pcfg.transform body of
                Ok pcfgTransform -> pcfgTransform.transform
                Err deadEnds ->
                  (\_ ->
                    Random.constant
                      <| String.concat
                          [ "Error parsing "
                          , url
                          , ": "
                          , ParserDebug.deadEndsToString deadEnds
                          ])
            Err httpError ->
              (\_ -> Random.constant <| "Error accessing " ++ url)
        )
    }



-- VIEW


viewSettings : Model -> Html Msg
viewSettings { transformStates } =
  Html.div [ Attr.class "transform-selector" ]
    <| List.indexedMap (transformToggle transformStates) allTransformSpecs

transformToggle : Dict Int TransformState -> Int -> TransformSpec -> Html Msg
transformToggle transformStates index transformSpec =
  Html.div
    [ Attr.class "transform-entry" ]
    [ Html.label
        [ Attr.title transformSpec.metadata.description
        ]
        [ Html.input
            [ Attr.type_ "checkbox"
            , Attr.checked
                <| .active
                <| Maybe.withDefault -- Won't happen
                    { active = False
                    , maybeTransform = Nothing
                    }
                <| Dict.get index transformStates
            , Events.onCheck <| ToggleTransformAtIndexTo index
            ]
            []
        , Html.text transformSpec.metadata.name
        ]
    ]
