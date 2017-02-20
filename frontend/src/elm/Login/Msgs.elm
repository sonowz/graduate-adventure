module Login.Msgs exposing (..)

import Login.Models exposing (LoginType)
import Login.MajorForm.Msgs


type Msg
  = UpdateLoginType LoginType
  | UpdateUsername String
  | UpdatePassword String
  | UpdateFile String
  | UpdateUseMysnuMajors Bool
  | MajorMsg Login.MajorForm.Msgs.Msg
  | SubmitForm LoginType
