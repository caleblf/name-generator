module Pcfg exposing (..)

import Dict exposing (Dict)
import Maybe
import Parser exposing (Parser, (|=), (|.))
import Random
import Set
import String

import Pcfg.Grammar exposing (Form, Pcfg, PcfgTransform)
import Pcfg.Parser exposing (pcfgSpecification)


type alias Language =
  { name : String
  , description : String
  , generator : Random.Generator String
  }

type alias Transform =
  { name : String
  , description : String
  , transform : Random.Generator String -> Random.Generator String
  }



-- PARSERS WITH VALIDATION


language : Parser Language
language =
  pcfgSpecification
    |> Parser.andThen
        (\{ header, definitions } ->
          withHeaderFields
            [ "name", "description", "root" ]
            header
            |> Parser.andThen
                (\_ ->
                  let
                    name = getPresentHeaderField "name" header
                    description = getPresentHeaderField "description" header
                    rootTag = getPresentHeaderField "root" header
                  in
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
                              { name = name
                              , description = description
                              , generator =
                                  Pcfg.Grammar.languageGenerator
                                    { formsByTag = definitions
                                    , rootForm = rootForm
                                    }
                              }
                          unrecognizedTags ->
                            Parser.problem
                              ("References to unrecognized tags: "
                                ++ String.join ", " unrecognizedTags)
                )
        )

transform : Parser Transform
transform =
  pcfgSpecification
    |> Parser.andThen
        (\{ header, definitions } ->
          withHeaderFields
            [ "name", "description", "input", "output" ]
            header
            |> Parser.andThen
                (\_ ->
                  let
                    name = getPresentHeaderField "name" header
                    description = getPresentHeaderField "description" header
                    inputTag = getPresentHeaderField "input" header
                    outputTag = getPresentHeaderField "output" header
                  in
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
                              { name = name
                              , description = description
                              , transform =
                                  Pcfg.Grammar.transformGenerator
                                    { formsByTag = definitions
                                    , rootForm = rootForm
                                    , inputTag = inputTag
                                    }
                              }
                          unrecognizedTags ->
                            Parser.problem
                              ("References to unrecognized tags: "
                                ++ String.join ", " unrecognizedTags)
                )
        )


keysNotPresentIn : List comparable -> Dict comparable a -> List comparable
keysNotPresentIn requiredFields dict =
  Set.diff (Set.fromList requiredFields) (Set.fromList <| Dict.keys dict)
    |> Set.toList


withHeaderFields : List String -> Dict String String -> Parser ()
withHeaderFields requiredFields header =
  case
    keysNotPresentIn requiredFields header
  of
    [] ->
      Parser.succeed ()
    missingHeaderFields ->
      Parser.problem
        ("Missing required header fields: "
          ++ String.join ", " missingHeaderFields)


getPresentHeaderField : String -> Dict String String -> String
getPresentHeaderField fieldName header =
  Dict.get fieldName header |> Maybe.withDefault ""
