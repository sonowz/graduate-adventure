module Main.Update exposing (..)

import Result exposing (Result(..))
import Navigation exposing (load)
import Http
import Cmd.Extra
import GlobalMsgs exposing (GlobalMsg(..))
import Array
import Maybe
import Main.Models exposing (..)
import Main.Response as Response
import Main.Msgs exposing (Msg(..))


currSimData : Model -> SimData
currSimData model =
  Maybe.withDefault initialSimData (Array.get model.tabNumber (Array.fromList model.totalSimData))


updateElement : List SimData -> Int -> SimData -> List SimData
updateElement list index newSimData =
  let
    toggle i simData =
      if i == index then newSimData else simData
  in
    List.indexedMap toggle list


update : Main.Msgs.Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    UpdateSimData simDataIndex ->
      ( { model | tabNumber = simDataIndex }, Cmd.none)

    UpdateYear newYear ->
      let
        simDataForm = currSimData model

        semesterForm = simDataForm.newSemester

        newSemesterForm =
          { semesterForm | year = newYear }

        newSimDataForm =
          { simDataForm | newSemester = newSemesterForm }

        newTotalSimData =
          updateElement model.totalSimData model.tabNumber newSimDataForm

      in
        ( { model | totalSimData = newTotalSimData }, Cmd.none )

    UpdateSeason newSeason ->
      let
        simDataForm = currSimData model

        semesterForm = simDataForm.newSemester

        newSemesterForm =
          { semesterForm | season = newSeason }

        newSimDataForm =
          { simDataForm | newSemester = newSemesterForm }

        newTotalSimData =
          updateElement model.totalSimData model.tabNumber newSimDataForm

      in
        ( { model | totalSimData = newTotalSimData }, Cmd.none )

    AddSemester filled ->
      case filled of
        True ->
          let
            simDataForm = currSimData model

            newSemesters = simDataForm.semesters ++ [ simDataForm.newSemester ]

            newSimDataForm =
              { simDataForm | semesters = newSemesters, newSemester = emptySemester }

            newTotalSimData =
              updateElement model.totalSimData model.tabNumber newSimDataForm

          in
            ( { model | totalSimData = newTotalSimData }, Cmd.none )
        False ->
          ( model, Cmd.none )

    Response result ->
      let
        loadingOff =
          Cmd.Extra.perform (Global (Loading False))
      in
        case result of
          Ok success ->
            ( { model | totalSimData = success, tabNumber = 0 }, loadingOff )
          Err _ ->
            ( model, Cmd.none ) --Cmd.batch [ load "/login" ] )

    Global _ ->
      ( model, Cmd.none )


getMainData : Cmd Msg
getMainData =
  Http.send Response
  <| Http.get "/api/main"
    ( Response.decoder )