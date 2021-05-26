# Representation Objects and Representation Exposure

In a data abstraction, each instance of the class that implements the abstraction is associated conceptually with a particular *abstract state*. In the case of a mutable abstraction, this association can change over time; in the case of an immutable abstraction, it is fixed upon creation of the object. Clients can use getter methods to inspect an object's abstract state. In order for the class to be able to implement these getter methods, it must store some concrete *representation* of the object's abstract state in the computer's memory. For example, in order for class `Interval` to be able to implement methods `getLowerBound()`, `getUpperBound()`, and `getWidth()`, it must store sufficient information to be able to derive an `Interval` object's lower bound, upper bound, and width in the computer's memory. One example implementation of class `Interval` that we have seen stores an `Interval` object's lower bound and width in *fields* of the object. We call these fields, and the way they relate to the object's abstract state, the object's *representation*. Usually, there are many different possible ways to design the represention for a given abstraction: for example, another example implementation of class `Interval` that we have seen stores an `Interval` object's lower bound and upper bound, rather than its lower bound and width.

In the example data abstraction implementations we have seen so far, such as `Interval`, `TimeOfDay`, `Fraction`, and `FractionContainer`, the class that implements the abstraction exclusively uses the fields of an instance to store its abstract state. However, in most cases, the fields of an object are not sufficient to store the object's abstract state. In those cases, the class must use auxiliary objects, known as *representation objects*, to help represent the object's abstract state.

In this chapter, we first use the example of a `String` class to introduce the concept of representation objects, and to show how *representation exposure* can break immutability. Then, we use a `FractionList` example to show how representation exposure can break consistency of an abstraction's representation. Finally, we use a `ByteBuffer` example to show how representation exposure can break modular reasoning.

## Strings

For example, consider (an extract from) the API of class `String` from the Java Platform API:

```java
/**
 * Each instance of this class represents a sequence of text characters.
 *
 * @immutable
 */
public class String {

    /**
     * Returns the length of the sequence of characters represented by this object.
     *
     * @post | 0 <= result
     */
    public int length()

    /**
     * Returns the character at the given index in the sequence of characters
     * represented by this object. The first character is at index 0.
     *
     * @throws IndexOutOfBoundsException if the given index is less than zero or
     *         not less than the length of this object.
     *    | index < 0 || length() <= index
     */
    public char charAt(int index)

    /**
     * Returns a `String` object of length 1 containing the single given character.
     *
     * @post | result != null
     * @post | result.length() == 1
     * @post | result.charAt(0) == c
     */
    public static String valueOf(char c)

    /**
     * Returns a `String` object that represents the sequence of characters
     * obtained by concatenating the sequence of characters represented by this
     * object and the given object, respectively.
     *
     * @throws NullPointerException | other == null
     * @post | result != null
     * @post | result.length() == length() + other.length()
     * @post | IntStream.range(0, length()).allMatch(i ->
     *       |     result.charAt(i) == charAt(i))
     * @post | IntStream.range(0, other.length()).allMatch(i ->
     *       |     result.charAt(length() + i) == other.charAt(i))
     */
    public String concat(String other)

}
```

For example, the expression `String.valueOf('H').concat(String.valueOf('i')).concat(String.valueOf('!'))` yields a `String` object that represents the sequence of characters `Hi!`. (An equivalent `String` object can be written more concisely using the expression `"Hi!"`. Also, concatenation of `String` objects can be written more concisely using the `+` operator; another equivalent expression is therefore `String.valueOf('H') + String.valueOf('i') + String.valueOf('!')`.)

It is impossible to represent the abstract value of a `String` object using just the fields of the object: a class with N fields can store at most N values, and a `String` object must be able to store arbitrarily many characters. Therefore, any implementation of class `String` must necessarily use auxiliary objects to help represent its state.

The following implementation of class `String` uses an auxiliary array object to store the characters of the string:

