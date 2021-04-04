module Pcfg.Parser exposing (PcfgSpecification, pcfgSpecification)

import Parser exposing (Parser, (|.), (|=))
import Dict exposing (Dict)
import Set exposing (Set)
import List
import Tuple
import Char

import List.Extra

import Pcfg.Grammar exposing (Form(..), Pcfg, PcfgTransform)


-- PARSER


type alias PcfgSpecification =
  { header : Dict String String
  , definitions : Dict String Form
  }


pcfgSpecification : Parser PcfgSpecification
pcfgSpecification =
  Parser.succeed PcfgSpecification
    |= header
    |= definitions



-- HEADER


headerField : Parser ( String, String )
headerField =
  Parser.succeed Tuple.pair
    |. Parser.symbol "!"
    |= Parser.variable
        { start = Char.isLower
        , inner = \c -> Char.isAlphaNum c || c == '_'
        , reserved = Set.empty
        }
    |. Parser.symbol ":"
    |. spaces
    |= (Parser.map String.trim
          (Parser.getChompedString
            <| Parser.chompWhile (\c -> c /= '\n' && c /= '#')))


header : Parser (Dict String String)
header =
  Parser.loop
    []
    (\headerFields ->
      Parser.oneOf
        [ Parser.succeed (\field -> Parser.Loop (field :: headerFields))
            |= headerField
        , Parser.map (\_ -> Parser.Loop headerFields) newLine
        , Parser.succeed ()
            |> Parser.map (\_ -> Parser.Done headerFields)
        ])
    |> Parser.andThen
        (\headerFields ->
          if List.Extra.allDifferent <| List.map Tuple.first headerFields
          then Parser.succeed <| Dict.fromList headerFields
          else Parser.problem "header must not contain duplicate fields")



-- FORM DEFINITIONS


definitions : Parser (Dict String Form)
definitions =
  Parser.loop
    []
    (\formDefinitions ->
      Parser.oneOf
        [ Parser.succeed (\definition -> Parser.Loop (definition :: formDefinitions))
            |= formDefinition
        , Parser.succeed ()
            |. newLine
            |> Parser.map (\_ -> Parser.Loop formDefinitions)
        , Parser.succeed ()
            |> Parser.map (\_ -> Parser.Done formDefinitions)
        ])
    |> Parser.andThen
        (\formDefinitions ->
          if List.Extra.allDifferent <| List.map Tuple.first formDefinitions
          then Parser.succeed <| Dict.fromList formDefinitions
          else Parser.problem "forms may only be defined once")


formDefinition : Parser ( String, Form )
formDefinition =
  Parser.succeed Tuple.pair
    |= Parser.variable
        { start = Char.isLower
        , inner = \c -> Char.isAlphaNum c || c == '-'
        , reserved = Set.empty
        }
    |. Parser.symbol ":"
    |. spaces
    |= Parser.oneOf
        [ Parser.succeed identity
            |= formExpression
            |. lineEnd
        , Parser.succeed identity
            |. newLine
            |= unionForm
        ]


formExpression : Parser Form
formExpression =
  Parser.oneOf
    [ variableForm
    , concatenationForm
    , quotedLiteralForm
    , unquotedLiteralForm
    ]


variableForm : Parser Form
variableForm =
  Parser.succeed VariableForm
    |. Parser.symbol "$"
    |= Parser.variable
        { start = Char.isLower
        , inner = \c -> Char.isAlphaNum c || c == '-'
        , reserved = Set.empty
        }


concatenationForm : Parser Form
concatenationForm =
  Parser.succeed ConcatenationForm
    |. Parser.symbol "["
    |= Parser.loop
        { sequenceState = AwaitingElement
        , revForms = []
        }
        (\({ sequenceState, revForms } as state) ->
          Parser.oneOf
            ((case sequenceState of
              AwaitingElement ->
                Parser.succeed
                  (\form ->
                    Parser.Loop
                      { sequenceState = AwaitingSeparator
                      , revForms = form :: revForms
                      })
                  |. spaces
                  |= simpleFormExpression
              AwaitingSeparator ->
                Parser.token " "
                  |. spaces
                  |> Parser.map
                      (\_ ->
                        Parser.Loop
                          { state | sequenceState = AwaitingElement }))
              :: [ spaces
                    |. Parser.symbol "]"
                    |> Parser.map (\_ -> Parser.Done (List.reverse revForms))
              ]))

type SequenceParsingState
  = AwaitingElement
  | AwaitingSeparator

simpleFormExpression : Parser Form
simpleFormExpression =
  Parser.oneOf
    [ variableForm
    , quotedLiteralForm
    , unquotedLiteralForm
    ]


quotedLiteralForm : Parser Form
quotedLiteralForm =
  Parser.succeed LiteralForm
    |= stringLiteral

allowedUnquotedPunctuation =
  Set.fromList <| String.toList "-'_"

unquotedLiteralForm : Parser Form
unquotedLiteralForm =
  (Parser.getChompedString
    <| Parser.chompWhile
        (\c -> Char.isAlpha c || Set.member c allowedUnquotedPunctuation))
    |> Parser.andThen
        (\string ->
          if String.isEmpty string
          then Parser.problem "An unquoted literal form may not be empty"
          else Parser.succeed <| LiteralForm string)


unionForm : Parser Form
unionForm =
  Parser.loop
    []
    (\entries ->
      Parser.oneOf
        [ Parser.token "  "
            |> Parser.andThen
                (\_ ->
                  Parser.oneOf
                    [ Parser.succeed (\entry -> Parser.Loop (entry :: entries))
                        |= unionFormEntry
                        |. newLine
                    , Parser.map (\_ -> Parser.Loop entries) newLine
                    ]
                )
        , Parser.map (\_ -> Parser.Loop entries) newLine
        , Parser.succeed ()
            |> Parser.map (\_ -> Parser.Done entries)
        ])
    |> Parser.andThen
        (\weightedForms ->
          if List.isEmpty weightedForms
          then
            Parser.problem
            "at least one clause is necessary in a weighted union form"
          else Parser.succeed <| UnionForm weightedForms)

unionFormEntry : Parser ( Float, Form )
unionFormEntry =
  Parser.oneOf
    [ Parser.succeed Tuple.pair
        |= number
        |. spaces
        |= formExpression
    , formExpression
        |> Parser.map (\form -> (1.0, form))
    ]



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
spaces = Parser.chompWhile (\c -> c == ' ')


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
            Just float -> Parser.succeed float
            Nothing ->
              Parser.problem ("Invalid weight")
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
                  |. Parser.chompWhile (\c -> c /= '"' && c /= '\\'))
                |> Parser.map (\chunk -> Parser.Loop (string ++ chunk)) 
            ])

