# First Steps in Modular Programming (Part II)

## Constructors

At this point, to use an `Interval` object to store a given interval, we must first create the object using a `new Interval()` expression, and then set its properties through the `setLowerBound`, `setUpperBound`, and/or `setWidth` setters. It is often convenient, and sometimes necessary, to allow client code to create an object and initialize its properties to desired values in one step. For this purpose, Java allows us to declare _constructors_. For example, we can allow clients to create an `Interval` object storing the interval with lower bound 3 and upper bound 7 using expression `new Interval(3, 7)` by inserting a _constructor declaration_ into class `Interval` as follows:

```java
package interval;

class Interval {
	private int lowerBound;
	private int upperBound;

	int getLowerBound() {
		return lowerBound;
	}
	
	int getUpperBound() {
		return upperBound;
	}
	
	int getWidth() {
		return upperBound - lowerBound;
	}
	
	Interval(int initialLowerBound, int initialUpperBound) {
		lowerBound = initialLowerBound;
		upperBound = initialUpperBound;
	}
	
	void setLowerBound(int value) {
		lowerBound = value;
	}
	
	void setUpperBound(int value) {
		upperBound = value;
	}
	
	void setWidth(int value) {
		upperBound = lowerBound + value;
	}

}
```

Notice the following:
- The name of a constructor is always simply the name of the class.
- A constructor declaration does not specify a return type.

Notice that Eclipse now marks expression `new Interval()` in `IntervalTest.java` as incorrect. Indeed, this expression refers to a constructor with zero parameters. If a class C does not explicitly declare a constructor, Java implicitly generates a _default constructor_ `C() {}`. Since we now explicitly declare a constructor, Java no longer generates this constructor and the expression `new Interval()` no longer works. To fix the error, we replace this expression with `new Interval(3, 7)`. We can now remove the setter calls:

```java
package interval;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class IntervalTest {
	
	@Test
	void test() {
		Interval interval = new Interval(3, 7);

		int width = interval.getWidth();
		assert width == 4;
	}

}
```

## Overloading

But what if we want to initialize an `Interval` object with a given lower bound and a given width? That is, we would like to additionally declare the following constructor:

```java
	Interval(int lowerBound, int width) {
		this.lowerBound = lowerBound;
		this.upperBound = lowerBound + width;
	}
```

Java does not allow this, because there would be no way to decide which constructor to use to execute an instance creation expression `new Interval(3, 7)`. Java does allow a class to declare multiple constructors, but each constructor must have either a different number of parameters or different parameter types. So, one way to add our additional constructor is as follows:

```java
	Interval(int lowerBound, int width, boolean dummy) {
		this.lowerBound = lowerBound;
		this.upperBound = lowerBound + width;
	}
```

This works: now, we can replace expression `new Interval(3, 7)` by the equivalent expression `new Interval(3, 4, false)` (or `new Interval(3, 4, true)`; the value for the dummy parameter does not matter).

Declaring multiple members with the same name is known as _overloading_. Java supports overloading of constructors, as well as methods. For example, we can extend our class with a method `setWidth` with two parameters that updates the lower bound or the upper bound, depending on the second argument:

```java
	void setWidth(int value, boolean updateLowerBound) {
		if (updateLowerBound)
			lowerBound = upperBound - value;
		else
			upperBound = lowerBound + value;
	}
```

## API Semantics: Documentation

Consider the following modified version of class `IntervalTest`:

```java
package interval;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class IntervalTest {
	
	@Test
	void test() {
		Interval interval = new Interval(3, 4, false);

		interval.setUpperBound(8);
		assert interval.getLowerBound() == 3;
	}

}
```

It checks that updating an interval's upper bound leaves its lower bound unchanged. If we were to update method `setUpperBound` in class `Interval` so that it updates the lower bound and leaves the width unchanged, this change would break this client: the `assert` statement would fail. Who would be to blame? To eliminate this error, who would have to change their code? The author of `Interval` or the author of `IntervalTest`?

In this case, it is reasonable to say that the client is to blame: they assumed that method `setUpperBound` would leave the lower bound unchanged, but the author of class `Interval` has made no such promises. Unless module authors make specific guarantees about how a method will behave, it is always safest to assume the worst and not rely on anything that is not explicitly guaranteed.

So, if we, as a module author, want to allow clients to assume certain facts about our methods' behavior, we have to state those facts clearly in the module's documentation. Writing clear and precise documentation for modules will be a central focus of this course. For maximum clarity and precision, we will write statements in documentation both informally and formally. A fully documented version of class `Interval` looks like this:

