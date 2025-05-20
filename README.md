# Stacked
###### A roguelike puzzle game by Sudospective

## What is Stacked?
Stacked is a roguelike puzzle game where you align tetrominoes in a matrix to gain enough score within 40 cleared lines. After each level is a shop where you can spend excess lines to improve your score. Each level doubles the required score, so plan your run accordingly!

## How to build
Stacked (more specifically, the Scarlet engine that runs Stacked) requires these libraries:
- CMake (3.25)
- Lua (5.4)
- SDL2
- SDL2_mixer
- SDL2_ttf
- sol2

Building the game is done as follows:
1. Install the required libraries and set your environment path accordingly.
2. Configure your CMake toolchain
3. Build the game and copy the executable to the "lua" folder

You should now be able to play the game from the "lua" folder directly! You may need to allow the game through your firewall, licenses are expensive, sorry.

This has been tested to compile on Windows and Linux. Mac compilation may be successful, but is not supported. (Anyone who would like to help, please let me know!)
