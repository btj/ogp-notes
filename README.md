# Object-Oriented Programming

- [Introduction: Topic of the course](intro.md)
- [Principles of programming in Java](programming.md)
  - Concepts: values, variables, types, methods, parameters, arguments, return values, classes, fields, objects, object creation, object references, method activations and the call stack

## Single-object abstractions

- First steps in modular programming [Part 1](lecture2part1.md) [Part 2](lecture2part2.md)
  - Example: [squareroot](https://github.com/btj/squareroot)
  - Example: [max3](https://github.com/btj/max3)
  - Example: [timeofday](https://github.com/btj/timeofday)
  - Concepts: Using Eclipse, creating JUnit test cases, creating classes, instance methods, encapsulation, `private` versus `public`, using Git, constructors, unit testing basics and best practices
- [Managing complexity through modularity and abstraction](complexity_modularity_abstraction.md)
  - Concepts: modularity, abstraction, API, client module, importance of documentation, information hiding, procedural abstraction, data abstraction, immutable versus mutable abstractions, abstract value/state of an object, Java's built-in datatypes and operators
- [Representation objects and representation exposure](representation_objects.md)
  - Concepts: representation object, representation exposure
- [How to properly document single-object abstractions](single_object_doc_instr.md)
  - Concepts: defensive programming, contractual programming, preconditions, postconditions, class representation invariants (= private class invariants), class abstract state invariants (= public class invariants), getters, mutators

## Inheritance

- [Polymorphism](polymorphism.md)
  - Concepts: abstract classes, polymorphism, subclassing, inheritance, `instanceof`, the static type checker, static/dynamic type of a variable or an expression, typecasts, pattern matching; class Object, autoboxing and -unboxing
- [Dynamic binding](dynamic_binding.md)
  - Concepts: dynamic binding, abstract methods, method overriding, `@Override`; methods `equals`, `hashCode`, `toString`, `getClass`; record classes
- [Behavioral subtyping: modular reasoning about programs that use dynamic binding](behavioral_subtyping.md)
  - Example: [intlist_inheritance](https://github.com/btj/intlist_inheritance)
  - Concepts: Non-modular reasoning, modular reasoning, method specifications, correctness of methods; method call resolution, resolved method vs called method, static versus dynamic method call binding; strenghtening of specifications, behavioral types, behavioral subtyping
- [Interfaces](interfaces.md)
  - Concepts: interfaces, multiple inheritance, static fields, the Singleton pattern
- [Implementation inheritance](implementation_inheritance.md)
  - Concepts: Inheritance of fields and methods, `super` constructor calls, `super` method calls
- [Closed types](closed_types.md)
  - Concepts: types with a closed set of instances, enum classes, types with a closed set of direct subtypes, sealed types, switch statements and expressions
- [Lists, sets, and maps](collections.md)
  - Concepts: the List, Set, and Map abstract datatypes (ADTs); the ArrayList, LinkedList, HashSet, and HashMap data structures; the Java Collections Framework

## Multi-object abstractions (= entity-relationship abstractions)

- [Single-class entity-relationship abstractions](entity_relationship_abstractions.md)
  - Example: [html](https://github.com/btj/html_ir)
  - Concepts: entity graphs, multi-object abstractions, bidirectional associations, consistency of bidirectional associations, peer objects, peer groups
- [Multi-class entity-relationship abstractions](multi_class_abstractions.md)
  - Concepts: packages, package-accessible fields/constructors/methods/classes, package representation invariants, package abstract state invariants, `HashSet`
- [How to properly document multi-object abstractions](multi_object_doc_instr.md)

## Advanced topics

(Students of course H02C5A can ignore this material.)

- [Iterators](iterators.md)
  - Concepts: (external) iterators, iterables, nested classes, inner classes, local classes, anonymous classes, enhanced `for` loop, internal iterators, lambda expressions, capturing outer variables, effectively final variables
- [Streams](https://docs.oracle.com/en/java/javase/13/docs/api/java.base/java/util/stream/package-summary.html) (on the web)
  - Concepts: streams, sources, map, filter, reduce, collect, parallel streams
- [Generics](generics.md)
  - Concepts: generic class, generic interface, type parameter, type argument, generic type instantiation, parameterized type, bounded type parameter, covariance, contravariance, invariance, upper-bounded wildcard, lower-bounded wildcard, generic method, erasure, unchecked cast warning
