module Models exposing (..)

import Routes

type alias Model =
  { result : String
  , route : Routes.Route
  }


initialModel : Routes.Route -> Model
initialModel route =
  { result = "Result : Nothing"
  , route = route
  }
