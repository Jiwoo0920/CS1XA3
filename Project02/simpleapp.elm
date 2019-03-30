--<<Imports>>--
module Simpleapp exposing(..)
import Browser
import Browser.Navigation exposing (Key(..))
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Url
import Random
import Tuple exposing (..)
import List exposing (..)
import String

--<<Type Delcaration>>--
type Msg = Tick Float GetKeyState
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | BlockTap BlockNum
         | StartOver 
         | SwitchStartingPlayer
         | RandomizeStartingPlayer
         | RandomTic TicState
         | ChangeColorThemeRight
         | ChangeColorThemeLeft
         | WithdrawMove
         | CompetitiveMode

type TicState = X | O | Blank 

type Status = On | Off

type GameStatus = Start | InProgress | Win | Draw  

type Mode = Peaceful | Competitive

type ColorTheme = Theme1 | Theme2 | Theme3 | Theme4 | Theme5 | Theme6 | Theme7 | Theme8 | Theme9 | Theme10 | Theme11 | Theme12 | Theme13 | Theme14 | Theme15

type BlockNum = Block1 | Block2 | Block3 | Block4 | Block5 | Block6 | Block7 | Block8 | Block9

type alias Row = (TicState,TicState,TicState)

type alias Table = (Row,Row,Row)

type alias Model = { board : Table
                   , currentPlayer : TicState
                   , gameStatus : GameStatus
                   , randomizePlayerStatus : Status
                   , theme : ColorTheme
                   , previousMove : List (BlockNum)
                   , time : Int
                   , count : Int
                   , mode : Mode
                   , timeOver : Bool
                   }

--<<Helper functions>>--------------------------------------------------------------------------------------------------------------------------------------------------
--BOARD
ticToString : TicState -> String
ticToString tic = case tic of
        X -> "X"
        O -> "O"
        Blank -> ""

andTic : Row -> TicState -> Bool
andTic (x0,x1,x2) ticState = x0 == ticState && x1 == ticState && x2 == ticState

checkWin : Table -> TicState -> Bool
checkWin (row1,row2,row3) tickState = 
    let
        (x1,x2,x3) = row1
        (y1,y2,y3) = row2
        (z1,z2,z3) = row3
        a = andTic (x1,x2,x3) tickState
        b = andTic (y1,y2,y3) tickState
        c = andTic (z1,z2,z3) tickState
        d = andTic (x1,y1,z1) tickState
        e = andTic (x2,y2,z2) tickState
        f = andTic (x3,y3,z3) tickState
        g = andTic (x1,y2,z3) tickState
        h = andTic (x3,y2,z1) tickState
    in a || b || c || d || e || f || g || h

hasWinner : Table -> Bool 
hasWinner table = checkWin table O || checkWin table X

isOccupied : Table -> BlockNum -> Bool  
isOccupied table blockNum = getTicAt table blockNum /= Blank

isFullRow : (TicState, TicState, TicState) -> Bool 
isFullRow (x1,x2,x3) = (x1 /= Blank) && (x2 /= Blank) && (x3 /= Blank)

isFullTable : Table -> Bool 
isFullTable (row1,row2,row3) = (isFullRow row1) && (isFullRow row2) && (isFullRow row3)

isEmptyRow : (TicState, TicState, TicState) -> Bool 
isEmptyRow (x1,x2,x3) = (x1 == Blank) && (x2 == Blank) && (x3 == Blank) 

isEmptyTable : Table -> Bool 
isEmptyTable (row1,row2,row3) = (isEmptyRow row1) && (isEmptyRow row2) && (isEmptyRow row3)

changeTurn : TicState -> TicState
changeTurn ticState = 
    case ticState of 
        O -> X
        X -> O
        Blank -> Blank

