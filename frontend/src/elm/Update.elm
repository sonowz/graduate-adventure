module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)
import Routes exposing (parseLocation)
import Login.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnLocationChange location ->
      let
        newRoute =
          parseLocation location
      in
        ( { model | route = newRoute }, Cmd.none )

    LoginFormMsg loginFormMsg ->
      let
        ( newLoginForm, cmd ) =
          Login.Update.update loginFormMsg model.loginForm
      in
        ( { model | loginForm = newLoginForm }, Cmd.map LoginFormMsg cmd )
