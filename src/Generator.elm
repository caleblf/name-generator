module Generator exposing (..)

import Random

import Language exposing (Language)


nameList : Int -> Language -> Random.Generator (List String)
nameList amount language =
  Random.list amount <| Random.map capitalize <| language.generator ()


capitalize : String -> String
capitalize string =
  String.toUpper (String.left 1 string) ++ String.dropLeft 1 string
