module Manifest exposing (languages, transforms)

import Pcfg exposing (Language, Transform)

import Languages.Nickname exposing (nickname)
import Languages.Elven exposing (elven)
import Languages.Halfling exposing (halfling)
import Languages.Dwarven exposing (dwarven)
import Languages.Common exposing (common)
import Languages.Orcish exposing (orcish)
import Languages.Fiendish exposing (fiendish)

import Transforms.Title exposing (title)
import Transforms.Profession exposing (profession)

languages : List Language
languages =
  List.sortBy .priority
    [ nickname
    , elven
    , halfling
    , dwarven
    , common
    , orcish
    , fiendish
    ]

transforms : List Transform
transforms =
  List.sortBy .priority
    [ title
    , profession
    ]
