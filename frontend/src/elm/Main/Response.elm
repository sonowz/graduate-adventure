module Main.Response exposing (..)

import Json.Decode as Json
import Main.Models as Model
import Utils.Major as Major


decoder : Json.Decoder (List Model.SimData)
decoder =
    ( Json.at [ "total_simdata" ] ( Json.list simDataDecoder ) )


simDataDecoder : Json.Decoder Model.SimData
simDataDecoder =
  Json.map5
    Model.SimData
    ( Json.field "major" majorDecoder )
    ( Json.field "semesters" (Json.list semesterDecoder) )
    ( Json.at [ "remaining_courses", "courses" ] (Json.list subjectDecoder) )
    ( Json.field "credit_results" creditResultsDecoder )
    ( Json.succeed Model.emptySemester )


majorDecoder : Json.Decoder Major.Major
majorDecoder =
  Json.map2
    Major.Major
    ( Json.field "name" Json.string )
    ( Json.field "type" (Json.map Major.stringToTypeSpecific Json.string) )


semesterDecoder : Json.Decoder Model.Semester
semesterDecoder =
  Json.map3
    Model.Semester
    ( Json.field "year" Json.string )
    ( Json.field "semester" Json.string )
    ( Json.field "courses" (Json.list subjectDecoder) )



subjectDecoder : Json.Decoder Model.Subject
subjectDecoder =
  Json.map3
    Model.Subject
    ( Json.field "title" Json.string )
    ( Json.field "category" Json.string )
    ( Json.field "tooltip" Json.string )


creditResultsDecoder : Json.Decoder Model.CreditResults
creditResultsDecoder =
  Json.map8
    Model.CreditResults
    ( Json.field "total_req" Json.int )
    ( Json.field "total_acq" Json.int )
    ( Json.field "required_req" Json.int )
    ( Json.field "required_acq" Json.int )
    ( Json.field "elective_req" Json.int )
    ( Json.field "elective_acq" Json.int )
    ( Json.field "liberal_req" Json.int )
    ( Json.field "liberal_acq" Json.int )