```java
/**
 * Each instance of this class represents a sequence of text characters.
 *
 * @immutable
 */
public class String {

    /**
     * @invar | characters != null
     *
     * @representationObject
     */
    private final char[] characters;

    private String(char[] characters) {
        this.characters = characters;
    }

    /**
     * Returns the length of the sequence of characters represented by this object.
     *
     * @post | 0 <= result
     */
    public int length() {
        return characters.length;
    }

    /**
     * Returns the character at the given index in the sequence of characters
     * represented by this object. The first character is at index 0.
     *
     * @throws IndexOutOfBoundsException if the given index is less than zero
     *         or not less than the length of this object.
     *    | index < 0 || length() <= index
     */
    public char charAt(int index) {
        if (index < 0 || length() <= index)
            throw new IndexOutOfBoundsException();
        return characters[index];
    }

    /**
     * Returns a `String` object of length 1 containing the single given character.
     *
     * @post | result != null
     * @post | result.length() == 1
     * @post | result.charAt(0) == c
     */
    public static String valueOf(char c) {
        return new String(new char[] {c});
    }

    /**
     * Returns a `String` object that represents the sequence of characters
     * obtained by concatenating the sequence of characters represented by this
     * object and the given object, respectively.
     *
     * @throws NullPointerException | other == null
     * @post | result != null
     * @post | result.length() == length() + other.length()
     * @post | IntStream.range(0, length()).allMatch(i ->
     *       |     result.charAt(i) == charAt(i))
     * @post | IntStream.range(0, other.length()).allMatch(i ->
     *       |     result.charAt(length() + i) == other.charAt(i))
     */
    public String concat(String other) {
        char[] cs = new char[characters.length + other.characters.length];
        System.arraycopy(characters, 0, cs, 0, characters.length);
        System.arraycopy(other.characters, 0, cs, characters.length,
            other.characters.length);
        return new String(cs);
    }

}
```

After a `String` object S has been initialized, field `S.characters` points to an array object, let's call it A, that stores the abstract value of S. We call A a *representation object* of S.

Notice that the existence of A is completely invisible to clients of S: the API of class `String` provides no means for clients to obtain a reference to an instance's representation object. We say the representation object is *encapsulated*. 

## Representation Exposure

Let's see what happens if we break encapsulation. Here is a first attempt to add a method `toCharArray` to class `String`:
```java
    /**
     * Returns an array containing the sequence of characters represented by this
     * object.
     *
     * @post | result != null
     * @post | result.length == length()
     * @post | IntStream.range(0, length()).allMatch(i ->
     *       |     result[i] == charAt(i))
     */
    public char[] toCharArray() {
        return characters;  // WRONG! Representation exposure
    }
```
Although this method satisfies its postconditions, it is still wrong. This is because it *leaks* the receiver object's representation object; it *exposes* the representation object to clients. This is wrong because it allows clients to perform inappropriate mutations of the abstract value of the `String` object by mutating the representation object. That is, it allows clients to break the immutability of the `String` object:
```java
String a = String.valueOf('a');
assert a.charAt(0) == 'a'; // Succeeds
a.toCharArray()[0] = 'b';
assert a.charAt(0) == 'a'; // Fails
```
An immutable class is only considered properly encapsulated if it protects its immutability; that is, it must not allow clients to mutate its abstract value in any way. This implies, among other things, that it must encapsulate its representation objects; that is, it must not leak or expose them to its clients.

A correct way to implement method `toCharArray` is by returning a copy of the representation object:
```java
    /**
     * Returns a new array containing the sequence of characters represented by
     * this object.
     *
     * @creates | result
     * @post | result != null
     * @post | result.length == length()
     * @post | IntStream.range(0, length()).allMatch(i ->
     *       |     result[i] == charAt(i))
     */
    public char[] toCharArray() {
        return characters.clone();
    }
```
Notice the following:
- Any array can be copied by calling its `clone()` method. This creates a new array with the same element type and the same elements.
- We made it explicit in the documentation of method `toCharArray` that the returned array has been newly created by the method. Tag `@creates | result` means that `result` has been newly created by the method, and furthermore that it is not a representation object of the receiver object or of any other object. The client can therefore safely mutate it without affecting any other object's abstract state.
- Our implementation of class `String` uses array objects for two very different purposes: to represent a `String` object's abstract state, and as a container for a sequence of characters to be returned as the result of a method call. It is crucial to always use separate objects for these two different purposes.

