module Tests.Routes exposing (all)

import Test exposing (..)
import Expect
import Navigation exposing (Location)
import Routes exposing (..)


all : Test
all =
  describe "Routes"
    [ routeTest "login" "/login" LoginRoute
    , routeTest "main" "/" MainRoute
    , routeTest "not found" "/not/exist/path" NotFoundRoute
    ]


routeTest : String -> String -> Route -> Test
routeTest name path route =
  test (name ++ " route") <|
    \() ->
      parsePath path
        |> Expect.equal route


parsePath : String -> Route
parsePath path =
  let
    location =
      { newLocation | pathname = path }

  in Routes.parseLocation location


newLocation : Location
newLocation =
  { href = ""
  , host = ""
  , hostname = ""
  , protocol = ""
  , origin = ""
  , port_ = ""
  , pathname = ""
  , search = ""
  , hash = ""
  , username = ""
  , password = ""
  }
