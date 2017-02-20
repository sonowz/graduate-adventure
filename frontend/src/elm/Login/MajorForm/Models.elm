module Login.MajorForm.Models exposing (..)


type alias Major =
  { majorType : String
  , majorName : String
  }


type alias Model =
  { majors : List Major
  , newMajorType : String
  , newMajorName : String
  }


initialModel : Model
initialModel =
  { majors = []
  , newMajorType = "주전공"
  , newMajorName = ""
  }
