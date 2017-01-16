module Tests.Util exposing (..)

import Html exposing (Html)


{--
  This function do 'Html.toString' to get string.
  example output :
    toString ( div [] [ text "aaa" ] ) ==

    { type = "node", tag = "div", facts = {},                  \
      children = { 0 = { type = "text", text = "aaa" } },      \
      namespace = <internal structure>, descendantsCount = 1   \
    }
--}

htmlHasStr : Html a -> String -> Bool
htmlHasStr msg str = 
  String.contains str ( toString msg )


htmlHasStrs : Html a -> List String -> Bool
htmlHasStrs msg list = 
  List.all ( htmlHasStr msg ) list