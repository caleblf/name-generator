module Pcfg exposing (..)

import Random
import Random.Extra


type alias Language =
  { name : String
  , description : String
  , priority : Int
  , generator : Form
  }

type alias Transform =
  { name : String
  , description : String
  , priority : Int
  , transform : Form -> Form
  }


type alias Form = Random.Generator String


-- Constructors for Forms

literalForm : String -> Form
literalForm s = Random.constant s

concatForms : List Form -> Form
concatForms forms =
  List.foldr
    (Random.map2 (++))
    (Random.constant "")
    forms

pickWeightedForm : List (Float, Form) -> Random.Generator String
pickWeightedForm weightedForms =
  case weightedForms of
    (firstWeight, firstForm)::rest ->
      Random.Extra.frequency (firstWeight, Random.lazy <| always firstForm)
        <| List.map (Tuple.mapSecond (always >> Random.lazy)) rest
    _ -> Random.constant "" -- Should never occur

-- aliases

lit = literalForm
cat = concatForms
pick = pickWeightedForm
