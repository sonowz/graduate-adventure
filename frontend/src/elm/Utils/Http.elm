module Utils.Http exposing (..)

import Http


-- Http.getString variant, see below link:
-- http://package.elm-lang.org/packages/elm-lang/http/1.0.0/Http

postString : String -> Http.Body -> Http.Request String
postString url body =
  Http.request
    { method = "POST"
    , headers = []
    , url = url
    , body = body
    , expect = Http.expectString
    , timeout = Nothing
    , withCredentials = False
    }