## Representation Exposure without Leaking

A class must never leak its representation objects. But not leaking representation objects is not sufficient to prevent representation exposure. Additionally, a class must never use pre-existing client-visible objects as representation objects. For example, here is a first attempt to add a method `valueOf(char[])` to class `String`:

```java
    /**
     * Returns a `String` object whose sequence of characters equals the
     * sequence of characters stored in the given array.
     *
     * @throws NullPointerException | characters == null
     * @inspects | characters
     * @post | result != null
     * @post | result.length() == characters.length
     * @post | IntStream.range(0, characters.length)
     *       |     .allMatch(i -> result.charAt(i) == characters[i])
     */
    public static String valueOf(char[] characters) {
        return new String(characters); // WRONG! Client-supplied object
                                       // used as representation object.
    }
```

This method passes the client-supplied array `characters` to the `String` constructor, which installs its argument as the representation object for the new `String` object. As a result, the client can mutate the new `String` object's abstract state by mutating the array object:
```java
char[] cs = {'a'};
String a = String.valueOf(cs);
assert a.charAt(0) == 'a'; // Succeeds
cs[0] = 'b';
assert a.charAt(0) == 'a'; // Fails
```

A correct way to implement the `valueOf(char[])` method is by copying the argument:
```java
    /**
     * Returns a `String` object whose sequence of characters equals the
     * sequence of characters stored in the given array.
     *
     * @throws NullPointerException | characters == null
     * @inspects | characters
     * @post | result != null
     * @post | result.length() == characters.length
     * @post | IntStream.range(0, characters.length)
     *       |     .allMatch(i -> result.charAt(i) == characters[i])
     */
    public static String valueOf(char[] characters) {
        return new String(characters.clone());
    }
```

Here, too, arrays are used for two different purposes: to represent a `String` object's abstract state, and to contain a sequence of characters to be passed as an argument to a method call. It is crucial to always use separate objects for these two different purposes.

## FractionLists: Representation Exposure Breaks Consistency

We have seen that immutable classes must encapsulate their representation object to protect their immutability. There is another important reason why classes must encapsulate their representation objects. We illustrate it by means of the following `FractionList` example.

```java
/**
 * Each instance of this class stores a list of fractions.
 */
public class FractionList {

    /**
     * @invar | elements != null
     * @invar | Arrays.stream(elements).allMatch(element -> element != null)
     *
     * @representationObject
     */
    private Fraction[] elements;

    /**
     * Returns the number of elements in the list of fractions stored by this
     * object.
     *
     * @post | 0 <= result
     */
    public int getSize() {
        return elements.length;
    }

    /**
     * Returns the element at the given index in the list of fractions stored by
     * this object.
     *
     * @throws IndexOutOfBoundsException | index < 0 || getSize() <= index
     */
    public Fraction getElementAt(int index) {
        if (index < 0 || getSize() <= index)
            throw new IndexOutOfBoundsException();

        return elements[index];
    }

    /**
     * Returns the sum of the elements of the list of fractions stored by this
     * object.
     *
     * @post | Objects.equals(result,
     *       |     IntStream.range(0, getSize())
     *       |         .mapToObj(i -> getElementAt(i))
     *       |         .reduce(Fraction.ZERO, (x, y) -> x.plus(y)))
     */
    public Fraction getSum() {
        return Arrays.stream(elements).reduce(Fraction.ZERO, (x, y) -> x.plus(y));
    }

    /**
     * Initializes this object to store an empty list of fractions.
     *
     * @post | getSize() == 0
     */
    public FractionList() {
        elements = new Fraction[0];
    }

    /**
     * Adds the given element to the end of the list of fractions stored by this
     * object.
     *
     * @throws NullPointerException | element == null
     * @mutates | this
     * @post | getSize() == old(getSize()) + 1
     * @post | Arrays.equals(
     *       |     IntStream.range(0, old(getSize()))
     *       |         .mapToObj(i -> getElementAt(i)).toArray(),
     *       |     old(IntStream.range(0, getSize())
     *       |         .mapToObj(i -> getElementAt(i)).toArray()))
     * @post | Objects.equals(getElementAt(old(getSize())), element)
     */
    public void add(Fraction element) {
        if (element == null)
            throw new IllegalArgumentException("element is null");

        Fraction[] newElements = new Fraction[elements.length + 1];
        System.arraycopy(elements, 0, newElements, 0, elements.length);
        newElements[elements.length] = element;
        elements = newElements;
    }

}
```

