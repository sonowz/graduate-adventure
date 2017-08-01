module Main exposing (..)

import Navigation exposing (Location)
import Routes exposing (Route)
import Models exposing (Model, initialModel)
import Msgs exposing (Msg(..))
import Subscription exposing (subscription)
import Update exposing (update)
import View exposing (view)
import Main.Update


init : Location -> (Model, Cmd Msg)
init location =
  let
    currentRoute =
      Routes.parseLocation location

    commands : Routes.Route -> (Cmd Msg)
    commands route =
      case route of
        Routes.MainRoute ->
          Cmd.map MainPageMsg (Cmd.batch [ Main.Update.getMainData ])
        _ ->
          Cmd.none
  in
    (initialModel currentRoute, commands currentRoute)


main : Program Never Model Msg
main =
  Navigation.program OnLocationChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscription
    }
