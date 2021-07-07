# Retake Project 2021

## Class Diagrams

Develop an abstraction for storing and manipulating *class diagrams*. A class
diagram consists of *class boxes* (class `ClassBox`), *roles* (class `Role`), and *association lines* (class `AssociationLine`). A class
box has a name and a set of *roles*. Each role has a name and a *multiplicity*
and is associated with an association line. A multiplicity is an object of
the type `Multiplicity` defined as follows:
```java
public enum Multiplicity {
    ZERO_TO_ONE,
    ONE,
    ZERO_TO_MANY
}
```
Each role whose association line has not been deleted belongs to exactly one
class box. No two roles of a class box may have the same name.
An association line
connects a *start role* to an *end role* (which may be the same, as in the
example above).

Allow the client to create a class box with a given name and no roles, and to create an association with a given start class, start role name, start role multiplicity, end class, end role name, and end role multiplicity. Furthermore, provide methods `getName` and `getRoles` in class `ClassBox`, the latter of which returns a `java.util.Map<String, Role>` object, methods `getClassBox` (which returns `null` if the role's associated association line has been deleted), `getName`, `getMultiplicity`, and `getAssociationLine` in class `Role`, and methods `getStartRole`, `getEndRole`, `isDeleted`, and `delete` in class `AssociationLine`. The latter deletes the association line's roles from its class boxes.

For simplicity, you may treat an attempt to create an association line that connects two roles of the same class box as illegal.

Ensure your abstraction is properly encapsulated (which implies, among other things, that it does not expose representation objects and that it protects the consistency of the bidirectional associations). Provide full public and internal formal documentation. (You need not provide any informal documentation.) Deal with illegal cases of creating an object defensively, and other illegal cases contractually.

Provide a test suite that tests each statement of your abstraction, except for statements that are executed only in illegal cases.

## Immutable Maps

Define a class hierarchy for representing immutable *maps*. Conceptually, a map is
a set of key-value pairs (also known as *entries*).
Specifically, a *map* (class `Map`) is either an *empty map* (class `EmptyMap`) or a *nonempty map* (class `NonemptyMap`). A nonempty map has a *key* and a *value* (both arbitrary objects (not `null`)) and a *tail*, which is again a `Map` instance. The set of key-value pairs of a nonempty map is the set of key-value pairs of the tail plus the given pair.

Allow the client to obtain an `EmptyMap` instance using `EmptyMap.of`, to obtain a `NonemptyMap` instance given a key, a value, and a tail using `NonemptyMap.of`, and to retrieve a `NonemptyMap` instance's key, value, and tail using methods `getKey`, `getValue`, and `getTail`.

Also allow the client to retrieve the value for a given key `key` in a `Map` object `map` by calling `map.get(key)`. This method should return `null` if the given key does not appear in the map. You cannot use typecasts for implementing this functionality.

Also ensure that two `Map` objects are considered equal by JUnit and by the Java Collections Framework if and only if they are either both empty maps, or both nonempty maps with equal key, value, and tail. (That is, the order of the entries matters.)

For extra points, allow the client to iterate over the keys of a `Map` object. Specifically, your `Map` class shall implement interface `java.lang.Iterable`.

For extra points, apply generics so that `Map<K, V>` is the type of maps with
keys of type `K` and values of type `V`.

For extra points, allow the client to iterate internally over the values of a map `m` by calling `m.forEachValue(consumer)`. Ensure this method has a maximally flexible type.

For extra points, use streams to implement a method `getLongKeyLengths` such
that `map.getLongKeyLengths()` returns a `Set<Integer>` containing the lengths
of the keys of `map` (when converted to a string) whose length (when converted
to a string) is greater than the length of the corresponding value (when
converted to a string). (You can turn any `java.lang.Iterable` object `i` into
a stream using `StreamSupport.stream(i.spliterator(), false)`.)

You need not provide any documentation for this class hierarchy. Also, you need not write defensive checks.

Provide a test suite that tests each statement of your `Map` class hierarchy.

## Submission and grading

Develop your class diagrams abstraction in package `retake2021.classdiagrams`, your test suite for this abstraction in package `retake2021.classdiagrams.tests`, your maps class hierarchy in package `retake2021.maps`, and your test suite for this class hierarchy in package `retake2021.maps.tests`. Submit a `.zip` file containing the contents of your `src/retake2021` folder.

To obtain a passing grade (≥ 10/20) for your submission, it must essentially
comply with all of the above requirements except for the ones marked as "For
extra points"; your documentation must show that you have a basic understanding
of all essential aspects of the course's documentation approach, including
documenting the invariants expressing the consistency of the bidirectional
associations; the automatic check must report no compilation errors when
compiling with FSC4J; and both your own test suite and the staff test suite
must pass without errors when executed with FSC4J. (The staff test suite does
not test the requirements marked "For extra points".)

The additional points are awarded based on the degree to which your code and your documentation is fully complete and fully correct and implements the requirements marked "For extra points". One point is awarded for correctly applying nested abstractions.

Students of course H02C5A need not implement the requirements marked "For extra points" to obtain a full score.
