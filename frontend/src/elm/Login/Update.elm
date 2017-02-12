module Login.Update exposing (..)

import Login.Messages exposing (Msg(..))
import Login.Models exposing (..)
import Login.Major.Update


update : Login.Messages.Msg -> LoginForm -> ( LoginForm, Cmd Msg )
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

    UpdateFile newFile ->
      let
        fileLoginForm =
          loginForm.fileLoginForm
        newFileLoginForm =
          { fileLoginForm | file = newFile }
      in
        ( { loginForm | fileLoginForm = newFileLoginForm }, Cmd.none )

    MajorMsg majorMsg ->
      let
        ( updatedMajorForm, cmd ) =
          Login.Major.Update.update majorMsg loginForm.majorForm
      in
        ( { loginForm | majorForm = updatedMajorForm }, Cmd.map MajorMsg cmd)

    SubmitForm loginType ->
      ( loginForm, Cmd.none )
