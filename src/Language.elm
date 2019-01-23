module Language exposing (..)

import Random
import Random.Extra


type alias Language =
  { name : String
  , generator : Form
  }

-- Generator definition must be deferred to allow circular (lazy) references
type alias Form = () -> Random.Generator String


lit : String -> Form
lit s _ = Random.constant s

cat : List Form -> Form
cat forms _ =
  List.foldr
    (Random.map2 (++))
    (Random.constant "")
    <| List.map ((|>) ()) forms

pick : List (Float, Form) -> Random.Generator String
pick weightedForms =
  case weightedForms of
    (firstWeight, firstForm)::rest ->
      Random.Extra.frequency (firstWeight, Random.lazy firstForm)
        <| List.map (Tuple.mapSecond Random.lazy) rest
    _ -> Random.constant "" -- Should never occur


-- Helpers for building pick trees

-- something to avoid parens
p : Float -> String -> (Float, Form)
p weight value = (weight, lit value)

-- something to avoid writing prob when is 1
u : String -> (Float, Form)
u = p 1
