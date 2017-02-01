module Pages.Prototype.LoginBox exposing (..)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as Json
import Http
import Maybe exposing (..)
import Result exposing (Result(..))
import TextBox
import Utils.Http
import URL


-- MODEL

type alias Model =
  { textBox_ID : TextBox.Model
  , textBox_pw : TextBox.Model
  , responseText : String
  }


init : Model
init =
  { textBox_ID = TextBox.init
  , textBox_pw = TextBox.initpw
  , responseText = ""
  }


-- MESSAGES

type Msg
  = TextInput_ID TextBox.Msg
  | TextInput_pw TextBox.Msg
  | Submit
  | Response (Result Http.Error JsonMsg)


type alias JsonMsg = 
  { success : Bool
  , message : Maybe String
  }


decoder : Json.Decoder JsonMsg
decoder = 
  Json.map2 JsonMsg
    ( Json.field "success" Json.bool )
    ( Json.maybe <| Json.field "message" Json.string )


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    TextInput_ID subMsg ->
      let
        ( newBox, cmd ) =
          TextBox.update subMsg model.textBox_ID
      in
        ( { model | textBox_ID = newBox }, Cmd.map TextInput_ID cmd )
    
    TextInput_pw subMsg ->
      let
        ( newBox, cmd ) =
          TextBox.update subMsg model.textBox_pw
      in
        ( { model | textBox_pw = newBox }, Cmd.map TextInput_pw cmd )
    
    Submit ->
      let
        url =
          URL.host ++ "api/login/mysnu/"
        
        parameter =
          "user_id=" ++ model.textBox_ID.text ++ "&password=" ++ model.textBox_pw.text

        body = 
          Http.stringBody "application/x-www-form-urlencoded" parameter
        
        request = 
          Http.post url body decoder
      in
        ( model, Http.send Response request )
      
    -- TODO: make request to main page when successful
    Response (Ok jsonMsg) ->
      let 
        newText = 
          withDefault "성공적으로 로그인했습니다." jsonMsg.message 
      in
        ( { model | responseText = newText }, Cmd.none )
    
    Response (Err error) ->
      ( { model | responseText = "Server not responding / Bad status" }, Cmd.none )


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

    horizontalFloat : Html.Attribute Msg
    horizontalFloat = 
      style [ ("display", "inline-block") ]

  in
    div
      [ mainBoxStyle ]
      [ div
        [ style
          [ ("position", "relative")
          , ("left", "150px")
          , ("bottom", "20px")
          ]
        ]
        [ div [ horizontalFloat ]
          [ text "ID" ]
        , div [ horizontalFloat ]
          [ Html.map TextInput_ID (TextBox.view model.textBox_ID) ]
        ]
      , div
        [ style
          [ ("position", "relative")
          , ("left", "142px")
          , ("top", "10px")
          ]
        ]
        [ div [ horizontalFloat ]
          [ text "PW" ]
        , div [ horizontalFloat ]
          [ Html.map TextInput_pw (TextBox.view model.textBox_pw) ]
        , text ("Debug : " ++ model.textBox_pw.text)
        ]
      , button
        [ style
          [ ("position", "relative")
          , ("left", "325px")
          , ("top", "30px")
          ]
        , onClick Submit
        ]
        [ text "Sign In" ]
      , div [ style [ ("top", "50px") ] ] [ text model.responseText ] -- debug text
      ]