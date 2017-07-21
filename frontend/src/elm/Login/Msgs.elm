module Login.Msgs exposing (..)

import Http
import GlobalMsgs exposing (..)
import Login.Models exposing (LoginType)
import Login.MajorForm.Msgs


type Msg
  = UpdateLoginType LoginType
  | UpdateUsername String
  | UpdatePassword String
  | Response (Result Http.Error Bool)
  | Responsejs String
  | UpdateUseMysnuMajors Bool
  | MajorMsg Login.MajorForm.Msgs.Msg
  | SubmitForm LoginType
  | Global GlobalMsg
