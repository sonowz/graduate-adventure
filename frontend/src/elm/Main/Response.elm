module Main.Response exposing (..)

import Json.Decode as Json
import Main.Models as Main
import Utils.Major as Utils


decoder : Json.Decoder (List Main.SimData)
decoder =
    ( Json.at [ "total_simdata" ] ( Json.list simDataDecoder ) )


simDataDecoder : Json.Decoder Main.SimData
simDataDecoder =
  Json.map5
    Main.SimData
    ( Json.field "major" majorDecoder )
    ( Json.field "semesters" (Json.list semesterDecoder) )
    ( Json.at [ "remaining_courses", "courses" ] (Json.list subjectDecoder) )
    ( Json.field "credit_results" creditResultsDecoder )
    ( Json.succeed Main.emptySemester )


majorDecoder : Json.Decoder Utils.Major
majorDecoder =
  Json.map2
    Utils.Major
    ( Json.field "name" Json.string )
    ( Json.field "type" (Json.map Utils.stringToTypeNormal Json.string) )


semesterDecoder : Json.Decoder Main.Semester
semesterDecoder =
  Json.map3
    Main.Semester
    ( Json.field "year" Json.string )
    ( Json.field "semester" Json.string )
    ( Json.field "courses" (Json.list subjectDecoder) )



subjectDecoder : Json.Decoder Main.Subject
subjectDecoder =
  Json.map3
    Main.Subject
    ( Json.field "title" Json.string )
    ( Json.field "category" Json.string )
    ( Json.field "tooltip" Json.string )


creditResultsDecoder : Json.Decoder Main.CreditResults
creditResultsDecoder =
  Json.map8
    Main.CreditResults
    ( Json.field "total_req" Json.int )
    ( Json.field "total_acq" Json.int )
    ( Json.field "required_req" Json.int )
    ( Json.field "required_acq" Json.int )
    ( Json.field "elective_req" Json.int )
    ( Json.field "elective_acq" Json.int )
    ( Json.field "liberal_req" Json.int )
    ( Json.field "liberal_acq" Json.int )