getTicAt : Table -> BlockNum -> TicState
getTicAt (row1,row2,row3) blockNum =
    let
        (x1,x2,x3) = row1
        (y1,y2,y3) = row2
        (z1,z2,z3) = row3
    in
        case blockNum of 
            Block1 -> x1
            Block2 -> x2
            Block3 -> x3
            Block4 -> y1
            Block5 -> y2
            Block6 -> y3
            Block7 -> z1
            Block8 -> z2
            Block9 -> z3

insertToBoard : Table -> BlockNum -> TicState -> Table
insertToBoard (row1,row2,row3) blockNum ticState =   
    let
        (x1,x2,x3) = row1
        (y1,y2,y3) = row2
        (z1,z2,z3) = row3
    in 
        case blockNum of 
            Block1 -> ((ticState,x2,x3), row2, row3) 
            Block2 -> ((x1,ticState,x3), row2, row3)
            Block3 -> ((x1,x2,ticState), row2, row3)
            Block4 -> (row1, (ticState,y2,y3), row3)
            Block5 -> (row1, (y1,ticState,y3), row3)
            Block6 -> (row1, (y1,y2,ticState), row3)
            Block7 -> (row1, row2, (ticState,z2,z3))
            Block8 -> (row1, row2, (z1,ticState,z3))
            Block9 -> (row1, row2, (z1,z2,ticState))

--Status
switchStatus : Status -> Status
switchStatus status = 
        case status of 
                On -> Off 
                Off -> On 

determineGameStatus :Table -> GameStatus 
determineGameStatus table =
        if isEmptyTable table == True then Start 
        else if hasWinner table == True then Win 
        else if isFullTable table == True then Draw 
        else InProgress
        
--Randomize Player 
randomizePlayer : Random.Generator TicState
randomizePlayer = Random.map (\b -> if b == 0 then O else X)  <| Random.int 0 1

generateRandTic : Cmd Msg
generateRandTic = Random.generate RandomTic randomizePlayer

--GRAPHICS
decideColor : TicState -> ColorTheme -> Color 
decideColor ticState colorTheme = case ticState of 
        O -> (first (colorThemeToColor colorTheme))
        X -> (second (colorThemeToColor colorTheme))
        Blank -> blank

createBlockShape : BlockNum -> Table -> ColorTheme -> Shape userMsg
createBlockShape blockNum table colorTheme = 
        let shape = roundedRect 25 25 5
            color = if isOccupied table blockNum == True then filled (decideColor (getTicAt table blockNum) colorTheme) else filled white
            outline = addOutline (solid 1) black 
        in  shape |> color |> outline
        
createBlockText : BlockNum -> Table -> Shape userMsg
createBlockText blockNum table = text (ticToString (getTicAt table blockNum)) |> centered |> sansserif |> bold |> size 20 |> filled white |> move(0,-7)
        
createBlock : BlockNum ->  Table -> ColorTheme -> Shape userMsg
createBlock blockNum table colorTheme = group [createBlockShape blockNum table colorTheme, createBlockText blockNum table]

textOutline : String -> Float -> Shape userMsg
textOutline string n = text (string) |> bold |> sansserif |> size n |> filled black 

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
                Theme8 -> Theme9
                Theme9 -> Theme10
                Theme10 -> Theme11
                Theme11 -> Theme12
                Theme12 -> Theme13
                Theme13 -> Theme14
                Theme14 -> Theme15
                Theme15 -> Theme1

changeThemeLeft : ColorTheme -> ColorTheme 
changeThemeLeft colorTheme = 
        case colorTheme of 
                Theme15 -> Theme14
                Theme14 -> Theme13
                Theme13 -> Theme12
                Theme12 -> Theme11
                Theme11 -> Theme10
                Theme10 -> Theme9
                Theme9 -> Theme8
                Theme8 -> Theme7 
                Theme7 -> Theme6 
                Theme6 -> Theme5
                Theme5 -> Theme4 
                Theme4 -> Theme3
                Theme3 -> Theme2
                Theme2 -> Theme1
                Theme1 -> Theme15

