module Models exposing (..)

import Routes
import Login.Models exposing (LoginForm, initialLoginForm)


type alias Model =
  { loginForm : LoginForm
  , result : String
  , route : Routes.Route
  }


initialModel : Routes.Route -> Model
initialModel route =
  { loginForm = initialLoginForm
  , result = "Result : Nothing"
  , route = route
  }
