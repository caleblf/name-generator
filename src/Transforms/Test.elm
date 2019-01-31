module Transforms/Test exposing (test)

import Language exposing (Transform, Form, lit, cat, pick, u, p)


test : Transform
test =
  { name = "Test Transform"
  , priority = 1
  , transform = root
  }

root name =
  let foo = lit "xyz"
      baz = cat [ foo, name ]
  in baz