colorThemeToColor : ColorTheme -> (Color, Color)
colorThemeToColor colorTheme = 
        case colorTheme of 
                Theme1 -> (blue, lightRed)
                Theme2 -> (rgb 72 35 212, rgb 169 252 136)
                Theme3 -> (rgb 112 23 67, rgb 96 106 112)
                Theme4 -> (rgb 171 5 82, rgb 69 40 99)
                Theme5 -> (rgb 230 25 75, rgb 223 220 234)
                Theme6 -> (rgb 36 54 101, rgb 139 216 189)
                Theme7 -> (rgb 227 52 82, rgb 215 243 110)
                Theme8 -> (rgb 59 87 35, rgb 174 189 56)
                Theme9 -> (rgb 44 50 79, rgb 245 215 96)
                Theme10 -> (rgb 41 96 45, rgb 255 225 89)
                Theme11 -> (rgb 93 91 159, rgb 76 150 203)
                Theme12 -> (rgb 77 155 160, rgb 168 199 107)
                Theme13 -> (rgb 227 52 82, rgb 74 216 133)
                Theme14 -> (rgb 221 86 80, rgb 256 189 65)
                Theme15 -> (rgb 230 190 255, rgb 142 250 180)


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
                Theme9 -> "9"
                Theme10 -> "10"
                Theme11 -> "11"
                Theme12 -> "12"
                Theme13 -> "13"
                Theme14 -> "14"
                Theme15 -> "15"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--<<Init>>--
emptyBoard : Table 
emptyBoard = ((Blank,Blank,Blank),(Blank,Blank,Blank),(Blank,Blank,Blank))

init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key = 
        let model =  { board = emptyBoard
                      , currentPlayer = O 
                      , gameStatus = Start
                      , randomizePlayerStatus = Off
                      , theme = Theme1
                      , previousMove = []
                      , time = 2
                      , count = 50
                      , mode = Peaceful
                      , timeOver = False
                      }     
        in ( model , Cmd.none ) 

--<<Update>>--
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
        Tick time keystate -> 
                if (model.mode == Competitive) && (member model.gameStatus [Start,InProgress]) then 
                        case (model.count,model.time) of
                                (_,0) -> ({model | timeOver = True, gameStatus = Win}, Cmd.none)
                                (0,_) -> ({model | count = 50, time = model.time-1}, Cmd.none)
                                _ -> ({model | count = model.count - 1}, Cmd.none)
                else (model, Cmd.none)

        MakeRequest req    -> (model, Cmd.none)
        UrlChange url      -> (model, Cmd.none)

        BlockTap blockNum  -> 
                if (isOccupied model.board blockNum == False) && (model.timeOver == False) && (member model.gameStatus [Start,InProgress]) then
                        let updatedBoard = insertToBoard model.board blockNum model.currentPlayer
                            newPlayer = changeTurn model.currentPlayer
                            updateGameStatus = determineGameStatus updatedBoard
                            updatePreviousMove = blockNum :: model.previousMove
                        in ( {model | board = updatedBoard, currentPlayer = newPlayer, gameStatus = updateGameStatus, previousMove = updatePreviousMove, time = 2, count = 50}, Cmd.none)
                else (model, Cmd.none)
                
        StartOver ->
                let message = if model.randomizePlayerStatus == On then generateRandTic else Cmd.none 
                in ( {model | board = emptyBoard, currentPlayer = O , gameStatus = Start, previousMove = [], time = 2 , count = 50 , timeOver = False }, message)

        SwitchStartingPlayer -> 
                if model.gameStatus == Start && model.randomizePlayerStatus == Off && model.mode == Peaceful then
                        ( {model | currentPlayer = changeTurn model.currentPlayer}, Cmd.none )
                else (model, Cmd.none)

        RandomizeStartingPlayer -> ({model | randomizePlayerStatus = switchStatus model.randomizePlayerStatus}, Cmd.none)

        RandomTic ticstate -> 
                if model.gameStatus == Start then 
                        ( { model | currentPlayer = ticstate },Cmd.none)
                else (model, Cmd.none)

        ChangeColorThemeRight -> ({model | theme = changeThemeRight model.theme}, Cmd.none)

        ChangeColorThemeLeft -> ({model | theme = changeThemeLeft model.theme}, Cmd.none)

        WithdrawMove -> 
                if (model.gameStatus /= Start) && (model.mode == Peaceful) then 
                        let updatedBoard = insertToBoard model.board a Blank 
                            a = case List.head model.previousMove of 
                                Nothing -> Block1 --better way to fix this? it will never give nothing but still??
                                Just val -> val
                            updatePreviousMove = case List.tail model.previousMove of 
                                Nothing -> []
                                Just val -> val
                            updateGameStatus = determineGameStatus updatedBoard
                            updateCurrentPlayer = changeTurn model.currentPlayer
                        in ({model | board = updatedBoard, previousMove = updatePreviousMove, gameStatus = updateGameStatus, currentPlayer = updateCurrentPlayer}, Cmd.none)
                else (model,Cmd.none)

        CompetitiveMode -> 
                if (model.gameStatus /= InProgress) then
                        let message = if model.randomizePlayerStatus == On then generateRandTic else Cmd.none 
                            newMode = if model.mode == Competitive then Peaceful else Competitive
                        in ({model | board = emptyBoard, mode = newMode, gameStatus = Start, timeOver = False, time = 2, count = 50}, message)
                else (model,Cmd.none)

