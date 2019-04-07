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
import String 

--<<Type Declaration>>
type Msg = Tick Float GetKeyState
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | DecideBigPlayer Player
         | ChangeColorThemeRight
         | ChangeColorThemeLeft

type Player = Player1 | Player2 | None

type State = Jump | NotJump

type GameStatus = Start | InProgress | End

type ColorTheme = Theme1 | Theme2 | Theme3 | Theme4 | Theme5 | Theme6 | Theme7 | Theme8 

type alias Model = { gameStatus : GameStatus
                   , player1_pos : (Float,Float)
                   , player2_pos : (Float, Float)
                   , count : Int
                   , jumpX : Float
                   , bigPlayer : Player
                   , points : Int 
                   , jumpingPlayer : Player
                   , theme : ColorTheme
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
    if all (\x->x==Player1) [a,b] || all (\x->x==Player2) [a,b] then True 
    else False 

--Final collision function
isCollision : Player -> Player -> (Float,Float) -> (Float,Float) -> Bool 
isCollision bigPlayer jumpingPlayer  player1_pos player2_pos = 
    if playerMatch bigPlayer jumpingPlayer then
        isCollisionBigOnSmall player1_pos player2_pos 
    else if playerMatch bigPlayer jumpingPlayer == False then 
        isCollisionSmallOnBig player1_pos player2_pos 
    else isCollisionNoJump player1_pos player2_pos 

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
                Theme5 -> Theme6
                Theme6 -> Theme7
                Theme7 -> Theme8
                Theme8 -> Theme1

changeThemeLeft : ColorTheme -> ColorTheme 
changeThemeLeft colorTheme = 
        case colorTheme of 
                Theme8 -> Theme7 
                Theme7 -> Theme6 
                Theme6 -> Theme5
                Theme5 -> Theme4 
                Theme4 -> Theme3
                Theme3 -> Theme2
                Theme2 -> Theme1
                Theme1 -> Theme8

colorThemeToColor : ColorTheme -> (Color, Color)
colorThemeToColor colorTheme = 
        case colorTheme of 
                Theme1 -> (red, blue)
                Theme2 -> (rgb 72 35 212, rgb 169 252 136)
                Theme3 -> (rgb 230 25 75, rgb 223 220 234)
                Theme4 -> (rgb 36 54 101, rgb 139 216 189)
                Theme5 -> (rgb 227 52 82, rgb 215 243 110)
                Theme6 -> (rgb 44 50 79, rgb 245 215 96)
                Theme7 -> (rgb 41 96 45, rgb 255 225 89)
                Theme8 -> (rgb 227 52 82, rgb 74 216 133)


colorThemeToString : ColorTheme -> String
colorThemeToString colorTheme = 
        case colorTheme of 
                Theme1 -> "1"
                Theme2 -> "2"
                Theme3 -> "3"
                Theme4 -> "4"
                Theme5 -> "5"
                Theme6 -> "6"
                Theme7 -> "7"
                Theme8 -> "8"

--textOutline (to avoid repetition)
textOutline : String -> Float -> Shape userMsg
textOutline string n = text (string) |> bold |> sansserif |> size n |> filled black 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--<<Init>>
init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key = 
    let model = { gameStatus = Start
                , player1_pos = (-30,-10)----function model = let (a,b)=model.player1pos in update b
                , player2_pos = (30,-10) 
                , count = 0
                , jumpX = 1.5
                , bigPlayer = Player2
                , points = 0
                , jumpingPlayer = None
                , theme = Theme1
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
                                    , gameStatus = InProgress
                                    }

                resetModel = {model | player1_pos = (-114,-10)
                                    , count = 0
                                    , jumpingPlayer = None 
                                    , jumpX = 0
                                    , player2_pos = (114,-10)
                                    , points = model.points + 1}

            in --CASE 1) if game over and player presses spacebar to restart
                if model.gameStatus == Start  && restart == False then (model,Cmd.none)
                else if restart && (model.gameStatus == End || model.gameStatus == Start) then (restartModel, randDecideSize)
                --CASE 2)if there's a collision, end game 
                else if isCollision model.bigPlayer model.jumpingPlayer model.player1_pos model.player2_pos then 
                    ({model | player1_pos = model.player1_pos, player2_pos = model.player2_pos, gameStatus = End },Cmd.none)
                
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
                                , gameStatus = InProgress }
                        , Cmd.none)

                --CASE 4) if time == 2 seconds, reset to original position
                else (resetModel, randDecideSize)
        
        MakeRequest req    -> (model, Cmd.none)
        UrlChange url      -> (model, Cmd.none)

        DecideBigPlayer player -> ({model | bigPlayer = player}, Cmd.none) 

        ChangeColorThemeRight -> ({model | theme = changeThemeRight model.theme}, Cmd.none)

        ChangeColorThemeLeft -> ({model | theme = changeThemeLeft model.theme}, Cmd.none)

