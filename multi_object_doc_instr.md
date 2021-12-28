### How to properly document multi-object abstractions

These instructions complement the instructions on _How to properly document single-object abstractions_.

#### Fields documentation

If an `@invar` clause for an object O mentions a field of an object O', then O' must be a representation object of O or a peer object of O.

An `@invar` clause must be well-defined (i.e. must not crash or loop forever) for arbitrary (concrete) states of the objects involved, with the following exceptions:
- An `@invar` clause is evaluated only if preceding `@invar` clauses of the same object evaluated to `true`. So, if, for example, the first clause says that some field is non-null, the second clause is allowed to call a method on the object referenced by that field.
- The N'th `@invar` clause of an object O that is a member of a peer group is evaluated only if, for each member O' of the same peer group, and each I < N, the I'th `@invar` clause of O' evaluated to `true`. So, for example, if the second `@invar` clause of some class calls a method on the `foo` field of a peer object, this is fine provided that the first `@invar` clause of the peer object's class says that `foo` is non-null.

#### Advanced topics

You need not read or apply this section if you are not going for a top score.

To achieve a complete specification of the behavior of a method or constructor, the `@peerObject` and `@peerObjects` clauses should be used to define an object's peer group, and the `@mutates`, `@mutates_properties`, and `@inspects` clauses should be used to indicate which pre-existing peer groups are mutated and inspected by the method or constructor, and the `@creates` clause should be used to indicate which peer groups that are visible to the client after the method or constructor finishes were created by the method or constructor.

For more information about peer groups, see the course notes on [Entity-relationship abstractions](entity_relationship_abstractions.md).

##### Mutates clauses

A method must not mutate any pre-existing peer groups not mentioned in its `@mutates` clause and not used to represent the state of any peer groups mentioned in its `@mutates` clause. That is, an execution of a method may mutate an object O if and only if either O was newly created during the method execution (i.e. it did not exist when the method execution started), or a member of O's peer group is mentioned in the method's `@mutates` clause, or O is a member of the peer group of a representation object of a member of the peer group of an object mentioned in the method's `@mutates` clause, or O is a member of the peer group of a representation object of a member of the peer group of a representation object of a member of the peer group of an object mentioned in the method's `@mutates` clause, and so forth.

##### `@mutates_properties` clauses

If a peer group is mentioned in a `@mutates` clause, then the new state of the peer group must be specified using postconditions. In general, the constructor or method's postconditions must (explicitly or by implication) specify the new return value of each getter of each member of the peer group. If most objects' getters' return values remain unchanged, and for the objects whose getters' return values do not all remain unchanged, most getters' return values do remain unchanged, one can use a `@mutates_properties` clause.

The clause `@mutates_properties | O1.M1(), O2.M2()` is equivalent to `@mutates | O1, O2` plus a postcondition that states that for each object O in the union of the peer group of O1 and O2, and for each basic inspector M of O, either (O, M) is in the set {(O1, M1), (O2, M2)} or `Objects.equals(O.M(), old(O.M()))`. A basic inspector is a getter that does not have a postcondition of the form `result == E` or `result.equals(E)` or `Objects.equals(result, E)` for some expression E.

##### Inspects clauses

Similarly, a method must not inspect the state of any pre-existing *mutable* objects that are not in the peer group of any object mentioned in its `@inspects` or `@mutates` clause and not used to represent the state of any objects mentioned in its `@inspects` or `@mutates` clause.

##### Defaults

If no `@mutates`, `@mutates_properties`, or `@inspects` clause is specified for a given method or constructor, the default is that it may inspect and mutate any object that is not an instance of an immutable class. Exception: if an instance method's name starts with `get` or `is`, the default is that it may mutate no object and that it may inspect `this`.

##### Creates clauses

By specifying an object in a `@creates` clause, you indicate that every member of the object's peer group was created during the execution of the method, and furthermore, that the peer group is disjoint from that of any direct or indirect representation object of any peer group mentioned in any of the method's `@inspects` or `@mutates` clauses.

##### Specifying collections of objects

One can specify a collection of objects in a `@mutates`, `@mutates_properties`, `@inspects`, or `@creates` clause using the `...collection` syntax:
```java
/**
 * @inspects | lists, strings
 * @mutates | ...lists
 */
static void allAddAll(StringList[] lists, String[] strings) {
    for (StringList list : lists)
        list.addAll(strings);
}

/**
 * @inspects | lists, ...lists
 */
static boolean anyIsEmpty(StringList[] lists) {
    for (StringList list : lists)
        if (list.getElements().length == 0)
            return true;
    return false;
}

class Rectangle {

    private int width;
    private int height;

    public int getWidth() { return width; }

    public int getHeight() { return height; }

    /** @post | result == getWidth() * getHeight() */
    public int getArea() { return width * height; }

    /**
     * @mutates_properties | getWidth()
     * @post | getWidth() == newWidth
     */
    public void setWidth(int newWidth) { width = newWidth; }

    /**
     * @inspects rectangles
     * @mutates_properties | (...rectangles).getWidth()
     * @post | Arrays.stream(rectangles).allMatch(r -> r.getWidth() == newWidth)
     */
    public static void allSetWidth(Rectangle[] rectangles, int newWidth) {
        for (Rectangle rectangle : rectangles)
            rectangle.setWidth(newWidth);
    }

}
```
