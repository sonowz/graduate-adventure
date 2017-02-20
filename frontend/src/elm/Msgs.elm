module Msgs exposing (..)

import Navigation exposing (Location)
import Login.Msgs


type Msg
  = OnLocationChange Location
  | LoginFormMsg Login.Msgs.Msg
