module Models exposing (..)

import Routes
import Login.Models as Login


type alias Model =
  { loginForm : Login.Model
  , result : String
  , route : Routes.Route
  }


initialModel : Routes.Route -> Model
initialModel route =
  { loginForm = Login.initialModel
  , result = "Result : Nothing"
  , route = route
  }
