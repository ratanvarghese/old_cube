# CUBE OF TIME PROJECT

I attempted to make a [roguelike](https://en.wikipedia.org/wiki/Roguelike) game many times, with many local repositories. This is one such attempt. It was discontinued before it could be completed, and I left the code alone for a long time. There are some obvious bugs and flaws which I did not fix before discontinuing development.

This code base will likely not be developed further, as my requirements for a dream roguelike have changed a lot.

There are some interesting parts of the code which I might re-use in a future roguelike attempt:

 + Operator overloading (accomplished through Lua metatables in this case) and custom iterators for Cartesian points. See [pt.lua](src/pt.lua).
 + Scheduling with coroutines. See [time.lua](src/time.lua).
 + Data structures to select values from keys *and* keys from values, while ensuring a one-to-one relationship between them. Accomplished with Lua metatables in [base.lua](src/base.lua).
 + Interfacing between a compiled language and a scripting language, to exploit the strengths of both. See [main.c](src/main.c) to see some Lua/C interop.

Additionally there are some well known algorithms used in the code:

 + Instead of relying on the system pseudorandom number generator, this project uses a [multiply-with-carry](https://en.wikipedia.org/wiki/Multiply-with-carry) based generator. The implementation does not use random seeds though: the seeds are themselves pseudorandom so the end result might not be as random as possible. See [l_rng.c](src/l_rng.c).
 + Bresenham's line algorithm and flood fills is used in [geomet.lua](src/geomet.lua).
 + Cellular-automata-inspired level generation, where the terrain of a tile is determined by the terrain of surrounding tiles. See [stgen.lua](src/stgen.lua).

## Dependencies

You will need the C libraries for:

 + Lua 5.3 or later
 + ncurses

This project has only ever been tested on Arch Linux.

## Compiling and Running

Navigate to the repository root and type `make` to create the executable `main`. This executable is intended to be run in a command-line , possibly with arguments. Before running it, create a 'save' folder inside the repository root.

Here are some things to keep in mind when running `main`:

 + There is currently an error on startup related to a configuration file not existing. However, the application runs fine without this file. Currently this file is not automatically generated, but must be written manually.
 + Startup can take a while. The level is procedurally generated. If a savefile exists, every action in the game up to the save point is re-executed (without being shown to the user). There are strengths and weaknesses to this approach. One strength is that it is easy to watch a recording of prior actions: run `./main -r visual` or `./main --replay visual`, and when asked for a name, use a name from a prior playthrough.
 + Once the map appears, the main thing the player can do is move around. The player is represented with a `@` and the default movement controls are [the usual roguelike/vi movement keys](http://roguebasin.com/index.php?title=User_interface_features#Vi_keys). The `.` key is considered 'invalid' and are used for skipping a turn.
 + Holding down a key continuously is interpreted as a large number of keystrokes. The application may take a few seconds to actually execute all those commands.
 + Quit by pressing `q`. This actually saves the game: there is no 'quit without save' option yet.
 + There is no collision checking, except with the edge of the map. This would not be good behaviour if the game were complete, but at the current stage of development it is intended. This is because when manual testing it is convenient to be able to move freely along the map.

There is an inbuilt test suite, which can be run (if `main` exists) by running `make check`. Currently, there is a failing test.
