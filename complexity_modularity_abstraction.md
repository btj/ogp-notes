# Managing Complexity through Modularity and Abstraction

The question addressed by this course is: how can we manage the complexity of the task of building large software systems?

The approach we teach is an instance of a general approach for any complex task: _divide and conquer_. This means that we try to split the problem up into subproblems, such that 1) each subprogram is easier to solve than the overall problem, and 2) solving all of the subprograms yields a solution for the overall problem.

In the case of software development, this means trying to _decompose_ the system development task into a set of simpler subsystem development tasks, such that the resulting subsystems can be composed to yield a system that solves the overall task.

One of the most effective ways to come up with such a decomposition is to try to come up with effective _abstractions_. In this course, we teach two main types of abstractions: _procedural abstractions_ and _data abstractions_.

## Procedural abstractions

In the case of procedural abstractions, we try to identify _operations_ such that it would make the system development task easier if those operations were _built into the programming language_.

Only a very limited number of operations are built into the Java programming language: `+`, `-`, `*`, `/`, `%`, `<`, `>`, `<=`, `>=`, `==`, `!=`, `&&`, `||`, and the bitwise operators `&`, `|`, `^`, `<<`, `>>`, and `>>>`. Anything else you want to do in a Java program, you need to _implement_ in terms of these basic operations.

For example, if an application needs to perform square root computations, it will have to implement a square root operation in terms of addition, subtraction, etc. The complexity of building such an application, then, includes the complexity of implementing a square root implementation.

The life of the application's developers would have been easier if square root had been a primitive operation in the Java programming language. Building the application would have been a simpler task.

Procedural abstraction, then, means that we split the task of building such an application into two parts:
- building a _client module_ that implements the application on top of not Java, but Java++, an extension of Java with a built-in square root operation (whose syntax is `MyMath.squareRoot(...)`).
- building a _square root module_ whose only job is to implement the square root operation (i.e. to implement method `MyMath.squareRoot`) in terms of Java's built-in operations.

Each of these two tasks is easier than the overall task:
- The client module's developers do not have to worry about how to implement a square root operation.
- The square root module's developers do not have to worry about the application. They need not care if the application is implementing a web shop, a game, a bookkeeping system, or anything else. All they need to worry about is correctly implementing the square root operation.

Note that this decomposition will only be effective if the abstraction is defined sufficiently _precisely_ and _abstractly_.
- If the only way the client module's developers can figure out what `MyMath.squareRoot` does is by looking at its implementation, then their life has not been made much simpler. They are still confronted with the complexity of the square root implementation. For this reason, it is crucial that the abstraction implemented by a module and used by the client application (also known as the module's _Application Programming Interface_ or _API_) be _properly documented_. The API documentation must document sufficiently precisely and abstractly the operations provided by the module to its clients.
- Analogously, if the only way the square root module developers can figure out what the application expects `MyMath.squareRoot` to do is by looking at the application's implementation and by understanding what the application as a whole is supposed to do, then they are still confronted with the complexity of the entire application. In conclusion, proper documentation is necessary to achieve true reduction of complexity and _separation of concerns_.
- A module's documentation should not just be sufficiently precise. It should also be sufficiently _abstract_. If the documentation for the square root operation simply showed the implementation algorithm, again the client module developers' life would not have been made much easier. Again they would be confronted with the complexity of the implementation. A module's documentation must _hide_ the implementation complexity as much as possible and define the meaning of the API as simply as possible.

See below a proper way to document the square root module:
```java
/**
 * Returns the square root of the given nonnegative integer, rounded down.
 *
 * @pre The given integer is nonnegative.
 *    | 0 <= x
 * @post The result is nonnegative and not greater than the given integer.
 *    | 0 <= result
 * @post The square of the result is not greater than the given integer.
 *    | (long)result * result <= x
 * @post The square of one more than the result is greater than the given integer.
 *    | x < ((long)result + 1) * ((long)result + 1)
 */
public static int squareRoot(int x) {
    int result = 0;
    while (result * result < x)
        result++;
    return result - 1;
}
```

