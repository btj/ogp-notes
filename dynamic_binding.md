# Dynamic binding

The implementation of method `toSVG` shown in the preceding chapter works, but it has a drawback: if we extend our drawing application to also support rectangles, we need to update method `toSVG`.

Suppose we want to be able to add new kinds of shapes without having to update class `Drawing`. We can achieve this by first implementing a `toSVG()` method in each subclass of `Shape`:

```java
public class Circle extends Shape {

    // ...

    public String toSVG() {
        return "<circle cx='" + x + "' cy='" + y + "' r='" + radius + "'/>";
    }

}

public class Polygon extends Shape {

    // ...

    public String toSVG() {
        String svg = "<polygon points='";
        for (int coord : coordinates)
            svg += coord + " ";
        return svg + "'/>";
    }

}

public class Drawing {

    // ...

    public String toSVG() {
        String svg = "<svg xmlns='http://www.w3.org/2000/svg'"
                     + " stroke='black' fill='transparent'>";
        for (Shape shape : shapes)
            if (shape instanceof Circle circle)
                svg += circle.toSVG();
            else
                svg += ((Polygon)shape).toSVG();
        return svg + "</svg>";
    }

}
```
Note that even though every subclass of `Shape` now implements a `toSVG()` method, Java's static type checker still does not allow us to call `toSVG()` on an expression of static type `Shape`.
We can remedy this by declaring an _abstract method_ `toSVG()` in class `Shape`, to indicate that each subclass of `Shape` should implement such a method:
```java
public abstract class Shape {

    public abstract String toSVG();

}
```
Java's static type checker now checks that each class that extends `Shape` declares a method named `toSVG` that takes no parameters and has return type `String`. Correspondingly, since class `Shape` now declares a method `toSVG`, we can now call `toSVG` directly on an expression of static type `Shape`:

```java
public class Drawing {

    // ...

    public String toSVG() {
        String svg = "<svg xmlns='http://www.w3.org/2000/svg'"
                     + " stroke='black' fill='transparent'>";
        for (Shape shape : shapes)
            svg += shape.toSVG();
        return svg + "</svg>";
    }

}
```

When the computer executes the method call `shape.toSVG()`, it determines which method body to execute based on the _dynamic type_ of the receiver object: if `shape` evaluates to a reference to an instance of `Circle`, then the implementation of `toSVG()` in class `Circle` is executed; if `shape` evaluates to a reference to an instance of `Polygon`, then the implementation of `toSVG()` in class `Polygon` is executed. This is known as _dynamic binding_ of method calls.

If a method declared by a subclass has the same name and the same number and types of parameters as a method declared by its superclass, we say it _overrides_ the superclass method. Calls of the method on an object of the subclass will execute the overriding method instead of the overridden method.

## Methods equals, hashCode, and toString

Class `Object` declares a number of methods:

```java
package java.lang;

public class Object {

    /**
     * Returns the Class object for this object's class.
     */
    public Class getClass() { /* ... */ }

    /**
     * Returns a number suitable for use as a hash code when using this object as
     * a key in a hash table.
     *
     * Note: two objects that are equal according to the `equals(Object)` method
     * must have the same hash code.
     *
     * The implementation of this method in class java.lang.Object returns a hash
     * code based on the identity of this object. That is, this implementation
     * usually returns a different number for different objects, although this is
     * not guaranteed.
     */
    public int hashCode() { /* ... */ }

    /**
     * Returns a textual representation of this object.
     *
     * The implementation of this method in class java.lang.Object is based on the
     * name of this object's class and this object's identity-based hash code.
     */
    public String toString() {
        return this.getClass().getName() + "@"
            + Integer.toHexString(this.hashCode());
    }

    /**
     * Returns whether this object is conceptually equal to the given object.
     *
     * The implementation of this method in class java.lang.Object returns whether
     * this object and the given object are the same object.
     */
    public boolean equals(Object other) { return other == this; }

    // ...

}
```

Methods `equals`, `hashCode`, and `toString` are often overridden by immutable classes. For example:
```java
public class Point {
	
	private final int x;
	private final int y;
	
	public Point(int x, int y) {
		this.x = x;
		this.y = y;
	}

	public int getX() {
		return x;
	}

	public int getY() {
		return y;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + x;
		result = prime * result + y;
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Point other = (Point) obj;
		if (x != other.x)
			return false;
		if (y != other.y)
			return false;
		return true;
	}

	@Override
	public String toString() {
		return "Point [x=" + x + ", y=" + y + "]";
	}

}
```
The implementations above were generated using Eclipse's _Generate hashCode() and equals()_ and _Generate toString()_ commands, which you can find in the _Source_ menu after right-clicking on the class.

