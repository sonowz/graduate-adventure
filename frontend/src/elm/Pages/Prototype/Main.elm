module Pages.Prototype.Main exposing (..)

import Html exposing (Html, div, text, button,body)
import Html.Events exposing (onClick)
import Html.Attributes exposing (align, style)
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
    mainBoxStyle : Html.Attribute Msg
    mainBoxStyle = 
      style
        [ ("position", "absolute")
        , ("top", "50%")
        , ("left", "50%")
        , ("transform", "translateX(-50%) translateY(-50%)")
        , ("width", "500px")
        , ("height", "350px")
        , ("background-color", "rgba(0,0,0,0.5)")
        ]
    buttonStyle : Html.Attribute Msg
    buttonStyle =
      style
        [ ("width", "50%")
        , ("height", "50px")
        , ("border", "none")
        , ("outline", "none")
        ]
    titleType : Html.Attribute Msg
    titleType =
      style
        [ ("font-size","22px")
        , ("color","white")
        ]

    modeSelect : Html Msg
    modeSelect = 
      div []
        [ button
          [ style <|[("float", "left")] ++ loginBoxColor
          , onClick StartByLogin
          , titleType
          , buttonStyle
          ]
          [ text "계정으로 로그인" ]
        , button
          [ style <|[("float", "right")] ++ fileBoxColor
          , onClick StartByFile
          , titleType
          , buttonStyle
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
    [
      style 
      [ ("background","-webkit-linear-gradient(rgb(99, 92, 136) 27%, rgb(148, 114, 147) 53%, rgb(219, 165, 139) 87%, rgb(214, 191, 164) 100%)")
      , ("background","linear-gradient(rgb(99, 92, 136) 27%, rgb(148, 114, 147) 53%, rgb(219, 165, 139) 87%, rgb(214, 191, 164) 100%)")
      , ("min-height","100vh") 
      , ("height","100%")
      ]
    ]
    [
      div
      [ mainBoxStyle ]
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
    
    