--<<View>>--
view : Model -> { title : String, body : Collage Msg } 
view model = 
    let title = "Tic Tac Toe"
        body = collage 155 155 shapes
        shapes = [ blocks, texts, button ]

        --BLOCKS
        blocks = group [createBlock Block1 model.board model.theme |> move(-30,27) |> notifyTap (BlockTap Block1)
                      , createBlock Block2 model.board model.theme |> move (-3,27) |> notifyTap (BlockTap Block2)
                      , createBlock Block3 model.board model.theme |> move (24,27) |> notifyTap (BlockTap Block3)
                      , createBlock Block4 model.board model.theme |> move (-30,0) |> notifyTap (BlockTap Block4)
                      , createBlock Block4 model.board model.theme |> move (-30,0) |> notifyTap (BlockTap Block4)
                      , createBlock Block5 model.board model.theme |> move (-3,0) |> notifyTap (BlockTap Block5)
                      , createBlock Block6 model.board model.theme |> move (24,0) |> notifyTap (BlockTap Block6)
                      , createBlock Block7 model.board model.theme |> move (-30,-27) |> notifyTap (BlockTap Block7)
                      , createBlock Block8 model.board model.theme |> move (-3,-27) |> notifyTap (BlockTap Block8)
                      , createBlock Block9 model.board model.theme |> move (24,-27) |> notifyTap (BlockTap Block9)] 

        --TEXTS
        texts = group [caption, turn, whoWon, draw, timeOver, timeText] 
                |> move (0,-3)

        caption = textOutline "2 Player Tic Tac Toe" 10
                |> move (-50, 58)

        turn =  text ("Player " ++ ticToString model.currentPlayer ++ "'s Turn")  
                |> sansserif
                |> bold
                |> size 4
                |> (if (member model.gameStatus [InProgress,Start]) && model.timeOver == False then filled (decideColor model.currentPlayer model.theme) else filled blank)
                |> move(-40,48)

        whoWon = text ("Player " ++ ticToString (changeTurn model.currentPlayer) ++ " Won!")
                |> sansserif
                |> bold
                |> size 4 
                |> (if (hasWinner model.board == True) then filled (decideColor (changeTurn model.currentPlayer) model.theme)  else filled blank)
                |> move(9,48)

        draw = text "It's a draw!"
                |> sansserif
                |> bold
                |> size 4
                |> (if (model.gameStatus == Draw) then filled black else filled blank)
                |> move(-40,48)

        timeOver = text ("Time Over! Player " ++ ticToString (changeTurn model.currentPlayer) ++ " Won!") 
                |> sansserif
                |> bold 
                |> size 4
                |> (if (model.mode == Competitive) && (model.timeOver == True) then filled (decideColor (changeTurn model.currentPlayer) model.theme) else filled blank)
                |> move (-13,48)
                
        
        timeText = text ("Time: " ++ (String.fromInt model.time))
                |> size 7
                |> sansserif 
                |> bold 
                |> underline
                |> (if model.mode == Competitive && (member model.gameStatus [Start,InProgress])then filled lightRed else filled blank)
                |> move (12, 48)

        --BUTTONS
        button = group [startOver, withdrawMove, theme, randomizeStartingPlayer, changeInitTurn, modeBlock]
                |> move (0,-3)
                |> scale 0.9

        --changeInitTurn
        changeInitTurn = group [changeInitTurnShape, changeInitTurnText]
                |> notifyTap SwitchStartingPlayer
                |> move (25,-60)

        changeInitTurnShape = roundedRect 41 7 2
                |> (if model.gameStatus == Start && model.randomizePlayerStatus == Off && model.mode == Peaceful then filled lightGreen else filled grey)
                |> addOutline (solid 0.7) black
        
        changeInitTurnText = textOutline "Switch Starting Player" 3.5
                |> move (-18.5,-1)
                
        --startOver
        startOver = group [startOverShape, startOverText]
                |> notifyTap StartOver
                |> move (-43,-50)

        startOverShape = roundedRect 24 7 2
                |> filled (rgb 255 64 82)
                |> addOutline (solid 0.7) black

        startOverText = textOutline "Start Over" 3.5
                |> move (-8.5,-1)

        --randomizeStartingPlayer
        randomizeStartingPlayer = group [randPlayerShape, randPlayerText]
                |> move (-26.5, -60)
                |> notifyTap RandomizeStartingPlayer

        randPlayerShape = roundedRect 58 7 2
                |> filled lightGreen
                |> addOutline (solid 0.7) black 

        randPlayerText = textOutline ("Randomize Starting Player: " ++ (if model.randomizePlayerStatus == On then "ON" else "OFF")) 3.5
                |> move (-27, -1)

        --theme
        theme = group [themeShape, themeText, rightTriangle, leftTriangle]
                |> move (-5,-70)

        themeShape = roundedRect 46 7 2
                |> filled lightYellow
                |> addOutline(solid 0.7) black 
        
        themeText = textOutline ("Change Theme: " ++ (colorThemeToString model.theme)) 3.5
                |> move (-15.5,-1)

        rightTriangle = triangle 2
                |> filled black 
                |> move (19, 0)
                |> notifyTap ChangeColorThemeRight
        
        leftTriangle = triangle 2
                |> filled black 
                |> mirrorX
                |> move (-19,0)
                |> notifyTap ChangeColorThemeLeft

        --withDraw Move
        withdrawMove = group [withdrawMoveShape, withdrawMoveText]
                |> move (29, -50)
                |> notifyTap WithdrawMove

        withdrawMoveShape = roundedRect 33 7 2
                |> (if (model.gameStatus /= Start) && (model.mode == Peaceful) then filled lightYellow else filled grey)
                |> addOutline (solid 0.7) black

        withdrawMoveText = textOutline "Withdraw Move" 3.5
                |> move (-12.5,-1)

        modeBlock = group [modeShape, modeText]
                |> move (-9,-50)
                |> notifyTap CompetitiveMode

        modeShape = roundedRect 39 7 2
                |> (if member model.gameStatus [Win,Draw,Start] || model.timeOver == True then filled (rgb 255 64 82) else filled grey)
                |> addOutline (solid 0.7) black 
        
        modeText = text ("Mode: " ++ (if model.mode == Competitive then "Competitive" else "Peaceful"))
                |> size 3.5
                |> sansserif
                |> bold
                |> centered
                |> filled black
                |> move (0, -1)

    in { title = title , body = body }

--<<Other>>--
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