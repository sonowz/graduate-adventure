module Tests.Components.TextBox exposing (tests)

import Html.Attributes exposing (style)
import Test exposing (Test, describe, test)
import Expect exposing (equal)
import Tests.Util as Util
import TextBox exposing (..)


tests : Test
tests = 
  describe "TextBox"
    [ describe "constructors"
      [ test "init" <|
        \_ ->
          init testAttr |> .defaultText
            |> equal ""
      
      , test "inittext with blank string" <|
        \_ ->
          inittext "" testAttr |> .defaultText
            |> equal ""
      
      , test "inittext with some string" <|
        \_ ->
          inittext " _str __" testAttr |> .defaultText
            |> equal " _str __"
      
      , test "initpw" <|
        \_ ->
          initpw testAttr |> .password
            |> equal True
      ]

    , describe "update function"
      [ test "update to msgText properly" <|
        \_ ->
          let
            ( updatedModel, cmd ) =
              update testMsg testModel
          in
            updatedModel.text
              |> equal "msgText"
      ]

    , describe "view function"
      [ test "testModel should have defText" <|
        \_ ->
          Util.htmlHasStr ( view testModel ) "defText"
            |> equal True
      
      , test "initpw should be password type" <|
        \_ ->
          Util.htmlHasStr ( view ( initpw testAttr ) ) "type = \"password\""
            |> equal True
      ]
    ]


testMsg = 
  TextBox.TextInput "msgText"


testModel = 
  inittext "defText" testAttr


testAttr = 
  style []