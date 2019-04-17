import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Browser
import Browser.Navigation exposing (Key(..))
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Url
import Random
import List exposing(..)
import Tuple exposing(..)
import String exposing(..)
import Json.Encode as JEncode
import Json.Decode as JDecode
import Html exposing (..)
import Html.Attributes
import Html.Events as Events
import Http
import Debug

--<<Type Declaration>>
type Msg = Tick Float GetKeyState
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | DecideBigPlayer Player
         | ChangeColorTheme ThemeButton
         | LoginPost
         | SignUpPost
         | LogoutPost
         | GotoSignUpScreen
         | GotoLeaderBoardScreen
         | GoBackToGame
         | GoBack
         | GotLoginResponse (Result Http.Error String) 
         | GotSignupResponse (Result Http.Error String) 
         | GotLogoutResponse (Result Http.Error String) 
         | Username String
         | Password String
         | PostUserInfo (Result Http.Error String) 
         | GetUserInfo (Result Http.Error UserInfo)
         | GetOverallHighscore (Result Http.Error OverallHighscore)
         | ToGame


type Player = Player1 | Player2 | None

type State = Jump | NotJump

type GameStatus = Start | InProgress | End

type Screen = Login | SignUp | Game GameStatus | LeaderBoard

type ColorTheme = Theme1 | Theme2 | Theme3 | Theme4 | Theme5 

type ThemeButton = ThemeUp | ThemeDown | ThemeRight | ThemeLeft

type alias Model = { screen : Screen
                   , error : String 
                   , player1_pos : (Float,Float)
                   , player2_pos : (Float, Float)
                   , count : Int
                   , jumpX : Float
                   , bigPlayer : Player
                   , jumpingPlayer : Player
                   , credentials : Credentials
                   , userinfo : UserInfo       
                   , gameEnd : Bool
                   , overallHighscore : OverallHighscore
                   } 

--Need for server
type alias Credentials = { username : String
                         , password : String
                         }

type alias OverallHighscore = { username : String
                           , highscore : Int}

type alias UserInfo = { highscore : Int
                      , points : Int
                      , avgPoints : Float
                      , gamesPlayed : Int
                      , playerTheme : ColorTheme 
                      , deviceTheme : ColorTheme
                      }

--<<Helper Functions>>-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Function to get the jumping motion
getProjectile : Float -> Player -> Player -> Float 
getProjectile x bigPlayer jumpingPlayer = 
    let angle = 1.2
        g = if bigPlayer == jumpingPlayer then 0.49 else 0.8
        v = 4
        blob = g/(2*(v^2)*(cos(angle))^2)
    in (tan(angle)*x) - blob*(x^2)

--Function to update the player's position
updatePos : (Float,Float) -> (Float,Float) -> (Float,Float)
updatePos (a,b) (c,d) = (a+c,d)

--COLLISION DETECTION
--Check if a jumping big player collides with the small player
isCollisionBigOnSmall : (Float,Float) -> (Float,Float) -> Bool 
isCollisionBigOnSmall (a,b) (c,d) = 
    if a+16 > c  && abs(b-d) <= 10.5 && c > -6 then True 
    else False 

--Check if a jumping small player collides with the big player
isCollisionSmallOnBig : (Float,Float) -> (Float,Float) -> Bool 
isCollisionSmallOnBig (a,b) (c,d) =     
    if a+16 > c && (abs(b-d) < 17 && c > -6) then True 
    else False 

--Check if there's a x-collusion only (no jumping movement)
isCollisionNoJump : (Float,Float) -> (Float,Float) -> Bool 
isCollisionNoJump (a,b) (c,d) = a+16 >c  && c > -6

--Helper function to tell if both bigPlayer and jumpingPlayer are the same
playerMatch : Player -> Player -> Bool 
playerMatch a b = 
    if List.all (\x->x==Player1) [a,b] || List.all (\x->x==Player2) [a,b] then True 
    else False 

--Final collision function
isCollision : Model -> Bool 
isCollision model = 
    if playerMatch model.bigPlayer model.jumpingPlayer then
        isCollisionBigOnSmall model.player1_pos model.player2_pos 
    else if playerMatch model.bigPlayer model.jumpingPlayer == False then 
        isCollisionSmallOnBig model.player1_pos model.player2_pos 
    else isCollisionNoJump model.player1_pos model.player2_pos 

