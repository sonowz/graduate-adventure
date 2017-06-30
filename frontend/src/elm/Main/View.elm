module Main.View exposing (view)

import Html exposing (Html, div, p, text, button, input, form, select, option, label)
import Html.Attributes exposing (id, class, name, placeholder, action, type_, checked, value, for, style)
import Html.Events exposing (onClick, onInput, onCheck, onSubmit)
import Array
import Main.Msgs exposing(Msg(..))
import Main.Models exposing (..)


--for filter subjects
isMajor : Subject -> Bool
isMajor subject =
  if subject.property == "G" then
    False
  else
    True


isGeneral : Subject -> Bool
isGeneral subject =
  if subject.property == "G" then
    True
  else
    False

--for number expresion
computePercentage : Int -> Int -> String
computePercentage full curr =
  if toFloat curr < 0.99*(toFloat full) then
    if toFloat curr> 0.01*(toFloat full) then
      toString ((toFloat curr)/(toFloat full)*100) ++ "%"
    else
      "0%"
  else
    "100%"


numberExpression : Int -> Int -> String
numberExpression full curr =
  if curr > full then
      toString curr ++ " / " ++ toString full
  else
    if curr <= 0 then
      "　"
    else
      toString curr

--return a bar of grades (FULL/REST)
gradesBar : String -> Int -> Int -> Int -> Html Msg
gradesBar title full curr rest = 
  div [ class "bar-area" ]
  [ div [ class "bar-label" ][ text title ]
  , div [ class "bar" ]
    [ div [ class "table" ]
      [ div [ class "done", style [ ("width", (computePercentage full curr) ) ] ] 
        [ text (numberExpression full curr) ]
      , div [ class "rest", style [ ("width", (computePercentage full rest) ) ] ] 
        [ text (numberExpression full rest) ]
      ]
    ]
  ]

-- subjects block(button)
subjectBlocks : Subject -> Html Msg
subjectBlocks subject =
  button
  [ class ( if subject.property /= "E" then 
              "course necessary" 
            else 
              "course optional")
  ]
  [ text subject.name ]

--semester rows
semesterRow : Semester -> Html Msg
semesterRow semester =
  div
  [ class "row" ]
  [ div 
    [ class "cell" ]
    [ text ( semester.year ++ "-" ++ semester.season ) ]
  , div
    [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isMajor semester.subjects ) )
  , div
    [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isGeneral semester.subjects ) )
  ]


--for selecting major
selectMajor : Int -> List Major -> Major
selectMajor index majors = 
  Maybe.withDefault initialMajor (Array.get index (Array.fromList majors))

--for select tab(major)
majorLists : Model -> Int -> Major -> Html Msg
majorLists model index major =
  div
  [ class ( if model.state == index then
              "tab active"
            else
              "tab")
  , onClick (UpdateMajor index)
  ]
  [ p []
    [ text (major.majorName++"/"++major.majorProperty) ] 
  ]


-- list of seasons for select element
seasons : List String
seasons =
  [ ""
  , "1"
  , "S"
  , "2"
  , "W"
  ]

seasonTypeOption : String -> Html Msg
seasonTypeOption season =
  option
    [ value season ]
    [ text season ]


--make new semester
newSemester : Major -> Html Msg
newSemester major =
  div
  [ class "row" ]
  [ div
    [ class "cell" ]
    [ input
      [ type_ "text"
      , name "year"
      , id "year"
      , onInput UpdateYear
      ][]
    , select
      [ name "semester"
      , id "semester"
      , onInput UpdateSeason
      ] (List.map seasonTypeOption seasons)
    , button
      [ class "plus"
      , onClick (if major.newSemester.year/="" && major.newSemester.season/="" then
                   AddSemester
                 else
                   None)
      ]
      [ text "+" ]
    ]
  , div [ class "cell" ][]
  , div [ class "cell" ][]
  ]


--View model
view : Model -> Html Msg
view model =
  div
  [ id "main" ]
  [ div
    [ class "tab-area" ]
    (List.indexedMap (majorLists model) model.majors)
  ,  summaryField model ]


--semester/subjects table
--allGradeRest : 총 잔여 학점
--mandatoryGradeRest : 총 잔여 전필 학점
--electivesGradeRest : 총 잔여 전선 학점
--generalGradeRest : 총 잔여 교양 학점
summaryField : Model -> Html Msg
summaryField model =
  let
    currMajor = selectMajor model.state model.majors

    allGradeRest = 
      currMajor.allGradeFull - currMajor.allGradeCurr

    mandatoryGradeRest = 
      currMajor.mandatoryGradeFull - currMajor.mandatoryGradeCurr

    electivesGradeRest = 
      currMajor.electivesGradeFull - currMajor.electivesGradeCurr

    generalGradeRest = 
      currMajor.generalGradeFull - currMajor.generalGradeCurr


  in
    div
    [ id "summary" ]
    [ gradesBar "전체" currMajor.allGradeFull currMajor.allGradeCurr allGradeRest
    , gradesBar "전필" currMajor.mandatoryGradeFull currMajor.mandatoryGradeCurr mandatoryGradeRest
    , gradesBar "전선" currMajor.electivesGradeFull currMajor.electivesGradeCurr electivesGradeRest
    , gradesBar "교양" currMajor.generalGradeFull currMajor.generalGradeCurr generalGradeRest
    , div 
      [ id "result" ]
      [ div 
        [ class "table" ]
        [ div
          [ class "table-body" ]
          ( [ div
            [ class "header" ]
            [ div [ class "cell year" ][ text "이수학기" ]
            , div [ class "cell major" ][ text "전공" ]
            , div [ class "cell liberal" ][ text "교양" ]
            ]
          ]
          ++ ( List.map semesterRow currMajor.majorSemesters ) 
          ++ [ newSemester currMajor
          , div
            [ class "row" ]
            [ div [ class "cell year" ][ text "미이수" ]
            , div
              [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isMajor currMajor.remainSubjects ) )
            , div
              [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isGeneral currMajor.remainSubjects ) )
            ]  
          ]
          )
        ]
      ]
    ]

