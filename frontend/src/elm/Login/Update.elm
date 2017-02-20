module Login.Update exposing (..)

import Login.Msgs exposing (Msg(..))
import Login.Models exposing (..)
import Login.MajorForm.Update


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
          Login.MajorForm.Update.update majorMsg loginForm.majorForm
      in
        ( { loginForm | majorForm = updatedMajorForm }, Cmd.map MajorMsg cmd)

    SubmitForm loginType ->
      ( loginForm, Cmd.none )
