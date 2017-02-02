module Pages.Prototype.Main exposing (..)

import Html exposing (Html, div, text, button)
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
        , ("background-color", "grey")
        , ("border-color", "black")
        , ("border-size", "1px")
        , ("border-style", "solid")
        ]

    modeSelect : Html Msg
    modeSelect = 
      div []
        [ button
          [ style <|
            [ ("width", "50%")
            , ("height", "50px")
            , ("float", "left")
            ]
            ++ loginBoxColor
          , onClick StartByLogin
          ]
          [ text "mySNU Login" ]
        , button
          [ style <|
            [ ("width", "50%")
            , ("height", "50px")
            , ("float", "right")
            ]
            ++ fileBoxColor
          , onClick StartByFile
          ]
          [ text "Load From File" ]
        ]

    (loginBoxColor, fileBoxColor) =
      if model.useLoginBox then
        ( [("background-color", "yellowgreen")], [("background-color", "green")] )
      else
        ( [("background-color", "green")], [("background-color", "yellowgreen")] )
    
    selectedModeBox : Html Msg
    selectedModeBox = 
      if model.useLoginBox then
        Html.map LoginBoxMsg (LoginBox.view model.loginBox)
      else
        Html.map FileSelectBoxMsg (FileSelectBox.view model.fileSelectBox)

  in
    div
      [ mainBoxStyle ]
      [ modeSelect
      , selectedModeBox
      ]