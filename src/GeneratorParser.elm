module GeneratorParser exposing (language, transform)

import Parser exposing (Parser, (|.), (|=))
import Dict exposing (Dict)
import Set exposing (Set)
import List
import Tuple
import Char
import Random

import List.Extra

import Markov
import Pcfg
import CommonParser


-- PARSERS


language : Parser (Random.Generator String)
language =
  CommonParser.header
    |> Parser.andThen languageBodyParser


transform : Parser (Random.Generator String -> Random.Generator String)
transform =
  CommonParser.header
    |> Parser.andThen transformBodyParser



-- CONTEXT DETECTION AND BODY PARSING


languageTypes : Set String
languageTypes =
  Set.fromList
    [ "pcfg-language"
    , "markov"
    ]

transformTypes : Set String
transformTypes =
  Set.fromList [ "pcfg-transform" ]


languageBodyParser : Dict String String -> Parser (Random.Generator String)
languageBodyParser metadata =
  case Dict.get "type" metadata of
    Nothing ->
      Parser.problem "header missing required field: type"
    Just "pcfg-language" ->
      requiredHeaderField "pcfg-language" "root" metadata
        |> Parser.andThen Pcfg.languageGeneratorParser
    Just "markov" ->
      Dict.get "ending-length" metadata
        |> Maybe.andThen String.toInt
        |> Maybe.withDefault 1
        |> Markov.generatorParser
    Just unrecognizedType ->
      Parser.problem
        <|
          if Set.member unrecognizedType transformTypes
          then
            "expected a language, but type was " ++ unrecognizedType
          else
            "unrecognized type in header: " ++ unrecognizedType


transformBodyParser : Dict String String -> Parser (Random.Generator String -> Random.Generator String)
transformBodyParser metadata =
  case Dict.get "type" metadata of
    Nothing ->
      Parser.problem "header missing required field: type"
    Just "pcfg-transform" ->
        requiredHeaderField "pcfg-transform" "input" metadata
        |> Parser.andThen
            (\inputTag ->
                requiredHeaderField "pcfg-transform" "output" metadata
                  |> Parser.andThen
                      (\outputTag ->
                          Pcfg.transformGeneratorParser inputTag outputTag
                      )
            )
    Just unrecognizedType ->
      Parser.problem
        <|
          if Set.member unrecognizedType languageTypes
          then
            "expected a transform, but type was " ++ unrecognizedType
          else
            "unrecognized type in header: " ++ unrecognizedType



requiredHeaderField : String -> String -> Dict String String -> Parser String
requiredHeaderField specificationType fieldName metadata =
  case Dict.get fieldName metadata of
    Nothing ->
      Parser.problem
        <| "header missing required field for type "
            ++ specificationType
            ++ ": "
            ++ fieldName
    Just value ->
      Parser.succeed value
