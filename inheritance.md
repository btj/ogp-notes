# Inheritance

## Polymorphism

Suppose we need to develop a drawing application. A drawing consists of a
number of triangles and circles, so we define a class where each instance
represents a triangle and a class where each instance represents a circle:

```java
package drawings;

public class Triangle {
    
    private final int x1, y1, x2, y2, x3, y3;
    
    public int getX1() { return x1; }
    public int getY1() { return y1; }
    public int getX2() { return x2; }
    public int getY2() { return y2; }
    public int getX3() { return x3; }
    public int getY3() { return y3; }
    
    public Triangle(int x1, int y1, int x2, int y2, int x3, int y3) {
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
        this.x3 = x3;
        this.y3 = y3;
    }
    
    public boolean contains(int x, int y) {
        return
                Math.signum(((long)x - x1) * ((long)y2 - y1) - ((long)y - y1) * ((long)x2 - x1)) *
                Math.signum(((long)x3 - x1) * ((long)y2 - y1) - ((long)y3 - y1) * ((long)x2 - x1)) >= 0 &&
                Math.signum(((long)x - x2) * ((long)y3 - y2) - ((long)y - y2) * ((long)x3 - x2)) *
                Math.signum(((long)x1 - x2) * ((long)y3 - y2) - ((long)y1 - y2) * ((long)x3 - x2)) >= 0 &&
                Math.signum(((long)x - x3) * ((long)y1 - y3) - ((long)y - y3) * ((long)x1 - x3)) *
                Math.signum(((long)x2 - x3) * ((long)y1 - y3) - ((long)y2 - y3) * ((long)x1 - x3)) >= 0;
    }
    
    public String getDrawingCommand() {
        return "triangle " + x1 + " " + y1 + " " + x2 + " " + y2 + " " + x3 + " " + y3;
    }

}
```

```java
package drawings;

public class Circle {
    
    private final int x, y;
    private final int radius;
    
    public int getX() { return x; }
    public int getY() { return y; }
    public int getRadius() { return radius; }
    
    public Circle(int x, int y, int radius) {
        this.x = x;
        this.y = y;
        this.radius = radius;
    }
    
    public boolean contains(int x, int y) {
        long dx = (long)x - this.x;
        long dy = (long)y - this.y;
        return dx * dx + dy * dy <= (long)radius * radius; 
    }
    
    public String getDrawingCommand() {
        return "circle " + x + " " + y + " " + radius;
    }

}
```

A drawing, then, is a sequence of shapes, where a shape is either a triangle or a circle. The order among the shapes is important
in case of overlaps: the shapes are drawn in reverse order so that the first shape appears on top. How can we store this sequence?
We can store it using an array or an `ArrayList`, but what should be the element type?

What we need is a type `Shape` that is conceptually the union of types `Triangle` and `Circle`: what we want is that an object
is an instance of `Shape` if and only if it is either an instance of `Triangle` or an instance of `Circle`.

For this purpose, Java has the concepts of _abstract classes_ and _inheritance_. We can declare an abstract class `Shape` and declare
classes `Triangle` and `Circle` as _subclasses_ of `Shape`:

```java
public abstract class Shape {
}

public class Triangle extends Shape {
    // class body unchanged
}

public class Circle extends Shape {
    // class body unchanged
}
```
We also say that `Triangle` and `Circle` _extend_ `Shape` and that they _inherit_ from `Shape`. `Shape` is the _superclass_ of `Triangle` and `Circle`.

A variable of type `Shape` is _polymorphic_: we can use it to store a reference to a `Triangle` instance or a reference to a `Circle` instance:
```java
Shape shape1 = new Triangle(0, 0, 10, 0, 5, 10);
Shape shape2 = new Circle(5, 10, 5);
```
This also means we can use an array of type `Shape[]` to store both triangles and circles:
```java
Shape[] shapes = {new Triangle(0, 0, 10, 0, 5, 10), new Circle(5, 10, 5)};
```

