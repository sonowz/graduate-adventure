import Html
import Pages.Prototype.Main as PMain

-- Currently using 'prototype' page as main

main : Program Never PMain.Model PMain.Msg
main =
  Html.program
    { init = PMain.init
    , view = PMain.view
    , update = PMain.update
    , subscriptions = PMain.subscriptions
    }