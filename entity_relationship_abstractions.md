# Entity-relationship abstractions

In this course, we consider the question of how to split up complex software development tasks into simpler subtasks. The main tool we teach is _abstraction_: developing _modules_ that extend the programming language with new _operations_ (_procedural abstraction_) and new _datatypes_ (_data abstraction_) so that _client modules_ can be written in a more powerful programming language.

In this course, we consider two types of data abstractions:
- _single-object abstractions_, where each instance of some class represents (_immutable value abstractions_) or stores (_mutable value abstractions_) some _abstract value_. See [here](complexity_modularity_abstraction.md) for an introduction to value abstraction.
- _multi-object abstractions_, where groups of objects of a single class (_single-class multi-object abstractions_) or groups of objects of multiple classes (_multi-class multi-object abstractions_) are used to together store special kinds of abstract values called _entity graphs_.

Multi-object abstractions, also called _entity-relationship abstractions_, are the topic of this document.

## OOP Teams

Suppose I wanted to write a Java program to manage the Object-Oriented Programming course. In particular, I would want to track team compositions for the project. Students are encouraged to work in teams of two students, but they can work alone if they really want to.

The information I want the program to keep track of, then, is, mathematically speaking, the set _S_ of students, along with the relation _is-teammate-of_ on this set. (One can think of this relation as a subset of the set of pairs of students _S &times; S_.)

For example, suppose the course has four students: _S = {Alice, Bob, Carol, Dan, Eve}_. Suppose Alice and Bob constitute a team, and so do Carol and Dan, but Eve works alone. Then we have _is-teammate-of = {(Alice, Bob), (Bob, Alice), (Carol, Dan), (Dan, Carol)}_. (_is-teammate-of_ must always be a symmetric relation: if _X_ is a teammate of _Y_, then _Y_ is necessarily a teammate of _X_ as well.)

Generalizing from this example, it is often the case that we want to use Java programs to store information of this form, which we call _entity graphs_. In the general case, an entity graph consists of some number of sets of _entities_, and some number of _relations_ between particular sets of entities. Furthermore, the graph may associate particular values with each element of some set of entities. For example, we may want to store each student's study programme; mathematically, this corresponds to a function that maps each element of _S_ to some element of the set _P_ of study programmes. We call each such function, that associates a value with each entity from some entity set, an _attribute_. In general, then, an entity graph consists of some sets of entities, some relations between the sets of entities, and some attributes.

Writing a program for managing the OOP course in Java includes the complexity of correctly storing and manipulating OOP team composition graphs. Writing such a program would be easier if it could be written in a programming language, let's call it Java++, that has a built-in way to store these graphs, that is, that has a built-in type whose values represent OOP students, and built-in operations for setting and getting a student's teammate and study programme.

We can achieve this complexity reduction by splitting the task of writing a Java program for managing the OOP course into two subtasks:
- Writing a _client module_ for managing the OOP course, written in the language Java++ that has built-in types and operations for storing OOP team composition graphs
- Writing an OOP team composition graphs module that implements the extra datatypes and operations of Java++ (or, in other words, the OOP team composition graph abstraction) in terms of the regular Java datatypes and constructs such as classes, fields, and methods.

By composing the OOP team composition graphs module and the client module, we obtain a program for managing the OOP course written in Java.

A natural way to write a module for storing a particular type of entity graph is to introduce a Java class for each type of entity, a getter in class _E_ for each attribute of entity type _E_, and getters in classes _E_ and _F_ for each relation between entity types _E_ and _F_.

To store a particular entity graph, then, we would create a separate instance of class _E_ for each entity of type _E_ in the entity graph, and whenever a relation from the entity graph links entities _e1_ and _e2_, we would store a reference to _e2_ in object _e1_ and a reference to _e1_ in object _e2_. Obviously, we would also store in object _e_ the attribute values assigned to entity _e_ by the entity graph.

For example, here is one way to implement the OOP team composition graph abstraction in Java:

```java
package teams;

/**
 * Each instance of this class represents an Object-Oriented Programming student
 * in an OOP team composition graph.
 * 
 * @invar | getStudyProgramme() != null
 * @invar | getTeammate() == null || getTeammate().getTeammate() == this
 */
public class OOPStudent {

    /**
     * @invar | studyProgramme != null
     * @invar | teammate == null || teammate.teammate == this
     */
    private final StudyProgramme studyProgramme;
    /** @peerObject */
    private OOPStudent teammate;

    /** @immutable */
    public StudyProgramme getStudyProgramme() {
        return studyProgramme;
    }

    /**
     * Returns this student's teammate, or {@code null} if this student has no teammate.
     * 
     * @peerObject
     */
    public OOPStudent getTeammate() {
        return teammate;
    }

    /**
     * Initializes this object to represent a student with the given study programme
     * and no teammate.
     * 
     * @throws IllegalArgumentException if {@code studyProgramme} is null
     *    | studyProgramme == null
     * @post This student's study programme equals the given study programme
     *    | getStudyProgramme() == studyProgramme
     * @post This student has no teammate
     *    | getTeammate() == null
     */
    public OOPStudent(StudyProgramme studyProgramme) {
        if (studyProgramme == null)
            throw new IllegalArgumentException("`studyProgramme` is null");
        this.studyProgramme = studyProgramme;
    }

    /**
     * Registers the fact that this student is teaming up with the given student.
     * 
     * @throws IllegalArgumentException if {@code teammate} is null
     *    | teammate == null
     * @throws IllegalStateException if this student already has a teammate
     *    | getTeammate() != null
     * @throws IllegalArgumentException if the given student already has a teammate
     *    | teammate.getTeammate() != null
     * @mutates | this, teammate
     * @post This student's teammate equals the given teammate
     *    | getTeammate() == teammate
     * @post The given student's teammate equals this student
     *       (Note: this postcondition is redundant because it follows from the public class invariant.)
     *    | teammate.getTeammate() == this
     */
    public void setTeammate(OOPStudent teammate) {
        if (teammate == null)
            throw new IllegalArgumentException("`teammate` is null");
        if (this.teammate != null)
            throw new IllegalStateException("This student already has a teammate");
        if (teammate.teammate != null)
            throw new IllegalArgumentException("The given teammate already has a teammate");
        this.teammate = teammate;
        teammate.teammate = this;
    }
    
    /**
     * Registers the fact that this student is splitting up with their teammate.
     * 
     * @throws IllegalStateException if this student has no teammate
     *    | getTeammate() == null
     * @mutates | this
     * @post This student has no teammate
     *    | getTeammate() == null
     * @post This student's old teammate has no teammate
     *    | old(getTeammate()).getTeammate() == null
     */
    public void clearTeammate() {
        if (teammate != null)
            throw new IllegalStateException("This student does not have a teammate");
        this.teammate.teammate = null;
        this.teammate = null;    
    }
}
```

