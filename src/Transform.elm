module Transform exposing (Model, Msg, init, update, viewSettings, applyTransforms)

import List
import List.Extra
import Random
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events

import Pcfg

import PcfgTransforms.Title
import PcfgTransforms.Profession
import PcfgTransforms.Domains



-- INTERFACE


applyTransforms : Model -> Random.Generator String -> Random.Generator String
applyTransforms ({ transformStates } as model) generator =
  let
    transforms : List Transform
    transforms =
      List.filterMap identity
        <| List.map
          (\(transform, active) ->
            if active then Just transform else Nothing)
        <| List.Extra.zip allTransforms transformStates
  in
    List.foldl .generatorTransform generator transforms



-- MODEL


type alias Model =
  { transformStates : List Bool } -- parallel to master transform list


init : (Model, Cmd msg)
init =
  ( { transformStates = List.repeat (List.length allTransforms) False }
  , Cmd.none
  )


type alias TransformMetadata =
  { name : String
  , description : String
  , priority : Int  -- how early in the list it should appear
  }

type alias Transform =
  { metadata : TransformMetadata
  , generatorTransform : Random.Generator String -> Random.Generator String
  }



-- UPDATE


type Msg
  = ToggleTransformAtIndexTo Int Bool

update : Msg -> Model -> (Model, Cmd Msg)
update msg ({ transformStates } as model) =
  case msg of
    ToggleTransformAtIndexTo index state ->
      ( { model
        | transformStates =
            List.Extra.setAt index state transformStates
        }
      , Cmd.none
      )


allTransforms : List Transform
allTransforms =
  List.sortBy (\transform -> transform.metadata.priority)
    <| List.map fromPcfgTransform pcfgTransforms


fromPcfgTransform : Pcfg.Transform -> Transform
fromPcfgTransform pcfgTransform =
  { metadata =
      { name = pcfgTransform.name
      , description = pcfgTransform.description
      , priority = pcfgTransform.priority
      }
  , generatorTransform = pcfgTransform.transform
  }

pcfgTransforms : List Pcfg.Transform
pcfgTransforms =
  List.sortBy .priority
    [ PcfgTransforms.Title.title
    , PcfgTransforms.Profession.profession
    , PcfgTransforms.Domains.domains
    ]


-- VIEW


viewSettings : Model -> Html Msg
viewSettings { transformStates } =
  Html.div [ Attr.class "transform-selector" ]
    <| List.indexedMap transformToggle
    <| List.Extra.zip allTransforms transformStates

transformToggle : Int -> (Transform, Bool) -> Html Msg
transformToggle index (transform, active) =
  Html.div
    [ Attr.class "transform-entry" ]
    [ Html.label
        [ Attr.title transform.metadata.description ]
        [ Html.input
            [ Attr.type_ "checkbox"
            , Attr.checked active
            , Events.onCheck <| ToggleTransformAtIndexTo index
            ]
            []
        , Html.text transform.metadata.name
        ]
    ]
