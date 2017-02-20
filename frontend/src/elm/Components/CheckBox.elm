module CheckBox exposing (..)

import Html exposing (Html, div, input,text)
import Html.Attributes exposing (type_)
import Html.Events exposing (onClick)


-- MODEL

type alias Model =
  { flag : Bool
  }

-- init
init : Model
init =
  { flag = False
  }

-- MESSAGES

type Msg
  = ToggleFlag


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
  case msg of
    ToggleFlag ->
      ( { model | flag = not model.flag } , Cmd.none )


-- VIEW

view : Model -> String -> (Html.Attribute Msg) -> Html Msg
view model contents checkBoxStyle =
    div [checkBoxStyle]
      [ input 
        [ type_ "checkbox"
        , onClick ToggleFlag 
        , checkBoxStyle
        ] 
        []
        , text contents 
      ]