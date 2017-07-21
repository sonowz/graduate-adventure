module Login.Update exposing (..)

import Result exposing (Result(..))
import Navigation exposing (load)
import Http
import Cmd.Extra
import Json.Decode as Decode exposing (field)
import Json.Encode as Encode exposing (object, string)
import GlobalMsgs exposing (GlobalMsg(..))
import Login.Msgs exposing (Msg(..))
import Login.Models exposing (..)
import Login.Ports as Ports
import Login.Response as Response
import Login.MajorForm.Update


update : Login.Msgs.Msg -> Model -> ( Model, Cmd Msg )
update msg loginForm =
  let
    mysnuLoginForm =
      loginForm.mysnuLoginForm
  in
    case msg of
      UpdateLoginType newLoginType ->
        ( { loginForm | loginType = newLoginType }, Cmd.none)

      UpdateUsername newUsername ->
        let
          newMysnuLoginForm =
            { mysnuLoginForm | username = newUsername }
        in
         ( { loginForm | mysnuLoginForm = newMysnuLoginForm }, Cmd.none )

      UpdatePassword newPassword ->
        let
          newMysnuLoginForm =
            { mysnuLoginForm | password = newPassword }
        in
         ( { loginForm | mysnuLoginForm = newMysnuLoginForm }, Cmd.none )

      UpdateUseMysnuMajors newUseMysnuMajors ->
        let
          newMysnuLoginForm =
            { mysnuLoginForm | useMysnuMajors = newUseMysnuMajors }
        in
         ( { loginForm | mysnuLoginForm = newMysnuLoginForm }, Cmd.none )
  {- TODO:
   - handle fail message of response (after handle decoder)
   - handle Response & Responsejs together (after handle filerequest in elm)
   -}
      Response result ->
        let
          loadingOff =
            Cmd.Extra.perform (Global (Loading False))
        in
          case result of
            Ok success ->
              case success of
                True ->
                  ( loginForm, Cmd.batch [loadingOff, load "/"] )
                False ->
                  ( loginForm, loadingOff )
            Err error ->
              ( loginForm, loadingOff )

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

          loadingOff =
            Cmd.Extra.perform (Global (Loading False))
        in
         ( { loginForm | fileLoginForm = newfileLoginForm }, loadingOff )

      MajorMsg majorMsg ->
        let
          ( updatedMajorForm, cmd ) =
            Login.MajorForm.Update.update majorMsg loginForm.majorForm
        in
          ( { loginForm | majorForm = updatedMajorForm }, Cmd.map MajorMsg cmd)

      SubmitForm loginType ->
        case loginType of
          MysnuLogin ->
            let
              doSubmit =
                if mysnuLoginForm.username /= ""
                && mysnuLoginForm.password /= "" then
                  Cmd.batch
                  [ Cmd.Extra.perform (Global (Loading True))
                  , postMysnuLogin loginForm.mysnuLoginForm
                  ]
                else
                  Cmd.none

            in
              ( loginForm, doSubmit )

          FileLogin ->
            let
              formID =
                "filerequest"
              url =
                "/api/login/file/"

            in
              ( loginForm, Ports.fileRequest ( formID ++ "@" ++ url ) )

      Global _ ->
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