(Note that we need to cast the `int` result to `long` before computing its square or adding one, to avoid arithmetic overflow.)

Notice that the documentation does not reveal the algorithm used to compute the square root. (The algorithm shown is a very slow and naive one; better-performing ones undoubtedly exist. Faster algorithms would undoubtedly be more complex and further increase the complexity reduction achieved by the layer of abstraction.)

It includes a _precondition_: the module promises to implement its abstraction correctly only if the client adheres to the precondition. The postconditions state the conditions that must hold when the method returns, for the method's behavior to be considered correct.

Proper documentation for a module, then, simplifies both the task of developing the module itself, and the task of developing client modules that use the module:
- The developers that implement the module need to look only at the module's API documentation to learn what the module is supposed to do.
- The developers that implement the client modules (i.e. the modules that use the module) need to look only at the module's API documentation to learn what the module does.

## Modular software development

Splitting a system up into modules with a clearly defined, abstract API between them is an effective way of splitting a software development task into a set of simpler subtasks. Each module is not just easier to **build** than the system as a whole; it is also easier for someone to come in, read the codebase, and understand what is going on, because each module can be **understood** separately. This is because there is now a well-defined notion, for each module separately, of what that module is supposed to do (i.e. there is a well-defined notion of _correctness_ for each module separately): a module is correct if it implements its API in such a way that it complies with the module's API documentation, assuming that the lower-level modules it builds upon comply with their API documentation.

Having a notion of correctness for each module separately means we can **verify** each module separately: we can perform testing and code review on each module independently from its clients.

It also means the modules of the system can be built in parallel, by independent software development teams. Furthermore, the developers of a module can release **new versions** of the module that fix bugs, improve performance, or add new features. So long as the new versions of the module comply with the original API documentation, the old version can be replaced by the new version in the overall system without adversely impacting the overall system's correct operation.

## Data abstractions

Procedural abstractions allow clients to work with a more powerful programming language, that has more operations built in.

Similarly, application development would often benefit from having more _datatypes_ built in besides the ones that are built into the Java programming language itself.

The datatypes built into Java itself are the following:

| Datatype | Values |
| -------- | ------ |
| `byte` | The integers between -128 and 127 |
| `short` | The integers between -32768 and 32767 |
| `int` | The integers between -2<sup>31</sup> and 2<sup>31</sup> - 1 |
| `long` | The integers between -2<sup>63</sup> and 2<sup>63</sup> - 1 |
| `char` | The integers between 0 and 65535 |
| `boolean` | `true` and `false` |
| `float` | The single-precision floating-point numbers |
| `double` | The double-precision floating-point numbers |

Important remarks about these datatypes:
- Values of type `char` are used to represent text characters. The notation `'X'` denotes the `char` value assigned to character `X` by the Unicode character encoding standard. For example, `'A'` denotes the `char` value 65.
- The arithmetic operations (`+`, `-`, `*`, `/`, `%`) do not operate directly on types `byte`, `short`, or `char`; instead, operands of type `byte`, `short`, or `char` are first _promoted_ to type `int`. For example, the type of expression `'A' + 'A'` is `int` and its value is 130.
- An expression that applies an arithmetic operator to two operands of type `int` is of type `int` itself, even though the mathematical result of the operation might not be within the limits of type `int`. In that case (known as _arithmetic overflow_), the value 2<sup>32</sup> is added to or subtracted from the result as many times as necessary to bring it within the limits of the type. For example: the expression `2000000000 + 2000000000` is of type `int` and its value is -294967296 (= 4000000000 - 2<sup>32</sup>).
- If either operand of an arithmetic expression is of type `long` and the other operand is of any integer type, the expression itself is of type `long` and 2<sup>64</sup> is added to or subtracted from the result as many times as necessary to bring it within the limits of type `long`.
- Type `float` has three kinds of values:
  1. The real values, of the form M &#215; 2<sup>E</sup> where mantissa M is an integer between -2<sup>24</sup> + 1 and 2<sup>24</sup> - 1, and exponent E is an integer between -149 and 104. Note, however, that there are two distinct "zero" values: positive zero (`0f`) and negative zero (`-0f`).
  2. The infinities, `Float.POSITIVE_INFINITY` and `Float.NEGATIVE_INFINITY`.
  3. The Not-a-Number (NaN) values; these are used to represent the result of operations that have no well-defined result in mathematics, such as `0f/0f` and `Float.POSITIVE_INFINITY/Float.POSITIVE_INFINITY`. You can tell whether a `float` value is a Not-a-Number value using method `Float.isNaN`.
