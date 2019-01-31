module Generator exposing (..)

import Random

import Language exposing (Language, Transform, Form)


nameList : Int -> Language -> Random.Generator (List String)
nameList amount language =
  Random.list amount <| Random.map capitalize <| language.generator ()


capitalize : String -> String
capitalize string =
  String.toUpper (String.left 1 string) ++ String.dropLeft 1 string


capitalizeForm : Form -> Form
capitalizeForm form () =
  Random.map capitalize <| form ()


applyTransforms : List Transform -> Language -> Random.Generator String
applyTransforms transforms language =
  List.foldl .transform (capitalizeForm language.generator) transforms ()
