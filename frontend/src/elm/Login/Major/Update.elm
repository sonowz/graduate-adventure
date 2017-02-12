module Login.Major.Update exposing (..)

import Login.Major.Messages exposing (Msg(..))
import Login.Major.Models exposing (Major, MajorForm)


removeAt : Int -> List a -> List a
removeAt index list =
  if index < 0 then
    list

  else if index == 0 then
    case list of
      x::xs ->
        xs

      [] ->
        []
  
  else 
    case list of
      x::xs ->
        x::(removeAt (index-1) xs)

      [] ->
        []


update : Msg -> MajorForm -> (MajorForm, Cmd Msg)
update message majorForm =
  case message of
    AddMajor major ->
      let
        newMajors = major::majorForm.majors
      in
        ( { majorForm | majors = newMajors }, Cmd.none )

    DeleteMajor index ->
      let
        newMajors = removeAt index majorForm.majors
      in
        ( { majorForm | majors = newMajors }, Cmd.none )

    OnNewMajorTypeChange newMajorType ->
      ( { majorForm | majorType = newMajorType }, Cmd.none )

    OnNewMajorChange newMajor ->
      ( { majorForm | major = newMajor }, Cmd.none )
