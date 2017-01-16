module Tests.Pages.Prototype exposing (tests)

import Test exposing (Test, describe, test)
import Expect exposing (equal)
import Tests.Util as Util
import Pages.Prototype.Main as Main


tests : Test
tests = 
  describe "Prototype"
    [ describe "constructors"
      [ test "Initial Cmd should be 'Cmd.none'" <|
        \_ ->
          let
            ( _, cmd ) = 
              Main.init
          in
            cmd |> equal Cmd.none
      ]

    , describe "update function"
      [ 
      ]

    , describe "view function"
      [ test "should print LoginBox" <|
        \_ ->
          Util.htmlHasStrs (Main.view loginModel) [ "ID", "PW" ]
            |> equal True
      
      , test "should print FileSelectBox" <|
        \_ ->
          Util.htmlHasStr (Main.view fileModel) "type = \"file\""
            |> equal True
      ]
    ]


loginModel =
  let
    ( model, cmd ) = 
      Main.init
  in
    model


fileModel =
  let
    ( model, cmd ) = 
      Main.init
  in
    { model | useLoginBox = False }