module Markov.Cluster exposing (Cluster, toClusters)

import Set exposing (Set)

import List.Extra


type alias Cluster = String


vowels : Set Char
vowels = Set.fromList <| String.toList "aeiouy"  -- include y? for now, yes

punctuation : Set Char
punctuation = Set.fromList <| String.toList "-'/*"


categorize : Char -> Int
categorize char =
  if Set.member char vowels then 0
  else if Set.member char punctuation then 1
  else 2

clusterTogether : Char -> Char -> Bool
clusterTogether char1 char2 = categorize char1 == categorize char2


toClusters : String -> List Cluster
toClusters =
  List.map (\(first, rest) -> first::rest |> String.fromList)
    << List.Extra.groupWhile clusterTogether
    << String.toList
