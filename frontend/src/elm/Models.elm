module Models exposing (..)

import Routes
import Login.Models as Login
import Main.Models as Main


type alias Model =
  { loginForm : Login.Model
  , mainForm : Main.Model
  , result : String
  , route : Routes.Route
  }


initialModel : Routes.Route -> Model
initialModel route =
  { loginForm = Login.initialModel
  , mainForm = Main.initialModel
  , result = "Result : Nothing"
  , route = route
  }
