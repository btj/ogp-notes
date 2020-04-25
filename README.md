# Object-Oriented Programming

## Single-object abstractions

- [First lecture](lecture1.md)
  - Concepts: values, variables, types, methods, parameters, arguments, return values, classes, fields, objects, object creation, object references, method activations and the call stack
- Lecture 2 [Part 1](lecture2part1.md) [Part 2](lecture2part2.md)
  - Example: [squareroot](https://github.com/btj/squareroot)
  - Example: [max3](https://github.com/btj/max3)
  - Example: [timeofday](https://github.com/btj/timeofday)
  - Concepts: Using Eclipse, creating JUnit test cases, creating classes, instance methods, encapsulation, `private` versus `public`, using Git, constructors
- [Managing complexity through modularity and abstraction](complexity_modularity_abstraction.md)
  - Concepts: modularity, abstraction, API, client module, importance of documentation, information hiding, procedural abstraction, data abstraction, immutable versus mutable abstractions, abstract value/state of an object, Java's built-in datatypes and operators
- [How to properly document single-object abstractions](drawit_doc_instr.md)
  - Concepts: defensive programming, contractual programming, preconditions, postconditions, class representation invariants (= private class invariants), class abstract state invariants (= public class invariants), getters, mutators

## Multi-object abstractions (= entity-relationship abstractions)

- [Single-class entity-relationship abstractions](entity_relationship_abstractions.md)
  - Example: [html](https://github.com/btj/html_ir)
  - Concepts: entity graphs, multi-object abstractions, bidirectional associations, consistency of bidirectional associations, peer objects, peer groups
- [Multi-class entity-relationship abstractions](multi_class_abstractions.md) (not relevant to Part 2 of project)
  - Concepts: packages, package-accessible fields/constructors/methods/classes, package representation invariants, package abstract state invariants, `HashSet`

## Inheritance

- [Polymorphism and dynamic binding](inheritance.md)
  - Concepts: polymorphism, subclassing, inheritance, `instanceof`, typecasts; dynamic binding, method overriding, `@Override`; class `Object`, `Object.equals`, `Object.hashCode`, `Object.toString`, `Object.getClass`
- [Behavioral subtyping: modular reasoning about programs that use dynamic binding](behavioral_subtyping.md)
  - Example: [intlist_inheritance](https://github.com/btj/intlist_inheritance)
  - Concepts: Non-modular reasoning, modular reasoning, method specifications, correctness of methods; method call resolution, resolved method vs called method, static versus dynamic method call binding; strenghtening of specifications, behavioral types, behavioral subtyping
- [Interfaces](interfaces.md)
  - Concepts: interfaces, multiple inheritance, static fields, the Singleton pattern
- [Implementation inheritance](implementation_inheritance.md)
  - Concepts: Inheritance of fields and methods, `super` constructor calls, `super` method calls

## Advanced topics

(Students of course H02C5A can ignore this material.)

- [Iterators](iterators.md)
  - Concepts: (external) iterators, iterables, nested classes, inner classes, local classes, anonymous classes, enhanced `for` loop, internal iterators, lambda expressions, capturing outer variables, effectively final variables
- [Streams](https://docs.oracle.com/en/java/javase/13/docs/api/java.base/java/util/stream/package-summary.html)
  - Concepts: streams, sources, map, filter, reduce, collect, parallel streams
