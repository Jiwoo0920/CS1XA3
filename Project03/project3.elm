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

--<<Type Declaration>>
type Msg = Tick Float GetKeyState
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | DecideBigPlayer Player
         | ChangeColorThemeRight
         | ChangeColorThemeLeft
         | ChangeDeviceColorUp
         | ChangeDeviceColorDown
         | LoginPost
         | GotoSignUpScreen
         | SignUpPost
         | GoBack
         | LogOutScreen
         | GotLoginResponse (Result Http.Error String) 
         | GotHighscoreResponse (Result Http.Error String) 
         | Username String
         | Password String
         | GetUserInfo (Result Http.Error UserInfo)
         | GetOverallHighscore (Result Http.Error UserInfo)
         | ToGame
         | GotSettingPostResponse (Result Http.Error String) 


type Player = Player1 | Player2 | None

type State = Jump | NotJump

type GameStatus = Start | InProgress | End

type Screen = Login | SignUp | Game GameStatus 

type ColorTheme = Theme1 | Theme2 | Theme3 | Theme4 | Theme5 



type alias Model = { screen : Screen
                   , error : String 
                   , player1_pos : (Float,Float)
                   , player2_pos : (Float, Float)
                   , count : Int
                   , jumpX : Float
                   , bigPlayer : Player
                   , points : Int 
                   , jumpingPlayer : Player
                   , credentials : Credentials
                   , userinfo : UserInfo
                   , overallHighscore : OverallHighscore
                   , settings : Settings
                   } 

--Need for server
type alias Credentials = { username : String
                         , password : String
                         }

type alias UserInfo = { username : String
                           , highscore : Int}

type alias OverallHighscore = { username : String 
                              , highscore : Int
                              }

type alias Settings = { username : String
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
            Theme1 -> (rgb 154 157 170, rgb 212 53 79)
            Theme2 -> (rgb 38 54 98, rgb 212 53 79)
            Theme3 -> (rgb 156 213 190, rgb 38 54 98)
            Theme4 -> (rgb 39 62 72, rgb 178 187 57)
            Theme5 -> (rgb 83 113 74, rgb 171 197 99)

colorThemeToString : ColorTheme -> String
colorThemeToString colorTheme = 
        case colorTheme of 
                Theme1 -> "1"
                Theme2 -> "2"
                Theme3 -> "3"
                Theme4 -> "4" 
                Theme5 -> "5"

stringToColorTheme : String -> ColorTheme 
stringToColorTheme string =
    case string of  
        "1" -> Theme1 
        "2" -> Theme2 
        "3" -> Theme3 
        "4" -> Theme4 
        "5" -> Theme5
        _ -> Theme1

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

signupPost : Model -> Cmd Msg
signupPost model =
    Http.post
        { url = rootUrl ++ "signup/"
        , body = Http.jsonBody <| userPassEncoder model
        , expect = Http.expectString GotLoginResponse
        }

--HIGHSCORE
highscoreEncoder : String -> Int -> JEncode.Value 
highscoreEncoder username highscore =
    JEncode.object
        [ ("username", JEncode.string username)
        , ("highscore", JEncode.int highscore)
        ]

highscorePost : String -> Int -> Cmd Msg
highscorePost username highscore =
    Http.post
        { url = rootUrl ++ "gethighscore/"
        , body = Http.jsonBody <| highscoreEncoder username highscore
        , expect = Http.expectString GotHighscoreResponse  
        }

highscoreDecoder : JDecode.Decoder UserInfo  
highscoreDecoder = 
    JDecode.map2 UserInfo
        (JDecode.field "username" JDecode.string)
        (JDecode.field "highscore" JDecode.int)

getUserInfo : Model -> Cmd Msg 
getUserInfo model =  
    Http.post 
        { url = rootUrl ++ "viewhighscore/"
        , body = Http.jsonBody <| userPassEncoder model
        , expect = Http.expectJson GetUserInfo highscoreDecoder
        }

--Get overall highscore from server
overallHighscoreDecoder : JDecode.Decoder OverallHighscore    
overallHighscoreDecoder = 
    JDecode.map2 OverallHighscore
        (JDecode.field "username" JDecode.string)
        (JDecode.field "highscore" JDecode.int)

getOverallHighscore : Cmd Msg 
getOverallHighscore =  
    Http.get 
        { url = rootUrl ++ "viewoverallhighscore/"
        , expect = Http.expectJson GetOverallHighscore highscoreDecoder
        }

--Settings 
settingsEncoder : String -> ColorTheme -> ColorTheme -> JEncode.Value
settingsEncoder username playerTheme deviceTheme = 
    JEncode.object
        [ ("username", JEncode.string username)
        , ("playerTheme", JEncode.string (colorThemeToString playerTheme))
        , ("deviceTheme", JEncode.string (colorThemeToString deviceTheme))
        ]

settingsPost : String -> ColorTheme -> ColorTheme -> Cmd Msg
settingsPost username playerTheme deviceTheme =
    Http.post
        { url = rootUrl ++ "updatesettings/"
        , body = Http.jsonBody <| settingsEncoder username playerTheme deviceTheme
        , expect = Http.expectString GotSettingPostResponse
        }
-- settingsDecoder : JDecode.Decoder Settings 
-- settingsDecoder =
--     JDecode.map3 Settings  
--         (JDecode.field "username" JDecode.string)
--         (JDecode.field "playerTheme" JDecode.string)
--         (JDecode.field "deviceTheme" JDecode.string)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
                , points = 0
                , jumpingPlayer = None
                , credentials = {username = "", password = ""}
                , userinfo= {username = "", highscore = 0}
                , overallHighscore = {username = "", highscore = 0}
                , settings = {username = "", playerTheme = Theme1, deviceTheme = Theme1 }
                
                }   
    in ( model , randDecideSize) -- add init model

