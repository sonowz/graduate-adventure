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
    []
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
    [ action "#"
    , id "file-login-form"
    ]
    [ div
      [ class "inline" ]
      [ input
        [ type_ "text"
        , id "file"
        , name "file"
        , placeholder "put grade file"
        , value loginForm.fileLoginForm.file
        , onInput UpdateFile
        ]
        []
      ]
    , Html.map MajorMsg (Login.MajorForm.View.view loginForm.majorForm)
    , submitButton FileLogin
    ]


submitButton : LoginType -> Html Msg
submitButton loginType =
  div
    [ class "inline"  ]
    [ input
      [ type_ "button"
      , id "submit"
      , value "로그인"
      , onSubmit (SubmitForm loginType)
      ]
      []
    ]