--Function to decide which player is bigger
randomizeSize : Random.Generator Player
randomizeSize = Random.map (\b -> if b == 0 then Player1 else Player2) <| Random.int 0 1

randDecideSize : Cmd Msg  
randDecideSize = Random.generate DecideBigPlayer randomizeSize

--change theme
changeThemeRight : ColorTheme -> ColorTheme 
changeThemeRight colorTheme =
        case colorTheme of 
                Theme1 -> Theme2
                Theme2 -> Theme3
                Theme3 -> Theme4
                Theme4 -> Theme5
                Theme5 -> Theme1

changeThemeLeft : ColorTheme -> ColorTheme 
changeThemeLeft colorTheme = 
        case colorTheme of 
                Theme5 -> Theme4 
                Theme4 -> Theme3
                Theme3 -> Theme2
                Theme2 -> Theme1
                Theme1 -> Theme5

colorThemeToPlayerColor : ColorTheme -> (Color, Color)
colorThemeToPlayerColor colorTheme = 
        case colorTheme of 
                Theme1 -> (red, blue)
                Theme2 -> (rgb 209 68 86, rgb 169 252 136)
                Theme3 -> (rgb 230 25 75, rgb 223 220 234)
                Theme4 -> (rgb 227 52 82, rgb 215 243 110)
                Theme5 -> (rgb 41 96 45, rgb 255 225 89)

colorThemeToDeviceColor : ColorTheme -> (Color, Color)
colorThemeToDeviceColor colorTheme =   
        case colorTheme of 
            Theme1 -> (rgb 42 54 82, rgb 211 224 247)
            Theme2 -> (rgb 215 243 110, rgb 227 52 82)
            Theme3 -> (rgb 38 54 98, rgb 156 213 190)
            Theme4 ->  (rgb 230 25 75, rgb 223 220 234)
            Theme5 -> (rgb 73 105 72, rgb 229 232 151)
--(rgb 249 213 102, rgb 226 62 79)
--(rgb 39 62 72, rgb 178 187 57)
colorThemeToString : ColorTheme -> String
colorThemeToString colorTheme = 
        case colorTheme of 
                Theme1 -> "1"
                Theme2 -> "2"
                Theme3 -> "3"
                Theme4 -> "4" 
                Theme5 -> "5"

colorThemeToInt : ColorTheme -> Int
colorThemeToInt colorTheme = 
        case colorTheme of 
                Theme1 -> 1
                Theme2 -> 2
                Theme3 -> 3
                Theme4 -> 4 
                Theme5 -> 5


--textOutline (to avoid repetition)
textOutline : String -> Float -> Shape userMsg
textOutline string n = GraphicSVG.text (string) |> bold |> sansserif |> size n |> filled black 


--SERVER------------------------
rootUrl = "https://mac1xa3.ca/e/leej229/"

--User Authentication
userPassEncoder : Model -> JEncode.Value
userPassEncoder model =
    JEncode.object
        [ ( "username", JEncode.string model.credentials.username)
        , ( "password", JEncode.string model.credentials.password)
        ]

loginPost : Model -> Cmd Msg
loginPost model =
    Http.post
        { url = rootUrl ++ "loginuser/"
        , body = Http.jsonBody <| userPassEncoder model 
        , expect = Http.expectString GotLoginResponse
        }

logoutPost : Cmd Msg 
logoutPost =
    Http.get 
        { url = rootUrl ++ "logoutuser/"
        , expect = Http.expectString GotLogoutResponse
        }

signupPost : Model -> Cmd Msg
signupPost model =
    Http.post
        { url = rootUrl ++ "signup/"
        , body = Http.jsonBody <| userPassEncoder model
        , expect = Http.expectString GotSignupResponse
        }

--UserInfo
userInfoEncoder : Model -> JEncode.Value 
userInfoEncoder model =
    JEncode.object
        [  ("highscore", JEncode.int model.userinfo.highscore)
          , ("gamesPlayed", JEncode.int model.userinfo.gamesPlayed)
          , ("points", JEncode.int model.userinfo.points)
          , ("playerTheme", JEncode.string (colorThemeToString model.userinfo.playerTheme))
          , ("deviceTheme", JEncode.string (colorThemeToString model.userinfo.deviceTheme))
        ]
postUserInfo : Model -> Cmd Msg
postUserInfo model = 
    Http.post
        { url = rootUrl ++ "postuserinfo/"
        , body = Http.jsonBody <| userInfoEncoder model
        , expect = Http.expectString PostUserInfo
        }

