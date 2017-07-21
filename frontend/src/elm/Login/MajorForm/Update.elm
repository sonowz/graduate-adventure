module Login.MajorForm.Update exposing (..)

import List.Extra exposing (removeAt)
import Login.MajorForm.Msgs exposing (Msg(..))
import Login.MajorForm.Models exposing (..)


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    AddMajor ->
      let
        newMajors =
          model.majors ++ [ model.newMajor ]

        newInitMajor =
          { name = ""
          , type_ = model.newMajor.type_
          }
      in
        ( { model
          | majors = newMajors
          , newMajor = newInitMajor
          }
        , Cmd.none
        )

    DeleteMajor index ->
      let
        newMajors =
          removeAt index model.majors
      in
        ( { model | majors = newMajors }, Cmd.none )

    UpdateNewMajorClass majorClass ->
      let
        changedMajor =
          { name = model.newMajor.name
          , type_ = majorClass
          }
      in
        ( { model | newMajor = changedMajor }, Cmd.none )

    UpdateNewMajorField majorField ->
      let
        changedMajor =
          { name = majorField
          , type_ = model.newMajor.type_
          }
      in
      ( { model | newMajor = changedMajor }, Cmd.none )
