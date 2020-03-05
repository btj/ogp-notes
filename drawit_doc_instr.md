# DrawIt Project: Documentation Instructions

The `.java` files you submit as your solution for Part 1 of the project assignment should include Javadoc comments providing complete informal and formal documentation for the public classes and their public members. 

Exceptions:
- You need not provide any documentation for classes `DoublePoint` and `DoubleVector` or its members
- You need not provide formal documentation for the return value of `IntPoint.lineSegmentsIntersect`.
- You need to provide formal documentation for the return value of `IntPoint.isOnLineSegment` only if you are going for a top score
- You need to deal with method arguments that cause arithmetic overflow as illegal arguments only if you are going for a top score. That is, you need to treat as illegal arguments some set of argument values that includes the argument values that cause arithmetic overflow. You may treat additional argument values as illegal as well; just make sure that those argument values that occur in actual executions of the DrawIt application are not treated as illegal.
- You need not provide formal documentation for method `IntVector.asDoubleVector`.
- You need not provide formal documentation for the return values of `RoundedPolygon.contains` and `RoundedPolygon.getDrawingCommands`.
- You need not document which exact string is returned by `PointArrays.checkDefinesProperPolygon`; your documentation only needs to specify when the return value is `null` and when it is not `null`.

Note: the OGP Taglets do not support all of the Javadoc tags described here. This is not a problem, since you do not need to generate or submit HTML files; you need to submit only the `.java` files themselves. Detailed submission instructions follow later.

## How to write complete documentation

### Class documentation

If a class implements an immutable abstraction, which implies that the properties of an instance of the class do not change throughout the lifetime of the instance, then you shall include an `@immutable` tag in the Javadoc comment for the class.

If not all possible values of the return types of the inspectors of a class are valid abstract values for the instances of the class, then you shall describe the set of valid abstract values by means of one or more `@invar` clauses in the Javadoc comment for the class. These specify the class' _public class invariants_.

For example, see the following documentation for an immutable `TimeOfDay` class:
```java
/**
 * Each instance of this class represents a time of day, at one-minute resolution.
 *
 * @immutable
 * @invar This object's hours are between 0 and 23
 *    | 0 <= getHours() && getHours() <= 23
 * @invar This object's minutes are between 0 and 59
 *    | 0 <= getMinutes() && getMinutes <= 59
 */
public class TimeOfDay {

    /**
     * @invar | 0 <= hours && hours <= 23
     * @invar | 0 <= minutes && minutes <= 59
     */
    private final int hours;
    private final int minutes;

    public int getHours() { return hours; }
    public int getMinutes() { return minutes; }

    /**
     * Initializes this object with the given hours and minutes.
     * 
     * @mutates | this
     *
     * @throws IllegalArgumentException if the given hours are not between 0
     *         and 23
     *    | !(0 <= hours && hours <= 23)
     * @throws IllegalArgumentException if the given minutes are not between 0
     *         and 59
     *    | !(0 <= minutes && minutes <= 59)
     *
     * @post This object's hours equal the given hours
     *    | getHours() == hours
     * @post This object's minutes equal the given minutes
     *    | getMinutes() == minutes
     *
     */
    public TimeOfDay(int hours, int minutes) {
        if (!(0 <= hours && hours <= 23))
            throw new IllegalArgumentException("hours out of range");
        if (!(0 <= minutes && minutes <= 59))
            throw new IllegalArgumentException("minutes out of range");
        this.hours = hours;
        this.minutes = minutes;
    }

    /**
     * Returns whether this time is before the given time.
     *
     * @pre Argument {@code other} is not {@code null}.
     *    | other != null
     * @post
     *      The result is {@code true} iff either this object's hours are less
     *      than the given object's hours, or this object's hours equal the
     *      given object's hours and this object's minutes are less than the
     *      given object's minutes.
     *    | result == (
     *    |     getHours() < other.getHours() ||
     *    |     getHours() == other.getHours() &&
     *    |         getMinutes() < other.getMinutes()
     *    | )
     */
    public boolean isBefore(TimeOfDay other) {
        return
            hours < other.hours ||
            hours == other.hours && minutes < other.minutes;
    }
}
```

