module CommonParser exposing (header, lineEnd, newLine, number, spaces, stringLiteral)

import Char
import Dict exposing (Dict)
import List
import List.Extra
import Parser exposing ((|.), (|=), Parser)
import Set
import Tuple



-- HEADER


header : Parser (Dict String String)
header =
    Parser.loop
        []
        (\headerFields ->
            Parser.oneOf
                [ Parser.succeed (\field -> Parser.Loop (field :: headerFields))
                    |= headerField
                    |. newLine
                , Parser.map (\_ -> Parser.Loop headerFields) newLine
                , Parser.succeed <| Parser.Done headerFields
                ]
        )
        |> Parser.andThen
            (\headerFields ->
                if List.Extra.allDifferent <| List.map Tuple.first headerFields then
                    Parser.succeed <| Dict.fromList headerFields

                else
                    Parser.problem "header must not contain duplicate fields"
            )


headerField : Parser ( String, String )
headerField =
    Parser.succeed Tuple.pair
        |. Parser.symbol "!"
        |= Parser.variable
            { start = Char.isLower
            , inner = \c -> Char.isAlphaNum c || c == '_' || c == '-'
            , reserved = Set.empty
            }
        |. Parser.symbol ":"
        |. spaces
        |= Parser.map String.trim
            (Parser.getChompedString <|
                Parser.chompWhile (\c -> c /= '\n' && c /= '#')
            )



-- GENERIC ELEMENTS


lineEnd : Parser ()
lineEnd =
    spaces
        |. Parser.oneOf
            [ Parser.lineComment "#"
            , Parser.succeed ()
            ]


newLine : Parser ()
newLine =
    lineEnd
        |. Parser.symbol "\n"


spaces : Parser ()
spaces =
    Parser.chompWhile (\c -> c == ' ')



-- Parser for floats and ints that disallows scientific notation


number : Parser Float
number =
    Parser.chompIf Char.isDigit
        |. Parser.chompWhile Char.isDigit
        |. Parser.chompWhile (\c -> c == '.')
        |. Parser.chompWhile Char.isDigit
        |> Parser.getChompedString
        |> Parser.andThen
            (\chompedString ->
                case String.toFloat chompedString of
                    Just float ->
                        Parser.succeed float

                    Nothing ->
                        Parser.problem "Invalid weight"
            )


stringLiteral : Parser String
stringLiteral =
    Parser.succeed identity
        |. Parser.symbol "\""
        |= Parser.loop
            ""
            (\string ->
                Parser.oneOf
                    [ Parser.token "\\\""
                        |> Parser.map (\_ -> Parser.Loop (string ++ "\""))
                    , Parser.token "\\\\"
                        |> Parser.map (\_ -> Parser.Loop (string ++ "\\"))
                    , Parser.token "\""
                        |> Parser.map (\_ -> Parser.Done string)
                    , Parser.getChompedString
                        (Parser.chompIf (always True)
                            |. Parser.chompWhile (\c -> c /= '"' && c /= '\\')
                        )
                        |> Parser.map (\chunk -> Parser.Loop (string ++ chunk))
                    ]
            )
