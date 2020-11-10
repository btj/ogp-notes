# OGP Fall 2020 Homework

## Portals and Transformations (14 points)

Develop a class `Portal` whose instances represent *wormhole portals*. At any point in time, a portal is *paired* with at most one other portal. (This is a symmetric relation: if portal A is paired with portal B, then B is paired with A as well.) Furthermore, each portal has a *transformation*: anything that passes through the portal is scaled by some fraction between 1/2 and 2. Define an interface `Transformation` with a method `apply` that takes an `int` value and returns the `int` value that results from transforming the given value. Define a class `TwoThirdsTransformation` whose `apply` method returns its argument multiplied by the fraction 2/3 (and rounded down), and a class `ThreeQuartersTransformation` whose `apply` method returns its argument multiplied by 3/4 (and rounded down). (Note: in this text, the division symbol (/) has its ordinary mathematical meaning, not the meaning it has in Java.) 

The argument to a transformation's `apply` method must be positive. Deal with illegal arguments defensively in `TwoThirdsTransformation` and contractually in `ThreeQuartersTransformation`.

Allow the client to create a `TwoThirdsTransformation`, a `ThreeQuartersTransformation`, and an unpaired `Portal` with a given transformation, to retrieve a `Portal`'s paired portal and transformation, and to set or clear its paired portal. In class `Portal`, deal with illegal calls defensively. Ensure class `Portal` is properly encapsulated.

Provide full public and internal formal documentation for all three classes and for interface `Transformation`. Interface `Transformation`'s documentation should be as precise as possible, while still allowing it to be implemented by any class that satisfies the rules stated above (so not just `TwoThirdsTransformation` and `ThreeQuartersTransformation`).

Provide a test suite for your code. You need not test illegal cases. Make sure each statement is tested, except for statements that run only in illegal cases.

## LinkedHashSet (6 points)

Develop a class `LinkedHashSet` that implements the `Set` interface from the Lists, sets, and maps chapter of the course notes, such that `contains`, `add`, and `remove` take constant expected time (assuming a good hash function and assuming the hash table is not overloaded), and where `toArray` returns the elements in the order in which they were added in linear time. (Adding an element that is already in the set has no effect on the order.)

You cannot use any classes from the Java Collections Framework. You can, however, reuse the classes defined in the Lists, sets, and maps chapter of the course notes.

**Implementation hint:** Internally, keep the elements both in a doubly linked list and in a `HashMap` that maps each element to the corresponding linked list node.

You need not provide a test suite. You need to provide public documentation only if you are going for 19/20 and internal documentation only if you are going for 20/20. That is: 4 points are on the implementation, 1 point is on the public documentation, and 1 point is on the internal documentation.