Note: the fields in the above example are marked as `final`. This causes the Java compiler to check that they are mutated only in the class' constructor. It is recommended to mark the fields of immutable classes as `final`.

If a class exists only to contain static methods, and is not intended to be instantiated, you shall declare a private constructor to ensure that no public constructor is implicitly generated.

Note: the Formal Specifications Checker for Java does not yet check public invariants.

### Fields documentation

All fields of all classes shall be marked as `private`.

If not all possible values of the types of the fields of a class represent a valid abstract state of an instance of the class, then you shall describe the set of valid representations by means of one or more `@invar` clauses in the Javadoc comments for the fields of the class. These specify the class' _private class invariants_, also called its _representation invariants_. (It does not matter which `@invar` clauses are in the Javadoc comment for which field; a reasonable approach is to specify all `@invar` clauses in the Javadoc comment preceding the entire block of fields.)

The above `TimeOfDay` example illustrates this.

Note: the Formal Specifications Checker for Java does not yet check representation invariants.

### Constructors and methods documentation

If not all possible values of the types of the parameters of a constructor or method are legal values, you shall deal with this either defensively or contractually.

- In classes `IntPoint`, `IntVector`, and `PointArrays`, you shall deal with illegal arguments contractually.
- In class `RoundedPolygon`, you shall deal with illegal arguments defensively.

#### Defensive programming

In defensive programming, you write code at the start of the method body to check if the arguments are legal. If not, you throw an `IllegalArgumentException` object. You include one or more `@throws` clauses in the constructor or method's Javadoc comment to specify the conditions under which the constructor or method throws particular types of exceptions.

The constructor in the example above is programmed defensively.

Callers can rely on a method's `@throws` clauses: if the condition specified by a `@throws` clause is satisfied, the method must throw the specified exception; it is not allowed to return normally.

Note: the Formal Specifications Checker for Java does not yet check `@throws` clauses.

#### Contractual programming

In contractual programming, you do not write any code in the method body to check whether the arguments are legal; instead, you implement the method under the assumption that the arguments are legal. You include one or more `@pre` clauses in the Javadoc comment for the constructor or method to specify the conditions that must hold at the start of an execution of the method. These are called _preconditions_. If any of these conditions do not hold, the resulting behavior of the method is unspecified. It may crash or exhibit arbitrary undesired behavior. It is the caller's obligation to ensure that the called method's preconditions are satisfied.

The method `isBefore` in the example above is programmed contractually.

Defensive programming is safer than contractual programming, because it keeps programming errors in one module from leading to failures inside another module. Programming errors are detected earlier and are easier to diagnose. Therefore, it is generally the recommended approach. However, in some cases the performance cost of the defensive checks is unacceptable. In these cases, contractual programming is necessary.

Even when programming contractually, it is recommended to check the preconditions at run time during development, and to turn the checks off only when necessary. Java supports this approach through the `assert` statement: execution of an `assert E;` statement, where `E` is a boolean expression, evaluates `E` and throws an `AssertionError` if it evaluates to `false`, but only if assertions are enabled. Assertions are enabled by default when using "Run as JUnit Test" in Eclipse, but they are disabled by default when using "Run as Java Application". To enable assertions, open the Run Configuration and add `-enableassertions` or `-ea` to the VM Arguments. It is recommended to disable assertions only if they cause unacceptable performance degradation.

It is possible to disable only the assertions in a particular class, by using the VM Arguments `-ea -da:mypackage.MyClass`, or in a particular package (and its subpackages), by using the VM Arguments `-ea -da:mypackage...`.

When using the Formal Specifications Checker for Java, `assert` statements that check a method or constructor's preconditions and postconditions are added to the method or constructor body implicitly.

#### Postconditions

You shall precisely specify the result and the side-effects of each constructor
and each method, by including one or more `@post` clauses in the constructor or
method's Javadoc comment that specify the conditions that must hold when the
constructor or method returns. In these conditions, you can refer to the
method's result as `result`. If the method or constructor mutates any objects,
you must fully specify these objects' new abstract state. Often, to do so you
need to refer to their old abstract state. You can do so using `old(E)`
expressions. The body of an `old(E)` expression is evaluated at the start of
the execution of the method.

The rule above implies that you must always explicitly declare at least one
constructor for each public class. Otherwise, Java would implicitly add a
default constructor, and there would be no way for you to document its
behavior.

