module Msgs exposing (..)

import Navigation exposing (Location)
import Login.Msgs
import Main.Msgs


type Msg
  = OnLocationChange Location
  | LoginFormMsg Login.Msgs.Msg
  | MainPageMsg Main.Msgs.Msg
