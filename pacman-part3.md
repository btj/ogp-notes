PacMan Part 3
=============

## Portals and wormholes

Develop, in package `pacman.wormholes`, an abstraction for manipulating graphs
whose nodes are *departure portals* (represented by instances of class
`DeparturePortal`), *arrival portals* (represented by instances of class
`ArrivalPortal`), and *wormholes* (represented by instances of class
`Wormhole`). Each wormhole is associated, at each point in time, with exactly
one departure portal and exactly one arrival portal. Each departure portal and
each arrival portal is associated with a square. 

Allow the client to create a departure portal at a given square, to create an
arrival portal at a given square, to create a wormhole with a given initial
departure portal and a given initial arrival portal, to get a departure or
arrival portal's square (with `getSquare()`) and set of associated wormholes
(with `getWormholes()`, returned as an instance of `java.util.Set<Wormhole>`),
to get a wormhole's departure portal (with `getDeparturePortal()`) and arrival
portal (with `getArrivalPortal()`), and to set the departure portal (with
`setDeparturePortal`) and the arrival portal (with `setArrivalPortal`).

For this project, do not introduce a class or interface that generalizes over
departure portals and arrival portals.

Provide full public and internal formal documentation. Deal with illegal calls
defensively. Also provide, in a separate package `pacman.wormholes.tests`, a
test suite that tests all statements of your abstraction, except for the
statements that are executed only in case of illegal calls.

To get a passing grade, you are allowed to treat an attempt to set a wormhole's
departure portal to its current departure portal, or to set a wormhole's
arrival portal to its current arrival portal, as illegal (because this makes it
easier to write complete postconditions). However, to get a maximum grade, your
abstraction shall not treat these cases as illegal.

## Extend PacMan with portals and wormholes

Extend class `Maze` so that it also keeps a list of departure portals, a list
of arrival portals, and a list of wormholes. Method
`getDeparturePortals()`/`getArrivalPortals()` shall return an array containing
the departure/arrival portals of the maze in left-to-right, top-to-bottom
order. Method `getWormholes()` shall return the wormholes in an array, in the
order in which they were added to the maze. Extend the constructor to take an
array of departure portals and an array of arrival portals, both sorted in
left-to-right, top-to-bottom order, as additional
arguments. A maze shall initially have no wormholes. Add a method `addWormhole`
that takes a wormhole as an argument and adds it to the maze's list of
wormholes. It shall defensively check that the wormhole's departure and arrival
portals are in the maze's lists of departure and arrival portals, respectively.

Extend method `movePacMan` so that if PacMan moves onto a departure portal that
is currently associated with at least one wormhole, one of these wormholes is
picked randomly, using `random.nextInt(N)` where N is the number of wormholes
associated with the departure portal. PacMan shall
instantaneously move to the wormhole's arrival portal. You may assume that a
maze does not contain a food item and a portal or two portals (or two food
items) on the same square. However, it is possible that there are ghosts at the
same square as a departure portal or an arrival portal; when PacMan travels
along a wormhole, he shall be considered to have hit both the ghosts at the
departure square and the ghosts at the arrival square.

Extend class `MazeDescriptions` so that a `D` causes a departure portal to be
generated and an `A` causes an arrival portal to be generated.

## Submission and grading

You shall submit the classes from package `pacman` (that is: the files `Direction.java`, `Dot.java`, `FoodItem.java`, `Ghost.java`, `GhostState.java`, `Maze.java`, `MazeDescriptions.java`, `MazeMap.java`, `PacMan.java`, `PowerPellet.java`, `RegularGhostState.java`, `Square.java`, and `VulnerableGhostState.java`), as well as the files that implement your package `pacman.wormholes` and your test suite for this package.

An automatic check will be performed on the submitted files.

To obtain a score of 5/10 for Part 3, your submission shall compile without
errors with FSC4J, your own test suite, which shall test all statements of your
`pacman.wormholes` package except for those that are executed only in case of
illegal calls shall run without failures when executed with FSC4J, and the
official test suite shall run without failures when executed with FSC4J.
Furthermore, your submission shall run correctly when tested manually using the
provided GUI, your package `pacman.wormholes` shall be properly encapsulated
and shall preserve the consistency of the bidirectional associations at all times
and the documentation you provide for package `pacman.wormholes` shall show
that you understand the basic principles of how to properly document
multi-object abstractions, and shall properly express the consistency of the
bidirectional associations, both as representation invariants and as abstract state invariants.

The remaining 5 points shall be awarded as follows:
- 1 point if you use the `@representationObject`, `@representationObjects`, `@peerObject`, and `@peerObjects` tags in the correct places in package `pacman.wormholes`.
- 1 point if the documentation you write for package `pacman.wormholes` is fully correct and you have complete postconditions.
- 1 point if your documentation for package `pacman.wormholes` is fully correct and complete, which implies among other things that you use `@mutates_properties` properly to precisely specify which properties of which objects may be mutated by a method or constructor.
- 1 point if you do not treat setting a wormhole's departure portal to its current departure portal or setting a wormhole's arrival portal to its current arrival portal as illegal, and you have complete postconditions for the setters of class `Wormhole` that correctly handle these cases.
- 1 point if you correctly apply nested abstractions to achieve maximum class-level encapsulation (in addition to package-level encapsulation) in package `pacman.wormholes`.

Given the limited amount of work required, there is no reduction for students working alone.
