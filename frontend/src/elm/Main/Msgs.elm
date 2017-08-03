module Main.Msgs exposing (..)

import Http
import Main.Models as Model
import GlobalMsgs exposing (..)

type Msg
  = UpdateYear String
  | UpdateSeason String
  | AddSemester Bool
  | UpdateSimData Int
  | Response (Result Http.Error ( List Model.SimData ) )
  | Global GlobalMsg