- Analogously, type `double` has three kinds of values:
  1. The real values, of the form M &#215; 2<sup>E</sup> where mantissa M is an integer between -2<sup>53</sup> + 1 and 2<sup>53</sup> - 1, and exponent E is an integer between -1074 and 971. Again, there are two distinct zero values: positive zero (`0.0`) and negative zero (`-0.0`).
  2. The infinities, `Double.POSITIVE_INFINITY` and `Double.NEGATIVE_INFINITY`.
  3. The NaN values. You can tell whether a `double` value is a NaN value using method `Double.isNaN`.
- This means that `float` values can be used to represent positive numbers between 10<sup>-37</sup> and 10<sup>38</sup> with 6 decimal digits of precision (as well as their negation), and `double` values can be used to represent positive numbers between 10<sup>-307</sup> and 10<sup>308</sup> with 15 decimal digits of precision (as well as their negation).
- Floating-point numbers can be written using scientific notation: `1.00001e-37f` denotes the `float` value closest to 1.00001 &#215; 10<sup>-37</sup>, and `9.99999999999999e307` denotes the `double` value closest to 9.99999999999999 &#215; 10<sup>307</sup>.
- Java's comparison operators have potentially surprising behavior on floating-point numbers: for example, `0.0 == -0.0` returns `true` and `0.0/0.0 == 0.0/0.0` returns `false`. To tell whether two `float` values are identical, compare the results of calling `Float.floatToRawIntBits` on both of them; similarly, to tell whether two `double` values are identical, compare the results of calling `Double.doubleToRawLongBits` on both of them.
- The arithmetic operations on floating-point values perform implicit rounding. In computations involving multiple arithmetic operations, these rounding errors can accumulate and lead to very large errors in the final result. Constructing correct floating-point computations is a very challenging and specialized skill that is outside the scope of this course.
- For further reading on floating-point numbers, see [here](https://people.eecs.berkeley.edu/~wkahan/ieee754status/IEEE754.PDF) and [here](https://cr.yp.to/2005-590/goldberg.pdf).
- Underscores can be used to make numbers more readable: `2_000_000_000`, `9_000_000_000_000_000_000L`, `9.999_999_999_999_99`. For integers, Java supports hexadecimal notation (e.g. `0xf` denotes 15 and `0x10` denotes 16), binary notation (e.g. `0b1000_0000` denotes 128), and octal notation (e.g. `0100` denotes 64).
- If you installed [AdoptOpenJDK](https://adoptopenjdk.net/) JDK 9 or newer, you can play with Java's datatypes and operators by opening a Command Prompt (on Windows: right-click the Start button and choose Command Prompt; on macOS: Applications -> Utilities -> Terminal) and entering `jshell`. Then enter e.g. `2_000_000_000 + 2_000_000_000` to see the result of evaluating the expression. To see the type of the result, enter `/vars`.

However, for many applications, these datatypes are not sufficient. For example, using floating-point numbers to count money in financial applications is a bad idea. Indeed, not all decimal fractions can be represented exactly as a binary floating-point number. For example: `0.10 + 0.10 + 0.10 + 0.10 + 0.10 + 0.10 + 0.10 + 0.10 + 0.10 + 0.10 == 1.00` yields `false`!

Financial applications would be much easier to write in Java if Java had a built-in type of fractions. Fortunately, Java supports _data abstraction_ by means of _classes_. By defining classes, we can extend Java with new datatypes. This way, we can split the task of developing a financial application in Java into two simpler subtasks:
- The development of a financial application, not in Java but in Java++, an extension of Java with a type `Fraction` whose values are (some subset of) the rational numbers*.
- The development of a fractions module, that implements datatype `Fraction` as a class that internally uses Java's built-in datatypes.

(*) Unfortunately, in Java the values of a class type such as `Fraction` always include the special value `null`, known as the _null reference_, in addition to the _object references_ that refer to _instances_ of class `Fraction`. Tony Hoare, who originally introduced null references in the programming language Algol, calls this his "billion-dollar mistake". With new programming languages such as [Kotlin](https://kotlinlang.org/) that do not suffer from this issue gaining popularity, the industry is slowly eliminating this scourge.

We call the application written in Java++ a _client module_ of the fractions module. Composing the client module with the fractions module yields a system that implements the financial application in Java.

Again, these two subtasks are simpler and easier than the overall application development task:
- The developers of the client module are working in a more powerful language, with more datatypes built in. They need not worry about how to implement fractions in Java.
- The developers of the fractions module only need to worry about correctly implementing the fractions abstraction. They need not worry about how it will be used or what it will be used for.

Again, the full benefit of this decomposition is obtained only if sufficiently _precise_ and _abstract_ _documentation_ is provided for the `Fraction` datatype's _API_:
- If the developers of the financial application need to look inside the implementation of the `Fraction` datatype to understand its behavior, then they are still exposed to the complexity of implementing fractions in terms of Java's built-in datatypes.
- Conversely, if the developers of the fractions module need to inspect the client module to understand the client's expectations with respect to the `Fraction` datatype's behavior, then they are still exposed to the complexity of the entire financial application.

Here is an example of a properly documented implementation of the fractions module:
```java
import java.math.BigInteger;

/**
 * Each instance of this class represents a rational number.
 * 
 * @immutable
 * 
 * @invar The denominator is positive.
 *    | 0 < getDenominator()
 * @invar The numerator is greater than the minimum {@code long} value.
 *    | Long.MIN_VALUE < getNumerator()
 * @invar The fraction is irreducible: the greatest common divisor of
 *        the absolute value of the numerator and the denominator is one.
 *    | MoreMath.gcd(Math.abs(getNumerator()), getDenominator()) == 1 
 */
public class Fraction {
    
    /**
     * @invar | 0 < denominator
     * @invar | Long.MIN_VALUE < numerator
     * @invar | MoreMath.gcd(Math.abs(numerator), denominator) == 1
     */
    private final long numerator;
    private final long denominator;
    
    public long getNumerator() { return numerator; }
    public long getDenominator() { return denominator; }
    
    private Fraction(long numerator, long denominator) {
        this.numerator = numerator;
        this.denominator = denominator;
    }

    /**
     * An object that represents the number zero.
     */
    public static final Fraction ZERO = new Fraction(0, 1);
    
    /**
     * Returns an object representing the rational number defined by the given numerator and denominator.
     * 
     * @throws IllegalArgumentException if the given denominator is zero.
     *    | denominator == 0
     * @may_throw ArithmeticException if arithmetic overflow occurs.
     *    | true
     * @post The result is not null.
     *    | result != null
     * @post The rational number represented by the result equals the rational number defined by the
     *       given numerator and denominator.
     *    | BigInteger.valueOf(result.getNumerator()).multiply(BigInteger.valueOf(denominator)).equals(
     *    |     BigInteger.valueOf(numerator).multiply(BigInteger.valueOf(result.getDenominator())))
     */
    public static Fraction of(long numerator, long denominator) {
        if (denominator == 0)
            throw new IllegalArgumentException("denominator is zero");
        if (numerator == 0)
            return ZERO;
        long gcd = MoreMath.gcd(
                MoreMath.absExact(numerator),
                MoreMath.absExact(denominator));
        if (denominator < 0)
            gcd = -gcd;
        return new Fraction(numerator / gcd, denominator / gcd);
    }
    
    /**
     * Returns whether this object and the given object represent the same rational number.
     *
     * @throws IllegalArgumentException if {@code other} is null.
     *    | other == null
     * @post
     *    | result == (
     *    |     getNumerator() == other.getNumerator() &&
     *    |     getDenominator() == other.getDenominator()
     *    | )
     */
    public boolean equals(Fraction other) {
        if (other == null)
            throw new IllegalArgumentException("other is null");
        return numerator == other.numerator && denominator == other.denominator;
    }
    
    /**
     * Returns an object representing the rational number obtained by adding
     * the rational number represented by this object to the rational number
     * represented by the given object.
     * 
     * @throws IllegalArgumentException if {@code other} is null.
     *    | other == null
     * @may_throw ArithmeticException if arithmetic overflow occurs.
     *    | true
     * @post The result is not null.
     *    | result != null
     * @post a/b == c/d + e/f if and only if adf == cbf + ebd.
     *    | BigInteger.valueOf(result.getNumerator()).
     *    |     multiply(BigInteger.valueOf(this.getDenominator())).
     *    |     multiply(BigInteger.valueOf(other.getDenominator())).
     *    |     equals(
     *    |         BigInteger.valueOf(this.getNumerator()).
     *    |             multiply(BigInteger.valueOf(result.getDenominator())).
     *    |             multiply(BigInteger.valueOf(other.getDenominator())).
     *    |             add(
     *    |                 BigInteger.valueOf(other.getNumerator()).
     *    |                     multiply(BigInteger.valueOf(result.getDenominator())).
     *    |                     multiply(BigInteger.valueOf(this.getDenominator()))))
     */
    public Fraction plus(Fraction other) {
        if (other == null)
            throw new IllegalArgumentException("other is null");
        long gcd = MoreMath.gcd(this.denominator, other.denominator);
        long numerator = Math.addExact(
                Math.multiplyExact(this.numerator, other.denominator / gcd),
                Math.multiplyExact(other.numerator, this.denominator / gcd));
        long denominator =
                Math.multiplyExact(this.denominator, other.denominator / gcd);
        return Fraction.of(numerator, denominator);
    }
    
}
```

It uses the following library of math methods:
```java
import java.util.stream.LongStream;

public class MoreMath {

    /**
     * Returns the absolute value of the given number.
     * 
     * @throws ArithmeticException if arithmetic overflow occurs.
     *    | x == Long.MIN_VALUE
     * @post The result is nonnegative.
     *    | 0 <= result
     * @post The result equals either the argument or its negation.
     *    | result == x || result == -x
     */
    public static long absExact(long x) {
        if (x == Long.MIN_VALUE)
            throw new ArithmeticException("Arithmetic overflow");
        return Math.abs(x);
    }

    /**
     * Returns whether the first given number divides the second given number.
     * 
     * @pre The first given number is not zero.
     *    | a != 0
     * @post | result == (b % a == 0)
     */
    public static boolean divides(long a, long b) {
        return b % a == 0;
    }
    
    /**
     * Returns the greatest common divisor of the two given integers.
     * 
     * @pre The given numbers are nonnegative.
     *    | 0 <= a && 0 <= b
     * @pre At least one given number is nonzero.
     *    | a != 0 || b != 0
     * @post The result is positive.
     *    | 0 < result
     * @post The result divides both given numbers.
     *    | divides(result, a) && divides(result, b)
     * @post No greater number divides both given numbers.
     *    | LongStream.range(result, Math.max(a, b)).allMatch(x -> !(divides(x + 1, a) && divides(x + 1, b)))
     */
    public static long gcd(long a, long b) {
        if (a == 0) return b;
        if (b == 0) return a;
        if (a < b) return gcd(b % a, a);
        return gcd(a % b, b);
    }
    
}
```

Notice that class `Fraction` does not expose any means for clients to mutate the association between a `Fraction` instance and the
rational number it represents. Classes like this, where clients cannot mutate an instance's _abstract value_, are called
_immutable classes_. We say they implement an _immutable value abstraction_. In order to allow clients to understand
that a class is immutable without having to check all methods, we include the `@immutable` tag in the Javadoc comment for the class.

Notice, furthermore, that class `Fraction` does not expose a constructor. Instead, it exposes a static method `of` to allow clients to
obtain a `Fraction` instance that represents a given abstract value. Exposing such a method, typically called `of` or `valueOf`,
is common practice for immutable classes; it allows the implementation to avoid the creation of a new instance in some cases. For
example, class `Fraction` reuses an existing object whenever the client requests an object that represents abstract value zero. Of
course, such reuse is safe only if the class is immutable.

Notice also that the documentation for `Fraction` uses Java's `BigInteger` class to avoid arithmetic overflow inside the documentation.

Client modules can use the `Fraction` class to perform financial computations in a safe and simple way. For example: the `assert` statement in the
following code snippet succeeds:
```java
Fraction tenCents = Fraction.of(10, 100);
Fraction total = Fraction.of(0, 100);
for (int i = 0; i < 10; i++)
  total = total.plus(tenCents);
assert total.equals(Fraction.of(100, 100));
```

### Mutable versus immutable data abstractions

An alternative abstraction that one could introduce for simplifying the task of building financial applications,
is a _mutable_ class for calculating with fractions:

```java
import java.math.BigInteger;

/**
 * Each instance of this class stores, at each point in time, a rational number.
 * 
 * @invar The denominator is positive.
 *    | 0 < getDenominator()
 * @invar The numerator is greater than the minimum {@code long} value.
 *    | Long.MIN_VALUE < getNumerator()
 * @invar The fraction is irreducible: the greatest common divisor of
 *        the absolute value of the numerator and the denominator is one.
 *    | MoreMath.gcd(Math.abs(getNumerator()), getDenominator()) == 1 
 */
public class FractionContainer {
    
    /**
     * @invar | 0 < denominator
     * @invar | Long.MIN_VALUE < numerator
     * @invar | MoreMath.gcd(Math.abs(numerator), denominator) == 1
     */
    private long numerator;
    private long denominator;
    
    public long getNumerator() { return numerator; }
    public long getDenominator() { return denominator; }
    
    /**
     * Returns whether the rational number stored by this object
     * equals the rational number defined by the given numerator
     * and denominator.
     * 
     * @throws IllegalArgumentException if the given denominator is zero.
     *    | denominator == 0
     * @post
     *    | result ==
     *    |     BigInteger.valueOf(getNumerator())
     *    |         .multiply(BigInteger.valueOf(denominator))
     *    |         .equals(
     *    |              BigInteger.valueOf(numerator)
     *    |                  .multiply(BigInteger.valueOf(this.getDenominator())))
     */
    public boolean equals(long numerator, long denominator) {
        if (denominator == 0)
            throw new IllegalArgumentException("denominator is zero");
        if (denominator % this.denominator != 0)
            return false;
        long factor = denominator / this.denominator;
        if (numerator % factor != 0)
            return false;
        return numerator / factor == this.numerator;
    }
    
    /**
     * Initializes this object so that it stores the number zero.
     * @post | getNumerator() == 0
     */
    public FractionContainer() {
        denominator = 1;
    }
    
    /**
     * Mutates this object so that it stores the rational number defined
     * by the given numerator and denominator.
     * 
     * @throws IllegalArgumentException if the given denominator is zero.
     *    | denominator == 0
     * @may_throw ArithmeticException if arithmetic overflow occurs.
     *    | true
     * @post The rational number stored by this object equals the rational number defined by the
     *       given numerator and denominator.
     *    | BigInteger.valueOf(getNumerator()).multiply(BigInteger.valueOf(denominator)).equals(
     *    |     BigInteger.valueOf(numerator).multiply(BigInteger.valueOf(getDenominator())))
     */
    public void set(long numerator, long denominator) {
        if (denominator == 0)
            throw new IllegalArgumentException("denominator is zero");
        long gcd = MoreMath.gcd(
                MoreMath.absExact(numerator),
                MoreMath.absExact(denominator));
        if (denominator < 0)
            gcd = -gcd;
        this.numerator = numerator / gcd;
        this.denominator = denominator / gcd;
    }
    
    /**
     * Mutates this object so that it stores the rational number obtained by adding
     * the old rational number stored by this object to the rational number
     * defined by the given numerator and denominator.
     * 
     * @throws IllegalArgumentException if the given denominator is zero.
     *    | other == null
     * @may_throw ArithmeticException if arithmetic overflow occurs.
     *    | true
     * @post a/b == c/d + e/f if and only if adf == cbf + ebd.
     *    | BigInteger.valueOf(getNumerator()).
     *    |     multiply(BigInteger.valueOf(old(getDenominator()))).
     *    |     multiply(BigInteger.valueOf(denominator)).
     *    |     equals(
     *    |         BigInteger.valueOf(old(getNumerator())).
     *    |             multiply(BigInteger.valueOf(getDenominator())).
     *    |             multiply(BigInteger.valueOf(denominator)).
     *    |             add(
     *    |                 BigInteger.valueOf(numerator).
     *    |                     multiply(BigInteger.valueOf(getDenominator())).
     *    |                     multiply(BigInteger.valueOf(old(getDenominator())))))
     */
    public void add(long numerator, long denominator) {
        if (denominator == 0)
            throw new IllegalArgumentException("denominator is zero");
        long gcd = MoreMath.gcd(this.denominator, MoreMath.absExact(denominator));
        if (denominator < 0)
            gcd = -gcd;
        long newNumerator = Math.addExact(
                Math.multiplyExact(this.numerator, denominator / gcd),
                Math.multiplyExact(numerator, this.denominator / gcd));
        long newDenominator =
                Math.multiplyExact(this.denominator, denominator / gcd);
        set(newNumerator, newDenominator);
    }
    
}
```

We could implement our example financial computation using class `FractionContainer` as follows:
```java
FractionContainer container = new FractionContainer();
for (int i = 0; i < 10; i++)
    container.add(10, 100);
assert container.equals(100, 100);
```

Notice that the association between the `FractionContainer` instance and the rational number it stores
changes 11 times during this computation: initially, it stores the value 0, then, after the first `add`
call, the value 1/10, then the value 2/10, etc. Therefore, it is not correct to say that an instance
of `FractionContainer` _is_ a rational number; rather, we can only say that it _stores_, at any given
point in time, a particular rational number.

The example shows both the main advantage and the main disadvantage of mutable classes compared to
immutable classes: when working with mutable classes, performance is often better because the program
creates fewer objects. On the other hand, when working with immutable classes, reasoning about the program
is generally easier because there is no need to distinguish between an object and its abstract value;
indeed, it is fine to think of object `Fraction.ZERO` as _being_ the number zero.

To highlight the fact that it is not correct to think of a `FractionContainer` instance as _being_ a
fraction, we have named the class `FractionContainer` rather than `Fraction`; however, in practice
mutable classes are very often called after the type of abstract values they store. For example, in
the Java Collections API, class `ArrayList` is a _mutable_ class for _storing_ lists of objects;
it is not correct to think of an `ArrayList` object as _being_ a list of objects.
