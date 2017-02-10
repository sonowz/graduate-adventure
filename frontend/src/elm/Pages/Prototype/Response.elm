module Pages.Prototype.Response exposing (..)

import Json.Decode as Json


type alias Decoded = 
  { success : Bool
  , message : Maybe String
  }


decoder : Json.Decoder Decoded
decoder = 
  Json.map2 Decoded
    ( Json.field "success" Json.bool )
    ( Json.maybe <| Json.field "message" Json.string )