For example:

```java
import java.util.Arrays;
import java.util.stream.IntStream;

/**
 * Each instance of this class stores a list of text strings.
 */
public class StringList {

    /**
     * @invar | elements != null
     * @invar | Arrays.stream(elements).allMatch(e -> e != null)
     * @representationObject
     */
    private String[] elements;

    /**
     * @creates | result
     * @post The result is not {@code null}
     *    | result != null
     * @post The result's elements are not {@code null}
     *    | Arrays.stream(result).allMatch(e -> e != null)
     */
    public String[] getElements() {
        return Arrays.copyOf(elements, elements.length);
    }

    /**
     * Initializes this object so that it stores an empty list of text strings.
     *
     * @mutates | this
     * @post This object's list of text strings is empty.
     *    | getElements().length == 0
     */
    public StringList() {
        elements = new String[0];
    }

    /**
     * Replaces each element of this object by the text string obtained by
     * replacing each character of the element by its corresponding uppercase
     * letter.
     *
     * @mutates | this
     * @post This object's number of elements equals its old number of elements.
     *    | getElements().length == old(getElements()).length
     * @post Each of this object's elements equals its old element at the same
     *       index after replacing each character by the corresponding
     *       uppercase letter.
     *    | IntStream.range(0, getElements().length).allMatch(i ->
     *    |     getElements()[i].equals(old(getElements())[i].toUpperCase()))
     */
    public void allToUpperCase() {
        for (int i = 0; i < elements.length; i++)
            elements[i] = elements[i].toUpperCase();
    }

    /**
     * Adds the given text strings to the end of this object's list of
     * text strings.
     *
     * @mutates | this
     * @inspects | other
     *
     * @throws IllegalArgumentException if argument {@code other} is 
     *         {@code null}
     *    | other == null
     * @throws IllegalArgumentException if the elements of the given array
     *         are {@code null}
     *    | Arrays.stream(other).anyMatch(e -> e == null)
     *
     * @post This object's number of elements equals its old number of
     *       elements plus the number of given text strings.
     *    | getElements().length == old(getElements()).length + other.length
     * @post This object's old elements have remained unchanged.
     *    | Arrays.equals(getElements(), 0, old(getElements()).length,
     *    |     old(getElements()), 0, old(getElements()).length)
     * @post The given list of text strings is a suffix of this object's list
     *       of text strings.
     *    | Arrays.equals(
     *    |     getElements(), old(getElements()).length, getElements().length,
     *    |     other, 0, other.length)
     */
    public void addAll(String[] other) {
        if (other == null)
            throw new IllegalArgumentException("other is null");
        for (int i = 0; i < other.length; i++)
            if (other[i] == null)
                throw new IllegalArgumentException("other[" + i + "] is null");

        String[] newElements = new String[elements.length + other.length];
        System.arraycopy(elements, 0, newElements, 0, elements.length);
        System.arraycopy(other, 0, newElements, elements.length, other.length);
        elements = newElements;
    }
}
```

Notice the following:
- In this example, the constraint that method `getElements`'s result is not `null` and that its elements are not `null` is specified in the form of postconditions of method `getElement`. A correct alternative would be to specify it in the form of public class invariants. The choice between inspector method postconditions and public class invariants (or a combination of both) is a matter of style.
- `Arrays.stream(array).allMatch(e -> C)` expresses that condition `C` holds for each element `e` of array `array`. Similarly, `Arrays.stream(array).anyMatch(e -> C)` expresses that condition `C` holds for at least one element `e` of array `array`.
- `IntStream.range(a, b).allMatch(i -> C)` expresses that condition `C` holds for each integer `i` between `a` (inclusive) and `b` (exclusive).
- `Arrays.equals(array1, from1, to1, array2, from2, to2)` expresses that the list of elements of `array1` at indices `from1` (inclusive) to `to1` (exclusive) equals the list of elements of `array2` at indices `from2` (inclusive) to `to2` (exclusive).
- `string1.equals(string2)` expresses that `String` objects `string1` and `string2` represent the same list of characters. In contrast, `string1 == string2` expresses that `string1` and `string2` refer to the same `String` object.
- The notation `{@code text}` in an informal part of a Javadoc comment is used to indicate that `text` should be formatted as code rather than as natural language text.

