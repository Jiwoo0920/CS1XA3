# Overview
**Name:** Jiwoo Lee  
**MacID:** leej229

**Last Update:** March 30, 2019  
**Status:** Finished Part 3 and 4 (Final Submission)

# Description
For more information about this project, please refer to [this link](https://mac1xa3.ca/Projects/Project02.pdf).

## Personal CV / Resume Webpage
A Personal CV/Resume Webpage for Co-op. Used an open-source template provided by [webthemez](https://webthemez.com/).  
Website can be reached [here](https://mac1xa3.ca/u/leej229/)  

## Web App: 2 Player Tic Tac Toe
A simple web app built in Elm; recreated 2 player Tic Tac Toe game with numerous custom features and customization options.   
Web app can be accessed [here](https://mac1xa3.ca/u/leej229/simpleapp.html)

# Basic Functionality of 2 Player Tic Tac Toe
## Features
**1) Start Over**: 
* Clears the board
* Players can start over the game whenever they wish to
* If **Randomize Starting Player** feature us not turned on, the **Start Over** button will always set the current player to O (otherwise, the starting player is randomized)
* Doesn't change the theme or mode of the game

**2) Modes**: 
* There are two modes of the game in this web app: Peaceful and Competitive. 
    * **Peaceful**: 
        * No time limit
        * Can withdraw moves in the middle of the game 
    * **Competitive**:
        * Each player is given 2 seconds to make a move
        * If a player doesn't make a move within this time limit, he/she loses
        * A timer will appear in the right-corner of the page that displays the time left for a player to make his/her move
        * Players cannot withdraw moves in the middle of the game 
* You can switch between modes either in the beginning of the game or at the end of the game (you can't switch modes if the player already made a move). However, if you withdraw all the moves you made so that the board is cleared, you can then switch the game mode.   
* If conditions are met so that players can change modes, the **Mode** button located below the board will be filled with red (otherwise grey) to nofity the user
* The modes will switch as soon as you click the **Mode** button (in Competitive mode, the timer starts immediately)
* Upon changing mode, the board is cleared (without changing any of the other settings)


**3) Withdraw Move**: 
* You can only withdraw moves in Peaceful mode
* Upon clicking the **Withdraw Move** button located below the board, player is able to withdraw his/her previous move
* If you want to withdraw multiple moves, simply click on the **Withdraw Move** button multiple times
* If conditions are met so that the players can withdraw their moves, the **Withdraw Move** button located below the board will be filled with yellow (otherwise grey) to notify the user

**4) Randomize Starting Player**
* Randomizes the initial starting player
* Doesn't immediately change the player; need to press **Start Over** button to take effect
* Once the player activates this feature, it will be turned on untill the player turns off (doesn't turn off automatically once pressing **Start Over** button)
* If conditions are met so that the players can turn on this feature, the **Randomize Starting Player** button located below the board will be filled with green (otherwise grey) to notify the user
* The status of this feature (whether it is turned on/off) will be dispayed as either "ON" or "OFF" in the **Randomize Starting Player** button itself
* While this feature is turned on, you cannot use **Switch Starting Player** feature

**5) Switch Starting Player**
* Automatically switches the starting Player
* Only holds effect in Peaceful mode
* You can only switch starting player when the board is cleared (cannot switch in between games)
* If conditions are met so that you can use this feature, the **Switch Starting Player** located below the baord will be filled with green (otherwise grey) to notify the user
* Current player is displayed in the upper-left corner of the page with corresponding player colours
* Cannot use this feature if **Randomize Starting Player** feature is turned on 

**6) Change Theme**
* There are a total of 15 themes in this game
* Themes can be changed at any point of the game, in any mode
* To switch between themes, navigate through the options by clicking the left/right triangle-shaped buttons located on the edges of the **Change Theme** button
* Themes are changed automatically, and does not reset to default upon pressing **Start Over** or **Change Mode** buttons


## Default Settings
By default, the game is initialized with the following settings:
* **Mode**: Peaceful
* **Randomize Starting Player**: Off
* **Theme**: 1
* **Current Player**: O

