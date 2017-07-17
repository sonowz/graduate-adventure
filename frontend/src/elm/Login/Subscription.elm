module Login.Subscription exposing (..)

import Login.Msgs exposing (Msg(..))
import Login.Ports as Ports
import Login.Models exposing (Model)


subscriptions : Model -> Sub Msg
subscriptions model =
  Ports.fileResponse Responsejs