module Markov exposing (generatorFromExamples, generator)

import Parser exposing (Parser, (|=), (|.))
import Random
import Dict exposing (Dict)

import CommonParser exposing (header, lineEnd, newLine, spaces, number, stringLiteral)
import Markov.Chain


type alias MarkovSpecification =
  { header : Dict String String
  , examples : List String
  }


generatorFromExamples : Int -> List String -> Random.Generator String
generatorFromExamples endingLength =
  List.map String.toLower
    >> Markov.Chain.buildProcess endingLength
    >> Markov.Chain.express


generator : Parser (Random.Generator String)
generator =
  markovSpecification
    |> Parser.map
        (\{ header, examples } ->
          generatorFromExamples
            (Dict.get "ending-length" header
              |> Maybe.andThen String.toInt
              |> Maybe.withDefault 1
            )
            examples
        )


markovSpecification : Parser MarkovSpecification
markovSpecification =
  Parser.succeed MarkovSpecification
    |= header
    |= markovExamples


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
