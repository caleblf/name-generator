module Markov exposing (generatorFromExamples)

import Random

import Markov.Chain


generatorFromExamples : List String -> Random.Generator String
generatorFromExamples =
  List.map String.toLower >> Markov.Chain.buildProcess >> Markov.Chain.express
