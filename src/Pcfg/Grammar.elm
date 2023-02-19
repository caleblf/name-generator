module Pcfg.Grammar exposing (..)

import Dict exposing (Dict)
import Random
import Random.Extra
import Set exposing (Set)
import String


type Form
    = ConcatenationForm (List Form)
    | LiteralForm String
    | VariableForm String
    | UnionForm (List ( Float, Form ))


type alias Pcfg =
    { formsByTag : Dict String Form
    , rootForm : Form
    }


type alias PcfgTransform =
    { formsByTag : Dict String Form
    , rootForm : Form
    , inputTag : String
    }



-- VALIDATION


freeTagsInDefinitions : Dict String Form -> Set String
freeTagsInDefinitions formsByTag =
    let
        referencedTags : Set String
        referencedTags =
            List.map freeVariables (Dict.values formsByTag)
                |> List.foldl Set.union Set.empty

        definedTags : Set String
        definedTags =
            Dict.keys formsByTag |> Set.fromList
    in
    Set.diff referencedTags definedTags


isValidPcfg : Pcfg -> Bool
isValidPcfg { formsByTag, rootForm } =
    let
        referencedTags : Set String
        referencedTags =
            List.map freeVariables (Dict.values formsByTag)
                |> List.foldl Set.union (freeVariables rootForm)

        definedTags : Set String
        definedTags =
            Dict.keys formsByTag |> Set.fromList
    in
    Set.diff referencedTags definedTags |> Set.isEmpty


isValidPcfgTransform : PcfgTransform -> Bool
isValidPcfgTransform { formsByTag, rootForm, inputTag } =
    isValidPcfg
        { formsByTag = Dict.insert inputTag (LiteralForm "") formsByTag
        , rootForm = rootForm
        }


freeVariables : Form -> Set String
freeVariables form =
    case form of
        ConcatenationForm forms ->
            List.map freeVariables forms
                |> List.foldl Set.union Set.empty

        LiteralForm _ ->
            Set.empty

        VariableForm formTag ->
            Set.singleton formTag

        UnionForm weightedForms ->
            List.map (Tuple.second >> freeVariables) weightedForms
                |> List.foldl Set.union Set.empty



-- GENERATION


languageGenerator : Pcfg -> Random.Generator String
languageGenerator { formsByTag, rootForm } =
    let
        express : Form -> Random.Generator String
        express form =
            case form of
                ConcatenationForm forms ->
                    Random.Extra.traverse express forms |> Random.map String.concat

                LiteralForm text ->
                    Random.constant text

                VariableForm formTag ->
                    Random.lazy
                        (\_ ->
                            Dict.get formTag formsByTag
                                |> Maybe.withDefault (LiteralForm "ERROR")
                                |> express
                        )

                UnionForm weightedForms ->
                    case weightedForms of
                        ( firstWeight, firstForm ) :: rest ->
                            Random.weighted ( firstWeight, firstForm ) rest
                                |> Random.andThen express

                        _ ->
                            Random.constant ""

        -- Should never occur
    in
    express rootForm


transformGenerator : PcfgTransform -> Random.Generator String -> Random.Generator String
transformGenerator { formsByTag, rootForm, inputTag } =
    Random.andThen
        (\inputText ->
            languageGenerator
                { formsByTag =
                    Dict.insert inputTag (LiteralForm inputText) formsByTag
                , rootForm = rootForm
                }
        )
