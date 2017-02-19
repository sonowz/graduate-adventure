module Pages.Prototype.FileSelectBox exposing (..)

import Html exposing (Html, div, text, br, input, button, form)
import Html.Attributes exposing (style, type_, id, name, value)
import Html.Events exposing (onClick, onSubmit)
import Json.Decode as Json
import Result exposing (Result(..))
import Pages.Prototype.Ports as Ports
import Pages.Prototype.Response as Response


-- MODEL

type alias Model =
  { responseText : String
  }


init : Model
init =
  { responseText = ""
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
      let
        formID =
          "filerequest"

        url = 
          "/api/login/file/"
      in
        ( model, Ports.fileRequest ( formID ++ "@" ++ url ) )
    
    Response str ->
      let
        decodedResult : Result String Response.Decoded
        decodedResult = 
          Json.decodeString Response.decoder str
      in
        case decodedResult of
          Ok decoded ->
            ( { model | responseText = Maybe.withDefault "" decoded.message }, Cmd.none )
          
          Err error ->
            ( { model | responseText = "Bad response" }, Cmd.none )
    
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
      [ ]
      [ div [] instructionText
      , form
        [ id "filerequest"
        , onSubmit None  -- Insert event.preventDefault()
        ]
        [ div [ horizontalFloat ]
          [ input [ type_ "file", name "course.txt" ] [] ]
        , div [ ]
          [ button [ onClick Submit, value "Submit" ] [] ]
        , input [ type_ "hidden", name "filename", value "course.txt" ] []
        ]
      , text ( "Debug : " ++ model.responseText )
      ]
        