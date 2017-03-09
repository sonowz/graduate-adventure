module Subscription exposing (..)

import Msgs exposing (Msg(..))
import Login.Subscription
import Models exposing (Model)

subscription : Model -> Sub Msg
subscription model =
  Sub.batch
  [ Login.Subscription.subscriptions model.loginForm
    |> Sub.map LoginFormMsg
  ]