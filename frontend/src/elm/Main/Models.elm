module Main.Models exposing (..)

import Utils.Major exposing (Major, MajorType(..))


type alias Model =
  { totalSimData : List SimData
  , tabNumber : Int
  }


type alias SimData =
  { major : Major
  , semesters : List Semester
  , allCreditFull : Int              --총학점
  , mandatoryCreditFull : Int        --총전공필수학점
  , electivesCreditFull : Int        --총전공선택학점
  , generalCreditFull : Int          --총교양학점
  , allCreditCurr : Int              --현학점
  , mandatoryCreditCurr : Int        --현전공필수학점
  , electivesCreditCurr : Int        --현전공선택학점
  , generalCreditCurr : Int          --현교양학점
  , remainSubjects : List Subject   --미이수과목
  , newSemester : Semester          --placeholder for user adding next semester
  }


type alias Semester =
  { year : String
  , season : String
  , subjects : List Subject
  }


type alias Subject =
  { name : String
  , property : String
  , credit : Int
  }


subject1 : Subject
subject1 =
  { name = "프로그래밍 연습"
  , property = "E"
  , credit = 3
  }


subject2 : Subject
subject2 =
  { name = "수학 및 연습 1"
  , property = "G"
  , credit = 3
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


initialSimData : SimData
initialSimData =
  { major =
    { name = "컴퓨터공학부"
    , type_ = MajorMulti
    }
  , semesters = [ initialSemesters ]
  , mandatoryCreditFull = 40
  , electivesCreditFull = 30
  , generalCreditFull = 60
  , mandatoryCreditCurr = 37
  , electivesCreditCurr = 27
  , generalCreditCurr = 64
  , allCreditFull = 130
  , allCreditCurr = 128
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
  , mandatoryCreditFull = 40
  , electivesCreditFull = 30
  , generalCreditFull = 60
  , mandatoryCreditCurr = 37
  , electivesCreditCurr = 27
  , generalCreditCurr = 64
  , allCreditFull = 130
  , allCreditCurr = 128
  , remainSubjects = []
  , newSemester = emptySemester
  }


initialModel : Model
initialModel =
  { totalSimData = [ initialSimData, initialSimData2 ]
  , tabNumber = 0
  }
