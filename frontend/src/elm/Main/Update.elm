module Main.Update exposing (..)


update : Login.Msgs.Msg -> ( Model, Cmd Msg )
update msg =
  case msg of