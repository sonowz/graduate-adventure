module Main.View exposing (view)

import Html exposing (Html, div, p, text, button, input, form, select, option, label)
import Html.Attributes exposing (id, class, name, placeholder, action, type_, checked, value, for, style)
import Html.Events exposing (onClick, onInput, onCheck, onSubmit)
import Msgs exposing (Msg(..))
import Main.Models exposing (..)
import Array


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


--Encapsulation
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


subjectBlocks : Subject -> Html Msg
subjectBlocks subject =
  button
  [ class ( if subject.property /= "E" then 
              "course necessary" 
            else 
              "course optional")
  ]
  [ text subject.name ]


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


--for Current major
currMajor : Model -> Major
currMajor model = 
  Maybe.withDefault initialMajor (Array.get model.state (Array.fromList model.majors))


majorLists : Model -> Int -> Major -> Html Msg
majorLists model index major =
  div
  [ class ( if model.state == index then
              "tab active"
            else
              "tab")
  ]
  [ p []
    [ text (major.majorName++"/"++major.majorProperty) ] 
  ]

seasons : List String
seasons =
  [ "1"
  , "S"
  , "2"
  , "W"
  ]

seasonTypeOption : String -> Html Msg
seasonTypeOption season =
  option
    [ value season ]
    [ text season ]

newSemester : Model -> Html Msg
newSemester model =
  div
  [ class "row" ]
  [ div
    [ class "cell" ]
    [ input
      [ type_ "text"
      , name "year"
      , id "year"
      ][]
    , select
      [ name "semester"
      , id "semester"
      ] (List.map seasonTypeOption seasons)
    , button
      [ class "plus" ]
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


summaryField : Model -> Html Msg
summaryField model =
  let
    allGradeRest = 
      (currMajor model).allGradeFull - (currMajor model).allGradeCurr

    mandatoryGradeRest = 
      (currMajor model).mandatoryGradeFull - (currMajor model).mandatoryGradeCurr

    electivesGradeRest = 
      (currMajor model).electivesGradeFull - (currMajor model).electivesGradeCurr

    generalGradeRest = 
      (currMajor model).generalGradeFull - (currMajor model).generalGradeCurr


  in
    div
    [ id "summary" ]
    [ gradesBar "전체" (currMajor model).allGradeFull (currMajor model).allGradeCurr allGradeRest
    , gradesBar "전필" (currMajor model).mandatoryGradeFull (currMajor model).mandatoryGradeCurr mandatoryGradeRest
    , gradesBar "전선" (currMajor model).electivesGradeFull (currMajor model).electivesGradeCurr electivesGradeRest
    , gradesBar "교양" (currMajor model).generalGradeFull (currMajor model).generalGradeCurr generalGradeRest
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
          ++ ( List.map semesterRow (currMajor model).majorSemesters ) 
          ++ [ newSemester model
          , div
            [ class "row" ]
            [ div [ class "cell year" ][ text "미이수" ]
            , div
              [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isMajor (currMajor model).remainSubjects ) )
            , div
              [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isGeneral (currMajor model).remainSubjects ) )
            ]  
          ]
          )
        ]
      ]
    ]

