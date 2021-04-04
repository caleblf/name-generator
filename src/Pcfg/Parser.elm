module Pcfg.Parser exposing (PcfgSpecification, pcfgSpecification)

import Parser exposing (Parser, (|.), (|=))
import Dict exposing (Dict)
import Set exposing (Set)
import List
import Tuple
import Char
import List.Extra

import CommonParser exposing (header, lineEnd, newLine, spaces, number, stringLiteral)
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



-- FORM DEFINITIONS


definitions : Parser (Dict String Form)
definitions =
  Parser.loop
    []
    (\formDefinitions ->
      Parser.oneOf
        [ Parser.succeed (\definition -> Parser.Loop (definition :: formDefinitions))
            |= formDefinition
        , Parser.map (\_ -> Parser.Loop formDefinitions) newLine
        , Parser.succeed <| Parser.Done formDefinitions
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
        , Parser.succeed <| Parser.Done entries
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
