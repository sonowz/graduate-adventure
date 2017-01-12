module TextBox exposing (..)

import Html exposing (Html, div, input)
import Html.Attributes exposing (placeholder, type_)
import Html.Events exposing (onInput)


-- MODEL

type alias Model =
  { text : String
  , defaultText : String
  , password : Bool
  }

-- no defaultText
init : Model
init =
  init2 ""

-- has defaultText
init2 : String -> Model
init2 text =
  { text = ""
  , defaultText = text
  , password = False
  }

-- password field
initpw : Model
initpw =
  let
    model = init2 ""
  in
    { model | password = True }


-- MESSAGES

type Msg
  = TextInput String


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    TextInput newText ->
      ( { model | text = newText }, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
  let
    fieldType =
      if model.password then "password" else "text"
  in
    div []
      [ input [ type_ fieldType, placeholder model.defaultText, onInput TextInput ] [] ]