module Login.MajorForm.Update exposing (..)

import List.Extra exposing (removeAt)
import Login.MajorForm.Msgs exposing (Msg(..))
import Login.MajorForm.Models exposing (..)


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    AddMajor ->
      let
        newMajor =
          { majorType = model.newMajorType
          , majorName = model.newMajorName
          }
        newMajors = model.majors ++ [ newMajor ]
      in
        ( { model
          | majors = newMajors
          , newMajorType = initialModel.newMajorType
          , newMajorName = initialModel.newMajorName
          }
        , Cmd.none
        )

    DeleteMajor index ->
      let
        newMajors =
          removeAt index model.majors
      in
        ( { model | majors = newMajors }, Cmd.none )

    UpdateNewMajorType updatedMajorType ->
      ( { model | newMajorType = updatedMajorType }, Cmd.none )

    UpdateNewMajorName updatedMajorName ->
      ( { model | newMajorName = updatedMajorName }, Cmd.none )
