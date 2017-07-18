module Main.View exposing (view)

import Html exposing (Html, div, p, text, button, input, form, select, option, label)
import Html.Attributes exposing (id, class, name, placeholder, action, type_, checked, value, for, style)
import Html.Events exposing (onClick, onInput, onCheck, onSubmit)
import Array
import Main.Msgs exposing(Msg(..))
import Main.Models exposing (..)
import Utils.Major as Major


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

--return a bar of credits (FULL/REST)
creditsBar : String -> Int -> Int -> Int -> Html Msg
creditsBar title full curr rest =
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
  [ class
    ( if subject.property /= "E" then
      "course necessary"
      else
      "course optional"
    )
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


--for selecting simData
selectSimData : Int -> List SimData -> SimData
selectSimData index totalSimData =
  Maybe.withDefault initialSimData (Array.get index (Array.fromList totalSimData))

--for select tab(simData)
simDataLists : Model -> Int -> SimData -> Html Msg
simDataLists model index simData =
  div
  [ class
    ( if model.tabNumber == index then
      "tab active"
      else
      "tab"
    )
  , onClick (UpdateSimData index)
  ]
  [ p []
    [ text (Major.toString simData.major) ]
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
newSemester : SimData -> Html Msg
newSemester simData =
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
      , onClick
        ( if simData.newSemester.year/="" && simData.newSemester.season/="" then
          AddSemester
          else
          None
        )
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
    (List.indexedMap (simDataLists model) model.totalSimData)
  ,  summaryField model ]


--semester/subjects table
--allCreditRest : 총 잔여 학점
--mandatoryCreditRest : 총 잔여 전필 학점
--electivesCreditRest : 총 잔여 전선 학점
--generalCreditRest : 총 잔여 교양 학점
summaryField : Model -> Html Msg
summaryField model =
  let
    currSimData = selectSimData model.tabNumber model.totalSimData

    allCreditRest =
      currSimData.allCreditFull - currSimData.allCreditCurr

    mandatoryCreditRest =
      currSimData.mandatoryCreditFull - currSimData.mandatoryCreditCurr

    electivesCreditRest =
      currSimData.electivesCreditFull - currSimData.electivesCreditCurr

    generalCreditRest =
      currSimData.generalCreditFull - currSimData.generalCreditCurr


  in
    div
    [ id "summary" ]
    [ creditsBar "전체" currSimData.allCreditFull currSimData.allCreditCurr allCreditRest
    , creditsBar "전필" currSimData.mandatoryCreditFull currSimData.mandatoryCreditCurr mandatoryCreditRest
    , creditsBar "전선" currSimData.electivesCreditFull currSimData.electivesCreditCurr electivesCreditRest
    , creditsBar "교양" currSimData.generalCreditFull currSimData.generalCreditCurr generalCreditRest
    , div
      [ id "result" ]
      [ div
        [ class "table" ]
        [ div
          [ class "table-body" ]
          ( [ div
            [ class "header" ]
            [ div [ class "cell year" ][ text "이수학기" ]
            , div [ class "cell simData" ][ text "전공" ]
            , div [ class "cell liberal" ][ text "교양" ]
            ]
          ]
          ++ ( List.map semesterRow currSimData.semesters )
          ++ [ newSemester currSimData
          , div
            [ class "row" ]
            [ div [ class "cell year" ][ text "미이수" ]
            , div
              [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isMajor currSimData.remainSubjects ) )
            , div
              [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isGeneral currSimData.remainSubjects ) )
            ]
          ]
          )
        ]
      ]
    ]
