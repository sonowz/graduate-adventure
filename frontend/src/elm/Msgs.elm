module Msgs exposing (..)

import Navigation exposing (Location)
import Login.Msgs
import Main.Msgs
import GlobalMsgs exposing (..)


type Msg
  = OnLocationChange Location
  | LoginFormMsg Login.Msgs.Msg
  | MainPageMsg Main.Msgs.Msg
  | Global GlobalMsg
