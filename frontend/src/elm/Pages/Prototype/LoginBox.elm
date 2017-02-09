module Pages.Prototype.LoginBox exposing (..)

import Html exposing (Html, div, text, button,table,thead,tr,td,th)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Result exposing (Result(..))
import TextBox
import CheckBox
import Utils.Http
import URL

-- MODEL

type alias Model =
  { textBox_ID : TextBox.Model
  , textBox_pw : TextBox.Model
  , responseText : String
  , checkBox_info : CheckBox.Model
  , visibilityTable : Html.Attribute Msg
  }


init : Model
init =
  { textBox_ID = TextBox.init
  , textBox_pw = TextBox.initpw
  , responseText = ""
  , checkBox_info = CheckBox.init
  , visibilityTable = style [("visibility","visible")]
  }


-- MESSAGES

type Msg
  = TextInput_ID TextBox.Msg
  | TextInput_pw TextBox.Msg
  | Submit
  | Response (Result Http.Error String)
  | Toggle_checkBox_info CheckBox.Msg


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
          URL.host ++ "login/mysnu/"
        
        parameter =
          "user_id=" ++ model.textBox_ID.text ++ "&password=" ++ model.textBox_pw.text

        body = 
          Http.stringBody "application/x-www-form-urlencoded" parameter
        
        request = 
          Utils.Http.postString url body
      in
        ( model, Http.send Response request )
      
    Response (Ok res) ->
      if String.length res > 100 then   -- temporary code for testing
        ( { model | responseText = "성공적으로 로그인했습니다." }, Cmd.none )
      else
        ( { model | responseText = res }, Cmd.none )
    
    Response (Err error) ->
      ( { model | responseText = "Server not responding / Bad status" }, Cmd.none )

    Toggle_checkBox_info subMsg ->
      let
        ( newBox,cmd ) =
          CheckBox.update subMsg model.checkBox_info
      in
        if model.visibilityTable == style [("visibility","visible")] then
          ({ model | checkBox_info = newBox 
                   , visibilityTable = style[("visibility","hidden")] }, Cmd.none)
        else
          ({ model | checkBox_info = newBox 
                   , visibilityTable = style[("visibility","visible")] }, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
  let
    fontType : Html.Attribute msg
    fontType = 
      style
      [ ("font-size","20px")
      , ("color","white")
      ]

    contentsType : Html.Attribute msg
    contentsType =
      style
      [ ("text-align","center")
      , ("float","left")
      , ("width","40%")
      ]

    textBoxBound : Html.Attribute msg
    textBoxBound = 
      style
      [ ("width","50%")
      , ("float","left")
      , ("border-radius","5px")
      , ("height","24px")
      ]

    buttonType : Html.Attribute msg
    buttonType =
      style
      [ ("font-size","20px")
      , ("color","black")
      , ("float","right")
      , ("text-align","center")
      , ("width","20%")
      , ("border-radius", "10px")
      ]

    tableType : Html.Attribute msg
    tableType = 
      style 
      [ ("clear","both")
      , ("width","80%")
      , ("margin-bottom", "20px")
      , ("float","left")
      , ("position","relative")
      , ("left","10%")
      , ("border-collapse","collapse")
      , ("background-color","white")
      , ("height","80px")
      ]

    tableIndexType : Html.Attribute msg
    tableIndexType =
      style
      [ ("border","1px solid white")
      , ("text-align","center")
      , ("color","white")
      , ("background-color","rgb(147,114,147)")
      ]

  in
    div [ ]
      [ div
        [ style
          [ ("padding-bottom", "50px")
          , ("padding-top","50px")
          , ("clear","left")
          ]
        ]
        [ div 
          [ contentsType,fontType ]
          [ text "id" ]
        , 
        Html.map TextInput_ID (TextBox.view model.textBox_ID textBoxBound)
        ]
      , div
        [ style
          [ ("padding-bottom", "50px")
          , ("clear","left")
          ]
        ]
        [ div 
          [ contentsType,fontType ]
          [ text "password" ]
        ,
        Html.map TextInput_pw (TextBox.view model.textBox_pw textBoxBound)
        ]
      , table
        [ model.visibilityTable
        , tableType
        ]
        [
          thead []
          [
            th [tableIndexType][text "전공구분"]
          , th [tableIndexType][text "전공명"]
          , th [tableIndexType][text "기준년도"]
          ]
          , tr[]
          [
            td [tableIndexType][text "주전공"]
          , td [tableIndexType][text "컴퓨터공학부"]
          , td [tableIndexType][text "2015"]
          ]
          , tr[]
          [
            td [tableIndexType][text "추가"]
          , td [tableIndexType][text ""]
          , td [tableIndexType][text ""]
          ]
        ]
      , button
        [ style
          [ ("margin-right", "10%")
          , ("clear","both")
          ]
          , onClick Submit
          , buttonType
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
            (CheckBox.view model.checkBox_info "마이스누 전공 정보 사용" fontType)
        ]
      , div 
        [ style [ ("clear", "both") ]
        ] 
        [ text model.responseText ] -- debug text
      ]