Suppose, now, that we want to add a method for retrieving an array containing a `FractionList` object's list of fractions. Here is a first attempt at adding such a method:
```java
    public Fraction[] getElements() {
        return elements; // WRONG! Leaks representation object.
    }
```
This method leaks the receiver object's representation object to the client. Even though class `FractionList` is a mutable class, this is still wrong, because this allows clients to break the `FractionList` object's *representation invariants*. In other words, it allows clients to bring the `FractionList` object into an *inconsistent state*. Specifically, it allows clients to introduce `null` elements into the representation object:
```java
FractionList myList = new FractionList();
myList.add(Fraction.ZERO);
Fraction[] elements = myList.getElements();
elements[0] = null;
// Object myList is now in an inconsistent state
myList.getSum(); // crashes with a NullPointerException
```
Method `getSum` relies on the receiver's representation invariants for its safe execution; indeed, running this method
after breaking the representation invariants causes the method to crash.

As before, we can fix this leak by copying the array:
```java
    /**
     * Returns a new array containing the list of fractions stored by this object.
     *
     * @creates | result
     * @post | Arrays.equals(result, IntStream.range(0, getSize())
     *       |     .mapToObj(i -> getElementAt(i)).toArray())
     */
    public Fraction[] getElements() {
        return elements.clone();
    }
```

## Modular Reasoning: `@mutates`

If a class is mutable and its representation invariants do not mention the mutable state of its representation object(s), then exposing representation object(s) does not endanger its immutability or its consistency. But even then, exposing representation object(s) is wrong, because it breaks modular reasoning, as we will illustrate next.

### ByteBuffer: first attempt (INCORRECT)

Consider the following INCORRECT attempt at designing and implementing an API for a `ByteBuffer` class.

```java
/**
 * Each instance of this class stores a sequence of bytes and an offset into that
 * sequence.
 */
public class ByteBuffer {

    /**
     * @invar | bytes != null
     * @invar | 0 <= offset
     */
    private byte[] bytes;
    private int offset;

    /**
     * Returns an array containing the sequence of bytes stored by this object.
     *
     * @post | result != null
     */
    public byte[] getBytes() { return bytes; }

    /**
     * Returns the offset stored by this object.
     *
     * @post | 0 <= result
     */
    public int getOffset() { return offset; }

    /**
     * Initializes this object so that it stores the given sequence of bytes and
     * offset zero.
     *
     * @throws IllegalArgumentException if the given array is null
     *    | bytes == null
     * @post | Arrays.equals(getBytes(), bytes)
     * @post | getOffset() == 0
     */
    public ByteBuffer(byte[] bytes) {
        if (bytes == null)
            throw new IllegalArgumentException("bytes is null");
        this.bytes = bytes;
    }

    /**
     * Writes the given byte into the sequence of bytes stored by this object
     * at the current offset, and increments the offset.
     *
     * @throws ArrayIndexOutOfBoundsException if the current offset is outside
     *         the bounds of the sequence of bytes stored by this object.
     *    | getBytes().length <= getOffset()
     * @mutates | this // WRONG!
     * @post | getOffset() == old(getOffset()) + 1
     * @post | getBytes().length == old(getBytes().length)
     * @post | getBytes()[old(getOffset())] == b
     * @post | IntStream.range(0, getBytes().length).allMatch(i ->
     *       |     i == old(getOffset()) || getBytes()[i] == old(getBytes())[i])
     */
    public void put(byte b) {
        this.bytes[offset] = b;
        offset++;
    }

}
```

