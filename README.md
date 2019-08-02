# chess.rb
A two player chess played via the command line. The game is played using the hotseat multiplayer method by which both players use the same device and take turns playing the game. All standard chess rules are implemented ~~with the exception of en-passant and castling (todo)~~.

The game will auto-detect checkmate, stalemate, and victory. The game allows one save file if you would like to save the game and continue the game later.

## Prerequisites
The game require ruby 2.6.3 to run.

## Running the game
Clone this repo, navigate to the chess folder and type
```
ruby chess.rb
```

## How to play
- **Starting the game**: Upon starting game you are given the option to start a new game or load a previous save.
- **Moving pieces**: Type your desired move in chess notation when prompted (ex. c1). Actions are done in two steps, type only a single chess coordinate when prompted. If a move is invalid the player will be prompted again and the piece will no be moved.
- **Castling**: To castle simply move the king two spaces towards a friendly rook
- **En Passant**: On a turn immediatly following a double move by an enemy pawn, you may capture the enemey pawn as if it only moved one cell.

## Improvments to Consider
- **Menus**: Give users options to customize the game (manage save files, choosing player names etc.)
- **Instructions**: Provide better onscreen instuctions.
- **Player Feedback**: Provide feedback to the players when an event occurs (ex. king is in check, illegal move). Currently the only feedback provided is the board state.
- **Colorization**: Default colors can be confusing depending on the terminal window color scheme.
- **Multiple save files**: Allow users to manage save files from within the game menus.

## Thoughts on the Project
Overall this was a very interesting coding project as well as my first "large" project without any direction via tutorials or other sources as a guide. I spent a fair amount of time learning how a game of chess is played (I've never actually played a game of chess before this).

The feature I had the most difficulty implementing was the checkmate detection. TDD and automated testing in general were **VERY** helpful when implementing this function as sometimes my "fixes" would cause false positives occur, I would not have caught these issues without the tests and the project would have been much more time consuming to complete.

Over the course of this project, I've noticed a few things I need to improve on.
1. Descriptive functions and variable names - I often found myself wondering what data type certain variables contain due to some ambiguous naming.
2. Testing was extremely helpful to completing this project, however I feel I would have benefited from spending a little more time learning how to write more efficient tests (mocks/doubles).

All in all this project was a great learning experience, it definitly took a fair amount of disipline and commitment to complete.

---
Chess.rb project is part of [The Odin Project](https://www.theodinproject.com/courses/ruby-programming/lessons/ruby-final-project).
