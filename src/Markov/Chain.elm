module Markov.Chain exposing (Process, buildProcess, express)

import Dict exposing (Dict)
import Random

import List.Extra
import Dict.Extra
import Random.Extra

import Markov.Cluster exposing (Cluster)


type alias Distribution a = List ( Float, a )

type alias TransitionFunction a = Dict a ( Distribution a )

type alias Process =
  { firstClusters : Distribution Cluster  -- distribution of initial clusters
  , clusterCounts : Distribution Int  -- distribution of cluster count
  , transitions : TransitionFunction Cluster  -- distributions of next cluster by previous cluster
  , lastClusters : TransitionFunction Cluster  -- distributions of last cluster by previous sluster
  }


consecutivePairs : List a -> List ( a, a )
consecutivePairs xs = List.Extra.zip xs <| Maybe.withDefault [] <| List.tail xs


observeDistribution : List comparable -> Distribution comparable
observeDistribution =
  List.map (\(x, count) -> (toFloat count, x)) << Dict.toList << Dict.Extra.frequencies

observeTable : List ( comparable, comparable ) -> TransitionFunction comparable
observeTable transitions =
  Dict.Extra.filterGroupBy (Just << Tuple.first) transitions
    |> Dict.map (always (observeDistribution << List.map Tuple.second))


buildProcess : List String -> Process
buildProcess examples =
  let
    clusteredExamples : List (List Cluster)
    clusteredExamples =
      List.filter (\clusters -> List.length clusters >= 2)
        <| List.map Markov.Cluster.toClusters examples

    firstClusters : Distribution Cluster
    firstClusters = observeDistribution <| List.filterMap List.head clusteredExamples

    clusterCounts : Distribution Int
    clusterCounts = observeDistribution <| List.map List.length clusteredExamples

    transitions : TransitionFunction Cluster
    transitions =
      let
        clusterTransitions : List (Cluster, Cluster)
        clusterTransitions = List.concatMap consecutivePairs clusteredExamples
      in
        observeTable clusterTransitions

    lastClusters : TransitionFunction Cluster
    lastClusters =
      observeTable
        <| List.concatMap
            (\clusters ->
              case List.reverse clusters of
                lastCluster::secondLastCluster::_ ->
                  [ (secondLastCluster, lastCluster) ]
                _ -> [])
            clusteredExamples
  in
    { firstClusters = firstClusters
    , clusterCounts = clusterCounts
    , transitions = transitions
    , lastClusters = lastClusters
    }


express : Process -> Random.Generator String
express { firstClusters, clusterCounts, transitions, lastClusters } =
  let
    expressFrom : Int -> Cluster -> Random.Generator String
    expressFrom clusterCount previousCluster =
      if clusterCount <= 1
      then
        Random.weighted (0.0, "")
          <| Maybe.withDefault []
          <| Dict.get previousCluster lastClusters
      else
        case Maybe.withDefault [] <| Dict.get previousCluster transitions of
          [] ->  -- No transitions
            Random.constant ""
          nextClusterDistribution ->
            Random.weighted (0.0, "") nextClusterDistribution
              |> Random.andThen
                  (\nextCluster ->
                    expressFrom (clusterCount - 1) nextCluster
                        |> (Random.map <| (++) nextCluster))
  in
    Random.Extra.andThen2
      (\clusterCount firstCluster ->
        expressFrom clusterCount firstCluster
          |> (Random.map <| (++) firstCluster))
      (Random.weighted (0.0, 2) clusterCounts)
      (Random.weighted (0.0, "") firstClusters)
