module Login.Major.View exposing (view)

import List exposing (indexedMap, reverse)
import Html exposing (Html, div, input, text, select, option)
import Html.Attributes exposing (id, class, type_, name, value)
import Html.Events exposing (onInput, onClick)

import Login.Major.Messages exposing (Msg(..))
import Login.Major.Models exposing (..)


view : MajorForm -> Html Msg
view majorForm =
  div
    [ id "major-info"
    , class "table"
    ]
    ([ header ] ++ (indexedMap majorRow  majorForm.majors) ++ [ newMajor majorForm ])


header : Html Msg
header =
  div
    [ class "header" ]
    [ div [ class "cell column" ] [ text "번호" ]
    , div [ class "cell column" ] [ text "전공 종류" ]
    , div [ class "cell column" ] [ text "전공 이름" ]
    ]


majorRow : Int -> Major -> Html Msg
majorRow index major =
  div
    [ class "row" ]
    [ div [ class "cell center vcenter" ] [ text (toString (index + 1)) ]
    , div [ class "cell center vcenter" ] [ text major.majorType ]
    , div [ class "cell center vcenter" ] [ text major.majorName ]
    , deleteButton index
    ]


majorTypes : List String
majorTypes =
  [ "주전공"
  , "복수전공"
  , "부전공"
  ]


majorTypeOption : String -> Html Msg
majorTypeOption majorType =
  option
    [ value majorType ]
    [ text majorType ]


newMajor : MajorForm -> Html Msg
newMajor majorForm =
  div
    [ class "row" ]
    [ div [ class "cell center vcenter" ] []
    , div
      [ class "cell center vcenter" ]
      [ select
        [ id "major-type"
        , name "major-type"
        , onInput UpdateNewMajorType
        ]
        (List.map majorTypeOption majorTypes)
      ]
    , div
      [ class "cell center vcenter" ]
      [ input
        [ type_ "text"
        , id "major-name"
        , name "major-name"
        , value majorForm.newMajorName
        , onInput UpdateNewMajorName
        ]
        []
      ]
    , addButton
    ]


addButton : Html Msg
addButton =
  input
    [ type_ "button"
    , id "add-major-button"
    , class "plus"
    , onClick AddMajor
    , value "추가"
    ]
    []


deleteButton : Int -> Html Msg
deleteButton index =
  input
    [ type_ "button"
    , id "add-major-button"
    , class "minus"
    , onClick (DeleteMajor index)
    , value "삭제"
    ]
    []
