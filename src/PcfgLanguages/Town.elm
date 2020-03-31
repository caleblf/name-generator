module PcfgLanguages.Town exposing (town)

import Pcfg exposing (Language, literalForm, concatForms, pickWeightedForm)


town : Language
town =
  { name = "Towns"
  , description = "Generic city/town names"
  , priority = 10
  , generator = root
  }


root = concatForms [adjective, feature]

adjective _ = pickWeightedForm
  [ (1.0, literalForm "Blessed")
  , (1.0, literalForm "Great")
  , (1.0, literalForm "Iron")
  , (1.0, literalForm "Gilded")
  , (1.0, literalForm "Gleaming")
  , (1.0, literalForm "Storm")
  , (1.0, literalForm "Thunder")
  , (1.0, literalForm "Blue")
  , (1.0, literalForm "Green")
  , (1.0, literalForm "Red")
  , (1.0, literalForm "Black")
  , (1.0, literalForm "Dun")
  , (1.0, literalForm "Gray")
  , (1.0, literalForm "Silver")
  , (1.0, literalForm "Golden")
  , (1.0, literalForm "Winter")
  , (1.0, literalForm "Summer")
  , (1.0, literalForm "Spring")
  , (1.0, literalForm "Azure")
  , (1.0, literalForm "Bleak")
  , (1.0, literalForm "Dead")
  , (1.0, literalForm "New")
  , (1.0, literalForm "Old")
  , (1.0, literalForm "Fox")
  , (1.0, literalForm "Bear")
  , (1.0, literalForm "Wolf")
  , (1.0, literalForm "Dogs")
  , (1.0, literalForm "Lions")
  , (1.0, literalForm "Dragon")
  , (1.0, literalForm "Eagle")
  , (1.0, literalForm "Raven")
  , (1.0, literalForm "Crow")
  , (1.0, literalForm "Elk")
  , (1.0, literalForm "Snake")
  , (1.0, literalForm "Leopard")
  , (1.0, literalForm "Grim")
  , (1.0, literalForm "Grave")
  , (1.0, literalForm "High")
  , (1.0, literalForm "Low")
  , (1.0, literalForm "Bronze")
  ]

feature _ = pickWeightedForm
  [ (1.0, literalForm "helm")
  , (1.0, literalForm "deep")
  , (1.0, literalForm "ford")
  , (1.0, literalForm "tree")
  , (1.0, literalForm "brook")
  , (1.0, literalForm " Warren")
  , (1.0, literalForm "river")
  , (1.0, literalForm "hill")
  , (1.0, literalForm " Mountain")
  , (1.0, literalForm " Valley")
  , (1.0, literalForm "lake")
  , (1.0, literalForm "run")
  , (1.0, literalForm "fall")
  , (1.0, literalForm "falls")
  , (1.0, literalForm "wood")
  , (1.0, literalForm "nest")
  , (1.0, literalForm "water")
  , (1.0, literalForm "well")
  , (1.0, literalForm "hall")
  , (1.0, literalForm "haven")
  , (1.0, literalForm "wall")
  , (1.0, literalForm "crest")
  , (1.0, literalForm "field")
  , (1.0, literalForm "fort")
  , (1.0, literalForm "bridge")
  , (1.0, literalForm "tower")
  , (1.0, literalForm "spire")
  , (1.0, literalForm "keep")
  , (1.0, literalForm "town")
  , (1.0, literalForm "downs")
  , (1.0, literalForm " Circle")
  , (1.0, literalForm " Pasture")
  , (1.0, literalForm " Crossing")
  , (1.0, literalForm " Moon")
  , (1.0, literalForm "march")
  , (1.0, literalForm "moot")
  , (1.0, literalForm "hollow")
  , (1.0, literalForm "rest")
  , (1.0, literalForm " Bastion")
  , (1.0, literalForm "moor")
  ]