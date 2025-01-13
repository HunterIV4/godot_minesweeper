# Minesweeper

 ![Minesweeper in Godot Engine](/.media/example_screenshot.png)

A refactored minesweeper game made using Godot 4.3. Originally created by Awfyboy here: [Minesweeper in Godot](https://github.com/Awfyboy/Minesweeper)

This has the same core features as the original but is refactored to be more modular and use signals rather than a strongly coupled design. This isn't necessarily the "best" or "only" way of doing things, but it's useful to be able to compare two very different ways of handling the same game.

## Summary of Key Changes:

* Moved most tile handing and interface functionality out of the main game script.
* Strongly decoupled all scenes; the Game, Board, Tile, and PlayArea (UI) can be run using F6 without errors, minus most functionality of the combined game.
* Refactored communication using signals.
* Removed secondary data structure for handling game board.
* Added a function to both start games and end the current game.
* Added functionality for determining game end conditions.
* Used custom resources for setting tile states and difficulty settings.

## Purpose

The goal of this refactor is to demonstrate how the same project can be organized in a different, more modular way but still maintain the same core functionality. The code attempts to balance extensibility with complexity. 

Since the game of Minesweeper has very specific design that is unlikely to be expanded, overcomplicating data structures and communication will likely just make the game harder to follow and maintain. The new structure attempts to stay simple while also increasing modularity and encapsulation.

Hopefully, I kept it simple enough that someone who is fairly new to the engine can reason about how things work while also keeping the structure closer to how a large scale game might be designed.

This code is not perfect. While I tried to remove all bugs and explain the code reasonably well, I wrote it in less than a week during my free time. I considered fixing every potential issue (and I will fix issues if they are reported!), I decided that finishing was also important. In the real world, you will deal with imperfect code, and may discover later that there was a more efficient way of doing things that you missed. While refactoring is an option, you have to consider the time and effort compared to the benefit of the refactor. While I refactored for fun, the original code *worked*, and that is ultimately important.

Also, decoupled code adds a bit of extra work. If we compare the two projects, the original is 289 LOC in 3 scripts while the updated version is 370 LOC in 7 scripts (as of my last check). It's not a huge difference (81 lines), but signals and utility functions require more code than direct references.

On the other hand, none of the refactor's individual scripts are as complex as the original `game.gd`. Using editor lines, the original was 464. The refactor's longest script, `board.gd`, is 238 lines, around half the length. The new `game.gd` is 42 editor lines.

I really enjoyed this project. The act of refactoring and reading through the original code let me think a lot about various tradeoffs in complexity vs. functionality. Hopefully others find it as useful as I did. Thanks again to Awfyboy for the original code and assets; it was a great starting point that made the refactor a lot easier than starting from scratch. I hope others can learn as much from seeing both as I did (or, in my case, actually working through it, as I had to make changes in structure several times).