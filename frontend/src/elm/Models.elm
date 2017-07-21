module Models exposing (..)

import Routes
import Main.Models as Main
import Login.Models as Login


type alias Model =
  { loginForm : Login.Model
  , mainPage : Main.Model
  , loading : Bool
  , route : Routes.Route
  }


initialModel : Routes.Route -> Model
initialModel route =
  { loginForm = Login.initialModel
  , mainPage = Main.initialModel
  , loading = False
  , route = route
  }
