### Interfaces

Suppose we are implementing a programming language. Our language supports the
datatypes `boolean`, `int`, and `string`, amongst others:
```java
public abstract class Type {}

public class BooleanType extends Type {
    private BooleanType() {}
    public static final BooleanType INSTANCE = new BooleanType();
}

public class IntType extends Type {
    private IntType() {}
    public static final IntType INSTANCE = new IntType();
}

public class StringType extends Type {
    private StringType() {}
    public static final StringType INSTANCE = new StringType();
}

public abstract class Value {
    public abstract Type getType(); 
}

public class BooleanValue extends Value {
    public final boolean value;
    public Type getType() { return BooleanType.INSTANCE; }
    private BooleanValue(boolean value) { this.value = value; }
    public final static BooleanValue TRUE = new BooleanValue(true);
    public final static BooleanValue FALSE = new BooleanValue(false);
    public static BooleanValue of(boolean value) { return value ? TRUE : FALSE; }
}

public class IntValue extends Value {
    public final int value;
    public Type getType() { return IntType.INSTANCE; }
    private IntValue(int value) { this.value = value; }
    public final static IntValue ZERO = new IntValue(0);
    public static IntValue of(int value) {
        return value == 0 ? ZERO : new IntValue(value);
    }
}

public class StringValue extends Value {
    public final String value;
    public Type getType() { return StringType.INSTANCE; }
    private StringValue(String value) { this.value = value; }
    public final static StringValue EMPTY = new StringValue("");
    public static StringValue of(String value) {
        return value.equals("") ? EMPTY : new StringValue(value);
    }
}
```
First of all, notice the following:
- Classes `BooleanType`, `IntType`, and `StringType` are examples of the _Singleton Pattern_: it does not make sense to create more than one instance of class `BooleanType`, so, instead of offering to clients a way to create new instances of class `BooleanType`, the class offers only a _static field_ `INSTANCE` that refers to the only instance of class `BooleanType` that will ever exist. A static field differs from a regular field in that it is a property of the class itself, rather than a property of each instance of the class.
- Classes `BooleanValue`, `IntValue`, and `StringValue` are examples of immutable value classes. Instead of exposing a constructor to clients directly, class `BooleanValue` offers a static method `of` that clients can use to obtain a `BooleanValue` instance corresponding to a particular `boolean` value. Instead of creating a new instance of `BooleanValue` at each call, method `of` reuses a `BooleanValue` instance stored in a static field of the class. Similarly, method `of` of class `IntValue` reuses an `IntValue` instance stored in static field `ZERO` if an `IntValue` instance corresponding to value `0` is requested; if some other value is requested, a new `IntValue` instance is created. Class `StringValue` implements this pattern as well.
- Names of `static final` fields are often written in all-uppercase.