Consider now the following client code:
```java
byte[] myBytes = {1, 2, 3};
ByteBuffer myBuffer = new ByteBuffer(myBytes);
assert myBytes[0] == 1; // Succeeds
myBuffer.put(4);
assert myBytes[0] == 1; // Fails
```
Calling method `put` on `myBuffer` mutates `myBytes`. Based on the documentation for method `put`, this is completely unexpected; indeed, method `put`'s `@mutates` clause asserts that the method mutates only `this`, i.e. `myBuffer` itself.

There are (at least) two possible ways to fix the `ByteBuffer` class, corresponding with two different design decisions, both of which are reasonable and useful and occur in practice. The relevant design question here is: do we want to hide the array that backs the `ByteBuffer` object from the client, or do we want the client to be aware of it? Both options have advantages and disadvantages: the former option leads to a more abstract and arguably simpler API; the latter option has better performance because it avoids the need to copy the array.

We show elaborations of both options below.

### ByteBuffer (opaque)

In this version of class `ByteBuffer`, the backing array is hidden from the client. This class is similar to Java's `ByteArrayOutputStream` class.

```java
/**
 * Each instance of this class stores a sequence of bytes and an offset into
 * that sequence.
 */
public class ByteBuffer {

    /**
     * @invar | bytes != null
     * @invar | 0 <= offset
     *
     * @representationObject
     */
    private byte[] bytes;
    private int offset;

    /**
     * Returns a new array containing the sequence of bytes stored by this object.
     *
     * @creates | result
     * @post | result != null
     */
    public byte[] getBytes() { return bytes.clone(); }

    /**
     * Returns the offset stored by this object.
     *
     * @post | 0 <= result
     */
    public int getOffset() { return offset; }

    /**
     * Initializes this object so that it stores the given sequence of bytes
     * and offset zero.
     *
     * @throws NullPointerException if the given array is null
     *    | bytes == null
     * @inspects | bytes
     * @post | Arrays.equals(getBytes(), bytes)
     * @post | getOffset() == 0
     */
    public ByteBuffer(byte[] bytes) {
        this.bytes = bytes.clone();
    }

    /**
     * Writes the given byte into the sequence of bytes stored by this object
     * at the current offset, and increments the offset.
     *
     * @throws ArrayIndexOutOfBoundsException if the current offset is outside
     *         the bounds of the sequence of bytes stored by this object.
     *    | getBytes().length <= getOffset()
     * @mutates | this
     * @post | getOffset() == old(getOffset()) + 1
     * @post | getBytes().length == old(getBytes().length)
     * @post | getBytes()[old(getOffset())] == b
     * @post | IntStream.range(0, getBytes().length).allMatch(i ->
     *       |     i == old(getOffset()) || getBytes()[i] == old(getBytes())[i])
     */
    public void put(byte b) {
        this.bytes[offset] = b;
        offset++;
    }

}
```

Notice that in this version, the `@mutates` clause of method `put` still only mentions `this`. This is fine, because the meaning of `@mutates | O` is that the method can mutate object `O` as well as any representation object of `O` (as well as the representation objects of those objects, if they have any, and so on). Since field `bytes` is marked as `@representationObject`, the array referenced by this field is considered a representation object of the `ByteBuffer` object. Since the representation objects of an object O must never become exposed to clients of O, the constructor and method `getBytes` must make the necessary copies. In return, the client can safely assume that when calling method `myBuffer.put`, none of the array objects it has references to are mutated:

