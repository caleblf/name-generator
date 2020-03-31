module Markov exposing (generatorFromExamples)

import Random

import Markov.Chain


generatorFromExamples : List String -> Random.Generator String
generatorFromExamples =
  Markov.Chain.buildProcess >> Markov.Chain.express