--<<View>>
view : Model -> { title : String, body : Collage Msg }
view model = 
    let title = "Clash!"
        body = collage 101 150 shapes
        shapes = [ background, caption, points, startText, gameOver, highScoreBoard, theme, floor, player1, player2 ] 

        caption = textOutline "Clash!" 10
            |> move (-13,54)

        points = text ("Points: " ++ (String.fromInt model.points)) 
            |> sansserif
            |> bold 
            |> size 4
            |> (if model.gameStatus == Start then filled blank else filled black)
            |> move (-7,47)

        startText = group [gameStart, instructions1, instructions2, instructions3, instructions4]
            |> move (0,4)

        instructions1 = text ("Instructions")
            |> sansserif
            |> bold 
            |> underline
            |> size 5
            |> (if model.gameStatus == Start then filled black else filled blank)
            |> move (-13,40)

        instructions2 = text "-Press Q to jump Player 1"
            |> sansserif
            |> bold 
            |> size 3
            |> (if model.gameStatus == Start then filled black else filled blank)
            |> move (-17,35)
        
        instructions3 = text ("-Press W to jump Player 2")
            |> sansserif
            |> bold 
            |> size 3
            |> (if model.gameStatus == Start then filled black else filled blank)
            |> move (-17,30)     

        instructions4 = text ("-Big guy jumps over the small guy")
            |> sansserif
            |> bold 
            |> size 3
            |> (if model.gameStatus == Start then filled black else filled blank)
            |> move (-22,25)    

        gameStart = text ("Press Spacebar to Start!")
            |> sansserif
            |> bold 
            |> size 5
            |> (if model.gameStatus == Start then filled red else filled blank)
            |> move (-29,15)

        gameOver = text("Game Over! Press Spacebar to Restart!")
            |> sansserif 
            |> bold
            |> size 5
            |> (if model.gameStatus == End then filled red else filled blank)
            |> move (-46,35)

        highScoreBoard = group [highScore, user, highscorePoints]

        highScore = text ("High Score: ")
            |> sansserif 
            |> bold
            |> underline
            |> size 4
            |> filled black 
            |> move (-50,-40)
       
        user = textOutline ("User: ") 3
            |> move (-50,-45)

        highscorePoints = textOutline ("Points: ") 3
            |> move (-50,-50)

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
                        |> filled (first (colorThemeToColor model.theme))
                        |> addOutline (solid 1) black
                        |> move (0.0,5.5)
                else
                        square 8
                        |> filled (first (colorThemeToColor model.theme))
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
                    |> filled (second (colorThemeToColor model.theme))
                    |> addOutline (solid 1) black 
                    |> move (0.0,5.5)
                else 
                    square 8
                    |> filled (second (colorThemeToColor model.theme))
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
        theme = group [themeShape, themeText, rightTriangle, leftTriangle]
                |> move (25,-41)

        themeShape = roundedRect 43 7 2
                |> filled lightYellow
                |> addOutline(solid 0.7) black 
        
        themeText = textOutline ("Change Theme: " ++ (colorThemeToString model.theme)) 3
                |> move (-13,-1)

        rightTriangle = triangle 2
                |> filled black 
                |> move (18, 0)
                |> notifyTap ChangeColorThemeRight
        
        leftTriangle = triangle 2
                |> filled black 
                |> mirrorX
                |> move (-18,0)
                |> notifyTap ChangeColorThemeLeft

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