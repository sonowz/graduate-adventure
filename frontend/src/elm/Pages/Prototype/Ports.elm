-- Interface for dealing with file POST request in 'FileSelectBox.elm'
port module Pages.Prototype.Ports exposing (..)


port fileRequest : String -> Cmd msg

port fileResponse : (String -> msg) -> Sub msg