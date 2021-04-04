module Markov exposing (generatorFromExamples, generator)

import Parser exposing (Parser)
import Random

import Markov.Chain


generatorFromExamples : List String -> Random.Generator String
generatorFromExamples =
  List.map String.toLower >> Markov.Chain.buildProcess >> Markov.Chain.express


generator : Parser (Random.Generator String)
generator =
  Parser.map (String.words >> generatorFromExamples)
    <| Parser.getChompedString
    <| Parser.chompWhile (always True)
