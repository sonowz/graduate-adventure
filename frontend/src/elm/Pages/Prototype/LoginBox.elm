module Pages.Prototype.LoginBox exposing (..)

import Html exposing (Html, div, text, button,table,thead,tr,td,th)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)
import Http
import Result exposing (Result(..))
import Pages.Prototype.Response as Response
import TextBox
import CheckBox

-- MODEL

type alias Model =
  { textBox_ID : TextBox.Model
  , textBox_pw : TextBox.Model
  , responseText : String
  , checkBox_info : CheckBox.Model
  }

textBoxBound : Html.Attribute msg
textBoxBound = 
  style
  [ ("width","50%")
  , ("float","left")
  , ("border-radius","5px")
  , ("height","24px")
  ]

init : Model
init =
  { textBox_ID = TextBox.init textBoxBound
  , textBox_pw = TextBox.initpw textBoxBound
  , responseText = ""
  , checkBox_info = CheckBox.init
  }


-- MESSAGES

type Msg
  = TextInput_ID TextBox.Msg
  | TextInput_pw TextBox.Msg
  | Submit
  | Toggle_checkBox_info CheckBox.Msg
  | Response (Result Http.Error Response.Decoded)


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
          "/api/login/mysnu/"
        
        parameter =
          "user_id=" ++ model.textBox_ID.text ++ "&password=" ++ model.textBox_pw.text

        body = 
          Http.stringBody "application/x-www-form-urlencoded" parameter
        
        request = 
          Http.post url body Response.decoder
      in
        ( model, Http.send Response request )
      
    -- TODO: make request to main page when successful
    Response (Ok decoded) ->
      ( { model | responseText = Maybe.withDefault "" decoded.message }, Cmd.none )
    
    Response (Err error) ->
      ( { model | responseText = "Bad response" }, Cmd.none )

    Toggle_checkBox_info subMsg ->
      let
        ( newBox,cmd ) =
          CheckBox.update subMsg model.checkBox_info
      in
        if model.checkBox_info.flag then
          ({ model | checkBox_info = newBox }, Cmd.none)
        else
          ({ model | checkBox_info = newBox }, Cmd.none)


visibilityTable : Bool -> Html.Attribute msg
visibilityTable flag =
  case flag of
    True -> style [("visibility","hidden")]
    False -> style [("visibility","visible")]

-- VIEW

view : Model -> Html Msg
view model =
    div [ ]
      [ div
        [ style
          [ ("padding-bottom", "50px")
          , ("padding-top","50px")
          , ("clear","left")
          ]
        ]
        [ div 
          [ class "loginStyle-font" ]
          [ text "id" ]
        , 
        Html.map TextInput_ID (TextBox.view model.textBox_ID)
        ]
      , div
        [ style
          [ ("padding-bottom", "50px")
          , ("clear","left")
          ]
        ]
        [ div 
          [ class "loginStyle-font" ]
          [ text "password" ]
        ,
        Html.map TextInput_pw (TextBox.view model.textBox_pw)
        ]
      , table
        [ visibilityTable model.checkBox_info.flag
        , class "loginStyle-table"
        ]
        [
          thead []
          [
            th [class "loginStyle-tableIndex"][text "전공구분"]
          , th [class "loginStyle-tableIndex"][text "전공명"]
          , th [class "loginStyle-tableIndex"][text "기준년도"]
          ]
          , tr[]
          [
            td [class "loginStyle-tableIndex"][text "주전공"]
          , td [class "loginStyle-tableIndex"][text "컴퓨터공학부"]
          , td [class "loginStyle-tableIndex"][text "2015"]
          ]
          , tr[]
          [
            td [class "loginStyle-tableIndex"][text "추가"]
          , td [class "loginStyle-tableIndex"][text ""]
          , td [class "loginStyle-tableIndex"][text ""]
          ]
        ]
      , button
        [ style
          [ ("margin-right", "10%")
          , ("clear","both")
          ]
          , onClick Submit
          , class "loginStyle-button"
        ]
        [ text "Login" ]
      , div
        [ style
          [ ("margin-left","10%")
          , ("float","left")
          ]
        ]
        [
          Html.map Toggle_checkBox_info 
            (CheckBox.view model.checkBox_info "마이스누 전공 정보 사용" (class "loginStyle-buttonFont"))
        ]
      , div 
        [ style [ ("clear", "both") ]
        ] 
        [ text model.responseText ] -- debug text
      ]