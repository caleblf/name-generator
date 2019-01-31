module Transforms.Title exposing (title)

import Language exposing (Transform, lit, cat, pick, u, p)


title : Transform
title =
  { name = "Title"
  , priority = 1
  , transform = transform
  }


transform name =
  let titled_name _ = pick
        [ (10, cat [ name, the, title_ ])
        , (5, cat [ name, of_the, sigil_phrase])
        , (1, cat [ adjective, sp, name])
        ]

      the = lit " the "
      of_the = lit " of the "
      sp = lit " "

      color _ = pick
        [ u "Golden"
        , u "Silver"
        , u "Argent"
        , u "Sable"
        , u "Red"
        , u "Blue"
        , u "Green"
        , u "White"
        , u "Orange"
        , u "Black"
        , u "Grey"
        , u "Yellow"
        , u "Purple"
        , u "Chartreuse"
        , u "Crimson"
        , u "Azure"
        , u "Violet"
        , u "Magenta"
        , u "Brown"
        , u "Beige"
        , u "Indigo"
        , u "Cyan"
        ]

      material _ = pick
        [ u "Stone"
        , u "Golden"
        , u "Iron"
        , u "Clay"
        , u "Crystalline"
        ]

      sigil_phrase _ = pick
        [ (2, cat [ sigil_mod_s, sp, sigil ])
        , (2, cat [ sigil_mod_pl, sp, sigil, lit "s" ])
        , (1, sigil)
        , (1, cat [ sigil, lit "s" ])
        ]

      sigil_mod_s _ = pick
        [ (4, color)
        , (4, material)
        , u "Majestic"
        , u "Great"
        , u "Noble"
        , u "Fallen"
        , u "Broken"
        , u "Cloven"
        , u "Lost"
        , u "Cursed"
        , u "Blessed"
        , u "Ancient"
        ]

      sigil_mod_pl _ = pick
        [ (4, sigil_mod_s)
        , (3, color)
        , u "Two"
        , u "Twin"
        , u "Three"
        , u "Four"
        , u "Five"
        , u "Six"
        , u "Seven"
        , u "Nine"
        , u "Dozen"
        , u "Multitudinous"
        ]

      sigil _ = pick -- must pluralize with -s suffix
        -- Animals
        [ u "Bear"
        , u "Lion"
        , u "Boar"
        , u "Cat"
        , u "Toad"
        , u "Owl"
        , u "Bat"
        , u "Rat"
        -- Rocks
        , u "Diamond"
        , u "Crystal"
        , u "Stone"
        -- Weapons
        , u "Spear"
        , u "Blade"
        , u "Sword"
        , u "Bow"
        , u "Arrow"
        , u "Dagger"
        , u "Club"
        , u "Lance"
        -- Armor
        , u "Shield"
        , u "Mantle"
        , u "Gauntlet"
        , u "Helm"
        , u "Crown"
        -- Magical foci
        , u "Wand"
        , u "Orb"
        -- Books
        , u "Scroll"
        , u "Tome"
        -- Structures
        , u "Gate"
        , u "Tower"
        , u "Door"
        , u "Pyramid"
        , u "Manse"
        , u "Tomb"
        , u "Spire"
        -- Natural places
        , u "River"
        , u "Grove"
        , u "Mountain"
        , u "Shore"
        , u "Tarn"
        , u "Desert"
        -- Astronomical bodies
        , u "Moon"
        , u "Sun"
        , u "Star"
        -- Plants
        , u "Clover"
        , u "Rose"
        , u "Oak"
        , u "Elm"
        -- Body parts
        , u "Fist"
        , u "Heart"
        , u "Skull"
        , u "Bone"
        , u "Claw"
        , u "Talon"
        , u "Hand"
        , u "Eye"
        ]

      adjective _ = pick
        [ (5, color)
        , (5, digit_adj)
        , u "Shark-toothed"
        , u "Half-dead"
        , u "One-eyed"
        , u "One-eared"
        , u "Fingerless"
        , u "Crooked"
        ]

      digit_adj _ = pick
        [ (3, cat [ digit_count, lit "-fingered" ])
        , (1, cat [ digit_count, lit "-toed" ])
        ]

      digit_count _ = pick
        [ u "Four"
        , p 2 "Six"
        , p 2 "Seven"
        , u "Eight"
        , p 2 "Nine"
        , u "Eleven"
        ]

      title_ _ = pick
        [ (12, color)
        -- Physical ability
        , u "Quick"
        , u "Nimble"
        , u "Feeble"
        , u "Strong"
        , u "Enduring"
        -- Statue
        , u "Lean"
        , u "Stout"
        , u "Tall"
        , u "Fat"
        , u "Giant"
        -- Mental ability
        , u "Incompetent"
        , u "Daft"
        , u "Half-Wit"
        , u "Silver-Tongued"
        , u "Clever"
        , u "Mad"
        -- Virtue
        , u "Great"
        , u "Wise"
        , u "Brave"
        , u "Honest"
        , u "Mighty"
        , u "Pious"
        , u "Noble"
        -- Vice
        , u "Spineless"
        , u "Craven"
        , u "Fool"
        -- Personality
        , u "Vague"
        , u "Cordial"
        , u "Crabby"
        , u "Incongruously Cheerful"
        , u "Reckless"
        , u "Unladylike"
        , u "Truculent"
        , u "Flirtatious"
        , u "Boorish"
        , u "Forthright"
        , u "Swanky"
        , u "Inconsistent"
        , u "Lunatic"
        , u "Quiet"
        , u "Merciful"
        , u "Vain"
        -- Feat
        , u "Deathless"
        , u "Dragonslayer"
        , u "Titan-killer"
        , u "Magnificent"
        -- Physical trait
        , u "Invisible"
        , u "Blind"
        , u "Deaf"
        , u "Wrinkled"
        , u "Smelly"
        , u "Toothless"
        , u "Unblinking"
        , u "Beautiful"
        , u "Fair"
        , u "Plain"
        , u "Gassy"
        , u "Hirsute"
        , u "Bald"
        -- Perception
        , u "Fearsome"
        , u "Slightly Off"
        , u "Bizarre"
        , u "Irksome"
        , u "Stand-up Guy"
        , u "Cruel"
        , u "Butcher"
        -- Higher power
        , u "Planetouched"
        , u "Fey"
        , u "Blessed"
        , u "Lucky"
        , u "Thrice-cursed"
        -- Class
        , u "Rich"
        , u "Poor"
        , u "Miserly"
        -- State
        , u "Drunkard"
        , u "Sober"
        -- Region of origin
        , u "Northron"
        , u "Southron"
        , u "Westron"
        , u "Eastron"
        , u "Beyonder"
        , u "Barbarian"
        -- Profession
        , u "Poet"
        , u "Bard"
        , u "Singer"
        , u "Thief"
        , u "Warrior"
        , u "Archer"
        , u "Magician"
        , u "Witch"
        , u "Trapper"
        , u "Enchanter"
        , u "Artificer"
        -- Animal
        , u "Boar"
        , u "Leopard"
        , u "Eagle"
        , u "Cheetah"
        , u "Worm"
        , u "Toad"
        , u "Eel"
        , u "Rat"
        , u "Mouse"
        , u "Bear"
        , u "Snake"
        , u "Fox"
        -- Fanciful titles
        , u "Myrmidon"
        , u "Zephyr"
        ]

  in titled_name
