module Login.Messages exposing (..)

import Login.Models exposing (LoginType)
import Login.Major.Messages


type Msg
  = UpdateLoginType LoginType
  | UpdateUsername String
  | UpdatePassword String
  | UpdateFile String
  | UpdateUseMysnuMajors Bool
  | MajorMsg Login.Major.Messages.Msg