userInfoDecoder : JDecode.Decoder UserInfo  
userInfoDecoder = 
    JDecode.map6 UserInfo
        (JDecode.field "highscore" JDecode.int)
        (JDecode.field "points" JDecode.int)
        (JDecode.field "avgPoints" JDecode.float)
        (JDecode.field "gamesPlayed" JDecode.int)
        (JDecode.field "playerTheme" decodeColorThemeType)
        (JDecode.field "deviceTheme" decodeColorThemeType)

decodeColorThemeType : JDecode.Decoder ColorTheme   
decodeColorThemeType = 
    JDecode.string |> JDecode.andThen (\colorThemeTypeString ->
        case colorThemeTypeString of 
            "1" -> JDecode.succeed Theme1 
            "2" -> JDecode.succeed Theme2 
            "3" -> JDecode.succeed Theme3 
            "4" -> JDecode.succeed Theme4 
            "5" -> JDecode.succeed Theme5 
            _ -> JDecode.succeed Theme5
    )

getUserInfo : Model -> Cmd Msg 
getUserInfo model =  
    Http.post 
        { url = rootUrl ++ "getuserinfo/"
        , body = Http.jsonBody <| userPassEncoder model
        , expect = Http.expectJson GetUserInfo userInfoDecoder
        }


--Get overall highscore from server
getOverallHighscore : Cmd Msg 
getOverallHighscore =  
    Http.get 
        { url = rootUrl ++ "getoverallhighscore/"
        , expect = Http.expectJson GetOverallHighscore overallHighscoreDecoder
        }

overallHighscoreDecoder : JDecode.Decoder OverallHighscore 
overallHighscoreDecoder = 
    JDecode.map2 OverallHighscore 
        (JDecode.field "username" JDecode.string)
        (JDecode.field "highscore" JDecode.int)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
loginCmdMsg model = Cmd.batch [ getUserInfo model, getOverallHighscore]
gameEndCmdMsg model = Cmd.batch [postUserInfo model, getUserInfo model, getOverallHighscore]

--<<Init>>
init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key = 
    let model = { screen = Login
                , error = ""
                , player1_pos = (-30,-10)
                , player2_pos = (30,-10) 
                , count = 0
                , jumpX = 1.5
                , bigPlayer = Player2
                , jumpingPlayer = None
                , gameEnd = False
                , credentials = {username = "", password = ""}
                , userinfo= {highscore = 0, points = 0, avgPoints = 0.0, gamesPlayed = 0, playerTheme = Theme1, deviceTheme = Theme1}
                , overallHighscore = {username = "", highscore = 0}
                }   
    in ( model , randDecideSize) -- add init model

