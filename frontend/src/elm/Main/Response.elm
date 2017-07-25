module Main.Response exposing (..)

import Json.Decode as Json
import Main.Models as Main
import Utils.Major as Utils


type alias Decoded = 
  { totalSimData : List SimData
  }

type alias SimDataDecoded =
  { major : Utils.Major
  , semesters : List Main.Semester
  , remainSubject : List Main.Subject
  , creditResults : Main.CreditResults
  }

type alias MajorDecoded =
  { name : String
  , type_ : String
  }


decoder : Json.Decoder Decoded
decoder =
  ( Json.field "totalSimData" (Json.list simDataDecoderExpend) )


simDataDecoderExpend : (Json.Decoder SimDataDecoded) -> (Json.Decoder Main.SimData)
simDataDecoderExpend inputSimData =
  case inputSimData of
    Ok res ->
      let
        resExpend =
          { major = res.major
          , semesters = res.semesters
          , remainSubject = res.remainSubject
          , creditResults = res.creditResults
          , newSemester = Main.emptySemester
          }
      in (Ok resExpend)
    Err error ->
      (Err error)


simDataDecoder : Json.Decoder SimDataDecoded
simDataDecoder =
  Json.map4
    Main.SimData
    ( majorTypeConv ( Json.field "major" (Json.list majorDecoder) ) )
    ( Json.field "semesters" (Json.list semesterDecoder) )
    ( Json.field "remainSubject" (Json.list subjectDecoder) )
    ( Json.field "creditResults" (Json.list creditResultsDecoder) )


majorTypeConv : (Json.Decoder MajorDecoded) -> (Json.Decoder Main.Major)
majorTypeConv inputMajorDecoder =
  case inputMajorDecoder of
    Ok res ->
      let
        resConv =
          { name = res.name
          , type_ = ( Utils.stringToType res.type_ )
          }
      in (Ok resConv)
    Err error ->
      (Err error)


majorDecoder : Json.Decoder MajorDecoded
majorDecoder =
  Json.map2
    MajorDecoded
    ( Json.field "name" Json.string )
    ( Json.field "type_" Json.string )


semesterDecoder : Json.Decoder Main.Semester
semesterDecoder =
  Json.map3
    Main.Semester
    ( Json.field "year" Json.string )
    ( Json.field "season" Json.string )
    ( Json.field "subjects" (Json.list subjectDecoder) )



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
    ( Json.field "totalReq" Json.int )
    ( Json.field "totalAcq" Json.int )
    ( Json.field "mandatoryReq" Json.int )
    ( Json.field "mandatoryAcq" Json.int )
    ( Json.field "electivesReq" Json.int )
    ( Json.field "electivesAcq" Json.int )
    ( Json.field "liberalReq" Json.int )
    ( Json.field "liberalAcq" Json.int )