module ParserDebug exposing (deadEndsToString)

import Parser exposing (Parser, Problem(..), DeadEnd)



deadEndsToString : List DeadEnd -> String
deadEndsToString deadEnds =
  String.join "\n"
    <| List.map
        (\{ row, col, problem } ->
          String.concat
            [ "row="
            , String.fromInt row
            , ", col="
            , String.fromInt col
            , ": "
            , case problem of
                Expecting string ->"Expecting: " ++ string
                ExpectingInt -> "Expecting Int"
                ExpectingHex -> "Expecting Hex"
                ExpectingOctal -> "Expecting Octal"
                ExpectingBinary -> "Expecting Binary"
                ExpectingFloat -> "Expecting Float"
                ExpectingNumber -> "Expecting Number"
                ExpectingVariable -> "Expecting Variable"
                ExpectingSymbol string -> "Expecting Symbol: " ++ string
                ExpectingKeyword string -> "Expecting Keyword: " ++ string
                ExpectingEnd -> "Expecting End"
                UnexpectedChar -> "Unexpected Char"
                Problem message -> message
                BadRepeat -> "BadRepeat"
            ]
        )
        deadEnds
