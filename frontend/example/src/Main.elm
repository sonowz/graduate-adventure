module Main exposing (..)

import Html exposing (Html, text, h3, h4, h5, p, div, img)
import Html.Attributes exposing (src, style)
import Material
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Layout as Layout
import Material.Scheme as Scheme
import Material.Grid as Grid
import Material.Options as Options
import Material.Chip as Chip
import Material.Typography as Typo
import Material.Footer as Footer

---- MODEL ----


type alias Model =
    { message : String
    , logo : String
    , mdl : Material.Model
    }


model : Model
model =
    { message = "Maretial Design Lite with Elm Tutorial"
    , logo = ""
    , mdl = Material.model
    }


---- UPDATE ----


type Msg
    = Mdl (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl massage_ ->
            Material.update Mdl massage_ model



type alias RuleArea =
    { name : String
    , subjects : List (Int, String, Bool)
    }

type alias Category = 
    { name : String
    , ruleAreas : List RuleArea
    }

---- VIEW ----

type alias Theme =
    { primary : Color.Hue
    , accent : Color.Hue
    }

theme : Theme
theme =
    { primary = Color.BlueGrey
    , accent = Color.Amber
    }


backPrimary : Color.Shade -> Options.Style Msg
backPrimary shade =
    Color.background (Color.color theme.primary shade)

backAccent : Options.Style Msg
backAccent =
    Color.background (Color.color theme.accent Color.S100)


view : Model -> Html Msg
view model =
    Layout.render Mdl model.mdl
    [ Layout.fixedHeader
    , Layout.scrolling
    , Layout.selectedTab 0
    ]
    { header = 
        [ Layout.row
            [ backPrimary Color.S500
            ] 
            [ Layout.title [] [ text "Graduate Simulator" ]
            , Layout.spacer
            , Layout.navigation [] 
                [ Layout.link
                    [ Layout.href "/logout" ]
                    [ text "Logout" ]
                , Layout.link 
                    [ Layout.href "https://github.com/dnsdhrj/graduate-adventure" ]
                    [ text "GitHub" ]
                ]
            ]
        ]
    , drawer =
        [ Options.div
            [ Options.css "padding" "10px"
            ]
            [ h4 [ ] [ text "Options" ]
            ]
        ]
    , tabs = ( [ text "main", text "simulation" ], [ backPrimary Color.S400] )
    , main =
        [ Options.div
            [ Color.background (Color.color Color.Grey Color.S50)
            ]
            [ Options.div
                [ Options.css "max-width" "1560px"
                , Options.css "margin" "auto"
                ]
                [ Options.div
                    [ Options.css "padding" "8px"
                    ]
                    []
                , Grid.grid
                    [ {-backPurple Color.S100-}
                    ]
                    [ majorCell Color.Indigo "컴퓨터공학" "주전공" cseM (Just cseC)
                    , majorCell Color.Orange "수학" "복수전공" mathM Nothing
                    , majorCell Color.Teal "심리학" "부전공" psyM Nothing
                    , majorCell Color.Brown "경영학" "부전공" entM Nothing
                    ]
                ]
            ]
        , Footer.mini []
            { left =
                Footer.left []
                    [ Footer.logo [] [ Footer.html <| text "Graduate Simulator" ]
                    , Footer.links []
                        [ Footer.linkItem [ Footer.href "/about" ] [ Footer.html <| text "About" ]
                        , Footer.linkItem [ Footer.href "https://github.com/dnsdhrj/graduate-adventure/issues" ] [ Footer.html <| text "Issues" ]
                        ]
                    ]
            , right =
                Footer.right [] []
            }
        ]
    }
    |> Scheme.topWithScheme theme.primary theme.accent

cseM : Category
cseM =
    { name = "전공"
    , ruleAreas =
        [
            { name = "전필"
            , subjects =
                [ (3, "이산수학", True)
                , (4, "논리설계", True)
                , (3, "컴퓨터프로그래밍", True)
                , (3, "전기전자회로", True)
                , (4, "자료구조", True)
                , (3, "컴퓨터구조", True)
                , (3, "소프트웨어 개발의 원리와 실제", False)
                , (3, "시스템프로그래밍", True)
                , (3, "하드웨어시스템설계", True)
                , (3, "알고리즘", False)
                , (3, "공대 공통교과목", False)
                ]
            }
        ,
            { name = "내규"
            , subjects =
                [ (1, "컴퓨터공학 세미나", True)
                , (3, "창의적 통합설계", False)
                ]
            }
        ,
            { name = "전선"
            , subjects =
                [ (3, "데이터베이스", True)
                , (3, "프로그래밍 언어", True)
                , (3, "오토마타이론", True)
                , (3, "운영체제", True)
                , (3, "프로그래밍 연습", True)
                , (7, "전선", False)
                ]
            }
        ]
    }

cseC : Category
cseC =
    { name = "교양"
    , ruleAreas =
        [
            { name = "외국어"
            , subjects =
                [ (1, "기초영어", True)
                , (2, "대학영어1", True)
                , (2, "외국어", False)
                ]
            }
        ,
            { name = "수량적 분석과 추론"
            , subjects =
                [ (3, "수학 및 연습 1", True)
                , (3, "수학 및 연습 2", True)
                , (3, "공학수학 1", True)
                , (3, "공학수학 2", True)
                , (3, "통계학", True)
                , (3, "통계학실험", True)
                ]
            }
        ,
            { name = "과학적 사고와 실험"
            , subjects =
                [ (3, "물리학1", True)
                , (1, "물리학실험1", True)
                , (3, "화학", True)
                , (1, "화학실험", True)
                , (3, "물리학2", True)
                , (1, "물리학실험2", True)
                ]
            }
        ,
            { name = "컴퓨터와 정보활용"
            , subjects =
                [ (3, "컴퓨터의 개념 및 실습", True)
                ]
            }
        ,
            { name = "학문의 세계"
            , subjects =
                [ (3, "논리학", True)
                , (3, "인간생활과 경제", True)
                ]
            }
        ,
            { name = "사회성/창의성 교과목군"
            , subjects =
                [ (3, "사회성 교과목", False)
                , (3, "창의성 교과목", False)
                ]
            }
        ]
    }

mathM : Category
mathM =
    { name = "전공"
    , ruleAreas =
        [
            { name = "전필"
            , subjects = 
                [ (3, "해석개론 1", False)
                , (3, "현대대수학 1", False)
                ]
            }
        , 
            { name = "전선"
            , subjects =
                [ (3, "선형대수학", True)
                , (3, "미분방정식 및 연습", True)
                , (27, "전선", False)
                ]
            }
        ]
    }

psyM : Category
psyM =
    { name = "전공"
    , ruleAreas =
        [
            { name = "전필"
            , subjects =
                [ (3, "심리통계학", True)
                , (3, "실험심리 입문 및 실험", True)
                ]
            }
        ,
            { name = "전선"
            , subjects =
                [ (3, "성격심리학", True)
                , (12, "전선", False)
                ]
            }
        ]   
    }

entM : Category
entM =
    { name = "전공"
    , ruleAreas =
        []
    }


maybeToList : Maybe a -> List a
maybeToList maybe =
    case maybe of
        Just m ->
            [ m ]

        Nothing ->
            []


majorCell : Color.Hue -> String -> String -> Category -> Maybe Category -> Grid.Cell Msg
majorCell color name type_ major general =
    let
        isSingle =
            general == Nothing

        gridProperty =
            if isSingle then
                [ Grid.size Grid.Tablet 8, Grid.size Grid.All 6 ]

            else
                [ Grid.size Grid.All 12 ]
        
        categories =
            [ major ] ++ ( maybeToList general )

    in
        Grid.cell gridProperty
            [ Options.div
                [ Options.css "padding" "10px 20px"
                , Options.css "height" "40px"
                , Options.css "line-height" "40px"
                , Elevation.e2
                , Color.background (Color.color color Color.S500)
                , Color.text Color.white
                , Typo.headline
                ]
                [ Options.span
                    []
                    [ text name
                    , Html.sub [] [text ("/" ++ type_) ]
                    ]
                ]
            , Grid.grid
                [ Color.background Color.white
                , Options.css "border" "1px solid rgba(0,0,0,.1)"
                ]
                ( List.map (ruleCategory isSingle) categories )
            ]


ruleCategory : Bool -> Category -> Grid.Cell Msg
ruleCategory single cat =
    let
        cellProperty =
            if single then
                [ Grid.size Grid.All 12 ]
            else
                [ Grid.size Grid.Desktop 6, Grid.size Grid.All 8 ]
    in
        Grid.cell
            ([ Color.background Color.white] ++ cellProperty)
            [ Options.div
                [ Options.css "padding" "1px 10px"
                , Options.css "border-bottom" "3px solid rgba(0,0,0,.1)"
                , Options.css "height" "30px"
                , Typo.title
                ]
                [ text cat.name
                ]
            , ruleAreas cat.ruleAreas
            ]

ruleAreas : List RuleArea -> Html Msg
ruleAreas rules =
    Grid.grid
        [ Color.background Color.white
        ]
        (List.map ruleArea rules)


ruleArea : RuleArea -> Grid.Cell Msg
ruleArea rule =
    Grid.cell
        [ {-backPurple Color.S50
        , -}Grid.size Grid.All 12
        , Options.css "margin" "0px"
        , Options.css "padding" "8px"
        , Options.css "border-bottom" "1px solid rgba(0,0,0,.1)"
        ]
        [ Options.div
            [ Options.css "font-weight" "bold"
            ]
            [ text rule.name
            ]
        , Options.div 
            []
            (List.map subjectChip rule.subjects)
        ]

subjectChip : (Int, String, Bool) -> Html Msg
subjectChip (credit, name, isTaked) =
    Chip.button
        [ Options.css "margin" "3px"
        , Color.background (Color.color (if isTaked then Color.Green else Color.Red) Color.S100)
        ]
        [ Chip.contact Html.span
            [ Color.background Color.white
            , Color.text Color.black
            ]
            [ text (toString credit) ]
        , Chip.content []
            [ text name ]
        ]

---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = ( { model | mdl = Layout.setTabsWidth 1384 model.mdl }, Material.init Mdl )
        , update = update
        , subscriptions = Material.subscriptions Mdl
        }
