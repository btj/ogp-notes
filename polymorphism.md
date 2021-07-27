# Polymorphism

Suppose we need to develop a drawing application. A drawing consists of a
number of circles and polygons, so we define a class where each instance
represents a circle and a class where each instance represents a polygon:

```java
public class Circle {
    
    private final int x;
    private final int y;
    private final int radius;
    
    public int getX() { return x; }
    public int getY() { return y; }
    public int getRadius() { return radius; }
    
    public Circle(int x, int y, int radius) {
        this.x = x;
        this.y = y;
        this.radius = radius;
    }
    
}
```

```java
public class Polygon {

    private final int[] coordinates;

    public int getNbVertices() { return coordinates.length / 2; }
    public int getX(int vertex) { return coordinates[vertex * 2]; }
    public int getY(int vertex) { return coordinates[vertex * 2 + 1]; }

    public Polygon(int... coordinates) {
        this.coordinates = coordinates.clone();
    }

}
```

(Constructor parameter `int... coordinates` is a *varargs parameter*; it is equivalent to `int[] coordinates` except that 
it allows `new Polygon(new int[] {1, 2, 3, 4, 5, 6})` to be written more concisely as `new Polygon(1, 2, 3, 4, 5, 6)`.)

A drawing, then, is a sequence of shapes, where a shape is either a circle or a polygon. The order among the shapes is important
in case of overlaps: the shapes are drawn in reverse order so that the first shape appears on top. How can we store this sequence?
We can store it using an array, but what should be the element type?

What we need is a type `Shape` that is conceptually the union of types `Circle` and `Polygon`: what we want is that an object
is an instance of `Shape` if and only if it is either an instance of `Circle` or an instance of `Polygon`.

For this purpose, Java has the concepts of _abstract classes_ and _inheritance_. We can declare an abstract class `Shape` and declare
classes `Circle` and `Polygon` as _subclasses_ of `Shape`:

```java
public abstract class Shape {
}

public class Circle extends Shape {
    // class body unchanged
}

public class Polygon extends Shape {
    // class body unchanged
}
```
We also say that `Circle` and `Polygon` _extend_ `Shape` and that they _inherit_ from `Shape`. `Shape` is the _superclass_ of `Circle` and `Polygon`.

A variable of type `Shape` is _polymorphic_: we can use it to store a reference to a `Circle` instance or a reference to a `Polygon` instance:
```java
Shape shape1 = new Circle(5, 10, 5);
Shape shape2 = new Polygon(-10, 0, 10, 0, 0, 20);
```
This also means we can use an array of type `Shape[]` to store both circles and polygons:
```java
Shape[] shapes = {new Circle(5, 10, 5), new Polygon(-10, 0, 10, 0, 0, 20)};
```

Once we have stored an object reference into a polymorphic variable, we can test whether it refers to an instance of a particular class using an `instanceof` expression:

```java
assertEquals(true, shape1 instanceof Circle);
assertEquals(true, shape2 instanceof Polygon);
assertEquals(false, shape1 instanceof Polygon);
assertEquals(false, shape2 instanceof Circle);
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
Shape myShape = new Circle(5, 10, 5);
Circle myCircle = myShape;
int radius = myCircle.getRadius();
```
Java's type checker rejects the assignment `myCircle = myShape` because the static type of `myShape` is `Shape` and class `Shape` is not a subclass of class `Circle`.

## Typecasts

To allow programmers to work around the incompleteness of Java's static type-checker, Java supports _typecasts_. The following program is accepted by Java's static type checker:
```java
Shape myShape = new Circle(5, 10, 5);
Circle myCircle = (Circle)myShape;
int radius = myCircle.getRadius();
```
Even though the static type of expression `myShape` is `Shape`, the static type of expression `(Circle)myShape` is `Circle`. The computer checks at run time, when evaluating expression
`(Circle)myShape`, that the value of `myShape` is in fact a reference to an instance of class `Circle`. If not, a `ClassCastException` is thrown.

We can use `instanceof` tests and typecasts to save a drawing given by an array of `Shape`s as a Scalable Vector Graphics (SVG) file:
```java
public class Drawing {

    private Shape[] shapes;

    public Drawing(Shape... shapes) {
        this.shapes = shapes.clone();
    }

    public String toSVG() {
        String svg = "<svg xmlns='http://www.w3.org/2000/svg'"
                     + " stroke='black' fill='transparent'>";
        for (Shape shape : shapes) {
            if (shape instanceof Circle) {
                Circle circle = (Circle)shape;
                svg += "<circle cx='" + circle.getX()
                       + "' cy='" + circle.getY()
                       + "' r='" + circle.getRadius()
                       + "'/>";
            } else {
                Polygon polygon = (Polygon)shape;
                svg += "<polygon points='";
                for (int k = 0; k < polygon.getNbVertices(); k++)
                    svg += polygon.getX(k) + " " + polygon.getY(k) + " ";
                svg += "'/>";
            }
        }
        return svg + "</svg>";
    }

    public void saveAsSVG(String filename) throws Exception {
        Files.writeString(
            new File(filename + ".svg").toPath(),
            toSVG(),
            StandardCharsets.UTF_8);
    }
    
    public static void main(String[] args) throws Exception {
    	Drawing drawing = new Drawing(
    	    new Polygon(0, 0, 300, 0, 150, 200),
    	    new Circle(150, 100, 80)
    	);
    	drawing.saveAsSVG("drawing");
    }

}
```