```java
byte[] myBytes = {1, 2, 3};
ByteBuffer myBuffer = new ByteBuffer(myBytes);
assert myBytes[0] == 1; // Succeeds
myBuffer.put(4);
assert myBytes[0] == 1; // Succeeds

byte[] moreBytes = myBuffer.getBytes();
assert moreBytes[1] == 2; // Succeeds
myBuffer.put(5);
assert moreBytes[1] == 2; // Succeeds
```

### ByteBuffer (transparent)

In this version of class `ByteBuffer`, the client is aware of the backing array. Therefore, the backing array is *not* a representation object and the contents of the backing array are *not* part of the state of the `ByteBuffer` object. Here, the `ByteBuffer` object does not store a sequence of bytes; it merely stores a reference to an array object.

This class is similar to Java's `ByteBuffer` class.

```java
/**
 * Each instance of this class stores a reference to a byte array and an offset
 * into that array.
 */
public class ByteBuffer {

    /**
     * @invar | array != null
     * @invar | 0 <= offset
     */
    private byte[] array;
    private int offset;

    /**
     * Returns the array reference stored by this object.
     *
     * @post | result != null
     * @immutable This object is associated with the same array reference
     *            throughout its lifetime.
     */
    public byte[] getArray() { return array; }

    /**
     * Returns the offset stored by this object.
     *
     * @post | 0 <= result
     */
    public int getOffset() { return offset; }

    /**
     * Initializes this object to store the given array reference and offset zero.
     *
     * @throws IllegalArgumentException if the given array reference is null
     *    | array == null
     * @post | getArray() == array
     * @post | getOffset() == 0
     */
    public ByteBuffer(byte[] array) {
        if (array == null)
            throw new IllegalArgumentException("array is null");
        this.array = array;
    }

    /**
     * Writes the given byte into the referenced array at the current offset, and
     * increments the offset.
     *
     * @throws ArrayIndexOutOfBoundsException if the current offset is outside
     *         the bound of the referenced array.
     *     | getArray().length <= getOffset()
     * @mutates | this, getArray()
     * @post | getOffset() == old(getOffset()) + 1
     * @post | getArray()[old(getOffset())] == b
     * @post The elements of the array referenced by this object, except for the
     *       element at the old offset, have remained unchanged.
     *    | IntStream.range(0, getArray().length).allMatch(i ->
     *    |     i == old(getOffset())
     *    |     || getArray()[i] == old(getArray().clone())[i])
     */
    public void put(byte b) {
        this.array[offset] = b;
        offset++;
    }

}
```

Notice that method `put` must mention both `this` *and* `getArray()` in its `@mutates` clause; this way, the client will not be surprised when its array object is mutated:
```java
byte[] myBytes = {1, 2, 3};
ByteBuffer myBuffer = new ByteBuffer(myBytes);
assert myBytes[0] == 1; // Succeeds
myBuffer.put(4);
assert myBytes[0] == 4; // Succeeds, as expected:
                        // `myBuffer.put()` mutates `myBuffer.getArray()`
                        // a.k.a. `myBytes`

byte[] moreBytes = myBuffer.getArray();
assert moreBytes[1] == 2; // Succeeds
myBuffer.put(5);
assert moreBytes[1] == 5; // Succeeds, as expected
```

## Conclusion

In this chapter, we introduced the notion of representation objects: objects used internally by an abstraction to help represent an instance's abstract state. We showed by means of three examples (`String`, `FractionList`, and `ByteBuffer`) that it is crucial that representation objects never be *exposed* to clients, since doing so can break immutability of the abstraction, consistency of the abstraction's representation, and/or modular reasoning about the abstraction by clients. If an object used by an abstraction is exposed to clients, it is not a representation object of the abstraction, its state is not a part of the state of the abstraction, and methods that mutate it must declare this explicitly in their `@mutates` clause.
