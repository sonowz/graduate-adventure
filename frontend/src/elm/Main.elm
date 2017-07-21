module Main exposing (..)

import Navigation exposing (Location)
import Routes exposing (Route)
import Models exposing (Model, initialModel)
import Msgs exposing (Msg(..))
import Subscription exposing (subscription)
import Update exposing (update)
import View exposing (view)


init : Location -> (Model, Cmd Msg)
init location =
  let
    currentRoute =
      Routes.parseLocation location

  in
    (initialModel currentRoute, Cmd.none)


main : Program Never Model Msg
main =
  Navigation.program OnLocationChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscription
    }
