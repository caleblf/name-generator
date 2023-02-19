module Loading exposing (..)

import Http


loadFromUrl : String -> { handleResponse : String -> a, handleErrorMessage : String -> a } -> Cmd a
loadFromUrl url { handleResponse, handleErrorMessage } =
    Http.get
        { url = url
        , expect =
            Http.expectString
                (\result ->
                    case result of
                        Ok body ->
                            handleResponse body

                        Err httpError ->
                            handleErrorMessage <|
                                "Error accessing "
                                    ++ url
                                    ++ "; "
                                    ++ httpErrorString httpError
                )
        }


httpErrorString : Http.Error -> String
httpErrorString error =
    case error of
        Http.BadUrl url ->
            "Bad URL: " ++ url

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network Error"

        Http.BadStatus status ->
            "Got status: " ++ String.fromInt status

        Http.BadBody body ->
            "Unexpected response body: " ++ body
