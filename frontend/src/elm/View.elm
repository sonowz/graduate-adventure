module View exposing (..)

import Html exposing (Html, div, text)
import Models exposing (Model)
import Messages exposing (Msg(..))
import Routes exposing (Route(..))


view : Model -> Html Msg
view model =
  div []
    [ page model ]


page : Model -> Html Msg
page model =
  case model.route of
    LoginRoute ->
      text "login page"

    MainRoute ->
      text model.result

    NotFoundRoute ->
      text "page Not Found"
