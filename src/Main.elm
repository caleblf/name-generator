module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Lazy as Lazy
import Html.Attributes as Attr
import Random

import NameGeneratorApp
import Language
import Transform



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
  { generatorModel : NameGeneratorApp.Model  -- app/generation state
  , languageModel : Language.Model  -- either a PCFG or Markov model
  , transformsModel : Transform.Model  -- a PCFG model, separate
  }


init : () -> (Model, Cmd Msg)
init _ =
  let
    (languageModel, languageCmd) = Language.init
    (transformsModel, transformsCmd) = Transform.init
    (generatorModel, generatorCmd) = NameGeneratorApp.init
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
  = GeneratorMsg NameGeneratorApp.Msg
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
          NameGeneratorApp.updateFrom generator generatorMsg generatorModel
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW

view : Model -> Html Msg
view { generatorModel, languageModel, transformsModel } =
  Html.div [ Attr.class "container" ]
    [ header
    , NameGeneratorApp.viewApp GeneratorMsg
        generatorModel
        [ Html.map LanguageMsg
            <| Lazy.lazy Language.viewSettings languageModel
        , Html.map TransformMsg
            <| Lazy.lazy Transform.viewSettings transformsModel
        ]
    ]


header : Html Msg
header =
  Html.h1 [] [ Html.text "Fantasy Name Generator by Iguanotron" ]
