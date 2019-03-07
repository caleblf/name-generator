module Pcfg exposing (..)

import Random
import Random.Extra


type alias Language =
  { name : String
  , description : String
  , generator : Form
  }

type alias Transform =
  { name : String
  , description : String
  , priority : Int
  , transform : Form -> Form
  }


-- Generator definition must be deferred to allow circular (lazy) references
type alias Form = () -> Random.Generator String


-- Constructors for Forms

literalForm : String -> Form
literalForm s _ = Random.constant s

concatForms : List Form -> Form
concatForms forms _ =
  List.foldr
    (Random.map2 (++))
    (Random.constant "")
    <| List.map ((|>) ()) forms

pickWeightedForm : List (Float, Form) -> Random.Generator String
pickWeightedForm weightedForms =
  case weightedForms of
    (firstWeight, firstForm)::rest ->
      Random.Extra.frequency (firstWeight, Random.lazy firstForm)
        <| List.map (Tuple.mapSecond Random.lazy) rest
    _ -> Random.constant "" -- Should never occur

-- aliases

lit = literalForm
cat = concatForms
pick = pickWeightedForm