The `@Override` annotations cause Java's static type checker to check that the methods do indeed override a method from the superclass. Without the annotation, it is easy to accidentally not override a superclass method. For example, if we accidentally declared the parameter type of `equals` as `Point` instead of `Object`, it would not override the `equals` method from class `Object` and we would not get the behavior shown below. Thanks to the `@Override` annotation, the Java static type checker would flag this as an error.

As a result of overriding these methods from class `Object`, we get the following behavior:
```java
assertEquals("This is Point [x=10, y=20].","This is " + new Point(10, 20) + ".");
assertEquals(new Point(10, 20), new Point(10, 20));
```

If we had not overridden these methods, the behavior would be as follows:
```java
assertEquals("This is Point@12345678.", "This is " + new Point(10, 20) + ".");
assertNotEquals(new Point(10, 20), new Point(10, 20));
```

Specifically, Java calls an object's `toString()` method when it is added to a string using the `+` operator. Similarly, JUnit's `assertEquals(Object o1, Object o2)` method calls `o1.equals(o2)` to compare its arguments.

As we will see later, the Java Collections Framework uses methods `equals` and `hashCode` to compare elements of collections. For example, `List.of(e1, e2).contains(e3)` returns `true` if and only if either `e3.equals(e1)` or `e3.equals(e2)` returns `true`, and `new HashSet(List.of(e1, e2)).size()` may return 1 or 2 depending both on whether `e1.hashCode()` equals `e2.hashCode()` and on whether `e1.equals(e2)` or `e2.equals(e1)` return `true`.

Since arrays are objects and can be assigned to variables of type `Object`, the `equals`, `hashCode`, and `toString` methods can be invoked on arrays. However, arrays simply inherit the implementations of these methods from class `Object`. This means that if `array1` and `array2` are arrays, `array1.equals(array2)` is equivalent to `array1 == array2`; it compares the identities of the arrays, not their contents. To compare the contents, use [`Arrays.equals(array1, array2)`](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/Arrays.html#equals(java.lang.Object%5B%5D,java.lang.Object%5B%5D)) or [`Arrays.deepEquals(array1, array2)`](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/Arrays.html#deepEquals(java.lang.Object%5B%5D,java.lang.Object%5B%5D)).

### Record classes

Since Java 16, released in March 2021, class `Point` above can be declared more concisely as follows:
```java
public record Point(int x, int y) {}
```
This declaration declares a *record class* with *components* `int x` and `int y`. A record class is a class with the following predefined members:
- a `private final` field for each component, with the same name and type. A *final field* is a field that cannot be modified after initialisation. This means that record classes are **immutable**.
- a public *accessor method* for each component, with the same name and type, and no parameters, which returns the value of the corresponding field. This is the only difference with the regular `Point` class shown above: the inspectors are called `x()` and `y()` instead of `getX()` and `getY()`.
- a constructor with the same visibility as the class itself (i.e. public in this case), whose parameter list matches the component list. It initializes each field with the corresponding parameter. This constructor is called the *canonical constructor*.
- an `equals(Object other)` method which overrides the method from class `Object`. It returns `true` if and only if `other` is an instance of the record class and the components of `this` are equal to the corresponding components of `other`. Components of reference type are compared using `equals`.
- a `hashCode()` method which overrides the method from class `Object`. It returns an `int` computed (in an unspecified way) from the values (in case of primitive types) or hash codes (in case of objects) of the components.
- a `toString()` method which overrides the method from class `Object`. It returns a string composed from the name of the record class and the names and string representations of the components.

Otherwise, a record class is just like any other class. In particular, a record class can declare additional constructors and methods. It can also explicitly declare a constructor or methods matching
some of the predefined members; in that case, the corresponding predefined members are not generated.

Record classes have the following restrictions:
- They always implicitly extend built-in class `Record`; an explicit `extends` clause is not permitted. (An `implements` clause is permitted, however; see the chapter on Interfaces.)
- They are *final*. A final class cannot be extended by other classes.
- They cannot explicitly declare any instance fields. That is, the implicitly declared fields are always the only instance fields of the class. (They can declare static fields, however.)

It is common to want to explicitly provide a canonical constructor that performs defensive checks and/or normalizes its arguments. For this reason, Java supports a *compact canonical constructor* notation:
```java
public record Circle(int x, int y, int radius) {
    public Circle {
        if (radius < 0)
            throw new IllegalArgumentException("`radius` must be nonnegative");
    }
}
```
Warning: be careful when using a record class if some of the components are mutable objects that should be treated like representation objects; the predefined members do not prevent representation exposure. Be extra careful when using arrays as record components: an array's `equals` method simply compares the identities of the two objects; it does not compare the array elements.
