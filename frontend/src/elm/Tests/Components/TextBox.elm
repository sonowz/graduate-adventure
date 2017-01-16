module Tests.Components.TextBox exposing (tests)

import Test exposing(Test, describe, test)
import Expect exposing(..)
import Tests.Util as Util
import TextBox exposing (..)


tests : Test
tests = 
  describe "TextBox"
    [ describe "constructors"
      [ test "init" <| \_ ->
          init |> .defaultText
            |> equal ""
      
      , test "inittext with blank string" <| \_ ->
          inittext "" |> .defaultText
            |> equal ""
      
      , test "inittext with some string" <| \_ ->
          inittext " _str __" |> .defaultText
            |> equal " _str __"
      
      , test "initpw" <| \_ ->
          initpw |> .password
            |> equal True
      ]

    , describe "update function"
      [ test "update to msgText properly" <| \_ ->
          let
            ( updatedModel, _ ) =
              update testMsg testModel
          in
            updatedModel.text
              |> equal "msgText"
      ]

    , describe "view function"
      [ test "testModel should have defText" <| \_ ->
          Util.htmlHasStr ( view testModel ) "defText"
            |> equal True
      
      , test "initpw should be password type" <| \_ ->
          Util.htmlHasStr ( view initpw ) "type = \"password\""
            |> equal True
      ]
    ]


testMsg = 
  TextBox.TextInput "msgText"


testModel = 
  inittext "defText"



