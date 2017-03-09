module Login.Msgs exposing (..)

import Login.Models exposing (LoginType)
import Login.MajorForm.Msgs
import Login.Ports as Ports
import Login.Response as Response

type Msg
  = UpdateLoginType LoginType
  | UpdateUsername String
  | UpdatePassword String
  | Response String
  | UpdateUseMysnuMajors Bool
  | MajorMsg Login.MajorForm.Msgs.Msg
  | SubmitForm LoginType
  | None
