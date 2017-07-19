module Login.Msgs exposing (..)

import Login.Models exposing (LoginType)
import Login.MajorForm.Msgs
import Http
import GlobalMsgs exposing (..)

type Msg
  = UpdateLoginType LoginType
  | UpdateUsername String
  | UpdatePassword String
  | Response (Result Http.Error Bool)
  | Responsejs String
  | UpdateUseMysnuMajors Bool
  | MajorMsg Login.MajorForm.Msgs.Msg
  | SubmitForm LoginType
  | None
  | Global GlobalMsg
