# Common errors

### Referring to private fields in the documentation for public program elements (classes, constructors, methods)

The following is wrong:
```java
/**
 * @invar | balance >= 0   // ERROR: Cannot refer to private field in documentation for public class.
 */
public class Account {
    private int balance;
}
```
This violates the rule that if the documentation for a program element X refers to a program element Y,
then any code that can see X must be able to see Y. Applied to the example:
the documentation for class `Account` refers to field `balance`, so any code that can see class
`Account` must be able to see field `balance`. However, this is not the case: class `Account` is public so it can be seen
by any code in the program; field `balance`, on the other hand, is `private` so it can be seen only by code inside class `Account`.

#### Solution

Use a getter instead:
```java
/**
 * @invar | getBalance() >= 0
 */
public class Account {
    private int balance;
    public int getBalance() { return balance; }
}
```

### Leaking representation objects

The following is wrong:
```java
public class Team {
    /**
     * @invar | members != null
     * @invar | members.stream().allMatch(s -> s != null && s.team == this)
     * @representationObject
     * @peerObjects
     */
    private Set<Student> members;
    public Set<Student> getMembers() { return members; }   // WRONG: Leaking representation object
}
```
Public method `getMembers()` returns a reference to the `Set<Student>` object used by the `Team` object to store its members.
Once client code has a reference to this object, it can modify it without respecting the `Team` object's representation invariants.
For example, it can add a `null` element, or it can add a `Student` object that is a member of a different team.

This error is known as *representation exposure*.

#### Solution

Instead of returning a reference to a representation object, return a copy:
```java
    public Set<Student> getMembers() { return Set.copyOf(members); }
```

### Neglecting to include public and private invariants that express the consistency of bidirectional associations

If a class is involved in one or more bidirectional associations, its public invariants *and* its private invariants
must express the consistency of these bidirectional associations.
For examples, see the chapters on entity-relationship abstractions in the course notes.

### Neglecting to include public or private invariants that express non-nullness

- If a field is never null, include a private invariant that states this.
- If a getter is never null, either include a public invariant that states this in the class documentation,
or include a postcondition that states this in the getter's documentation.
- If the elements of a collection stored by an object are never null, include a private invariant that states this.
- If the elements of a collection returned by a getter are never null, either include a public invariant that states this
in the class documentation, or include a postcondition that states this in the getter's documentation.
To express that a collection `C` has no null elements, you can write `C.stream().allMatch(e -> e != null)`.

### Comparing collections using `==`

To express that the two arrays `A1` and `A2` store equal sequences of elements, use `Arrays.equals(A1, A2)`, not `A1 == A2`.
To express that two `Set` objects, two `List` objects, or two `Map` objects `C1` and `C2` store equal collections of elements,
use `C1.equals(C2)`, not `C1 == C2`. The `==` operator compares the identity of two objects, not their contents.
