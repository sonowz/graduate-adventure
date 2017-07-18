module Login.MajorForm.View exposing (view)

import List exposing (indexedMap, reverse)
import Html exposing (Html, div, input, text, select, option)
import Html.Attributes exposing (id, class, type_, name, value)
import Html.Events exposing (onInput, onClick)
import Login.MajorForm.Msgs exposing (Msg(..))
import Login.MajorForm.Models exposing (..)
import Select
import Utils.Major as Major exposing (Major, MajorType(..))


view : Model -> Html Msg
view majorForm =
  div [ id "major-info" ]
    [ div []
        [ header
        , div [ class "table_scroll" ] ( indexedMap majorRow majorForm.majors )
        , newMajor majorForm
        ]
    , div [ id "table-wrapper" ] []
    ]


header : Html Msg
header =
  div
    [ class "table header" ]
    [ div [ class "cell number" ] [ text "번호" ]
    , div [ class "cell major-type" ] [ text "전공 종류" ]
    , div [ class "cell major-name" ] [ text "전공 이름" ]
    ]


majorRow : Int -> Major -> Html Msg
majorRow index major =
  div
    [ class "table row" ]
    [ div [ class "cell number" ] [ text (toString (index + 1)) ]
    , div [ class "cell major-type" ] [ text (Major.typeToString major.type_) ]
    , div [ class "cell major-name" ] [ text major.name ]
    , deleteButton index
    ]


majorTypeOption : String -> Html Msg
majorTypeOption majorType =
  option
    [ value majorType ]
    [ text majorType ]


newMajor : Model -> Html Msg
newMajor majorForm =
  let
    majorClasses =
      [ MajorSingle, MajorMulti, Minor, DoubleMajor ]
  in
    div
      [ class "table row" ]
      [ div [ class "cell center vcenter number" ] []
      , div
        [ class "cell center vcenter major-type" ]
        [ Select.from_ majorClasses UpdateNewMajorClass toString Major.typeToString
        ]
      , div
        [ class "cell center vcenter major-name" ]
        [ input
          [ type_ "text"
          , id "major-name"
          , name "major-name"
          , value majorForm.newMajor.name
          , onInput UpdateNewMajorField
          ]
          []
        ]
      , addButton
      ]


addButton : Html Msg
addButton =
  div
    [ id "major-button" ]
    [
      input
        [ type_ "button"
        , class "plus"
        , onClick AddMajor
        , value "+"
        ]
        []
    ]


deleteButton : Int -> Html Msg
deleteButton index =
  div
    [ id "major-button" ]
    [
      input
        [ type_ "button"
        , class "minus"
        , onClick (DeleteMajor index)
        , value "-"
        ]
        []
    ]
