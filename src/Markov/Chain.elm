module Markov.Chain exposing (Process, buildProcess, express)

import Dict exposing (Dict)
import Set exposing (Set)
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
  , finalTransitions : TransitionFunction Cluster  -- distributions of last cluster by previous cluster
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


filterTable :
  (comparable -> comparable -> Bool)
  -> TransitionFunction comparable
  -> TransitionFunction comparable
filterTable predicate =
  Dict.map
    (\previous distribution ->
      List.filter (\(_, next) -> predicate previous next) distribution)
  >> Dict.filter (always (not << List.isEmpty))


-- Sampling from distributions

sampleDistribution : Distribution a -> Maybe (Random.Generator a)
sampleDistribution distribution =
  case distribution of
    [] -> Nothing
    first :: rest -> Just <| Random.weighted first rest

sampleTransitionDistribution :
  TransitionFunction comparable
  -> comparable
  -> Maybe (Random.Generator comparable)
sampleTransitionDistribution transitions previousItem =
  Maybe.andThen sampleDistribution
    <| Dict.get previousItem transitions


-- String Markov process

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

    -- Transitions from second-last cluster to final cluster
    finalTransitions : TransitionFunction Cluster
    finalTransitions =
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
    , finalTransitions = finalTransitions
    }


express : Process -> Random.Generator String
express { firstClusters, clusterCounts, transitions, finalTransitions } =
  let
    expressFrom : Int -> Cluster -> Random.Generator String
    expressFrom clustersLeft previousCluster =
      let
        expressMore : () -> Random.Generator String
        expressMore () =
          case sampleTransitionDistribution transitions previousCluster of
            Nothing ->  -- No transitions
              Random.constant ""  -- previousCluster must be a viable last cluster
            Just nextClusterGenerator ->
              nextClusterGenerator
                |> Random.andThen
                    (\nextCluster ->
                      (Random.map <| (++) nextCluster)
                        <| expressFrom (clustersLeft - 1) nextCluster)
      in
        if clustersLeft <= 1
        then
          case sampleTransitionDistribution finalTransitions previousCluster of
            Nothing ->  -- previousCluster is not a viable second-last cluster
              expressMore ()  -- generate extra clusters until we can stop
            Just lastClusterGenerator -> lastClusterGenerator
        else
          expressMore ()
  in
    Random.Extra.andThen2
      (\clusterCount firstCluster ->
        (Random.map <| (++) firstCluster)
          <| expressFrom (clusterCount - 1) firstCluster)
      (Random.weighted (0.0, 2) clusterCounts)
      (Random.weighted (0.0, "") firstClusters)
