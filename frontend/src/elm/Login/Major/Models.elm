module Login.Major.Models exposing (..)


type alias Major =
  { majorType : String
  , majorName : String
  }


type alias MajorForm =
  { majors : List Major
  , newMajorType : String
  , newMajorName : String
  }


initialMajorForm : MajorForm
initialMajorForm =
  { majors = []
  , newMajorType = "주전공"
  , newMajorName = ""
  }