Once we have stored an object reference into a polymorphic variable, we can test whether it refers to an instance of a particular class using an `instanceof` expression:

```java
assertEquals(true, shape1 instanceof Triangle);
assertEquals(true, shape2 instanceof Circle);
assertEquals(false, shape1 instanceof Circle);
assertEquals(false, shape2 instanceof Triangle);
```

## Static type checking

Java is a _statically typed_ programming language. This means that the computer will refuse to execute any Java program that is not _statically well-typed_.
Specifically, before the computer starts executing a Java program, it first type-checks it. If the type-check fails, the program is not executed.
The purpose of type-checking is to ensure that certain types of problems will never occur at run time. In particular, Java's static type system ensures
that a well-typed program never tries to call a method named M on an object whose class does not declare a method named M, and that it never tries to access
a field named F of an object whose class does not declare a field named F.

To ensure this, the Java type-checker assigns a _static type_ to each expression of the program, based on a simple analysis of the program text.
In particular:
- The static type of a variable reference is the declared type of the variable. For example, the static type of an expression `shape1`
  that appears in the scope of a variable declaration `Shape shape1` is `Shape`.
- Analogously, the static type of a field reference is the declared type of the field, and the static type of a method call is the declared return type of the method.

Java's static type-checking rules ensure that whenever an expression E evaluates to a value V at run time, then V is a value of the static type of E.
For example, Java's static type checker allows an assignment `x = E` only if the static type of expression E is compatible with the declared type of variable `x`.
This ensures that at any point during the execution of a program, the value stored in a variable is a value of the declared type of the variable.

To prevent bad method calls or field accesses, Java's static type checker allows a method call `E.m(...)` only if the static type of `E` is a class that declares a method named `m`.
Similarly, it allows a field access `E.f` only if the static type of `E` is a class that declares a field named `f`.

Java's static type-checker is _incomplete_, in the technical sense that in some cases it rejects a program even though no execution of that program would go wrong at run time.

For example, the following program never goes wrong, but it is rejected by Java's static type checker:
```java
Shape myShape = new Triangle(0, 0, 10, 0, 5, 10);
Triangle myTriangle = myShape;
int x1 = myTriangle.getX1();
```
Java's type checker rejects the assignment `myTriangle = myShape` because the static type of `myShape` is `Shape` and class `Shape` is not a subclass of class `Triangle`.

## Typecasts

To allow programmers to work around the incompleteness of Java's static type-checker, Java supports _typecasts_. The following program is accepted by Java's static type checker:
```java
Shape myShape = new Triangle(0, 0, 10, 0, 5, 10);
Triangle myTriangle = (Triangle)myShape;
int x1 = myTriangle.getX1();
```
Even though the static type of expression `myShape` is `Shape`, the static type of expression `(Triangle)myShape` is `Triangle`. The computer checks at run time, when evaluating expression
`(Triangle)myShape`, that the value of `myShape` is in fact a reference to an instance of class `Triangle`. If not, a `ClassCastException` is thrown.

We can use `instanceof` tests and typecasts to compute the drawing commands for a drawing given by an array of `Shape`s:
```java
public class Drawing {

    private Shape[] shapes;

    public String getDrawingCommands() {
        String drawingCommands = "";
        for (int i = shapes.length - 1; 0 <= i; i--) {
            Shape shape = shapes[i];
            if (shape instanceof Triangle)
                drawingCommands += ((Triangle)shape).getDrawingCommand();
            else
                drawingCommands += ((Circle)shape).getDrawingCommand();
            drawingCommands += "\n";
        }
        return drawingCommands;
    }
}
```

## Dynamic binding

The implementation of method `getDrawingCommands` shown above for composing the drawing commands for a drawing works, but it is not optimal from a modularity point of view: if we extend our drawing application to also support rectangles, we need to update method `getDrawingCommands`.

