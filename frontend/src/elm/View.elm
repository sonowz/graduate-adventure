module View exposing (..)

import Html exposing (Html, div, text, object)
import Html.Attributes exposing (class, id, src, type_, attribute)
import Routes exposing (Route(..))
import Models exposing (Model)
import Msgs exposing (Msg(..))
import Main.Models as Main
import Main.View
import Login.Models as Login
import Login.View


view : Model -> Html Msg
view model =
  let
    loadingComponents =
      case model.loading of
        True ->
          [ loadingOverlay ]
        False ->
          []
  in
    div
      [ class "elm-body" ]
      ( loadingComponents ++
        [ div
          [ class "center-wrapper" ]
          [ page model ]
        ]
      )


page : Model -> Html Msg
page model =
  case model.route of
    LoginRoute ->
      loginPage model.loginForm

    MainRoute ->
      mainPage model.mainPage

    NotFoundRoute ->
      text "page Not Found"


mainPage : Main.Model -> Html Msg
mainPage mainPage =
    Html.map MainPageMsg (Main.View.view mainPage)


loginPage : Login.Model -> Html Msg
loginPage loginForm =
    Html.map LoginFormMsg (Login.View.view loginForm)


loadingOverlay : Html Msg
loadingOverlay =
  div
    [ id "overlay" ]
    [ object
      [ id "loading"
      , attribute "data" "/static/image/loading.svg"
      , type_ "image/svg+xml"
      ]
      []
    ]