--<<Update>>
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
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
                
                restartModel = {model | player1_pos = (-114,-10)
                                    , player2_pos = (114,-10) 
                                    , count = 0
                                    , jumpX = 1.5
                                    , bigPlayer = None
                                    , points = 0
                                    , jumpingPlayer = None
                                    , screen = Game InProgress
                                    }

                resetModel = {model | player1_pos = (-114,-10)
                                    , count = 0
                                    , jumpingPlayer = None 
                                    , jumpX = 0
                                    , player2_pos = (114,-10)
                                    , points = model.points + 1}

            in --CASE 1) if game over and player presses spacebar to restart
                if model.screen == Login || model.screen == SignUp then (model,Cmd.none)
                else if model.screen == Game Start  && restart == False then (model,Cmd.none)
                else if restart && (model.screen == Game End || model.screen == Game Start) then (restartModel, randDecideSize)
                --CASE 2)if there's a collision, end game 
                else if isCollision model then 
                    let
                        newHighscore = if model.points > model.userinfo.highscore then model.points else model.userinfo.highscore 
                        message = if model.points > model.userinfo.highscore then highscorePost model.userinfo.username model.points else Cmd.none
                        oldUserInfo = model.userinfo
                        newUserInfo= { oldUserInfo | highscore = newHighscore}
                    in
                        ({model | player1_pos = model.player1_pos, player2_pos = model.player2_pos, screen = Game End, userinfo = newUserInfo}, message) --sendHighscore model 
                
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
                else (resetModel, randDecideSize)
        
        MakeRequest req    -> (model, Cmd.none)
        UrlChange url      -> (model, Cmd.none)

        DecideBigPlayer player -> ({model | bigPlayer = player}, getOverallHighscore) --where to put getoverall highscore lol NOTE!!

        ChangeColorThemeRight -> 
            let
                oldSettings = model.settings
                newTheme = changeThemeRight oldSettings.playerTheme
                newSettings = {oldSettings | playerTheme = newTheme}
                message = settingsPost model.settings.username newTheme model.settings.deviceTheme
            in
                ({model | settings = newSettings},message)
        
        ChangeColorThemeLeft ->             
            let
                oldSettings = model.settings
                newTheme = changeThemeLeft oldSettings.playerTheme
                newSettings = {oldSettings | playerTheme = newTheme}
                message = settingsPost model.settings.username newTheme model.settings.deviceTheme
            in
                ({model | settings = newSettings}, message)
        
        ChangeDeviceColorUp -> 
            let
                oldSettings = model.settings
                newTheme = changeThemeRight oldSettings.deviceTheme
                newSettings = {oldSettings | deviceTheme = newTheme }
                message = settingsPost model.settings.username model.settings.playerTheme newTheme
            in
                ({model | settings = newSettings}, message)

        ChangeDeviceColorDown ->             
            let
                oldSettings = model.settings
                newTheme = changeThemeLeft oldSettings.deviceTheme
                newSettings = {oldSettings | deviceTheme = newTheme }
                message = settingsPost model.settings.username model.settings.playerTheme newTheme
            in
                ({model | settings = newSettings}, message)

        --Login
        LoginPost -> (model, loginPost model) --log in button
        
        GotoSignUpScreen -> 
            let
                oldCredentials= model.credentials
                newCredentials = { oldCredentials | username = "", password = ""}
            in
                ({model | credentials = newCredentials, screen = SignUp}, Cmd.none)

        SignUpPost -> (model,signupPost model)

        LogOutScreen -> 
            let
                oldCredentials= model.credentials
                newCredentials= { oldCredentials | username = "", password = ""}
                oldUserInfo = model.userinfo 
                newUserInfo = { oldUserInfo | username = "", highscore = 0}
                oldSettings = model.settings   
                newSettings = {oldSettings | username = "", playerTheme = Theme1, deviceTheme = Theme1}
            in
                ({model | credentials = newCredentials, userinfo = newUserInfo, screen = Login, settings = newSettings}, Cmd.none) --TODO: update logout post!!
        
        GoBack ->             --THIS IS EXACLY SAME AS LOGOUTSCREEN 
            let
                oldCredentials= model.credentials
                newCredentials= { oldCredentials | username = "", password = ""}
            in
                ({model | credentials = newCredentials, screen = Login}, Cmd.none) 
        --Update username and password on user input
        Username newUsername -> 
            let
                oldCredentials = model.credentials
                newCredentials = { oldCredentials | username = newUsername}
                oldUserInfo = model.userinfo 
                newUserInfo = {oldUserInfo | username = newUsername}
                oldSettings = model.settings   
                newSettings = {oldSettings | username = newUsername}
            in
                ({model | credentials = newCredentials, userinfo = newUserInfo, settings = newSettings}, Cmd.none)

        Password newPassword ->
            let
                oldCredentials = model.credentials
                newCredentials = { oldCredentials | password = newPassword}
            in
                ({model | credentials = newCredentials}, Cmd.none)

        --SERVER 
        --Highscore
        GotHighscoreResponse result ->
            case result of
                Ok _ -> 
                    (model, getOverallHighscore) --cmd.none?
                Err error ->
                    ( handleError model error, Cmd.none )

        GetUserInfo result -> 
            case result of
                Ok newModel ->
                        let
                            newUserInfo = newModel
                        in
                            ( { model | userinfo = newModel}, Cmd.none )

                Err error ->
                    ( handleError model error, Cmd.none )

        GetOverallHighscore result-> 
            case result of 
                Ok newModel -> 
                    let 
                        newOverallHighscore = newModel
                    in 
                        ( { model | overallHighscore = newOverallHighscore}, Cmd.none)
                Err error ->    
                    ( handleError model error, Cmd.none)



        --User Authentication 
        GotLoginResponse result ->
            case result of
                Ok "LoginFailed" ->
                   ( { model | error = "Login Failed"}, Cmd.none)
                Ok "SignupSuccess" -> 
                    ( {model | screen = Game Start, player1_pos = (-30,-10), player2_pos = (30,-10) }, Cmd.none)
                Ok "LoggedIn" ->
                    ( { model | screen = Game Start, player1_pos = (-30,-10), player2_pos = (30,-10) }, getUserInfo model )
                Ok _ -> 
                    (model, Cmd.none)
                Err error ->
                    ( handleError model error, Cmd.none )


        GotSettingPostResponse result -> 
            case result of 
                Ok _ -> (model, Cmd.none)
                Err error ->
                    (handleError model error, Cmd.none)


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
                    ,usertest
                    , togame
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
                    ]
                Game _ ->
                    [ gamebody, background, caption, points, startText, gameOver, overallHighscore, floor, player1, player2, logoutButton, themeButtons ] 
        togame = square 5
            |> filled green 
            |> notifyTap ToGame 
        usertest = textOutline (model.credentials.username ++ "/" ++ model.credentials.password) 4
            |> move (0,-40)
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

        points = GraphicSVG.text ("Points: " ++ (String.fromInt model.points)) 
            |> sansserif
            |> bold 
            |> size 4
            |> (if model.screen == Game Start then filled blank else filled black)
            |> move (-7,47)

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

        overallHighscore = group [highscoreShape, highScore, user, highscorePoints]
            |> move (3,-3)

        highscoreShape = roundedRect 47 20 2
            |> filled lightGrey
            |> addOutline (solid 0.7) black 
            |> move (-24,-44)

        highScore = textOutline ("Overall Highscore: " ++ String.fromInt model.overallHighscore.highscore) 4
            |> move (-45,-40)
       
        user = textOutline ("By User: " ++ model.overallHighscore.username) 3
            |> move (-45,-45)

        highscorePoints = textOutline ("Your highscore is: " ++ String.fromInt model.userinfo.highscore ) 3
            |> move (-45,-50)

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
                        |> filled (first (colorThemeToPlayerColor model.settings.playerTheme))
                        |> addOutline (solid 1) black
                        |> move (0.0,5.5)
                else
                        square 8
                        |> filled (first (colorThemeToPlayerColor model.settings.playerTheme))
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
                    |> filled (second (colorThemeToPlayerColor model.settings.playerTheme))
                    |> addOutline (solid 1) black 
                    |> move (0.0,5.5)
                else 
                    square 8
                    |> filled (second (colorThemeToPlayerColor model.settings.playerTheme))
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
            |> (filled (first (colorThemeToDeviceColor model.settings.deviceTheme)))
            |> addOutline (solid 1) black 

        themeButtons = group[themeLeft, leftTriangle, themeRight, rightTriangle, themeUp, upTriangle, themeDown, downTriangle]

        rightTriangle = triangle 2
            |> filled black 
            |> move (36, -48)
            |> notifyTap ChangeColorThemeRight
                
        leftTriangle = triangle 2
            |> filled black 
            |> mirrorX
            |> move (21,-48)
            |> notifyTap ChangeColorThemeLeft

        upTriangle = triangle 2
            |> filled black 
            |> rotate (3.14/2)
            |> move (28.5,-40)
            |> notifyTap ChangeDeviceColorUp

        downTriangle = triangle 2
            |> filled black 
            |> rotate (3.14/2)
            |> mirrorY
            |> move (28.5,-56)
            |> notifyTap ChangeDeviceColorDown

        themeRight = circle 4
            |> (filled (second (colorThemeToDeviceColor model.settings.deviceTheme)))
            |> addOutline(solid 0.7) black 
            |> move (36,-48)
            |> notifyTap ChangeColorThemeRight

        themeLeft = circle 4
            |> (filled (second (colorThemeToDeviceColor model.settings.deviceTheme)))
            |> addOutline(solid 0.7) black 
            |> move (21,-48)
            |> notifyTap ChangeColorThemeLeft

        themeUp = circle 4
            |> (filled (second (colorThemeToDeviceColor model.settings.deviceTheme)))
            |> addOutline(solid 0.7) black 
            |> move (28.5,-40)
            |> notifyTap ChangeDeviceColorUp

        themeDown = circle 4
            |> (filled (second (colorThemeToDeviceColor model.settings.deviceTheme)))
            |> addOutline(solid 0.7) black 
            |> move (28.5,-56)
            |> notifyTap ChangeDeviceColorDown


        --logout
        logoutButton = group [logoutShape,logoutText]
            |> move (41,-96)
            |> scale 0.7
            |> notifyTap LogOutScreen

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



