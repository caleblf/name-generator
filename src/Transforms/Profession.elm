module Transforms.Profession exposing (profession)

import Language exposing (Transform, lit, cat, pick, u, p)


profession : Transform
profession =
  { name = "Profession"
  , priority = 3
  , transform = transform
  }


transform name =
  let comma = lit ", "
      
      job _ = pick
        [ (3, peasant)
        , (3, artisan)
        , (2, specialist)
        , (1, adventurer)
        ]

      peasant _ = pick
        [ u "laborer"
        , u "farmer"
        , u "shepherd"
        , u "thresher"
        , u "carter"
        , u "urchin"
        , u "beggar"
        , u "fisher"
        ]

      artisan _ = pick
        [ u "carpenter"
        , u "glazier"
        , u "baker"
        , u "apothecary"
        , u "barber"
        , u "blacksmith"
        , u "butcher"
        , u "chandler"
        , u "innkeeper"
        , u "jeweler"
        , u "locksmith"
        , u "stonemason"
        , u "tailor"
        , u "shoemaker"
        , u "tanner"
        , u "waiter"
        , u "weaver"
        , u "artisan's apprentice"
        , u "librarian"
        , u "shopkeeper"
        ]

      specialist _ = pick
        [ u "surgeon"
        , u "priest"
        , u "hedge wizard"
        , u "hedge witch"
        , u "hedge knight"
        , u "grifter"
        , u "musician"
        , u "gladiator"
        , u "actor"
        , u "author"
        , u "trapper"
        , u "hunter"
        , u "magician's apprentice"
        , u "shaman"
        , u "oracle"
        , u "pickpocket"
        , u "burglar"
        , u "bounty hunter"
        , u "alchemist"
        , u "artificer"
        ]

      adventurer = cat [ lit "level ", level, lit " ", class ]

      level _ = pick
        [ p 5 "1"
        , p 4 "2"
        , p 3 "3"
        , p 2 "4"
        , p 1 "5"
        ]

      class _ = pick
        [ u "barbarian"
        , u "bard"
        , u "cleric"
        , u "druid"
        , u "fighter"
        , u "monk"
        , u "paladin"
        , u "ranger"
        , u "rogue"
        , u "sorcerer"
        , u "warlock"
        , u "wizard"
        ]

  in cat [ name, comma, job ]
