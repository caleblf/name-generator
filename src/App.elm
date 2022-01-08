module App exposing (..)

import Browser
import Html exposing (Html)
import Html.Lazy as Lazy
import Html.Attributes as Attr
import Random

import Manifest exposing (Manifest)
import NameGenerator
import Language
import Transform


-- MODEL


type alias Model =
  { generatorModel : NameGenerator.Model  -- app/generation state
  , languageModel : Language.Model  -- either a PCFG or Markov model
  , transformsModel : Transform.Model  -- a PCFG model, separate
  }


init : Manifest -> (Model, Cmd Msg)
init manifest =
  let
    (languageModel, languageCmd) = Language.init manifest.languageGroups
    (transformsModel, transformsCmd) = Transform.init manifest.transforms
    (generatorModel, generatorCmd) = NameGenerator.init
  in
    ( { generatorModel = generatorModel
      , languageModel = languageModel
      , transformsModel = transformsModel
      }
    , Cmd.batch
        [ Cmd.map GeneratorMsg generatorCmd
        , Cmd.map LanguageMsg languageCmd
        , Cmd.map TransformMsg transformsCmd
        ]
    )



-- UPDATE


type Msg
  = GeneratorMsg NameGenerator.Msg
  | LanguageMsg Language.Msg
  | TransformMsg Transform.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg ({ generatorModel, languageModel, transformsModel } as model) =
  case msg of
    GeneratorMsg generatorMsg ->
      let
        generator : Random.Generator String
        generator =
          Transform.applyTransforms transformsModel
          <| Random.map capitalize
          <| Language.languageGenerator languageModel
        (newGeneratorModel, generatorCmd) =
          NameGenerator.updateFrom generator generatorMsg generatorModel
      in
        ( { model | generatorModel = newGeneratorModel }
        , Cmd.map GeneratorMsg generatorCmd
        )
    LanguageMsg languageMsg ->
      let
        (newLanguageModel, languageCmd) =
          Language.update languageMsg languageModel
      in
        ( { model | languageModel = newLanguageModel }
        , Cmd.map LanguageMsg languageCmd
        )
    TransformMsg transformsMsg ->
      let
        (newTransformModel, transformsCmd) =
          Transform.update transformsMsg transformsModel
      in
        ( { model | transformsModel = newTransformModel }
        , Cmd.map TransformMsg transformsCmd
        )


capitalize : String -> String
capitalize string =
  String.toUpper (String.left 1 string) ++ String.dropLeft 1 string



-- VIEW

view : Model -> Html Msg
view { generatorModel, languageModel, transformsModel } =
  NameGenerator.viewApp GeneratorMsg
    generatorModel
    [ Html.map LanguageMsg
        <| Lazy.lazy Language.viewSettings languageModel
    , Html.map TransformMsg
        <| Lazy.lazy Transform.viewSettings transformsModel
    ]
