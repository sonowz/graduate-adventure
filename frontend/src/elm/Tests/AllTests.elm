module Tests.AllTests exposing (all)

import Test exposing (..)
import Expect
import Tests.Routes


all : Test
all =
  describe "graduate-adventure"
    [ Tests.Routes.all
    ]
