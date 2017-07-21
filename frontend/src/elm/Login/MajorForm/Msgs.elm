module Login.MajorForm.Msgs exposing (..)

import Utils.Major exposing (MajorType)


type Msg
  = AddMajor
  | DeleteMajor Int
  | UpdateNewMajorClass MajorType
  | UpdateNewMajorField String