--<<Update>>
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case Debug.log "msg" msg of
        Tick time (keyToState,(arrowX,arrowY),(wasdX,wasdY)) -> 
            let player1_jumpState = 
                    case keyToState (Key "q") of 
                        JustDown ->  Jump 
                        Down -> Jump
                        _ ->  NotJump

                player2_jumpState =
                    case keyToState (Key "w") of 
                        JustDown -> Jump
                        Down -> Jump
                        _ -> NotJump

                restart = 
                    case keyToState Space of 
                        JustDown -> True 
                        _ -> False

                player1_jumpingModel = {model | jumpingPlayer = Player1--change jumpStatus to jump
                                                , jumpX = model.jumpX + 1.5
                                                , player1_pos = updatePos (model.player1_pos) (2.5, getProjectile model.jumpX model.bigPlayer model.jumpingPlayer )
                                                , player2_pos = updatePos (model.player2_pos) (-2.5, -10)
                                                , count = model.count + 1 }

                notJumpingModel = {model | jumpingPlayer = None
                                            , jumpX = 0
                                            , player1_pos = updatePos (model.player1_pos) (2.5, -10)
                                            , player2_pos = updatePos (model.player2_pos) (-2.5,-10) }

                player2_jumpingModel = {model | jumpingPlayer = Player2
                                                , jumpX = model.jumpX + 1.5
                                                , player1_pos = updatePos (model.player1_pos) (2.5,-10)
                                                , player2_pos = updatePos (model.player2_pos) (-2.5, getProjectile model.jumpX model.bigPlayer model.jumpingPlayer )
                                                , count = model.count + 1 }

                resetModel = let oldUserInfo = model.userinfo 
                                 newUserInfo = { oldUserInfo | points = model.userinfo.points + 1}
                             in {model | player1_pos = (-114,-10)
                                    , count = 0
                                    , jumpingPlayer = None 
                                    , jumpX = 0
                                    , player2_pos = (114,-10)
                                    , userinfo = newUserInfo}

            in --CASE 1) if game over and player presses spacebar to restart
                if model.screen == Login || model.screen == SignUp || model.screen == LeaderBoard then (model,Cmd.none)
                else if model.screen == Game Start  && restart == False then (model,Cmd.none)
                else if restart && (model.screen == Game End || model.screen == Game Start) then 
                    let
                        oldUserInfo = model.userinfo 
                        newUserInfo = { oldUserInfo | gamesPlayed = model.userinfo.gamesPlayed + 1, points = 0}
                        newModel = { model | player1_pos = (-114,-10)
                                    , player2_pos = (114,-10) 
                                    , count = 0
                                    , jumpX = 1.5
                                    , bigPlayer = None
                                    , jumpingPlayer = None
                                    , screen = Game InProgress
                                    , gameEnd = False
                                    , userinfo = newUserInfo }
                    in (newModel, randDecideSize)
                --CASE 2)if there's a collision, end game 
                else if isCollision model then 
                    let
                        newHighscore = if model.userinfo.points > model.userinfo.highscore then model.userinfo.points else model.userinfo.highscore 
                        oldUserInfo = model.userinfo
                        newUserInfo= { oldUserInfo | highscore = newHighscore}
                        newModel = {model | player1_pos = model.player1_pos, player2_pos = model.player2_pos, screen = Game End, userinfo = newUserInfo, gameEnd=True }
                    in
                        if model.gameEnd == True then
                            (model,Cmd.none)
                        else
                            (newModel, postUserInfo newModel) --sendHighscore model 
                
                --CASE 3) for 100 ticks, move players, after 100 ticks, reset to original position
                else if model.count < 100 then
                    --if player1 initialized jumping 
                    if (player1_jumpState == Jump) && (model.jumpingPlayer == None) then
                        (player1_jumpingModel, Cmd.none)
                    --if player1 is still in air 
                    else if model.jumpingPlayer == Player1 then 
                        -- if player 1 hit the ground; ie finished jumping
                        if (getProjectile model.jumpX model.bigPlayer model.jumpingPlayer ) <= -10 then 
                            (notJumpingModel, Cmd.none)
                        -- if player1 is still in air
                        else (player1_jumpingModel, Cmd.none)
                    --if player2 initialized jumping
                    else if (player2_jumpState == Jump) && model.jumpingPlayer == None then
                        (player2_jumpingModel, Cmd.none)
                    --if player2 is still in air
                    else if model.jumpingPlayer == Player2 then 
                        -- of player2 hits the ground
                        if (getProjectile model.jumpX model.bigPlayer model.jumpingPlayer ) <= -10 then 
                            (notJumpingModel, Cmd.none)
                    -- if player1 is still in air
                        else (player2_jumpingModel, Cmd.none)              
                    --if neither player1 nor player2 jumps
                    else
                        ({model | player1_pos = updatePos (model.player1_pos) (2.5,-10)
                                , player2_pos = updatePos (model.player2_pos) (-2.5,-10)
                                , count = model.count + 1
                                , screen = Game InProgress }
                        , Cmd.none)

                --CASE 4) if time == 2 seconds, reset to original position
                else (resetModel, Cmd.batch[randDecideSize, Cmd.none])
        
        MakeRequest req    -> (model, Cmd.none)
        UrlChange url      -> (model, Cmd.none)

        DecideBigPlayer player -> ({model | bigPlayer = player}, Cmd.none) --where to put getoverall highscore lol NOTE!!

        ChangeColorTheme button -> --ChangeColorThemeRight # case sdgadsg of asgsadgd do asdgasgs
                let newTheme = 
                        case button of
                            ThemeUp -> changeThemeRight model.userinfo.deviceTheme
                            ThemeDown -> changeThemeLeft model.userinfo.deviceTheme
                            ThemeRight -> changeThemeRight model.userinfo.playerTheme
                            ThemeLeft -> changeThemeLeft model.userinfo.playerTheme
                in 
                    if member button [ThemeUp, ThemeDown] then
                        let oldUserInfo = model.userinfo
                            newUserInfo = {oldUserInfo | deviceTheme = newTheme}
                            newModel = {model | userinfo = newUserInfo}
                        in ({model | userinfo = newUserInfo}, postUserInfo newModel)
                    else 
                        let oldUserInfo = model.userinfo
                            newUserInfo = {oldUserInfo | playerTheme = newTheme}
                            newModel = {model | userinfo = newUserInfo}
                        in (newModel, postUserInfo newModel)

        --Login
        LoginPost -> (model, loginPost model) --log in button

        LogoutPost -> (model, logoutPost)
        
        GotoSignUpScreen -> 
            let oldCredentials= model.credentials
                newCredentials = { oldCredentials | username = "", password = ""}
            in ({model | credentials = newCredentials, screen = SignUp, error = ""}, Cmd.none)

        GotoLeaderBoardScreen ->
            if member model.screen [Game Start, Game End] then ({model | screen = LeaderBoard}, Cmd.none)
            else (model, Cmd.none)

        GoBackToGame ->
            if model.screen == LeaderBoard then ({model | screen = Game Start}, Cmd.none)
            else (model, Cmd.none)

        SignUpPost -> (model,signupPost model) 

        GoBack ->             --THIS IS EXACLY SAME AS LOGOUTSCREEN 
            let oldCredentials= model.credentials
                newCredentials= { oldCredentials | username = "", password = ""}
            in ({model | credentials = newCredentials, screen = Login, error = ""}, Cmd.none) 
        --Update username and password on user input
        Username newUsername -> 
            let
                oldCredentials = model.credentials
                newCredentials = { oldCredentials | username = newUsername}
            in
                ({model | credentials = newCredentials}, Cmd.none)

        Password newPassword ->
            let oldCredentials = model.credentials
                newCredentials = { oldCredentials | password = newPassword}
            in ({model | credentials = newCredentials}, Cmd.none)

        --SERVER 
        PostUserInfo result ->
            case result of 
                Ok "UpdatedUserInfo" ->
                    ( model, Cmd.batch[getOverallHighscore,getUserInfo model])
                Ok "UserIsNotLoggedIn" ->
                    ( {model | error = "User Is Not Logged In"}, Cmd.none)
                Ok _ -> 
                    (model, Cmd.none)
                Err error ->
                    ( handleError model error, Cmd.none )

        GetUserInfo result -> 
            case result of
                Ok newModel ->
                    ( { model | userinfo = newModel}, Cmd.none)
                Err error ->
                    ( handleError model error, Cmd.none )

        GetOverallHighscore result-> 
            case result of 
                Ok newModel -> 
                    ( { model | overallHighscore = newModel}, Cmd.none)
                Err error ->    
                    ( handleError model error, Cmd.none)



        --User Authentication 
        GotLoginResponse result ->
            case result of
                Ok "LoginFailed" ->
                   ( { model | error = "Incorrect Username/Password"}, Cmd.none)
                Ok "LoggedIn" ->
                    ( { model | screen = Game Start, player1_pos = (-30,-10), player2_pos = (30,-10), error = "" }, loginCmdMsg model)
                Ok _ -> 
                    (model, Cmd.none)
                Err error ->
                    ( handleError model error, Cmd.none )

        GotSignupResponse result ->
            case result of 
                Ok "SignupFail" ->  
                    ({ model | error = "Invalid Username/Password"}, Cmd.none)
                Ok "UserAlreadyExists" ->
                    ({ model | error = "User Already Exists! Try Again."}, Cmd.none)
                Ok _ ->
                    ( {model | screen = Game Start, player1_pos = (-30,-10), player2_pos = (30,-10), error = "" }, Cmd.none)
                Err error ->
                    ( handleError model error, Cmd.none )


        GotLogoutResponse result ->
            case result of 
                Ok "LoggedOut" ->
                    let
                        oldCredentials= model.credentials
                        newCredentials= { oldCredentials | username = "", password = ""}
                        oldUserInfo = model.userinfo 
                        newUserInfo = { oldUserInfo | highscore = 0, points = 0, avgPoints = 0, gamesPlayed = 0, playerTheme = Theme1, deviceTheme = Theme1}
                    in
                        ({model | credentials = newCredentials, userinfo = newUserInfo, screen = Login, error = ""}, Cmd.none) --TODO: update logout post!!
                Ok _ -> ( {model | error = "something happened"}, Cmd.none)
                Err error ->
                    ( handleError model error, Cmd.none)


        ToGame -> ({model | screen = Game Start}, Cmd.none)

