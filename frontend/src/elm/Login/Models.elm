module Login.Models exposing (..)

import Login.Major.Models exposing (..)


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


type alias LoginForm =
  { loginType : LoginType
  , mysnuLoginForm : MysnuLoginForm
  , fileLoginForm : FileLoginForm
  , majorForm : MajorForm
  }


initialLoginForm : LoginForm
initialLoginForm =
  { loginType = MysnuLogin
  , mysnuLoginForm =
    { username = ""
    , password = ""
    , useMysnuMajors = True
    }
  , fileLoginForm =
    { file = ""
    }
  , majorForm = initialMajorForm
  }