Now suppose that in our programming language, like in Java, we can use the `+` operator to add `int` values and to concatenate `string` values, but we cannot use it on `boolean` values. Furthermore,
suppose that, again like in Java, we can use the logical AND operator `&` to compute the  bitwise AND of two `int` values and to compute the logical AND of two `boolean` values, but we cannot use it
on `string` values. To implement this, it would make sense to make classes `IntType` and `StringType` extend an abstract class `AddableType` with an abstract method `add`, and to make classes `BooleanType` and `IntType` extend an abstract class `AndableType` with an abstract method `and`. We could then implement a method `evaluate` as follows:
```java
public abstract class AddableType {
    public abstract Value add(Value leftOperand, Value rightOperand);
}
public abstract class AndableType {
    public abstract Value and(Value leftOperand, Value rightOperand);
}
public class BooleanType extends Type, AndableType { // ERROR
    // ...
    public Value and(Value leftOperand, Value rightOperand) {
        return BooleanValue.of(((BooleanValue)leftOperand).value
            & ((BooleanValue)rightOperand).value);
    }
}
public class IntType extends Type, AddableType, AndableType { // ERROR
    // ...
    public Value add(Value leftOperand, Value rightOperand) {
        return IntValue.of(((IntValue)leftOperand).value
            + ((IntValue)rightOperand).value);
    }
    public Value and(Value leftOperand, Value rightOperand) {
        return IntValue.of((IntValue)leftOperand).value
            & ((IntValue)rightOperand).value);
    }
}
public class StringType extends Type, AddableType { // ERROR
    // ...
    public Value add(Value leftOperand, Value rightOperand) {
        return StringValue.of(((StringValue)leftOperand).value
            + ((StringValue)rightOperand).value);
    }
}
public class Interpreter {
    public static Value evaluate(Value value1, char operator, Value value2) {
        Type type = value1.getType();
        if (type != value2.getType())
            throw new UnsupportedOperationException(
                "The operand types do not match");
        switch (operator) {
            case '+':
                if (!(type instanceof AddableType))
                    throw new UnsupportedOperationException(
                        "Type " + type + " does not support the + operator");
                return ((AddableType)type).add(value, value2);
            case '&':
                if (!(type instanceof AndableType))
                    throw new UnsupportedOperationException(
                        "Type " + type + " does not support the & operator");
                return ((AndableType)type).and(value1, value2);
            // ...
         }
    }
}
```
Unfortunately, this is not valid Java code: Java does not allow a class to extend multiple superclasses. (Some other programming languages, such as C++, do allow such _multiple inheritance_.) However, Java does allow a restricted form of multiple inheritance: it allows a class to extend from one superclass and zero or more _interfaces_. An interface, declared using the `interface` keyword, is in most ways just like a class, except that it is not allowed to declare any instance (i.e. non-static) fields and it is not allowed to declare any constructors. We can therefore turn the incorrect program above into the correct program below:
```java
public interface AddableType {
    Value add(Value leftOperand, Value rightOperand);
}
public interface AndableType {
    Value and(Value leftOperand, Value rightOperand);
}
public class BooleanType extends Type implements AndableType {
    // ...
    public Value and(Value leftOperand, Value rightOperand) {
        return BooleanValue.of(((BooleanValue)leftOperand).value
            & ((BooleanValue)rightOperand).value);
    }
}
public class IntType extends Type implements AddableType, AndableType {
    // ...
    public Value add(Value leftOperand, Value rightOperand) {
        return IntValue.of(((IntValue)leftOperand).value
            + ((IntValue)rightOperand).value);
    }
    public Value and(Value leftOperand, Value rightOperand) {
        return IntValue.of((IntValue)leftOperand).value
            & ((IntValue)rightOperand).value);
    }
}
public class StringType extends Type implements AddableType {
    // ...
    public Value add(Value leftOperand, Value rightOperand) {
        return StringValue.of(((StringValue)leftOperand).value
            + ((StringValue)rightOperand).value);
    }
}
public class Interpreter {
    public static Value evaluate(Value value1, char operator, Value value2) {
        Type type = leftOperand.getType();
        if (type != rightOperand.getType())
            throw new UnsupportedOperationException(
                "The operand types do not match");
        switch (operator) {
            case '+':
                if (!(type instanceof AddableType))
                    throw new UnsupportedOperationException(
                        "Type " + type + " does not support the + operator");
                return ((AddableType)type).add(value1, value2);
            case '&':
                if (!(type instanceof AndableType))
                    throw new UnsupportedOperationException(
                        "Type " + type + " does not support the & operator");
                return ((AndableType)type).and(value1, value2);
            // ...
         }
    }
}
```
Notice the following:
- Interfaces are like abstract classes in that you cannot directly instantiate an interface (although you can instantiate a class that implements the interface). Interfaces are always abstract; it is
not necessary to specify the `abstract` keyword.
- Methods declared by interfaces are `public` and `abstract` by default; these keywords need not be specified explicitly.
- A class can _extend_ at most one superclass, but it can additionally _implement_ any number of interfaces. The interfaces are specified after the `implements` keyword. A class that implements an interface must _implement_ each of the interface's methods (i.e. declare, for each of the interface's methods, a non-abstract method that overrides it), unless the class is declared `abstract` itself.
- You can use the `instanceof` operator to test if an object implements an interface, in exactly the same way that you can test if it is an instance of some class. Furthermore, you can use a typecast to cast an object to an interface type, and then call the interface's methods on it. Just like when casting to a class type, a run-time check will be performed to check that the object's class indeed implements the interface; if not, a `ClassCastException` is thrown.