--error 
handleError : Model -> Http.Error -> Model
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | error = "bad url: " ++ url }
        Http.Timeout ->
            { model | error = "timeout" }
        Http.NetworkError ->
            { model | error = "network error" }
        Http.BadStatus i ->
            { model | error = "bad status " ++ String.fromInt i }
        Http.BadBody body ->
            { model | error = "bad body " ++ body }




--<<View>>
view : Model -> { title : String, body : Collage Msg }
view model = 
    let title = "Clash!"
        body = collage 101 150 shapes
        shapes =
            case model.screen of
                Login -> 
                    [ html 50 20 (Html.input [Html.Attributes.style "width" "25px", Html.Attributes.style "height" "5px", Html.Attributes.style "font-size" "3pt", Html.Attributes.placeholder "Username", Events.onInput Username][])
                        |> move (0,35)
                    , html 50 20 (Html.input [Html.Attributes.style "width" "25px", Html.Attributes.style "height" "5px", Html.Attributes.style "font-size" "3pt", Html.Attributes.placeholder "Password", Html.Attributes.type_ "password", Events.onInput Password] [])
                        |> move (0,20)
                    , loginTitle
                    , userBox 
                    , passwordBox
                    , loginButton
                    , gotoSignUpButton
                    , usertest
                    , togame
                    , errorMessage
                    ]
                SignUp -> 
                    [ html 50 20 (Html.input [Html.Attributes.style "width" "25px", Html.Attributes.style "height" "5px", Html.Attributes.style "font-size" "3pt", Html.Attributes.placeholder "Username", Events.onInput Username] [])
                        |> move (0,35)
                    ,   html 50 20 (Html.input [Html.Attributes.style "width" "25px", Html.Attributes.style "height" "5px", Html.Attributes.style "font-size" "3pt", Html.Attributes.placeholder "Password", Html.Attributes.type_ "password", Events.onInput Password] [])
                        |> move (0,20)
                    , signUpTitle
                    , userBox 
                    , passwordBox
                    , signUpButton
                    , goBackButton
                    , usertest
                    , errorMessage
                    ]
                Game _ ->
                    [ gamebody, background, caption, points, startText, gameOver, overallHighscore, floor,username, player1, player2, logoutButton, themeButtons, showLeaderBoardButton, goBackToGameButton ] 

                LeaderBoard -> 
                    [ gamebody, background, caption, overallHighscore, floor,username, logoutButton, themeButtons, showLeaderBoardButton, goBackToGameButton ] 


        togame = square 5
            |> filled green 
            |> notifyTap ToGame 
        usertest = textOutline (model.credentials.username ++ "/" ++ model.credentials.password) 4
            |> move (0,-40)

        errorMessage = GraphicSVG.text model.error
            |> size 5
            |> sansserif
            |> bold 
            |> filled red 
            |> move (-39,-25) 
        
        --Screen: LOGIN
        loginTitle = textOutline "Login" 12
            |> move (-18,40)

        loginButton = group [loginShape,loginText]
            |> move (-20,-13)
            |> scale 0.7
            |> notifyTap LoginPost

        loginShape = rect 30 10 
            |> filled grey 
            |> addOutline(solid 0.7) black 

        loginText = textOutline "Login" 6
            |> move (-8,-2)

        userBox = group [userShape,userText]
            |> move (-20,22.7)

        userShape = rect 30 10.5
            |> filled lightRed 
            |> addOutline(solid 0.7) black 

        userText = textOutline "Username" 5
            |> move (-12,-2)
      
        passwordBox = group [passwordShape,passwordText]
            |> move (-20,8)

        passwordShape = rect 30 10.5
            |> filled blue 
            |> addOutline(solid 0.7) black 

        passwordText = textOutline "Password" 5
            |> move (-12,-2)

        gotoSignUpButton = group [gotoSignUpShape,gotoSignUpText]
            |> move (15,-13)
            |> scale 0.7
            |> notifyTap GotoSignUpScreen

        gotoSignUpShape = rect 30 10 
            |> filled grey 
            |> addOutline(solid 0.7) black 
        
        gotoSignUpText = textOutline "Sign up" 6
            |> move (-10,-2)
        
        --Screen: SIGNUP
        signUpTitle = textOutline "Sign Up" 12
            |> move (-24,40)

        signUpButton = group [signUpShape,signUpText]
            |> move (15,-13)
            |> scale 0.7
            |> notifyTap SignUpPost

        signUpShape = rect 30 10 
            |> filled grey 
            |> addOutline(solid 0.7) black 

        signUpText = textOutline "Sign up" 6
            |> move (-10,-2)
        
        goBackButton = group [goBackShape,goBackText]
            |> move (-20,-13)
            |> scale 0.7
            |> notifyTap GoBack

        goBackShape = rect 30 10 
            |> filled grey 
            |> addOutline(solid 0.7) black 

        goBackText = textOutline "Go Back" 6
            |> move (-12,-2)
        
        --Screen: GAME
        caption = textOutline "Clash!" 10
            |> move (-13,54)

        points = GraphicSVG.text ("Points: " ++ (String.fromInt model.userinfo.points)) 
            |> sansserif
            |> bold 
            |> size 4
            |> (if model.screen == Game Start then filled blank else filled black)
            |> move (-7,47)
        
        username = textOutline ("User: " ++ model.credentials.username) 4
            |> move (-46,-30)

        startText = group [gameStart, instructions1, instructions2, instructions3, instructions4]
            |> move (0,4)

        instructions1 = GraphicSVG.text ("Instructions")
            |> sansserif
            |> bold 
            |> underline
            |> size 5
            |> (if model.screen == Game Start then filled black else filled blank)
            |> move (-13,40)

        instructions2 = GraphicSVG.text "-Press Q to jump Player 1"
            |> sansserif
            |> bold 
            |> size 3
            |> (if model.screen == Game Start then filled black else filled blank)
            |> move (-17,35)
        
        instructions3 = GraphicSVG.text ("-Press W to jump Player 2")
            |> sansserif
            |> bold 
            |> size 3
            |> (if model.screen == Game Start then filled black else filled blank)
            |> move (-17,30)     

        instructions4 = GraphicSVG.text ("-Big guy jumps over the small guy")
            |> sansserif
            |> bold 
            |> size 3
            |> (if model.screen == Game Start then filled black else filled blank)
            |> move (-22,25)    

        gameStart = GraphicSVG.text ("Press Spacebar to Start!")
            |> sansserif
            |> bold 
            |> size 5
            |> (if model.screen == Game  Start then filled red else filled blank)
            |> move (-29,15)

        gameOver = GraphicSVG.text ("Game Over! Press Spacebar to Restart!")
            |> sansserif 
            |> bold
            |> size 5
            |> (if model.screen == Game  End then filled red else filled blank)
            |> move (-46,35)

        -- highScoreBoard = group [highScore, user, highscorePoints]
        showLeaderBoardButton = group [showLeaderBoardShape, showLeaderBoardText]
            |> move (13,-45)
            |> notifyTap GotoLeaderBoardScreen

        showLeaderBoardShape = roundedRect 9 9 2
            |> (filled (second (colorThemeToDeviceColor model.userinfo.deviceTheme)))
            |> addOutline (solid 0.7) black 
        
        showLeaderBoardText = textOutline "L" 8
            |> move (-2.5,-2.5)

        --Go back button
        goBackToGameButton = group [goBackToGameShape, goBackToGameText]
            |> move (13,-56)
            |> notifyTap GoBackToGame

        goBackToGameShape = roundedRect 9 9 2
            |> (filled (second (colorThemeToDeviceColor model.userinfo.deviceTheme)))
            |> addOutline (solid 0.7) black 
        
        goBackToGameText = textOutline "B" 8
            |> move (-3,-3)


        overallHighscore = group [highscoreShape, highScore, user, highscorePoints, gamesPlayed, avgPoints]
            |> move (3,-3)

        highscoreShape = roundedRect 47 33 2
            |> filled lightGrey
            |> addOutline (solid 0.7) black 
            |> move (-24,-50)

        highScore = textOutline ("Overall Highscore: " ++ String.fromInt model.overallHighscore.highscore) 4
            |> move (-45,-40)
       
        user = textOutline ("By User: " ++ model.overallHighscore.username) 3
            |> move (-45,-45)

        highscorePoints = textOutline ("Your highscore is: " ++ String.fromInt model.userinfo.highscore ) 3
            |> move (-45,-52)

        gamesPlayed = textOutline ("# Games Played: " ++ String.fromInt model.userinfo.gamesPlayed) 3
            |> move (-45, -57)

        avgPoints = textOutline ("Avg Points: " ++ String.fromFloat model.userinfo.avgPoints ) 3
            |> move (-45, -62)

        background = square 100
            |> filled (rgb 214 244 255)
            |> addOutline (solid 1) black 
            |> move (0, 17)

        floor = rect 100 20
            |> filled (rgb 177 227 127)
            |> addOutline (solid 1) black 
            |> move (0,-23.5)

        --Player 1
        player1 = group [player1_body, player1_eye]
            |> move (model.player1_pos)

        player1_body = 
                if model.bigPlayer == Player1 then
                        square 16
                        |> filled (first (colorThemeToPlayerColor model.userinfo.playerTheme))
                        |> addOutline (solid 1) black
                        |> move (0.0,5.5)
                else
                        square 8
                        |> filled (first (colorThemeToPlayerColor model.userinfo.playerTheme))
                        |> addOutline (solid 1) black
                        |> move(0.0,1.5)

        player1_eye = 
            if model.bigPlayer == Player1 then
                circle 1.5
                |> filled white
                |> move (3,7)
                |> addOutline (solid 1) black
            else
                circle 0.8
                |> filled white
                |> move(1.7,2)
                |> addOutline(solid 0.7) black

        --Player 2
        player2 = group [player2_body, player2_eye]
            |> move (model.player2_pos)

        player2_body = if model.bigPlayer == Player2 then 
                    square 16
                    |> filled (second (colorThemeToPlayerColor model.userinfo.playerTheme))
                    |> addOutline (solid 1) black 
                    |> move (0.0,5.5)
                else 
                    square 8
                    |> filled (second (colorThemeToPlayerColor model.userinfo.playerTheme))
                    |> addOutline (solid 1) black 
                    |> move(0.0,1.5)

        player2_eye = 
            if model.bigPlayer == Player2 then 
                rect 6 2 
                    |> filled white 
                    |> addOutline (solid 1) black 
                    |> move (3.5,7.5)
                    |> rotate 0.7
            else 
                rect 2.5 1
                    |> filled white 
                    |> addOutline (solid 0.5) black
                    |> rotate (0.7)
                    |> move (-1,2.5)

        --theme
        gamebody = roundedRect 100 148 5
            |> (filled (first (colorThemeToDeviceColor model.userinfo.deviceTheme)))
            |> addOutline (solid 1) black 

        themeButtons = group[ --UpButton
                              circle 4 |> (filled (second (colorThemeToDeviceColor model.userinfo.deviceTheme))) |> addOutline(solid 0.7) black |> move (28.5,-40) |> notifyTap (ChangeColorTheme ThemeUp)
                            , triangle 2 |> filled black |> rotate (3.14/2)|> move (28.5,-40) |> (notifyTap (ChangeColorTheme ThemeUp))
                             -- DownButton
                            , circle 4 |> (filled (second (colorThemeToDeviceColor model.userinfo.deviceTheme)))|> addOutline(solid 0.7) black |> move (28.5,-56) |> notifyTap (ChangeColorTheme ThemeDown)
                            , triangle 2 |> filled black |> rotate (3.14/2) |> mirrorY |> move (28.5,-56) |> notifyTap (ChangeColorTheme ThemeDown)
                             -- RightButton
                            ,  circle 4 |> (filled (second (colorThemeToDeviceColor model.userinfo.deviceTheme))) |> addOutline(solid 0.7) black |> move (36,-48) |> notifyTap (ChangeColorTheme ThemeRight)
                            , triangle 2 |> filled black |> move (36, -48) |> notifyTap (ChangeColorTheme ThemeRight)
                            -- LeftButton
                            , circle 4 |> (filled (second (colorThemeToDeviceColor model.userinfo.deviceTheme))) |> addOutline(solid 0.7) black  |> move (21,-48) |> notifyTap (ChangeColorTheme ThemeLeft)
                            , triangle 2 |> filled black |> mirrorX |> move (21,-48) |> notifyTap (ChangeColorTheme ThemeLeft)
                            ] |> move (6,0)

        --logout
        logoutButton = group [logoutShape,logoutText]
            |> move (41,-96)
            |> scale 0.7
            |> notifyTap LogoutPost

        logoutShape = roundedRect 30 10 2
            |> filled (rgb 212 53 79)
            |> addOutline(solid 1) black 

        logoutText = textOutline "Logout" 6
            |> move (-10,-2)

        

    in { title = title , body = body }

--<<Other>>
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : AppWithTick () Model Msg
main = appWithTick Tick
       { init = init
       , update = update
       , view = view
       , subscriptions = subscriptions
       , onUrlRequest = MakeRequest
       , onUrlChange = UrlChange
       } 



