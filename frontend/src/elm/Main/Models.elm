module Main.Models exposing (..)


type alias Model =
  { majors : List Major
  , state : Int
  }

type alias Major =
  { majorName : String
  , majorProperty : String
  , majorSemesters : List Semester
  , allGradeFull : Int              --총학점
  , mandatoryGradeFull : Int        --총전공필수학점
  , electivesGradeFull : Int        --총전공선택학점
  , generalGradeFull : Int          --총교양학점
  , allGradeCurr : Int              --현학점
  , mandatoryGradeCurr : Int        --현전공필수학점
  , electivesGradeCurr : Int        --현전공선택학점
  , generalGradeCurr : Int          --현교양학점
  , remainSubjects : List Subject   --미이수과목
  , newSemester : Semester
  }


type alias Semester =
  { year : String
  , season : String
  , subjects : List Subject
  }


type alias Subject =
  { name : String
  , property : String
  , grade : Int
  }


subject1 : Subject
subject1 =
  { name = "프로그래밍 연습"
  , property = "E"
  , grade = 3
  }


subject2 : Subject
subject2 =
  { name = "수학 및 연습 1"
  , property = "G"
  , grade = 3
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


initialMajor : Major
initialMajor =
  { majorName = "컴퓨터공학부"
  , majorProperty = "주"
  , majorSemesters = [ initialSemesters ]
  , mandatoryGradeFull = 40
  , electivesGradeFull = 30
  , generalGradeFull = 60
  , mandatoryGradeCurr = 37
  , electivesGradeCurr = 27
  , generalGradeCurr = 64
  , allGradeFull = 130
  , allGradeCurr = 128
  , remainSubjects = [ subject1, subject2 ]
  , newSemester = emptySemester
  }


initialMajor2 : Major
initialMajor2 =
  { majorName = "수리과학부"
  , majorProperty = "부"
  , majorSemesters = [ initialSemesters2 ]
  , mandatoryGradeFull = 40
  , electivesGradeFull = 30
  , generalGradeFull = 60
  , mandatoryGradeCurr = 37
  , electivesGradeCurr = 27
  , generalGradeCurr = 64
  , allGradeFull = 130
  , allGradeCurr = 128
  , remainSubjects = []
  , newSemester = emptySemester
  }


initialModel : Model
initialModel =
  { majors = [ initialMajor, initialMajor2 ]
  , state = 0
  }