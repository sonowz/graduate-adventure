module Subscription exposing (..)

import Models exposing (Model)
import Msgs exposing (Msg(..))
import Login.Subscription


subscription : Model -> Sub Msg
subscription model =
  Sub.batch
  [ Login.Subscription.subscriptions model.loginForm
    |> Sub.map LoginFormMsg
  ]
