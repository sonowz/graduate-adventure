module Utils.Major exposing (..)


type alias Major =
  { name : String
  , type_ : MajorType
  }


type MajorType
  = MajorSingle
  | MajorMulti
  | Minor
  | DoubleMajor


typeToString : MajorType -> String
typeToString majorType =
  case majorType of
    MajorSingle ->
      "주전공(단일)"
    MajorMulti ->
      "주전공(복/부)"
    Minor ->
      "부전공"
    DoubleMajor ->
      "복수전공"

stringToType : String -> MajorType
stringToType input =
  case input of
    "주전공(단일)" ->
      MajorSingle
    "주전공(복/부)" ->
      MajorMulti
    "부전공" ->
      Minor
    "복수전공" ->
      DoubleMajor


typeToShort : MajorType -> String
typeToShort majorType =
  typeToString majorType
    |> String.left 1


toString : Major -> String
toString major =
  major.name ++ "/" ++ typeToShort major.type_
