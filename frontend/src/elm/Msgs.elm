module Msgs exposing (..)

import Navigation exposing (Location)
import GlobalMsgs exposing (..)
import Main.Msgs
import Login.Msgs


type Msg
  = OnLocationChange Location
  | LoginFormMsg Login.Msgs.Msg
  | MainPageMsg Main.Msgs.Msg
  | Global GlobalMsg
