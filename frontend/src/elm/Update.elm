module Update exposing (..)

import Msgs exposing (Msg(..))
import Models exposing (Model)
import Routes exposing (parseLocation)
import Login.Update
import Main.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnLocationChange location ->
      let
        newRoute =
          parseLocation location
      in
        ( { model | route = newRoute }, Cmd.none )

    MainFormMsg mainFormMsg ->
      let
        ( newMainForm, cmd ) =
          Main.Update.update mainFormMsg model.mainForm
      in
        ( { model | mainForm = newMainForm }, Cmd.map MainFormMsg cmd )

    LoginFormMsg loginFormMsg ->
      let
        ( newLoginForm, cmd ) =
          Login.Update.update loginFormMsg model.loginForm
      in
        ( { model | loginForm = newLoginForm }, Cmd.map LoginFormMsg cmd )
