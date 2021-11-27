module Markov exposing (generatorFromExamples, generatorParser)

import Parser exposing (Parser, (|=), (|.))
import Random
import Dict exposing (Dict)

import CommonParser exposing (lineEnd, newLine, spaces, number, stringLiteral)
import Markov.Chain



generatorFromExamples : Int -> List String -> Random.Generator String
generatorFromExamples endingLength =
  List.map String.toLower
    >> Markov.Chain.buildProcess endingLength
    >> Markov.Chain.express


generatorParser : Int -> Parser (Random.Generator String)
generatorParser endingLength =
  markovExamples
    |> Parser.map (generatorFromExamples endingLength)


markovExamples : Parser (List String)
markovExamples =
  Parser.loop
    []
    (\exampleBlocks ->
      Parser.oneOf
        [ Parser.succeed (\block -> Parser.Loop (block :: exampleBlocks))
            |= (Parser.map String.words
                <| Parser.getChompedString
                <| Parser.chompWhile (\c -> c /= '\n' && c /= '#'))
            |. newLine
        , Parser.map (\_ -> Parser.Loop exampleBlocks) newLine
        , Parser.succeed <| Parser.Done exampleBlocks
        ])
    |> Parser.map List.concat
