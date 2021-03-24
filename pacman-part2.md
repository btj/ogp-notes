# PacMan Part 2

In this second part of the PacMan project, you will extend the system of Part 1 with *Power Pellets* and *Ghost States*.

## Power Pellets

In Part 1, *dots* were the only type of food item available to PacMan. In Part
2, there are two types of food items: dots and Power Pellets. Introduce a class
`PowerPellet` and a class `FoodItem` that generalizes over classes `Dot` and
`PowerPellet`. Adapt class `Maze` so that it deals only with food items
generally, not with dots specifically. Adapt class `MazeDescriptions` so that a lowercase `p` in a maze description is turned into a `PowerPellet` object.

Provide a public method `int getSize()` in class `FoodItem` that returns the size of the food item, relative to the size of a dot. The size of a power pellet is twice that of a dot.

## Ghost States

When PacMan eats a power pellet, the ghosts become vulnerable for a limited amount of time. Ghosts move at a reduced speed when they are vulnerable.

Introduce a class `RegularGhostState` and a class `VulnerableGhostState`, and a class `GhostState` that generalizes over `RegularGhostState` and `VulnerableGhostState`. Adapt class `Ghost` so that each instance keeps a ghost state, which is initially a regular ghost state.

Introduce a public method `boolean isVulnerable()` into class `Ghost`.

Introduce a public method `void pacManAtePowerPellet()` into class `Ghost`. It should reverse the ghost's direction and bring it into a vulnerable state. Adapt class `Maze` so that this method is called on each ghost when PacMan eats a power pellet.

Introduce a public method `GhostState move(Ghost ghost, Random random)` into class `GhostState`. Rename method `void move(Random random)` of class `Ghost` to `void reallyMove(Random random)`, and introduce a method `void move(Random random)` that calls `move(this, random)` on the ghost's current state and sets the result as the ghost's new state.

When a ghost is in a regular state, moving simply means really moving, and it remains in the same state. When a ghost is in a vulnerable state, it really moves only when its *move delay* is zero; otherwise, all that happens is that its move delay is decremented. When a ghost becomes vulnerable, its initial move delay is 1. This means that, the first time `move` is called on a ghost after it became vulnerable, it does not really move. The second time, it does really move, and it also resets its move delay to 1. So, the third time, it again does not really move, but the fourth time, it does, etc. Also, after a ghost really moves for the sixth time after becoming vulnerable, it becomes regular again.

## PacMan eats vulnerable ghosts

If PacMan coincides with a ghost in a regular state, PacMan dies. If PacMan coincides with a vulnerable ghost, PacMan remains unharmed and eats the ghost; more specifically, the ghost jumps immediately to its original square and becomes regular again.

Adapt class `Ghost` so that it remembers its original square, as specified at construction time.

Add a public method `public GhostState hitBy(Ghost ghost, PacMan pacMan)` to class `GhostState`. Also add a public method `void hitBy(PacMan pacMan)` to class `Ghost` and implement it by calling `hitBy(this, pacMan)` on the ghost's current state, and setting the result as the ghost's new state. Adapt class `Maze` so that, whenever a ghost's square equals PacMan's square, instead of immediately calling `pacMan.die()`, `ghost.hitBy(pacMan)` is called.

## What to submit

You will have to submit classes `Direction`, `Dot`, `FoodItem`, `Ghost`, `GhostState`, `Maze`, `MazeDescriptions`, `MazeMap`, `PacMan`, `PowerPellet`, `RegularGhostState`, `Square`, and `VulnerableGhostState`, all of which shall reside in package `pacman`.

For this Part, you need not write any documentation, except that you shall write complete formal documentation for method `getSize` in class `FoodItem` and its subclasses; make sure to respect behavioral subtyping.

You also need not submit a test suite.

Given that this assignment is very lightweight, there will not be a reduction for students working alone.

To obtain a score of 3/6, your solution must compile without errors, and must pass 66% of the official test cases. To obtain a score of 4/6, your solution must pass 80% of the official test cases. To obtain a score of 5/6, your solution must pass 100% of the official test cases. To obtain a score of 6/6, your solution must additionally not use `instanceof` or otherwise perform explicit case analysis on the type of food item or ghost state; instead, it must only use dynamic binding to realize behavior that differs between the types of food item or ghost state. (Note that the GUI is not considered to be part of the solution.)