### Pattern matching

Consider the following piece of code:
```java
if (shape instanceof Circle) {
    Circle circle = (Circle)shape;
    area = circle.getRadius() * circle.getRadius() * Math.PI;
}
```
Since Java 16, released in March 2021, we can write this code more concisely as follows:
```java
if (shape instanceof Circle circle)
    area = circle.getRadius() * circle.getRadius() * Math.PI;
```

This form of the `instanceof` operator is called the *pattern match operator*.
More generally, a pattern matching expression `E instanceof T x` is evaluated
by first evaluating `E` to a value `V`. If `V` is `null` or a reference to an
object that is not an instance of type `T`, the pattern matching expression
evaluates to `false`; otherwise, it evaluates to `true` and *pattern variable*
`x` is bound to `V`. It is advisable to use a pattern matching expression
instead of a traditional `instanceof` check followed by a typecast wherever
possible.

## Class Object

It is not, in fact, strictly true that we needed to introduce a class `Shape` in order
to be able to store `Circle` objects and `Polygon` objects in an array. We could have
used the built-in class `Object` instead. The following works:
```java
Object[] shapes = {new Circle(5, 10, 5), new Polygon(-10, 0, 10, 0, 0, 20)};
```
This is because
```java
class Circle { /* ... */ }
class Polygon { /* ... */ }
```
is equivalent to
```java
class Circle extends Object { /* ... */ }
class Polygon extends Object ( /* ... */ }
```
Indeed, if a class (other than class `Object` itself) does not explicitly extend another class, it implicitly extends class `Object`.
It follows that class `Object` is the direct or indirect superclass of all classes in a Java program.
It also follows that a variable of type `Object` can store a reference to any Java object.

This is both a strength and a weakness: if `shapes` is of type `Object[]`, nothing stops us from storing a
`String` object into it:
```java
Object[] shapes = {new Circle(5, 10, 5), new Polygon(-10, 0, 10, 0, 0, 20), "Hi!"};
```
Our `Drawing` class shown above would crash when trying to convert this drawing to SVG. (Specifically,
it would throw a `ClassCastException` when trying to cast the `String` object to type `Polygon`.)
In contrast, the statement
```java
Shape[] shapes = {new Circle(5, 10, 5), new Polygon(-10, 0, 10, 0, 0, 20), "Hi!"};
```
is rejected by Java's static type checker, since class `String` is not a subclass of class `Shape`.
Therefore, using a specific abstract class is generally preferable to using class `Object`.

### Class Object and primitive values

Java's primitive types `boolean`, `byte`, `short`, `char`, `int`, `long`, `float`, and `double` are not classes
and their values are not objects. Nonetheless, the following works:
```java
Object[] values = {true, 42, 'A', 3.14};
```
To make this work, Java implicitly converts these values of primitive types to instances of corresponding *wrapper classes*, as follows:
```java
Object[] values = {
    Boolean.valueOf(true),
    Integer.valueOf(42),
    Character.valueOf('A'),
    Double.valueOf(3.14)
};
```
Static method `valueOf` of class `Boolean` returns the instance of class `Boolean` corresponding to the given `boolean` value. Analogously,
method `valueOf` of class `Integer` returns an instance of class `Integer` corresponding to the given `int` value. This generally
involves creating a new object, so it may have a significant cost in space and time. The wrapper classes for types `byte`, `short`, `long`, and `float` are `Byte`, `Short`, `Long`, and `Float`.

This feature is known as *autoboxing*. Java also supports *auto-unboxing*:
```java
int sumOfIntegers = 0;
for (Object value : values)
    if (value instanceof Integer i)
        sumOfIntegers += i;
```
Java implicitly calls the appropriate inspector on the wrapper class to retrieve the primitive value. The line `sumOfIntegers += i;` is equivalent to
`sumOfIntegers += i.intValue();`. Similarly, `sumOfIntegers += (int)values[1];` is equivalent to `sumOfIntegers += ((Integer)values[1]).intValue();`.
