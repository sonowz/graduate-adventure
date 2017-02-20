module Main exposing (..)

import Navigation exposing (Location)
import Models exposing (Model, initialModel)
import View exposing (view)
import Update exposing (update)
import Msgs exposing (Msg(..))
import Routes exposing (Route)


init : Location -> (Model, Cmd Msg)
init location =
  let
    currentRoute =
      Routes.parseLocation location

  in
    (initialModel currentRoute, Cmd.none)


subscription : Model -> Sub Msg
subscription model =
  Sub.none


main : Program Never Model Msg
main =
  Navigation.program OnLocationChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscription
    }
