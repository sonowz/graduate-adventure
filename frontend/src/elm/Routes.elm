module Routes exposing (Route(..), match, toString, parseLocation, navigationTo)

import Navigation exposing (Location)
import Route exposing (..)


type Route
  = LoginRoute
  | MainRoute
  | NotFoundRoute


loginRoute : Route.Route Route
loginRoute =
  LoginRoute := static "login"


mainRoute : Route.Route Route
mainRoute =
  MainRoute := static "main"


routes : Route.Router Route
routes =
  router
    [ loginRoute
    , mainRoute
    ]


match : String -> Route
match =
  Route.match routes
    >> Maybe.withDefault NotFoundRoute


toString : Route -> String
toString route =
  case route of
    LoginRoute ->
      reverse loginRoute []

    MainRoute ->
      reverse mainRoute []

    NotFoundRoute ->
      Debug.crash "cannot route to NotFound"


parseLocation : Location -> Route
parseLocation =
  .pathname >> match


navigationTo : Route -> Cmd msg
navigationTo =
  toString >> Navigation.newUrl
