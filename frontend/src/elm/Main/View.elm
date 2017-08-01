module Main.View exposing (view)

import Array
import Html exposing (Html, div, p, text, button, input, form, select, option, label)
import Html.Attributes exposing (id, class, name, placeholder, action, type_, checked, value, for, style)
import Html.Events exposing (onClick, onInput, onCheck, onSubmit)
import Utils.Major as Major
import Main.Msgs exposing(Msg(..))
import Main.Models exposing (..)


--for filter subjects

isMajor : Subject -> Bool
isMajor subject =
  not (isLiberal subject)


isLiberal : Subject -> Bool
isLiberal subject =
  if subject.category == "liberal" || subject.category == "free" then
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
    ( if subject.category == "required" then
      "course necessary"
      else
      "course optional"
    )
  ]
  [ text subject.title ]

--semester rows
semesterRow : Semester -> Html Msg
semesterRow semester =
  div
  [ class "row" ]
  [ div
    [ class "cell year" ]
    [ text ( semester.year ++ "-" ++ semester.season ) ]
  , div
    [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isMajor semester.subjects ) )
  , div
    [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isLiberal semester.subjects ) )
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
newSemester : Semester -> Html Msg
newSemester semester =
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
        ( AddSemester (semester.year /= "" && semester.season /= "" ) )
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

    currCreditResults = currSimData.creditResults

    totalRest =
      currCreditResults.totalReq - currCreditResults.totalAcq

    mandatoryRest =
      currCreditResults.mandatoryReq - currCreditResults.mandatoryAcq

    electivesRest =
      currCreditResults.electivesReq - currCreditResults.electivesAcq

    liberalRest =
      currCreditResults.liberalReq - currCreditResults.liberalAcq


  in
    div
    [ id "summary" ]
    [ creditsBar "전체" currCreditResults.totalReq currCreditResults.totalAcq totalRest
    , creditsBar "전필" currCreditResults.mandatoryReq currCreditResults.mandatoryAcq mandatoryRest
    , creditsBar "전선" currCreditResults.electivesReq currCreditResults.electivesAcq electivesRest
    , creditsBar "교양" currCreditResults.liberalReq currCreditResults.liberalAcq liberalRest
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
          ++ ( List.map semesterRow currSimData.semesters )
          ++ [ newSemester currSimData.newSemester
          , div
            [ class "row" ]
            [ div [ class "cell year" ][ text "미이수" ]
            , div
              [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isMajor currSimData.remainSubjects ) )
            , div
              [ class "cell subjects" ] ( List.map subjectBlocks ( List.filter isLiberal currSimData.remainSubjects ) )
            ]
          ]
          )
        ]
      ]
    ]
