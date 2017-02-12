module Login.Major.Update exposing (..)

import List.Extra exposing (removeAt)
import Login.Major.Messages exposing (Msg(..))
import Login.Major.Models exposing (Major, MajorForm, initialMajorForm)


update : Msg -> MajorForm -> (MajorForm, Cmd Msg)
update message majorForm =
  case message of
    AddMajor ->
      let
        newMajor =
          { majorType = majorForm.newMajorType
          , majorName = majorForm.newMajorName
          }
        newMajors = majorForm.majors ++ [ newMajor ]
      in
        ( { majorForm 
          | majors = newMajors
          , newMajorType = initialMajorForm.newMajorType
          , newMajorName = initialMajorForm.newMajorName
          }
        , Cmd.none 
        )

    DeleteMajor index ->
      let
        newMajors =
          removeAt index majorForm.majors
      in
        ( { majorForm | majors = newMajors }, Cmd.none )

    UpdateNewMajorType updatedMajorType ->
      ( { majorForm | newMajorType = updatedMajorType }, Cmd.none )

    UpdateNewMajorName updatedMajorName ->
      ( { majorForm | newMajorName = updatedMajorName }, Cmd.none )
