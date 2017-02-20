module Login.Models exposing (..)

import Login.MajorForm.Models as Major


type LoginType
  = MysnuLogin
  | FileLogin


type alias MysnuLoginForm =
  { username : String
  , password : String
  , useMysnuMajors : Bool
  }


type alias FileLoginForm =
  { file : String
  }


type alias Model =
  { loginType : LoginType
  , mysnuLoginForm : MysnuLoginForm
  , fileLoginForm : FileLoginForm
  , majorForm : Major.Model
  }


initialModel : Model
initialModel =
  { loginType = MysnuLogin
  , mysnuLoginForm =
    { username = ""
    , password = ""
    , useMysnuMajors = True
    }
  , fileLoginForm =
    { file = ""
    }
  , majorForm = Major.initialModel
  }
