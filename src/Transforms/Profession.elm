module Transforms.Profession exposing (profession)

import Language exposing (Language, Form, lit, cat, pick, u, p)


profession : Transform
profession =
  { name = "Profession"
  , priority = 3
  , transform = transform
  }


transform name =
  let output = cat [name, comma, job]

      comma = lit ", "

      job _ = pick
        [ (3.0, peasant)
        , (3.0, artisan)
        , (2.0, specialist)
        , (1.0, adventurer)
        ]

      peasant _ = pick
        [ (1.0, lit "laborer")
        , (1.0, lit "farmer")
        , (1.0, lit "shepherd")
        , (1.0, lit "thresher")
        , (1.0, lit "carter")
        , (1.0, lit "urchin")
        , (1.0, lit "beggar")
        , (1.0, lit "fisher")
        ]

      artisan _ = pick
        [ (1.0, lit "carpenter")
        , (1.0, lit "glazier")
        , (1.0, lit "baker")
        , (1.0, lit "apothecary")
        , (1.0, lit "barber")
        , (1.0, lit "blacksmith")
        , (1.0, lit "butcher")
        , (1.0, lit "chandler")
        , (1.0, lit "innkeeper")
        , (1.0, lit "jeweler")
        , (1.0, lit "locksmith")
        , (1.0, lit "stonemason")
        , (1.0, lit "tailor")
        , (1.0, lit "shoemaker")
        , (1.0, lit "tanner")
        , (1.0, lit "waiter")
        , (1.0, lit "weaver")
        , (1.0, lit "artisan's apprentice")
        , (1.0, lit "librarian")
        , (1.0, lit "shopkeeper")
        ]

      specialist _ = pick
        [ (1.0, lit "surgeon")
        , (1.0, lit "priest")
        , (1.0, lit "hedge wizard")
        , (1.0, lit "hedge witch")
        , (1.0, lit "hedge knight")
        , (1.0, lit "grifter")
        , (1.0, lit "musician")
        , (1.0, lit "gladiator")
        , (1.0, lit "actor")
        , (1.0, lit "author")
        , (1.0, lit "trapper")
        , (1.0, lit "hunter")
        , (1.0, lit "magician's apprentice")
        , (1.0, lit "shaman")
        , (1.0, lit "oracle")
        , (1.0, lit "pickpocket")
        , (1.0, lit "burglar")
        , (1.0, lit "bounty hunter")
        , (1.0, lit "alchemist")
        , (1.0, lit "artificer")
        ]

      adventurer = cat [lit "level", sp, level, sp, class]

      sp = lit " "

      level _ = pick
        [ (5.0, lit "1")
        , (4.0, lit "2")
        , (3.0, lit "3")
        , (2.0, lit "4")
        , (1.0, lit "5")
        ]

      class _ = pick
        [ (1.0, lit "barbarian")
        , (1.0, lit "bard")
        , (1.0, lit "cleric")
        , (1.0, lit "druid")
        , (1.0, lit "fighter")
        , (1.0, lit "monk")
        , (1.0, lit "paladin")
        , (1.0, lit "ranger")
        , (1.0, lit "rogue")
        , (1.0, lit "sorcerer")
        , (1.0, lit "warlock")
        , (1.0, lit "wizard")
        ]
  in output
