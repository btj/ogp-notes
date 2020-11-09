# Set, SortedSet, and behavioral subtyping

## The problem

The documentation of the Set interface from [Lists, sets, and maps](collections.md) does not specify any preconditions for method `add`, other than that the value must not be `null`.

Suppose we define an interface SortedSet that extends Set and that specifies a precondition `value instanceof Comparable` for method `add`. Does this satisfy behavioral subtyping? The answer is: no; such a SortedSet interface would not be a behavioral subtyping of interface Set as defined in [Lists, sets, and maps](collections.md). Indeed, for SortedSet to be a behavioral subtype of Set, the specification of each method of interface SortedSet would have to strengthen the corresponding method in interface Set (if any). Specifically, the specification of method `add` in SortedSet would have to strengthen the specification of `add` in Set. This implies that the precondition of `add` in SortedSet would have to be weaker than the precondition of `add` in Set. The condition `value instanceof Comparable`, however, is not weaker than `value != null`; it is stronger.

Indeed, it is not the case that every conceivable method that implements the specification of `add` in SortedSet also implements the specification of `add` in Set. Specifically, consider a method that crashes if the argument is not an instance of Comparable. Such a method would (potentially) implement the specification of `add` in SortedSet, but it would not implement the specification of `add` in Set.

## Possible solutions

### Generics

There are multiple possible solutions. The simplest solution would be to use generics. This means that we would define interface Set to have a type parameter E, and we would define method `add` with parameter type E:

```java
package collections;

import java.util.Arrays;
import java.util.stream.Stream;

/**
 * @invar The set has no null elements.
 *     | Arrays.stream(toArray()).allMatch(e -> e != null)
 * @invar {@code toArray()} does not contain duplicates.
 *     | Arrays.stream(toArray()).distinct().count() == size()
 */
public interface Set<E> {

    /**
     * @inspects | this
     * @creates | result
     * @post | result != null
     */
    Object[] toArray();
    
    default Stream<Object> stream() { return Arrays.stream(toArray()); } 

    /**
     * @inspects | this
     * @post | result == toArray().length
     */
    int size();

    /**
     * @pre | value != null
     * @inspects | this
     * @post | result == Arrays.stream(toArray()).anyMatch(e -> e.equals(value))
     */
    boolean contains(Object value);
    
    /**
     * @pre | value != null
     * @mutates | this
     * @post The given value is in the set.
     *       | Arrays.stream(toArray()).anyMatch(e -> e.equals(value))
     * @post No elements have disappeared from the set.
     *       | Arrays.stream(old(toArray())).allMatch(eo ->
     *       |     Arrays.stream(toArray()).anyMatch(e -> e.equals(eo)))
     * @post No elements, other than the given value, have been added.
     *       | Arrays.stream(toArray()).allMatch(e -> e.equals(value) ||
     *       |     Arrays.stream(old(toArray())).anyMatch(eo -> e.equals(eo)))
     */
    void add(E value);

    /**
     * @pre | value != null
     * @mutates | this
     * @post The given value is no longer in the set.
     *       | Arrays.stream(toArray()).noneMatch(e -> e.equals(value))
     * @post No elements, other than the given value, have disappeared
     *       from the set.
     *       | Arrays.stream(old(toArray())).allMatch(eo -> eo.equals(value) ||
     *       |     Arrays.stream(toArray()).anyMatch(e -> e.equals(eo)))
     * @post No elements have been added to the set.
     *       | Arrays.stream(toArray()).allMatch(e ->
     *       |     Arrays.stream(old(toArray())).anyMatch(eo -> e.equals(eo)))
     */
    void remove(Object value);
    
}
```
Notice, by the way, the following:
- Method `toArray`'s return type is still `Object[]`, not `E[]`. This is due to a limitation of Java known as *erasure*: type arguments are not available at run time, so it is not possible for method `toArray` to create an array with element type E.
- Just like in the [real Set interface](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/Set.html), parameter types of methods `contains` and `remove` are still `Object`. Indeed, passing an object that is not an instance of E to these methods is not incorrect. (The alternative design decision of using `E` as the parameter type would be a valid choice as well. Both options have advantages and disadvantages: if client code passes an object that is not an instance of E, this is probably a programming error, and using parameter type E would cause the compiler to catch this error. On the other hand, it is not always an error, so using parameter type E would rule out some valid use cases.)

We could then define interface SortedSet to take a type parameter E constrained to be a subtype of `Comparable<E>`:
```java
public interface SortedSet<E extends Comparable<E>> extend Set<E> { ... }
```
This expresses that each element of SortedSet must have a `compareTo` method with parameter type E.

In fact, it is also fine if each element of SortedSet has a `compareTo` method whose parameter type is a supertype of E, so the correct definition is as follows:
```java
public interface SortedSet<E extends Comparable<? super E>> extends Set<E> { ... }
```
This definition uses a *bounded wildcard* `? super E`.

