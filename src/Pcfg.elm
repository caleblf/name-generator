module Pcfg exposing (..)

import Dict exposing (Dict)
import Maybe
import Parser exposing (Parser, (|=), (|.))
import Random
import Set
import String

import Pcfg.Grammar exposing (Form, Pcfg, PcfgTransform)
import Pcfg.Parser


-- PARSERS WITH VALIDATION


languageGeneratorParser : String -> Parser (Random.Generator String)
languageGeneratorParser rootTag =
  Pcfg.Parser.definitions
    |> Parser.andThen
        (\definitions ->
            case Dict.get rootTag definitions of
              Nothing ->
                Parser.problem ("Root tag not defined: " ++ rootTag)
              Just rootForm ->
                case
                  Pcfg.Grammar.freeTagsInDefinitions definitions
                    |> Set.toList
                of
                  [] ->  -- no references to undefined tags
                    Parser.succeed 
                      <| Pcfg.Grammar.languageGenerator
                          { formsByTag = definitions
                          , rootForm = rootForm
                          }
                  unrecognizedTags ->
                    Parser.problem
                      ("References to unrecognized tags: "
                        ++ String.join ", " unrecognizedTags)
        )


transformGeneratorParser : String -> String -> Parser (Random.Generator String -> Random.Generator String)
transformGeneratorParser inputTag outputTag =
  Pcfg.Parser.definitions
    |> Parser.andThen
        (\definitions ->
            case Dict.get outputTag definitions of
              Nothing ->
                Parser.problem ("Root tag not defined: " ++ outputTag)
              Just rootForm ->
                case
                  Set.remove
                    inputTag
                    (Pcfg.Grammar.freeTagsInDefinitions definitions)
                    |> Set.toList
                of
                  [] ->  -- no references to undefined tags
                    Parser.succeed
                      <| Pcfg.Grammar.transformGenerator
                          { formsByTag = definitions
                          , rootForm = rootForm
                          , inputTag = inputTag
                          }
                  unrecognizedTags ->
                    Parser.problem
                      ("References to unrecognized tags: "
                        ++ String.join ", " unrecognizedTags)
        )
