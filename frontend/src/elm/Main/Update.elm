module Main.Update exposing (..)

import Main.Models exposing (..)
import Main.Msgs exposing (Msg(..))
import Array
import Maybe


currMajor : Model -> Major
currMajor model = 
  Maybe.withDefault initialMajor (Array.get model.state (Array.fromList model.majors))


updateElement : List Major -> Int -> Major -> List Major
updateElement list index newMajor =
  let
    toggle i major =
      if i == index then newMajor else major
  in
    List.indexedMap toggle list


update : Main.Msgs.Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    UpdateMajor majorIndex ->
      ( { model | state = majorIndex }, Cmd.none)

    UpdateYear newYear ->
      let
        majorForm = currMajor model

        semesterForm = majorForm.newSemester

        newSemesterForm =
          { semesterForm | year = newYear }

        newMajorForm =
          { majorForm | newSemester = newSemesterForm }

        newMajors = 
          updateElement model.majors model.state newMajorForm

      in
        ( { model | majors = newMajors }, Cmd.none )

    UpdateSeason newSeason ->
      let
        majorForm = currMajor model

        semesterForm = majorForm.newSemester

        newSemesterForm =
          { semesterForm | season = newSeason }

        newMajorForm =
          { majorForm | newSemester = newSemesterForm }

        newMajors = 
          updateElement model.majors model.state newMajorForm

      in
        ( { model | majors = newMajors }, Cmd.none )

    AddSemester ->
      let
        majorForm = currMajor model

        newMajorSemesters = majorForm.majorSemesters ++ [ majorForm.newSemester ]

        newMajorForm =
          { majorForm | majorSemesters = newMajorSemesters, newSemester = emptySemester }

        newMajors = 
          updateElement model.majors model.state newMajorForm

      in
        ( { model | majors = newMajors }, Cmd.none )

    None ->
      ( model, Cmd.none )