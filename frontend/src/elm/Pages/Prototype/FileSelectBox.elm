module Pages.Prototype.FileSelectBox exposing (..)

import Html exposing (Html, div, text, br, input)
import Html.Attributes exposing (style, type_)

--TODO: get file info

-- MODEL

type alias Model =
  { file : Maybe String
  }


init : Model
init =
  { file = Nothing
  }


-- MESSAGES

type Msg
  = FileSelection String


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    FileSelection newFile ->
      ( { model | file = Just newFile }, Cmd.none )


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
      , div [ fileBoxStyle ]
        [ div [ horizontalFloat ]
          [ input [ type_ "file" ] [] ]
        , div [ horizontalFloat ]
          [ input [ type_ "submit" ] [] ]
        ]
    --, text ( "Debug : " ++ (Maybe.withDefault "nofile" model.file) )
      , text ( toString (div[] [text "aaa"]))
      ]
        