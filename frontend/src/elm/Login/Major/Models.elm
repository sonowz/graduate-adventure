module Login.Major.Models exposing (..)


type alias Major =
  { majorType : String
  , major : String
  }


type alias MajorForm =
  { majors : List Major
  , majorType : String
  , major : String
  }


initialMajorForm : MajorForm
initialMajorForm =
  { majors = []
  , majorType = ""
  , major = ""
  }
