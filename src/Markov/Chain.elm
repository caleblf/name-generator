module Markov.Chain exposing (Process, buildProcess, express)

import Dict exposing (Dict)
import Dict.Extra
import List.Extra
import Markov.Cluster exposing (Cluster)
import Random
import Random.Extra


type alias Distribution a =
    List ( Float, a )


type alias TransitionFunction a =
    Dict a (Distribution a)


{-| Markov process

    firstClusters - Distribution of initial clusters
    clusterCounts - Distribution of cluster count
    transitions - Distributions of next cluster by previous cluster
    finalTransitions - Distributions of terminal cluster by previous cluster

-}
type alias Process =
    { firstClusters : Distribution Cluster
    , clusterCounts : Distribution Int
    , transitions : TransitionFunction Cluster
    , finalTransitions : TransitionFunction Cluster
    }


consecutivePairs : List a -> List ( a, a )
consecutivePairs xs =
    List.Extra.zip xs <| Maybe.withDefault [] <| List.tail xs


observeDistribution : List comparable -> Distribution comparable
observeDistribution =
    List.map
        (\( x, count ) ->
            ( toFloat count, x )
        )
        << Dict.toList
        << Dict.Extra.frequencies


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
            List.filter (\( _, next ) -> predicate previous next) distribution
        )
        >> Dict.filter (always (not << List.isEmpty))



-- Sampling from distributions


sampleDistribution : Distribution a -> Maybe (Random.Generator a)
sampleDistribution distribution =
    case distribution of
        [] ->
            Nothing

        first :: rest ->
            Just <| Random.weighted first rest


sampleTransitionDistribution :
    TransitionFunction comparable
    -> comparable
    -> Maybe (Random.Generator comparable)
sampleTransitionDistribution transitions previousItem =
    Maybe.andThen sampleDistribution <|
        Dict.get previousItem transitions



-- Terminal superclusters


combineFinalClusters : Int -> List Cluster -> List Cluster
combineFinalClusters endingLength clusters =
    let
        length =
            List.length clusters

        ( headClusters, tailClusters ) =
            List.Extra.splitAt (length - endingLength) clusters
    in
    List.append headClusters [ String.concat tailClusters ]



-- String Markov process


{-| Construct a Markov process

    endingLength -
      Number of clusters at the end ofthe word to combine into superclusters
    examples - Examples on which to base the process

-}
buildProcess : Int -> List String -> Process
buildProcess endingLength examples =
    let
        clusteredExamples : List (List Cluster)
        clusteredExamples =
            List.filter (\clusters -> List.length clusters >= 2) <|
                List.map (combineFinalClusters endingLength) <|
                    List.map Markov.Cluster.toClusters examples

        firstClusters : Distribution Cluster
        firstClusters =
            observeDistribution <| List.filterMap List.head clusteredExamples

        clusterCounts : Distribution Int
        clusterCounts =
            observeDistribution <| List.map List.length clusteredExamples

        transitions : TransitionFunction Cluster
        transitions =
            let
                clusterTransitions : List ( Cluster, Cluster )
                clusterTransitions =
                    List.concatMap consecutivePairs clusteredExamples
            in
            observeTable clusterTransitions

        -- Transitions from second-last cluster to final cluster
        finalTransitions : TransitionFunction Cluster
        finalTransitions =
            observeTable <|
                List.concatMap
                    (\clusters ->
                        case List.reverse clusters of
                            lastCluster :: secondLastCluster :: _ ->
                                [ ( secondLastCluster, lastCluster ) ]

                            _ ->
                                []
                    )
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
                        Nothing ->
                            -- No transitions
                            -- previousCluster must be a viable last cluster
                            Random.constant ""

                        Just nextClusterGenerator ->
                            nextClusterGenerator
                                |> Random.andThen
                                    (\nextCluster ->
                                        (Random.map <| (++) nextCluster) <|
                                            expressFrom (clustersLeft - 1) nextCluster
                                    )
            in
            if clustersLeft <= 1 then
                case sampleTransitionDistribution finalTransitions previousCluster of
                    Nothing ->
                        -- previousCluster is not a viable second-last cluster
                        expressMore ()

                    -- generate extra clusters until we can stop
                    Just lastClusterGenerator ->
                        lastClusterGenerator

            else
                expressMore ()
    in
    Random.Extra.andThen2
        (\clusterCount firstCluster ->
            (Random.map <| (++) firstCluster) <|
                expressFrom (clusterCount - 1) firstCluster
        )
        (Random.weighted ( 0.0, 2 ) clusterCounts)
        (Random.weighted ( 0.0, "" ) firstClusters)
