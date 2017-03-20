module Main exposing (..)

import Navigation exposing (Location)
import Models exposing (Model, initialModel)
import View exposing (view)
import Update exposing (update)
import Msgs exposing (Msg(..))
import Routes exposing (Route)
import Subscription exposing (subscription)


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
    