The abstraction exposes the _is-teammate-of_ relation as a getter `getTeammate()` on class `OOPStudent`. The call `s.getTeammate()` returns
either student `s`'s teammate, or `null` if student `s` has no teammate. This reflects the fact that in OOP, a student can have at most
one teammate.

## Consistency of bidirectional associations

This example exhibits a typical characteristic of entity-relationship abstractions: the states of the objects that together constitute
the entity-relationship abstraction are not independent: if `s1.getTeammate()` returns `s2`, then `s2.getTeammate()` must return `s1`.
We call this the **consistency of the bidirectional association**. It is characteristic of entity-relationship abstractions that there
are bidirectional associations between the objects; that is, these objects allow clients to navigate along the association in both directions.
It is a crucial responsibility of a module that implements an entity-relationship abstraction that it maintain the consistency of the
bidirectional associations at all times. Notice that methods `setTeammate` and `clearTeammate` do so carefully. Each check is necessary;
for example, if we left out the `this.teammate != null` check in `setTeammate`, the following client code would break the consistency
of the bidirectional association:
```java
alice.setTeammate(bob);
alice.setTeammate(carol); // Should fail!
assertEquals(alice, bob.getTeammate()); // Inconsistent!
```
The second `setTeammate` call is incorrect and should cause an exception. Otherwise, after this call `bob.getTeammate()` returns `alice`
while `alice.getTeammate()` returns `carol`, which is inconsistent.

## Peer groups

This interdependency between the states of the objects that constitute the entity-relationship abstraction is reflected in the
representation invariants: the representation invariant for an `OOPStudent` object `s1` where `s1.teammate == s2` talks not just
about the fields of `s1` but about the fields of `s2` as well: in particular, it specifies that `s2.teammate == s1`. This means that
changing the state of object `s2` can break the representation invariant of `s1`. This, in turn, means that when implementing the methods
of class `OOPStudent`, it is crucial to remember not just to preserve the validity of the representation of the objects directly involved
in the call, but also to remember to preserve the validity of the representation of the other objects whose representation invariants
involve the objects directly involved in the call. For example, in method `clearTeammate`, to preserve the representation invariants of
`this`, it is sufficient to set `this.teammate = null`. The extra assignment `this.teammate.teammate = null` is necessary to preserve
the representation invariant of the receiver's old teammate.

Generalizing from this example, in order to avoid inadvertently breaking the representation invariants of objects, when implementing
methods we need to know which objects' representations invariants we may break when mutating particular objects. For this reason, we
introduce the following rules:
- The representation invariants for an object X may mention a non-final field or non-immutable property of an object Y only if:
  - X = Y, or
  - Y is a representation object of X, or
  - Y is a _peer object_ of X.
- If X is a peer object of Y, then Y must be a peer object of X.

We define the set of representation objects of an object X as the set of objects reachable via the fields marked `@representationObject` of X. For example,
the array object used by an `IntList` object to store the elements of the list is a representation object of the `IntList` object. Representation objects of an object
X must be _encapsulated_ inside object X; that is, it must not be possible to access the representation objects of X outside the class of X.

We define the set of peer objects of an object X as the set of objects reachable via the fields marked `@peerObject` of X. For example, the teammate of an
`OOPStudent` object is a peer object of the `OOPStudent` object. This allows the representation invariant to mention the teammate's `teammate` field.

We refer to a set of objects, each of which is a direct or indirect peer object of the others, as a _peer group_. The objects of a peer group
together constitute an entity-relationship abstraction. It does not make sense to consider each member of a peer group as a separate abstraction;
the notions of representation validity and abstract state apply meaningfully only to a peer group as a whole.

The `@peerObject` tags on fields are internal documentation for internal use by a module author to reason about the correctness of the module.
However, it is also important for client module authors to know which objects constitute a peer group. Therefore, we also define an object's
peer group publicly by marking appropriate public getters as `@peerObject` as well, as in the example above.

Since the objects of a peer group do not have independent representations or abstract states, we interpret an object mentioned in a `@mutates` clause
as representing that object's entire peer group. This is why, in the documentation for method `clearTeammate()`, it is sufficient to
write `@mutates | this`: the method mutates object `this.teammate` as well, but since that object is a peer object of `this`, it need not be
mentioned separately.
