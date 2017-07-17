module Models exposing (..)

import Routes
import Login.Models as Login
import Main.Models as Main


type alias Model =
  { loginForm : Login.Model
  , mainPage : Main.Model
  , result : String
  , route : Routes.Route
  }


initialModel : Routes.Route -> Model
initialModel route =
  { loginForm = Login.initialModel
  , mainPage = Main.initialModel
  , result = "Result : Nothing"
  , route = route
  }