```java
package interval;

/**
 * An object of this class stores an interval of integers.   
 * 
 * @invar This interval's lower bound is not greater than its upper bound.
 *     | getLowerBound() <= getUpperBound()
 * @invar This interval's width equals the difference between its upper bound
 *        and its lower bound.
 *     | getWidth() == getUpperBound() - getLowerBound()
 */
class Interval {
	
	/**
	 * @invar This interval's lower bound is not greater than its upper bound.
	 *      | lowerBound <= upperBound
	 */
	private int lowerBound;
	private int upperBound;

	int getLowerBound() {
		return lowerBound;
	}
	
	int getUpperBound() {
		return upperBound;
	}
	
	int getWidth() {
		return upperBound - lowerBound;
	}
	
	/**
	 * Initializes this interval with the given lower bound and upper bound.
	 * 
	 * @pre The given lower bound is not greater than the given upper bound.
	 *    | lowerBound <= upperBound
	 * @post This interval's lower bound equals the given lower bound.
	 *    | getLowerBound() == lowerBound
	 * @post This interval's upper bound equals the given upper bound.
	 *    | getUpperBound() == upperBound
	 */
	Interval(int lowerBound, int upperBound) {
		this.lowerBound = lowerBound;
		this.upperBound = upperBound;
	}

	/**
	 * Initializes this interval with the given lower bound and width.
	 *
	 * @pre The given width is nonnegative.
	 *    | 0 <= width
	 * @post This interval's lower bound equals the given lower bound.
	 *    | getLowerBound() == lowerBound
	 * @post This interval's width equals the given width.
	 *    | getWidth() == width
	 */
	Interval(int lowerBound, int width, boolean dummy) {
		this.lowerBound = lowerBound;
		this.upperBound = lowerBound + width;
	}
	
	/**
	 * Sets this interval's lower bound to the given value.
	 *
	 * @pre The given value is not greater than this interval's upper bound.
	 *    | value <= getUpperBound()
	 * @post This interval's lower bound equals the given value.
	 *    | getLowerBound() == value
	 * @post This interval's upper bound has remained unchanged.
	 *    | getUpperBound() == old(getUpperBound())
	 */
	void setLowerBound(int value) {
		lowerBound = value;
	}
	
	/**
	 * Sets this interval's upper bound to the given value.
	 * 
	 * @pre The given value is not less than this interval's lower bound.
	 *    | getLowerBound() <= value
	 * @post This interval's upper bound equals the given value.
	 *     | getUpperBound() == value
	 * @post This interval's lower bound has remained unchanged.
	 *     | getLowerBound() == old(getLowerBound())  
	 */
	void setUpperBound(int value) {
		upperBound = value;
	}
	
	/**
	 * Sets this interval's width to the given value.
	 * 
	 * @pre The given value is nonnegative.
	 *    | 0 <= value
	 * @post This interval's width equals the given value.
	 *     | getWidth() == value
	 * @post This interval's lower bound has remained unchanged.
	 *     | getLowerBound() == old(getLowerBound())
	 */
	void setWidth(int value) {
		upperBound = lowerBound + value;
	}
	
	/**
	 * Sets this interval's width to the given value.
	 *
	 * @pre The given value is nonnegative.
	 *    | 0 <= value
	 * @post This interval's width equals the given value.
	 *     | getWidth() == value
	 * @post If the caller specified that the lower bound should be updated, the
         *       upper bound has remained unchanged.
	 *     | !updateLowerBound || getUpperBound() == old(getUpperBound())
	 * @post If the caller specified that the lower bound should not be updated,
         *       the lower bound has remained unchanged.
	 *     | updateLowerBound || getLowerBound() == old(getLowerBound())
	 */
	void setWidth(int value, boolean updateLowerBound) {
		if (updateLowerBound)
			lowerBound = upperBound - value;
		else
			upperBound = lowerBound + value;
	}

}
```

Notice that we write documentation structured into four kinds of _clauses_:
- _Postconditions_, indicated by tag `@post`, state conditions that are promised by the module author to be true after execution of the method, provided that the method's preconditions are true before execution of the method.
- _Preconditions_, indicated by tag `@pre`, state conditions that must be true at the start of an execution of the method. If at the start of a particular execution of a method, the method's preconditions are not true, then the module author is not required to ensure that the method's postconditions are true at the end of this execution.
- _Private invariants_, also known as _representation invariants_, indicated by tag `@invar` in a documentation comment preceding the private fields of a class, state conditions on the values of the fields of an object that must be true for the object to be considered to be in a valid state. It is a module author's responsibility to ensure that an object is in a valid state whenever no constructor or method of the object is being executed. Note: the private invariants are not part of the API specification; they serve only as internal documentation for the module author's own use to facilitate their reasoning about the correctness of their module.
- _Public invariants_, indicated by tag `@invar` in the documentation comment for the class declaration itself, state conditions on the values returned by the getters of an object that must be true whenever no constructor or method of the object is being executed. It is a module author's responsibility to ensure this.
