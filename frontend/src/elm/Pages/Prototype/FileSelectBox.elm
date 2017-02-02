module Pages.Prototype.FileSelectBox exposing (..)

import Html exposing (Html, div, text, br, input, button, form)
import Html.Attributes exposing (style, type_, id)
import Html.Events exposing (onClick, onSubmit)
import Pages.Prototype.Ports as Ports

--TODO: get file info

-- MODEL

type alias Model =
  { text : String
  }


init : Model
init =
  { text = "aaaa"
  }


-- MESSAGES

type Msg
  = Submit
  | Response String
  | None


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Submit ->
      ( model, Ports.fileRequest "filerequest" )
    
    Response str ->
      ( { model | text = str }, Cmd.none )
    
    None ->
      ( model, Cmd.none )


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Ports.fileResponse Response


-- VIEW

view : Model -> Html Msg
view model =
  let
    mainBoxStyle : Html.Attribute Msg
    mainBoxStyle = 
      style
        [ ("position", "relative")
        , ("top", "50%")
        , ("left", "50%")
        , ("transform", "translateX(-50%) translateY(-50%)")
        ]
    
    fileBoxStyle : Html.Attribute Msg
    fileBoxStyle = 
      style
        [ ("position", "relative")
        , ("top", "100px")
        ]

    horizontalFloat : Html.Attribute Msg
    horizontalFloat = 
      style [ ("display", "inline-block") ]

    instructionText : List (Html Msg)
    instructionText =
      [ text "Put instructions here."
      , br [] []
      , text "ㅁㄴㅇㄹ"
      ]

  in
    div
      [ mainBoxStyle ]
      [ div [] instructionText
      , form
        [ fileBoxStyle
        , id "filerequest"
        , onSubmit None  -- Insert event.preventDefault()
        ]
        [ div [ horizontalFloat ]
          [ input [ type_ "file" ] [] ]
        , div [ horizontalFloat ]
          [ button [ onClick Submit ] [] ]
        ]
      , text ( "Debug : " ++ model.text )
      ]
        