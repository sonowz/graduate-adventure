module Pages.Prototype.Main exposing (..)

import Html exposing (Html, div, text, button,body)
import Html.Events exposing (onClick)
import Html.Attributes exposing (align, style, class)
import Pages.Prototype.LoginBox as LoginBox
import Pages.Prototype.FileSelectBox as FileSelectBox


-- MODEL

type alias Model =
  { useLoginBox : Bool
  , loginBox : LoginBox.Model
  , fileSelectBox : FileSelectBox.Model
  }


init : ( Model, Cmd Msg )
init =
  ( { useLoginBox = True
    , loginBox = LoginBox.init
    , fileSelectBox = FileSelectBox.init
    }
  , Cmd.none )


-- MESSAGES

type Msg
  = StartByLogin
  | StartByFile
  | LoginBoxMsg LoginBox.Msg
  | FileSelectBoxMsg  FileSelectBox.Msg


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    StartByLogin ->
      ( { model | useLoginBox = True }, Cmd.none )

    StartByFile ->
      ( { model | useLoginBox = False }, Cmd.none )

    LoginBoxMsg subMsg ->
      let
        ( newModel, cmd ) =
          LoginBox.update subMsg model.loginBox
      in
        ( { model | loginBox = newModel }, Cmd.map LoginBoxMsg cmd )
    
    FileSelectBoxMsg subMsg ->
      let
        ( newModel, cmd ) =
          FileSelectBox.update subMsg model.fileSelectBox
      in
        ( { model | fileSelectBox = newModel }, Cmd.map FileSelectBoxMsg cmd )


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ FileSelectBox.subscriptions model.fileSelectBox
      |> Sub.map FileSelectBoxMsg
    ]


-- VIEW

view : Model -> Html Msg
view model =
  let
    modeSelect : Html Msg
    modeSelect = 
      div []
        [ button
          [ style <|[("float", "left")] ++ loginBoxColor
          , onClick StartByLogin
          , class "mainStyle-button"
          ]
          [ text "계정으로 로그인" ]
        , button
          [ style <|[("float", "right")] ++ fileBoxColor
          , onClick StartByFile
          , class "mainStyle-button"
          ]
          [ text "성적 파일로 입력" ]
        ]

    (loginBoxColor, fileBoxColor) =
      if model.useLoginBox then
        ( [("background-color", "rgba(0,0,0,0)")],
          [("background-color", "rgba(0,0,0,0.75)")] )
      else
        ( [("background-color", "rgba(0,0,0,0.75)")],
          [("background-color", "rgba(0,0,0,0)")] )
    
    selectedModeBox : Html Msg
    selectedModeBox = 
      if model.useLoginBox then
        Html.map LoginBoxMsg (LoginBox.view model.loginBox)
      else
        Html.map FileSelectBoxMsg (FileSelectBox.view model.fileSelectBox)

  in
    div
    [ class "Background" ]
    [
      div
      [ class "mainStyle-border" ]
      [ 
        div
        [ style 
          [("height","50px")]
        ]
        [ modeSelect ]
        ,
        div
        [ style
          [("height","300px")]
        ]
        [ selectedModeBox ]
      ]
    ]
    
    