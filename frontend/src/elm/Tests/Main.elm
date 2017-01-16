port module Tests.Main exposing (..)

import Test exposing (Test, describe)
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)
import Tests.Components.Test


tests : Test
tests = 
  describe "Tests"
    [ Tests.Components.Test.tests
    ]


main : TestProgram
main =
  run emit tests


port emit : ( String, Value ) -> Cmd msg