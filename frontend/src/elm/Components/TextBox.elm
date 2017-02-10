module TextBox exposing (..)

import Html exposing (Html, div, input)
import Html.Attributes exposing (placeholder, type_)
import Html.Events exposing (onInput)


-- MODEL

type alias Model =
  { text : String
  , defaultText : String
  , password : Bool
  , attr : Html.Attribute Msg
  }

-- no defaultText
init : (Html.Attribute Msg) -> Model
init newAttr =
  inittext "" newAttr

-- has defaultText
inittext : String -> (Html.Attribute Msg) -> Model
inittext text newAttr =
  { text = ""
  , defaultText = text
  , password = False
  , attr = newAttr
  }

-- password field
initpw : (Html.Attribute Msg) -> Model
initpw newAttr =
  let
    model =
      inittext "" newAttr
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
      [ input 
        [ type_ fieldType
        , placeholder model.defaultText
        , onInput TextInput
        , model.attr
        ] 
        [] 
      ]