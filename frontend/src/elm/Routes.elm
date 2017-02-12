module Routes exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route 
  = LoginRoute
  | MainRoute
  | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ map MainRoute top
    , map LoginRoute (s "login")
    ]


parseLocation : Location -> Route
parseLocation location =
  case (parsePath matchers location) of
    Just route ->
      route

    Nothing ->
      NotFoundRoute
