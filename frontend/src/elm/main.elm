import Html exposing (..)


-- APP
main : Program Never Model Msg
main =
  Html.beginnerProgram { model = model, view = view, update = update }


-- MODEL
type Model = Empty

model : Model
model = Empty


-- UPDATE
type Msg = None

update : Msg -> Model -> Model
update msg model = Empty

-- VIEW
view : Model -> Html Msg
view model =
  div [] []