### Expressions allowed inside Javadoc formal parts

Any side-effect-free, terminating boolean Java expressions are allowed in Javadoc formal parts. This includes calling side-effect-free methods and constructors of the program being documented. Of course, to achieve complete documentation those methods should themselves be documented properly. Also, be careful not to create infinite recursions this way. 

In this context, an expression, method or constructor is side-effect-free if it does not mutate any pre-existing objects. Creating and initializing new objects is allowed. (Also, of course a constructor is allowed to mutate `this`.)

Note, however, that in the Javadoc comment for class or class member X, you can refer to another class or class member Y only if Y is visible to any code that can see X. For example, in the Javadoc comment for a public method of a public class, you cannot refer to private fields or methods of that class or to any non-public classes, constructors or methods in the same package.

Note also that evaluation of Javadoc formal parts must never crash, i.e. throw an Exception. If evaluation of a Javadoc formal part crashes, the documentation is considered incorrect. For example, removing the first `@throws` clause in the documentation for method `addAll` above would lead to incorrect documentation, because calling `addAll` with a `null` argument would then cause the `Arrays.stream` call in the second `@throws` clause to throw a `NullPointerException`.

(Note: This rule implies that evaluation of a Javadoc formal part must never lead to calling a method with arguments that violate that method's preconditions. Indeed, the behavior of such a call is completely unspecified so it might throw an Exception. This means that it is **not** the case that a method M automatically inherits the preconditions of methods M' called in M's preconditions.)

### Advanced topics

You need not read or apply this section if you are not going for a top score.

To achieve a complete specification of the behavior of a method or constructor, the `@mutates` and `@inspects` clauses should be used to indicate which pre-existing objects are mutated and inspected by the method or constructor, and the `@creates` clause should be used to indicate which objects that are visible to the client after the method or constructor finishes were created by the method or constructor.

#### Mutates clauses

A method must not mutate any pre-existing objects not mentioned in its `@mutates` clause and not used to represent the state of any objects mentioned in its `@mutates` clause. That is, an execution of a method may mutate an object O if and only if either O was newly created during the method execution (i.e. it did not exist when the method execution started), or O is mentioned in the method's `@mutates` clause, or O is a representation object of an object mentioned in the method's `@mutates` clause, or O is a representation object of a representation object of an object mentioned in the method's `@mutates` clause, and so forth.

An object O is a representation object of another object O' if a field marked `@representationObject` of O' holds a reference to O. For example, a `StringList` object's `elements` array is a representation object of the `StringList` object. This is why method `allToUpperCase` can mutate the array object, even though it is not mentioned by the method's `@mutates` clause.

#### Inspects clauses

Similarly, a method must not inspect the state of any pre-existing *mutable* objects not mentioned in its `@inspects` or `@mutates` clause and not used to represent the state of any objects mentioned in its `@inspects` or `@mutates` clause.

Instances of immutable classes need not be mentioned in `@inspects` clauses.

(Documenting which objects are inspected by a method is important for at least two reasons: 1) the caller must ensure that the inspected objects are in a valid state, i.e. their representation invariants hold; 2) in a multithreaded program, no other thread must mutate the inspected objects.)

#### Defaults

If no `@mutates` or `@inspects` clause is specified for a given method or constructor, the default is that it may inspect and mutate any object that is not an instance of an immutable class. Exception: if an instance method's name starts with `get` or `is`, the default is that it may mutate no object and that it may inspect `this`.

Each of these clauses takes a comma-separated list of zero or more expressions that should evaluate to an object. If an expression evaluates to `null`, it is ignored.

Obviously, it is an error to specify an instance of an immutable class in a `@mutates` clause.

#### Creates clauses

By specifying an object in a `@creates` clause, you indicate that the object was created during the execution of the method, and furthermore, that the object is distinct from any direct or indirect representation object of any object mentioned in any of the method's `@inspects` or `@mutates` clauses.

The purpose is to allow the client to conclude that the object will not be inspected or mutated by any future method calls that mutate or inspect pre-existing objects.

Objects created by a method or constructor that do not become visible to the client when the method or constructor finishes need not (and cannot) be mentioned in a `@creates` clause.
