module Main exposing (..)
import Http exposing(..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput,onClick)
import String


-- MAIN
main =
  Browser.element{ init = init, update = update, view = view, subscriptions = subscriptions}


-- MODEL
type alias Model =
  { name : String
  , password : String
  , passwordAgain : String
  , response : String
  }

testpost : String -> String -> String -> Cmd Msg
testpost name password passwordAgain=
    Http.post
        { url = "https://mac1xa3.ca/e/leej229/lab7/"
        , body = Http.stringBody "application/x-www-form-urlencoded" ("user="++name++"&password="++password++"&passwordAgain="++passwordAgain)
        , expect = Http.expectString GotText
        }

init : () -> ( Model, Cmd Msg )
init _ = ({name="",password="",passwordAgain="",response=""}, Cmd.none )

-- UPDATE
type Msg
  = Name String
  | Password String
  | PasswordAgain String
  | ButtonPushed String String String
  | GotText (Result Http.Error String)



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    --Change name
    Name newName ->
      ({ model | name = newName }, Cmd.none)
    --Change password
    Password newPassword ->
      ({ model | password = newPassword }, Cmd.none)
    --Change passwordAgain
    PasswordAgain newPasswordAgain ->
      ({ model | passwordAgain = newPasswordAgain }, Cmd.none)
    --When button's pushed, update response
    ButtonPushed name password passwordAgain->
        ({ model | name = name, password = password, passwordAgain = passwordAgain }, testpost model.name model.password model.passwordAgain )
    --Error Handling
    GotText result ->
            case result of
                Ok val ->
                    ( { model | response = val }, Cmd.none)
                    
                Err error ->
                    (handleError model error , Cmd.none)


--Error Handling
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | response = "bad url: " ++ url }  
        Http.Timeout ->
            { model | response = "timeout" }
        Http.NetworkError ->
            { model | response = "network error" }
        Http.BadStatus i ->
            { model | response = "bad status " ++ String.fromInt i }
        Http.BadBody body ->
            { model | response = "bad body " ++ body }

-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ viewInput "text" "Name" model.name Name
    , viewInput "password" "Password" model.password Password
    , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
    , viewValidation model
    , viewButton model.name model.password model.passwordAgain "Log In"
    , viewText model.response
    ]

--Button
viewButton : String -> String -> String -> String -> Html Msg
viewButton name password passwordAgain msg = 
  button [onClick (ButtonPushed name password passwordAgain)] [text msg]

--View resulting response from post
viewText : String -> Html Msg
viewText response = div [] [text response]

--view input name,password,etc...
viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []

--view OK/Passwords do not match
viewValidation : Model -> Html msg
viewValidation model =
  if model.password == model.passwordAgain then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Passwords do not match!" ]

--Subscription
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none