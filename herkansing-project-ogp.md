# Herkansing Project OGP

All of the code you develop must be in package `roads` and/or subpackages.

## 1. Road Network

Define and implement an entity-relationship abstraction, consisting of classes `City` and `Road`, for representing a network of roads connecting cities. A city has a name. A road connects exactly two cities, and has a length in kilometers, expressed as an `int`, greater than zero. Allow clients to create a city with a given name, create a road with a given length connecting two given cities, retrieve the name of a city and the set of roads that connect that city to other cities, and the length of a road and the set of cities that this road connects. You need not support the removal of roads or cities from the network.

The constructors shall deal with illegal arguments defensively. Provide complete public and internal formal documentation. (You need not provide informal documentation.)

To fully document the `Road` constructor, it may be useful to introduce a static method `getRoadsMap` that takes a set of cities and returns a map that maps each city from the set to its set of roads. Furthermore, you may use the [`logicalcollections`](https://github.com/btj/logicalcollections) project.

## 2. Routes

Define and implement an immutable abstraction, consisting of classes `Route`, `EmptyRoute`, and `NonemptyRoute`, for representing *routes*. A route is either an empty route or a nonempty route. Each route has a start city. A nonempty route also has a first leg, which is a road, and a continuation, which is again a route. It is illegal if the client attempts to construct a nonempty route whose first leg does not connect its start city and the start city of its continuation. Allow the client to obtain the length (in kilometers) and the end city of any `Route` object. The end city of an empty route equals its start city; the end city of a nonempty route equals its continuation's end city.

Ensure that two `Route` objects `r1` and `r2` are considered equal by the Java Collections library, by JUnit, etc., (for example, `new HashSet<>(List.of(r1)).contains(r2)` returns `true`) if and only if they represent the same route. Write a test case to check this.

Your implementation shall deal with illegal cases defensively; however, you need not write any documentation.

## 3. getRoutesTo

Add a method `getRoutesTo` to class `City` that returns a `Stream<Route>` containing all routes from the receiver city to the given city that have no loops, i.e. that do not pass through the same city more than once. You need not write any documentation for this method.

**Implementation Hints:** It may be useful to define a helper method that additionally takes a set of cities to avoid. Use `Stream.of` to build a singleton stream. `s.flatMap(f)`, where function `f` maps an element of `s` to a stream, returns the stream obtained by concatenating the streams obtained by applying `f` to each element of `s`. If A and C are not the same city, then there is a route from A to C for every combination of a road from A to B and a route from B to C.

## 4. Routing strategies

Define an interface `RoutingStrategy` with a method `getRoute` that takes two cities and returns a route between them, or `null` if there is no route between them. Define two classes, `FastRoutingStrategy` and `OptimalRoutingStrategy`, that implement `RoutingStrategy`. The implementation of `getRoute` in `FastRoutingStrategy` returns any route between the given cities, and the implementation of `getRoute` in `OptimalRoutingStrategy` returns a route with minimal length.

Provide full documentation for method `getRoute` in interface `RoutingStrategy` and in both implementing classes, in a way that complies with behavioral subtyping. In your documentation, you may use method `getRoutesTo`. (This is an exception to the rule that in documentation, you may use only methods that are properly documented themselves.)

## Grading

### Teams of 2 students

To obtain a passing grade (>= 10/20) for this project, you must execute
Sections 1 and 2 above. For Section 1, you must provide complete `@throws`
clauses and postconditions, complete abstract state invariants and complete
representation invariants.

To obtain a distinction (>= 14/20), you must execute Section 3 as well; furthermore, for Section 1 you must provide all necessary `@inspects`, `@mutates`, `@mutates_properties`, `@representationObject`, `@peerObject`, and `@peerObjects` clauses.

To obtain a score of 17/20 or more, you must execute Section 4 as well.

To obtain a score of 20/20, additionally, for Section 1 you must apply nested abstractions.

In each case, for each Section that you execute, you must provide a test suite that tests each statement of your implementation, except for statements that run only in illegal cases.

### Teams of 1 student

To obtain a passing grade (>= 10/20) for this project, you must execute
Section 1 above. You must provide complete `@throws`
clauses and postconditions, complete abstract state invariants and complete
representation invariants.

To obtain a score of 13/20 or more, you must additionally execute Section 2.

To obtain a score of 16/20 or more, you must execute Section 3 as well; furthermore, for Section 1 you must provide all necessary `@inspects`, `@mutates`, `@mutates_properties`, `@representationObject`, `@peerObject`, and `@peerObjects` clauses.

To obtain a score of 18/20 or more, you must execute Section 4 as well.

To obtain a score of 20/20, additionally, for Section 1 you must apply nested abstractions.

In each case, for each Section that you execute, you must provide a test suite that tests each statement of your implementation, except for statements that run only in illegal cases.
