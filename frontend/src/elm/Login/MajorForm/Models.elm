module Login.MajorForm.Models exposing (..)

import Utils.Major exposing (Major, MajorType(..))

type alias Model =
  { majors : List Major
  , newMajor : Major
  }


initialModel : Model
initialModel =
  { majors = []
  , newMajor =
    { name = ""
    , type_ = MajorSingle
    }
  }
