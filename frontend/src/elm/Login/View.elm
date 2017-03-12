module Login.View exposing (view)

import Html exposing (Html, div, p, text, button, input, form, label)
import Html.Attributes exposing (id, class, name, placeholder, action, type_, checked, value, for)
import Html.Events exposing (onClick, onInput, onCheck, onSubmit)
import Login.MajorForm.View
import Login.Models exposing (..)
import Login.Msgs exposing (Msg(..))


view : Model -> Html Msg
view loginForm =
  div
    [ id "login" ]
    [ div
      [ class "tab-area" ]
      [ tab MysnuLogin "계정으로 로그인" loginForm
      , tab FileLogin "성적파일로 입력" loginForm
      ]
    , div
      [ class "login-form" ]
      [ case loginForm.loginType of
          MysnuLogin ->
            viewMysnuLoginForm loginForm
          FileLogin ->
            viewFileLoginForm loginForm
      ]
    ]


tab : LoginType -> String -> Model -> Html Msg
tab loginType title loginForm =
  div
    [ type_ "button"
    , class (if loginForm.loginType == loginType then "tab active" else "tab")
    , onClick (UpdateLoginType loginType)
    ]
    [ p [] [ text title ] ]


viewMysnuLoginForm : Model -> Html Msg
viewMysnuLoginForm loginForm =
  form
    [ action "#"
    , id "mysnu-login-form"
    ]
    [ usernameField loginForm.mysnuLoginForm.username
    , passwordField loginForm.mysnuLoginForm.password
    , checkboxField loginForm.mysnuLoginForm.useMysnuMajors
    , if loginForm.mysnuLoginForm.useMysnuMajors then
        div [] []
      else
        Html.map MajorMsg (Login.MajorForm.View.view loginForm.majorForm)
    , submitButton MysnuLogin
    ]


usernameField : String -> Html Msg
usernameField username =
  div
    [ class "inline" ]
    [ label
      [ for "username" ]
      [ text "ID" ]
    , input
      [ type_ "text"
      , id "username"
      , name "username"
      , placeholder "mySNU ID"
      , value username
      , onInput UpdateUsername
      ]
      []
    ]


passwordField : String -> Html Msg
passwordField password =
  div
    [ class "inline" ]
    [ label
      [ for "password" ]
      [ text "PW" ]
    , input
      [ type_ "password"
      , id "password"
      , name "password"
      , placeholder "mySNU Password"
      , value password
      , onInput UpdatePassword
      ]
      []
    ]


checkboxField : Bool -> Html Msg
checkboxField useMysnuMajors =
  div
    [ class "checkBox"]
    [ input
      [ type_ "checkbox"
      , id "use-mysnu-majors"
      , checked useMysnuMajors
      , onCheck UpdateUseMysnuMajors
      ]
      []
    , label
      [ for "use-mysnu-majors" ]
      [ text "마이스누의 전공정보를 사용합니다" ]
    ]


viewFileLoginForm : Model -> Html Msg
viewFileLoginForm loginForm =
  form
    [ id "filerequest"
    , onSubmit None
    ]
    [ explanationBox
    , Html.map MajorMsg (Login.MajorForm.View.view loginForm.majorForm)
    , uploadFile loginForm
    , submitButton FileLogin
    , input [ type_ "hidden", name "filename", value "file" ] []
    ]


explanationBox : Html Msg
explanationBox =
  div
    [ class "explanationBox" ]
    [ text "다음과 같은 방식으로 성적 파일을 업로드합니다." ]


uploadFile : Model -> Html Msg
uploadFile loginForm =
  label
    [ id "fileInputButton" ]
    [ input
      [ type_ "file"
      , name "file"
      ]
      []
      , text "성적 파일 업로드"
      , text loginForm.fileLoginForm.file
    ]


submitButton : LoginType -> Html Msg
submitButton loginType =
  label
    [ class "inline loginButton"  ]
    [ input
      [ type_ "button"
      , value "로그인"
      , onClick (SubmitForm loginType)
      ]
      []
    ]
