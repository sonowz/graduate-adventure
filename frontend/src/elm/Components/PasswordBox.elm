module PasswordBox exposing (..)

import Html exposing (Html, div, input)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onInput)
import TextBox exposing (Msg(..))

-- WARNING : This is obsolete code (left for code reference)
--           Use 'TextBox.initpw' constructor instead

-- INHERITANCE
-- TODO: is there a better way to inherit?
type alias Model = TextBox.Model
init = TextBox.init
init2 = TextBox.init2
type Msg = TextInput String


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    TextInput newText ->
      ( { model | text = filterText newText model.text }, Cmd.none )


filterText : String -> String -> String
filterText new old = 
  let
    newl = String.toList new
    
    oldl = String.toList <| String.padRight (String.length new) '*' old

    replace : Char -> Char -> Char
    replace x y = if x == '*' then y else x
  in
    List.map2 replace newl oldl
      |> String.fromList


-- VIEW

view : Model -> Html Msg
view model =
  let
    showText = 
      String.repeat (String.length model.text) "*"
  in
    div []
      [ input [ placeholder model.defaultText, value showText, onInput TextInput ] [] ]