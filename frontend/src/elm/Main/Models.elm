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


subject1 : Subject
subject1 =
  { title = "프로그래밍 연습"
  , category = "electives"
  , tooltip = ""
  }


subject2 : Subject
subject2 =
  { title = "수학 및 연습 1"
  , category = "liberal"
  , tooltip = ""
  }


emptySemester : Semester
emptySemester =
  { year = ""
  , season = ""
  , subjects = [ ]
  }


initialSemesters : Semester
initialSemesters =
  { year = "2015"
  , season = "1"
  , subjects = [ subject1, subject2 ]
  }


initialSemesters2 : Semester
initialSemesters2 =
  { year = "2015"
  , season = "1"
  , subjects = [ subject1, subject2 ]
  }

initialCreditResults1 : CreditResults
initialCreditResults1 =
  { totalReq = 130
  , totalAcq = 128
  , mandatoryReq = 40
  , mandatoryAcq = 37
  , electivesReq = 30
  , electivesAcq = 27
  , liberalReq = 60
  , liberalAcq = 64
  }


initialCreditResults2 : CreditResults
initialCreditResults2 =
  { totalReq = 130
  , totalAcq = 128
  , mandatoryReq = 40
  , mandatoryAcq = 37
  , electivesReq = 30
  , electivesAcq = 27
  , liberalReq = 60
  , liberalAcq = 64
  }


initialSimData : SimData
initialSimData =
  { major =
    { name = "컴퓨터공학부"
    , type_ = MajorMulti
    }
  , semesters = [ initialSemesters ]
  , creditResults = initialCreditResults1
  , remainSubjects = [ subject1, subject2 ]
  , newSemester = emptySemester
  }


initialSimData2 : SimData
initialSimData2 =
  { major =
    { name = "수리과학부"
    , type_ = Minor
    }
  , semesters = [ initialSemesters2 ]
  , creditResults = initialCreditResults2
  , remainSubjects = []
  , newSemester = emptySemester
  }


initialModel : Model
initialModel =
  { totalSimData = [ initialSimData, initialSimData2 ]
  , tabNumber = 0
  }
