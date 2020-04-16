module PcfgTransforms.Profession exposing (profession)

import Pcfg exposing (Transform, literalForm, concatForms, pickWeightedForm)


profession : Transform
profession =
  { name = "Profession"
  , description = "Medieval professions"
  , priority = 3
  , transform = transformName
  }


transformName name =
  let output = concatForms [name, comma, job]

      comma = literalForm ", "

      job = pickWeightedForm
        [ (3.0, peasant)
        , (3.0, artisan)
        , (2.0, specialist)
        , (1.0, adventurer)
        ]

      peasant = pickWeightedForm
        [ (1.0, literalForm "laborer")
        , (1.0, literalForm "farmer")
        , (1.0, literalForm "shepherd")
        , (1.0, literalForm "thresher")
        , (1.0, literalForm "carter")
        , (1.0, literalForm "urchin")
        , (1.0, literalForm "beggar")
        , (1.0, literalForm "fisher")
        ]

      artisan = pickWeightedForm
        [ (1.0, literalForm "carpenter")
        , (1.0, literalForm "glazier")
        , (1.0, literalForm "baker")
        , (1.0, literalForm "apothecary")
        , (1.0, literalForm "barber")
        , (1.0, literalForm "blacksmith")
        , (1.0, literalForm "butcher")
        , (1.0, literalForm "chandler")
        , (1.0, literalForm "innkeeper")
        , (1.0, literalForm "jeweler")
        , (1.0, literalForm "locksmith")
        , (1.0, literalForm "stonemason")
        , (1.0, literalForm "tailor")
        , (1.0, literalForm "shoemaker")
        , (1.0, literalForm "tanner")
        , (1.0, literalForm "waiter")
        , (1.0, literalForm "weaver")
        , (1.0, literalForm "artisan's apprentice")
        , (1.0, literalForm "librarian")
        , (1.0, literalForm "shopkeeper")
        ]

      specialist = pickWeightedForm
        [ (1.0, literalForm "surgeon")
        , (1.0, literalForm "priest")
        , (1.0, literalForm "hedge wizard")
        , (1.0, literalForm "hedge witch")
        , (1.0, literalForm "hedge knight")
        , (1.0, literalForm "grifter")
        , (1.0, literalForm "musician")
        , (1.0, literalForm "gladiator")
        , (1.0, literalForm "actor")
        , (1.0, literalForm "author")
        , (1.0, literalForm "trapper")
        , (1.0, literalForm "hunter")
        , (1.0, literalForm "magician's apprentice")
        , (1.0, literalForm "shaman")
        , (1.0, literalForm "oracle")
        , (1.0, literalForm "pickpocket")
        , (1.0, literalForm "burglar")
        , (1.0, literalForm "bounty hunter")
        , (1.0, literalForm "alchemist")
        , (1.0, literalForm "artificer")
        ]

      adventurer = concatForms [literalForm "level", sp, level, sp, class]

      sp = literalForm " "

      level = pickWeightedForm
        [ (5.0, literalForm "1")
        , (4.0, literalForm "2")
        , (3.0, literalForm "3")
        , (2.0, literalForm "4")
        , (1.0, literalForm "5")
        ]

      class = pickWeightedForm
        [ (1.0, literalForm "barbarian")
        , (1.0, literalForm "bard")
        , (1.0, literalForm "cleric")
        , (1.0, literalForm "druid")
        , (1.0, literalForm "fighter")
        , (1.0, literalForm "monk")
        , (1.0, literalForm "paladin")
        , (1.0, literalForm "ranger")
        , (1.0, literalForm "rogue")
        , (1.0, literalForm "sorcerer")
        , (1.0, literalForm "warlock")
        , (1.0, literalForm "wizard")
        ]
  in output