We will introduce Java generics, including bounded type parameters and wildcards, in the final lecture of this course. You do not yet need to know these concepts.

## An eligibility predicate

The above approach, based on generics, is fine in the context of the exercise, but it does not correspond with [the real SortedSet interface](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/SortedSet.html). Notice that the real SortedSet interface's type parameter is not bounded. This is because elements have to implement interface Comparable only if no Comparator object was specified when the SortedSet object was created.

The question then arises: does the fact that the real SortedSet interface extend [the real Set interface](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/Set.html) in the Java Collections Framework satisfy behavioral subtyping? The answer is yes: if you read the documentation for the Set interface carefully, you will notice that the documentation for method `add` specifies that the method may refuse to add any particular element.

Can we adapt the definition of Set from [Lists, sets, and maps](collections.md) to reflect this? Of course, we could add a precondition `@pre | false` to the documentation for method `add`. This would allow us to define a SortedSet interface that is a behavioral subtype of Set, but it would not allow us to write any polymorphic code that adds elements to a Set object. In this approach, the Set interface might as well not have an `add` method at all.

A more powerful solution is to extend interface Set with the notion of an *eligibility predicate* that specifies which values are acceptable as elements of the Set:
```java
package collections;

import java.util.Arrays;
import java.util.stream.Stream;

/**
 * @invar The set has no null elements.
 *     | Arrays.stream(toArray()).allMatch(e -> e != null)
 * @invar {@code toArray()} does not contain duplicates.
 *     | Arrays.stream(toArray()).distinct().count() == size()
 * @invar All elements satisfy the eligibility predicate.
 *     | Arrays.stream(toArray()).allMatch(e -> getEligibilityPredicate().test(e))
 */
public interface Set {

    /**
	 * @post | result != null
	 * @immutable
	 */
    Predicate getEligibilityPredicate();

    /**
     * @inspects | this
     * @creates | result
     * @post | result != null
     */
    Object[] toArray();
    
    default Stream<Object> stream() { return Arrays.stream(toArray()); } 

    /**
     * @inspects | this
     * @post | result == toArray().length
     */
    int size();

    /**
     * @pre | value != null
     * @inspects | this
     * @post | result == Arrays.stream(toArray()).anyMatch(e -> e.equals(value))
     */
    boolean contains(Object value);
    
    /**
     * @pre | value != null
	 * @pre | getEligibilityPredicate().test(value)
     * @mutates | this
     * @post The given value is in the set.
     *       | Arrays.stream(toArray()).anyMatch(e -> e.equals(value))
     * @post No elements have disappeared from the set.
     *       | Arrays.stream(old(toArray())).allMatch(eo ->
     *       |     Arrays.stream(toArray()).anyMatch(e -> e.equals(eo)))
     * @post No elements, other than the given value, have been added.
     *       | Arrays.stream(toArray()).allMatch(e -> e.equals(value) ||
     *       |     Arrays.stream(old(toArray())).anyMatch(eo -> e.equals(eo)))
     */
    void add(Object value);

    /**
     * @pre | value != null
     * @mutates | this
     * @post The given value is no longer in the set.
     *       | Arrays.stream(toArray()).noneMatch(e -> e.equals(value))
     * @post No elements, other than the given value, have disappeared
     *       from the set.
     *       | Arrays.stream(old(toArray())).allMatch(eo -> eo.equals(value) ||
     *       |     Arrays.stream(toArray()).anyMatch(e -> e.equals(eo)))
     * @post No elements have been added to the set.
     *       | Arrays.stream(toArray()).allMatch(e ->
     *       |     Arrays.stream(old(toArray())).anyMatch(eo -> e.equals(eo)))
     */
    void remove(Object value);
    
}
```
This solution uses the interface Predicate defined as follows:
```java
public interface Predicate {
    /**
	 * @inspects | this, value
	 * @immutable
	 */
    boolean test(Object value);
}
```
We can now define a class IsComparablePredicate:
```java
public class IsComparablePredicate implements Predicate {
    /**
	 * @inspects nothing |
	 * @post | result == (value instanceof Comparable)
	 */
    public boolean test(Object value) { return value instanceof Comparable; }
}
```
Using this class, we can now define SortedSet as a behavioral subtype of Set:
```java
public interface SortedSet extends Set {

    @Override
    public IsComparablePredicate getEligibilityPredicate();

    ...

}
```
Notice the following:
- This solution allows us to write polymorphic client code that adds elements to a Set object, provided that the code has a precondition that specifies that the elements it adds are eligible.
- The [real Set interface](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/Set.html#add(E)) does not have a method `getEligibilityPredicate` or anything similar. However, we can still *imagine* that it has such a method for purposes of formal documentation. (Note: FSC4J does not (yet) support the use of such imaginary methods in documentation.)
