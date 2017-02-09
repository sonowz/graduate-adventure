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
  inittext ""

-- has defaultText
inittext : String -> Model
inittext text =
  { text = ""
  , defaultText = text
  , password = False
  }

-- password field
initpw : Model
initpw =
  let
    model =
      inittext ""
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

view : Model -> (Html.Attribute Msg) -> Html Msg
view model textBoxType=
  let
    fieldType =
      if model.password then "password" else "text"
  in
    div []
      [ input 
        [ type_ fieldType
        , placeholder model.defaultText
        , onInput TextInput
        , textBoxType 
        ] 
        [] 
      ]