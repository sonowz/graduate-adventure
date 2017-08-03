module Main.Models exposing (..)

import Utils.Major exposing (Major, MajorType(..))


type alias Model =
  { totalSimData : List SimData
  , tabNumber : Int
  }


type alias SimData =
  { major : Major
  , semesters : List Semester
  , remainSubjects : List Subject   --미이수과목
  , creditResults : CreditResults
  , newSemester : Semester          --placeholder for user adding next semester
  }


type alias CreditResults =
  { totalReq : Int              --총학점
  , totalAcq : Int              --현학점
  , mandatoryReq : Int        --총전공필수학점
  , mandatoryAcq : Int        --현전공필수학점
  , electivesReq : Int        --총전공선택학점
  , electivesAcq : Int        --현전공선택학점
  , liberalReq : Int          --총교양학점
  , liberalAcq : Int          --현교양학점
  }


type alias Semester =
  { year : String
  , season : String
  , subjects : List Subject
  }


type alias Subject =
  { title : String
  , category : String
  , tooltip : String
  }


emptySemester : Semester
emptySemester =
  { year = ""
  , season = ""
  , subjects = [ ]
  }

initialCreditResults : CreditResults
initialCreditResults =
  { totalReq = 0
  , totalAcq = 0
  , mandatoryReq = 0
  , mandatoryAcq = 0
  , electivesReq = 0
  , electivesAcq = 0
  , liberalReq = 0
  , liberalAcq = 0
  }

initialSimData : SimData
initialSimData =
  { major =
    { name = ""
    , type_ = MajorMulti
    }
  , semesters = [ ]
  , creditResults = initialCreditResults
  , remainSubjects = [ ]
  , newSemester = emptySemester
  }


initialModel : Model
initialModel =
  { totalSimData = [ initialSimData ]
  , tabNumber = 0
  }
