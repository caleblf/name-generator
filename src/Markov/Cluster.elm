module Markov.Cluster exposing (Cluster, toClusters)

import List.Extra
import Set exposing (Set)


type alias Cluster =
    String


categorize : List (Set comparable) -> comparable -> Int
categorize groups item =
    Maybe.withDefault -1 <|
        List.Extra.findIndex (Set.member item) groups


charsIn : String -> Set Char
charsIn =
    String.toList >> Set.fromList


categorizeLetter : Char -> Int
categorizeLetter =
    categorize <|
        List.map charsIn
            [ "aeiou"
            , "bcdfghjklmnpqrstvwxz"
            , "y"
            , " "
            ]



-- All other characters are "punctuation"


clusterTogether : Char -> Char -> Bool
clusterTogether char1 char2 =
    categorizeLetter char1 == categorizeLetter char2


toClusters : String -> List Cluster
toClusters =
    List.map (\( first, rest ) -> first :: rest |> String.fromList)
        << List.Extra.groupWhile clusterTogether
        << String.toList
