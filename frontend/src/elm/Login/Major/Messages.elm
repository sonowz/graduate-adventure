module Login.Major.Messages exposing (..)

import Login.Major.Models exposing (..)


type Msg
  = AddMajor Major
  | DeleteMajor Int
  | OnNewMajorTypeChange String
  | OnNewMajorChange String
