module View exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Models exposing (Model)
import Msgs exposing (Msg(..))
import Routes exposing (Route(..))
import Login.View
import Login.Models as Login


view : Model -> Html Msg
view model =
  page model


page : Model -> Html Msg
page model =
  case model.route of
    LoginRoute ->
      loginPage model.loginForm

    MainRoute ->
      text model.result

    NotFoundRoute ->
      text "page Not Found"


loginPage : Login.Model -> Html Msg
loginPage loginForm =
  div
    [ class "center-wrapper" ]
    [ Html.map LoginFormMsg (Login.View.view loginForm) ]