We can avoid this by using _dynamic binding_. Since each subclass of class `Shape` is supposed to declare a method `getDrawingCommand()`, we can declare an _abstract method_ `getDrawingCommand()` in class `Shape`:

```java
public abstract class Shape {

    public abstract String getDrawingCommand();

}
```

Java's static type checker checks that each class that extends `Shape` declares a method named `getDrawingCommand` that takes no parameters and has return type `String`. Correspondingly, since class `Shape` now declares a method `getDrawingCommand`, we can now call `getDrawingCommand` directly on an expression of static type `Shape`:

```java
public class Drawing {

    private Shape[] shapes;

    public String getDrawingCommands() {
        String drawingCommands = "";
        for (int i = shapes.length - 1; 0 <= i; i--) {
            Shape shape = shapes[i];
            drawingCommands += shape.getDrawingCommand();
            drawingCommands += "\n";
        }
        return drawingCommands;
    }
}
```

When the computer executes the method call `shape.getDrawingCommand()`, it determines which method body to execute based on the _dynamic type_ of the receiver object: if `shape` evaluates to a reference to an instance of `Triangle`, then the implementation of `getDrawingCommand()` in class `Triangle` is executed; if `shape` evaluates to a reference to an instance of `Circle`, then the implementation of `getDrawingCommand()` in class `Circle` is executed. This is known as _dynamic binding_ of method calls.

If a method declared by a subclass has the same name and the same number and types of parameters as a method declared by its superclass, we say it _overrides_ the superclass method. Calls of the method on an object of the subclass will execute the overriding method instead of the overridden method.

## Class Object

If, when declaring a class, we do not explicitly specify a superclass using an `extends` clause, the class implicitly extends class `java.lang.Object`. This means that every class is a direct or indirect subclass of class `java.lang.Object`. (Since package `java.lang` is always imported implicitly, we can simply write `Object`.) This also means that a variable of type `Object` can be used to store a reference to any object of any class.

Class `Object` declares a number of methods:

```java
package java.lang;

public class Object {

    /**
     * Returns the Class object for this object's class.
     */
    public Class getClass() { /* ... */ }

    /**
     * Returns a number suitable for use as a hash code when using this object as a key in a hash table.
     * Note: two objects that are equal according to the `equals(Object)` method must have the same hash code.
     * The implementation of this method in class java.lang.Object returns a hash code
     * based on the identity of this object. That is, this implementation usually returns a different number
     * for different objects, although this is not guaranteed.
     */
    public int hashCode() { /* ... */ }

    /**
     * Returns a textual representation of this object.
     * The implementation of this method in class java.lang.Object is based on the name of this object's class
     * and this object's identity-based hash code.
     */
    public String toString() { return this.getClass().getName() + "@" + Integer.toHexString(this.hashCode()); }

    /**
     * Returns whether this object is conceptually equal to the given object.
     * The implementation of this method in class java.lang.Object returns whether this object and the given
     * object are the same object.
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
assertEquals("This is Point [x=10, y=20].", "This is " + new Point(10, 20) + ".");
assertEquals(true, new Point(10, 20).equals(new Point(10, 20)));
assertEquals(new Point(10, 20), new Point(10, 20));
assertEquals(true, Arrays.asList(new Point(3, 9), new Point(7, 20)).contains(new Point(3, 9)));
assertEquals(true, Set.of(new Point(3, 9), new Point(7, 20)).contains(new Point(7, 20)));
```

If we had not overridden these methods, the behavior would be as follows:
```java
assertEquals("This is Point@12345678.", "This is " + new Point(10, 20) + ".");
assertEquals(false, new Point(10, 20).equals(new Point(10, 20)));
assertEquals(false, Arrays.asList(new Point(3, 9), new Point(7, 20)).contains(new Point(3, 9)));
assertEquals(false, Set.of(new Point(3, 9), new Point(7, 20)).contains(new Point(7, 20)));
```
