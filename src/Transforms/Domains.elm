module Transforms.Domains exposing (domains)

import Pcfg exposing (Transform, literalForm, concatForms, pickWeightedForm)


domains : Transform
domains =
  { name = "Divine Domains"
  , description = "Divine domains"
  , priority = 2
  , transform = transformName
  }


transformName name =
  let output = concatForms [name, comma, epithet]

      comma = literalForm ", "

      epithet _ = pickWeightedForm
        [ (3.0, concatForms [title, literalForm " of ", domain])
        , (4.0, concatForms [title, literalForm " of ", domain, literalForm " and ", domain])
        , (1.0, concatForms [title, literalForm " of ", domain, comma, domain, literalForm ", and ", domain])
        ]

      title _ = pickWeightedForm
        [ (12.0, literalForm "God")
        , (3.0, literalForm "Lord")
        , (3.0, literalForm "Master")
        , (2.0, literalForm "King")
        , (14.0, literalForm "Goddess")
        , (6.0, literalForm "Queen")
        , (6.0, literalForm "Spirit")
        , (1.0, literalForm "Warden")
        , (1.0, literalForm "Protector")
        , (1.0, literalForm "Guardian")
        ]

      domain _ = pickWeightedForm
        [ (1.0, literalForm "Dreams")
        , (1.0, literalForm "Secrets")
        , (1.0, literalForm "Death")
        , (1.0, literalForm "Fate")
        , (1.0, literalForm "Chance")
        , (1.0, literalForm "Sleep")
        , (1.0, literalForm "Prophecy")
        , (1.0, literalForm "Chaos")
        , (1.0, literalForm "Valor")
        , (1.0, literalForm "Honor")
        , (1.0, literalForm "Love")
        , (1.0, literalForm "Fertility")
        , (1.0, literalForm "Justice")
        , (1.0, literalForm "Treachery")
        , (1.0, literalForm "Trickery")
        , (1.0, literalForm "Madness")
        , (1.0, literalForm "Plague")
        , (1.0, literalForm "Famine")
        , (1.0, literalForm "War")
        , (1.0, literalForm "Trade")
        , (1.0, literalForm "the Crossroads")
        , (1.0, literalForm "the Hearth")
        , (1.0, literalForm "the Hunt")
        , (1.0, literalForm "Poetry")
        , (1.0, literalForm "Song")
        , (1.0, literalForm "Dance")
        , (1.0, literalForm "Riddles")
        , (1.0, literalForm "Witchcraft")
        , (1.0, literalForm "Monsters")
        , (1.0, literalForm "Names")
        , (1.0, literalForm "Magicians")
        , (1.0, literalForm "Craftsmen")
        , (1.0, literalForm "Farmers")
        , (1.0, literalForm "Merchants")
        , (1.0, literalForm "Travelers")
        , (1.0, literalForm "Wanderers")
        , (1.0, literalForm "Sailors")
        , (1.0, literalForm "Miners")
        , (1.0, literalForm "Shepherds")
        , (1.0, literalForm "Warriors")
        , (1.0, literalForm "Mothers")
        , (1.0, literalForm "Fathers")
        , (1.0, literalForm "Shipwrights")
        , (1.0, literalForm "Thieves")
        , (1.0, literalForm "Hunters")
        , (1.0, literalForm "Clouds")
        , (1.0, literalForm "Lightning")
        , (1.0, literalForm "Thunder")
        , (1.0, literalForm "the Sea")
        , (1.0, literalForm "Wild Places")
        , (1.0, literalForm "Volcanoes")
        , (1.0, literalForm "Fire")
        , (1.0, literalForm "the Wind")
        , (1.0, literalForm "Mountains")
        , (1.0, literalForm "Snow")
        , (1.0, literalForm "Rain")
        , (1.0, literalForm "Springtime")
        , (1.0, literalForm "Summertime")
        , (1.0, literalForm "the Winter")
        , (1.0, literalForm "the Harvest")
        , (1.0, literalForm "Planting Season")
        , (1.0, literalForm "the Sun")
        , (1.0, literalForm "the Moon")
        , (1.0, literalForm "the Stars")
        , (1.0, literalForm "the Sky")
        , (1.0, literalForm "Cows")
        , (1.0, literalForm "Cats")
        , (1.0, literalForm "Horses")
        , (1.0, literalForm "Dragons")
        , (1.0, literalForm "Crocodiles")
        , (1.0, literalForm "Snakes")
        , (1.0, literalForm "Iron")
        , (1.0, literalForm "Gold")
        , (1.0, literalForm "Gemstones")
        , (1.0, literalForm "Sand")
        ]
  in output
