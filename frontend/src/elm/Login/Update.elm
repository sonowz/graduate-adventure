module Login.Update exposing (..)

import Login.Msgs exposing (Msg(..))
import Login.Models exposing (..)
import Json.Decode as Decode exposing (field)
import Json.Encode as Encode exposing (object, string)
import Login.MajorForm.Update
import Result exposing (Result(..))
import Login.Ports as Ports
import Login.Response as Response
import Http
import Navigation exposing (load)


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
{- TODO:
 - handle fail message of response (after handle decoder)
 - handle Response & Responsejs together (after handle filerequest in elm)
 -}
    Response result ->
      case result of
        Ok success ->
          case success of
            True ->
              ( loginForm, load "/" )
            False ->
              ( loginForm, Cmd.none )
        Err error ->
          ( loginForm, Cmd.none )

    Responsejs str ->
      let
        decodedResult : Result String Response.Decoded
        decodedResult =
          Decode.decodeString Response.decoder str

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
          ( loginForm, postMysnuLogin loginForm.mysnuLoginForm )

        FileLogin ->
          let
            formID =
              "filerequest"
            url =
              "/api/login/file/"

          in
            ( loginForm, Ports.fileRequest ( formID ++ "@" ++ url ) )

    None ->
      ( loginForm, Cmd.none )


postMysnuLogin : MysnuLoginForm -> Cmd Msg
postMysnuLogin mysnu =
  Http.send Response
  <| Http.post
    "/api/login/mysnu/"
    ( mysnuLoginBody mysnu )
    ( field "success" Decode.bool )

mysnuLoginBody : MysnuLoginForm -> Http.Body
mysnuLoginBody mysnu =
  Http.jsonBody
    <| object
      [ ( "user_id", string mysnu.username )
      , ( "password", string mysnu.password )
      , ( "major_info", Encode.bool (not mysnu.useMysnuMajors) )
      ]

{- TODO: send additional body when major_info is true
-}
