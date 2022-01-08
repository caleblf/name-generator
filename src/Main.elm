module Main exposing (main)

import Browser
import Result
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Json.Decode as Dec

import App
import Manifest exposing (Manifest)



-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = (\_ -> Sub.none)
    , view = view
    }



-- MODEL


type Model
  = DisplayingText String
  | RunningApp App.Model

init : () -> (Model, Cmd Msg)
init _ =
  ( DisplayingText ""
  , loadManifestFromUrl "manifest.json"
      |> Cmd.map
          (\manifestResult ->
            case manifestResult of
              Ok manifest ->
                LoadedManifest manifest
              Err errorMessage ->
                FailedWithError errorMessage
          )
  )


loadManifestFromUrl : String -> Cmd (Result String Manifest)
loadManifestFromUrl url =
  Http.get
    { url = url
    , expect =
        Http.expectString
        (\result ->
          case result of
            Ok body ->
              Dec.decodeString Manifest.decoder body
                |> Result.mapError
                    (\jsonError ->
                      "Failed to parse manifest: "
                      ++ Dec.errorToString jsonError
                    )
            Err httpError ->
              Err
                <| "Error accessing " ++ url
        )
    }



-- UPDATE


type Msg
  = LoadedManifest Manifest
  | FailedWithError String
  | AppMsg App.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (msg, model) of
    (LoadedManifest manifest, DisplayingText _) ->
      let
        (appModel, appCmd) = App.init manifest
      in
        ( RunningApp appModel
        , Cmd.map AppMsg appCmd
        )
    (AppMsg appMsg, RunningApp appModel) ->
      let
        (updatedAppModel, appCmd) = App.update appMsg appModel
      in
        ( RunningApp updatedAppModel
        , Cmd.map AppMsg appCmd
        )
    (FailedWithError errorMessage, _) ->
      (DisplayingText errorMessage, Cmd.none)
    _ ->
      (DisplayingText "Illegal state", Cmd.none)  -- Should not happen



-- VIEW

view : Model -> Html Msg
view model =
  Html.div [ Attr.class "container" ]
    [ header
    , case model of
        DisplayingText text ->
          Html.text text
        RunningApp appModel ->
          Html.map AppMsg <| App.view appModel
    ]


header : Html Msg
header =
  Html.h1 [] [ Html.text "Fantasy Name Generator by Iguanotron" ]
