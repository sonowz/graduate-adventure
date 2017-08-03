module Utils.Major exposing (..)

import Maybe


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

stringToType : String -> Maybe MajorType
stringToType input =
  case input of
    "주전공" ->
      Just MajorSingle
    "주전공(복/부)" ->
      Just MajorMulti
    "부전공" ->
      Just Minor
    "복수전공" ->
      Just DoubleMajor
    _ ->
      Nothing


specify : Maybe MajorType -> MajorType
specify type_ = Maybe.withDefault MajorSingle type_

stringToTypeSpecific : String -> MajorType
stringToTypeSpecific input = specify (stringToType input)


typeToShort : MajorType -> String
typeToShort majorType =
  typeToString majorType
    |> String.left 1


toString : Major -> String
toString major =
  major.name ++ "/" ++ typeToShort major.type_
