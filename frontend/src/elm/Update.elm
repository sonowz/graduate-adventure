module Update exposing (..)

import Msgs exposing (Msg(..))
import Login.Msgs
import GlobalMsgs exposing (GlobalMsg(..))
import Models exposing (Model)
import Routes exposing (parseLocation)
import Login.Update
import Main.Update
import Cmd.Extra exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnLocationChange location ->
      let
        newRoute =
          parseLocation location
      in
        ( { model | route = newRoute }, Cmd.none )

    MainPageMsg mainPageMsg ->
      let
        ( newMainPage, cmd ) =
          Main.Update.update mainPageMsg model.mainPage
      in
        ( { model | mainPage = newMainPage }, Cmd.map MainPageMsg cmd )

    LoginFormMsg loginFormMsg ->
      case loginFormMsg of
        Login.Msgs.Global global ->
          ( model, perform (Global global) )

        _ ->
          let
            ( newLoginForm, cmd ) =
              Login.Update.update loginFormMsg model.loginForm
          in
            ( { model | loginForm = newLoginForm }, Cmd.map LoginFormMsg cmd )

    Global global ->
      case global of
        Loading on ->
          ( { model | loading = on }, Cmd.none )
