-- Interface that handles HTTP form request & intercepts response for 'FileSelectBox.elm'
-- Elm 0.18 does not support 'file input request' in native.
port module Pages.Prototype.Ports exposing (..)


-- String : <'id' attribute of target form>@<Submit URL>
port fileRequest : String -> Cmd msg

-- (String -> msg) : <Function that decodes HTTP response>
port fileResponse : (String -> msg) -> Sub msg
