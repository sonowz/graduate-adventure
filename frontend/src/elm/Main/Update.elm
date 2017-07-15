module Main.Update exposing (..)

import Main.Models exposing (..)
import Main.Msgs exposing (Msg(..))
import Array
import Maybe


currDiscipline : Model -> Discipline
currDiscipline model = 
  Maybe.withDefault initialDiscipline (Array.get model.tabNumber (Array.fromList model.disciplines))


updateElement : List Discipline -> Int -> Discipline -> List Discipline
updateElement list index newDiscipline =
  let
    toggle i discipline =
      if i == index then newDiscipline else discipline
  in
    List.indexedMap toggle list


update : Main.Msgs.Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    UpdateDiscipline disciplineIndex ->
      ( { model | tabNumber = disciplineIndex }, Cmd.none)

    UpdateYear newYear ->
      let
        disciplineForm = currDiscipline model

        semesterForm = disciplineForm.newSemester

        newSemesterForm =
          { semesterForm | year = newYear }

        newDisciplineForm =
          { disciplineForm | newSemester = newSemesterForm }

        newDisciplines = 
          updateElement model.disciplines model.tabNumber newDisciplineForm

      in
        ( { model | disciplines = newDisciplines }, Cmd.none )

    UpdateSeason newSeason ->
      let
        disciplineForm = currDiscipline model

        semesterForm = disciplineForm.newSemester

        newSemesterForm =
          { semesterForm | season = newSeason }

        newDisciplineForm =
          { disciplineForm | newSemester = newSemesterForm }

        newDisciplines = 
          updateElement model.disciplines model.tabNumber newDisciplineForm

      in
        ( { model | disciplines = newDisciplines }, Cmd.none )

    AddSemester ->
      let
        disciplineForm = currDiscipline model

        newDisciplineSemesters = disciplineForm.disciplineSemesters ++ [ disciplineForm.newSemester ]

        newDisciplineForm =
          { disciplineForm | disciplineSemesters = newDisciplineSemesters, newSemester = emptySemester }

        newDisciplines = 
          updateElement model.disciplines model.tabNumber newDisciplineForm

      in
        ( { model | disciplines = newDisciplines }, Cmd.none )

    None ->
      ( model, Cmd.none )