module Login.Subscription exposing (..)

import Login.Models exposing (Model)
import Login.Msgs exposing (Msg(..))
import Login.Ports as Ports


subscriptions : Model -> Sub Msg
subscriptions model =
  Ports.fileResponse Responsejs
