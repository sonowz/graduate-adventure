module Login.Update exposing (..)

import Login.Msgs exposing (Msg(..))
import Login.Models exposing (..)
import Json.Decode as Json
import Login.MajorForm.Update
import Result exposing (Result(..))
import Login.Ports as Ports
import Login.Response as Response


update : Login.Msgs.Msg -> Model -> ( Model, Cmd Msg )
update msg loginForm =
  case msg of
    UpdateLoginType newLoginType ->
      ( { loginForm | loginType = newLoginType }, Cmd.none)

    UpdateUsername newUsername ->
      let
        mysnuLoginForm =
          loginForm.mysnuLoginForm
        newMysnuLoginForm =
          { mysnuLoginForm | username = newUsername }
      in
       ( { loginForm | mysnuLoginForm = newMysnuLoginForm }, Cmd.none )

    UpdatePassword newPassword ->
      let
        mysnuLoginForm =
          loginForm.mysnuLoginForm
        newMysnuLoginForm =
          { mysnuLoginForm | password = newPassword }
      in
       ( { loginForm | mysnuLoginForm = newMysnuLoginForm }, Cmd.none )

    UpdateUseMysnuMajors newUseMysnuMajors ->
      let
        mysnuLoginForm =
          loginForm.mysnuLoginForm
        newMysnuLoginForm =
          { mysnuLoginForm | useMysnuMajors = newUseMysnuMajors }
      in
       ( { loginForm | mysnuLoginForm = newMysnuLoginForm }, Cmd.none )

    Response str ->
      let
        decodedResult : Result String Response.Decoded
        decodedResult =
          Json.decodeString Response.decoder str
        fileLoginForm =
          loginForm.fileLoginForm
        newfileLoginForm = 
          case decodedResult of
            Ok decoded ->
              { fileLoginForm | file = Maybe.withDefault "" decoded.message }
            Err error ->
              { fileLoginForm | file = "X" }
      in
       ( { loginForm | fileLoginForm = newfileLoginForm }, Cmd.none )

    MajorMsg majorMsg ->
      let
        ( updatedMajorForm, cmd ) =
          Login.MajorForm.Update.update majorMsg loginForm.majorForm
      in
        ( { loginForm | majorForm = updatedMajorForm }, Cmd.map MajorMsg cmd)

    SubmitForm loginType ->
      case loginType of
        MysnuLogin ->
          ( loginForm, Cmd.none )
        FileLogin ->
          let
            formID =
              "filerequest"
            url =
              "localhost:8000/api/login/file"

          in
            ( loginForm, Ports.fileRequest ( formID ++ "@" ++ url ) )

    None ->
      ( loginForm, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
  Ports.fileResponse Response