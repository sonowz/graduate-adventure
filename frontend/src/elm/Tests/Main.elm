port module Main exposing (..)

import Tests.AllTests exposing (all)
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)


main : TestProgram
main =
  run emit all


port emit : ( String, Value ) -> Cmd msg
