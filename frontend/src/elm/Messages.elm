module Messages exposing (..)

import Navigation exposing (Location)
import Login.Messages


type Msg
  = OnLocationChange Location
  | LoginFormMsg Login.Messages.Msg
