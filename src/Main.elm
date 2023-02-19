module Main exposing (main)

import App
import Browser
import Html exposing (Html)
import Json.Decode as Dec
import Loading
import Manifest exposing (Manifest)
import Result



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



-- MODEL


type Model
    = DisplayingText String
    | RunningApp App.Model


init : () -> ( Model, Cmd Msg )
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
    let
        handleResponse body =
            Dec.decodeString Manifest.decoder body
                |> Result.mapError
                    (\jsonError ->
                        "Failed to parse manifest: "
                            ++ Dec.errorToString jsonError
                    )
    in
    Loading.loadFromUrl
        url
        { handleResponse = handleResponse
        , handleErrorMessage = Err
        }



-- UPDATE


type Msg
    = LoadedManifest Manifest
    | FailedWithError String
    | AppMsg App.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LoadedManifest manifest, DisplayingText _ ) ->
            let
                ( appModel, appCmd ) =
                    App.init manifest
            in
            ( RunningApp appModel
            , Cmd.map AppMsg appCmd
            )

        ( AppMsg appMsg, RunningApp appModel ) ->
            let
                ( updatedAppModel, appCmd ) =
                    App.update appMsg appModel
            in
            ( RunningApp updatedAppModel
            , Cmd.map AppMsg appCmd
            )

        ( FailedWithError errorMessage, _ ) ->
            ( DisplayingText errorMessage, Cmd.none )

        _ ->
            ( DisplayingText "Illegal state", Cmd.none )



-- Should not happen
-- VIEW


view : Model -> Html Msg
view model =
    case model of
        DisplayingText text ->
            Html.text text

        RunningApp appModel ->
            Html.map AppMsg <| App.view appModel
