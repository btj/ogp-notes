# Implementation inheritance

Consider the following class `Color`, whose instances represent colors defined by their red, green, and blue components:
```java
public class Color {
    public final int red, green, blue;
    public Color(int red, int green, int blue) {
        this.red = red;
        this.green = green;
        this.blue = blue;
    }
    public int getHue() { /* ... */ }
    public int getSaturation() { /* ... */ }
    public int getValue() { /* ... */ }
    @Override
    public String toString() {
        return "rgb(" + red + ", " + green + ", " + blue + ")";
    }
    @Override
    public boolean equals(Object other) {
        return
            other.getClass() == getClass() &&
            ((Color)other).red == red &&
            ((Color)other).green == green &&
            ((Color)other).blue == blue;
    }
}
```
Often, this class is sufficient. But sometimes, we need to additionally store a _transparency value_. Instead of duplicating the existing functionality of `Color`,
we can declare class `TransparentColor` as a subclass of `Color`:
```java
public class TransparentColor extends Color {
    public final int transparency;
    public TransparentColor(int red, int green, int blue, int transparency) {
        super(red, green, blue);
        this.transparency = transparency;
    }
    @Override
    public String toString() {
        return "rgba(" + red + ", " + green + ", " + blue + ", " + transparency + ")";
    }
    @Override
    public boolean equals(Object other) {
        return super.equals(other) &&
        ((TransparentColor)other).transparency == transparency;
    }
}
```
Notice the following:
- Class `TransparentColor` _inherits_ the instance (i.e. non-static) fields `red`, `green`, and `blue` from class `Color`.
  This means that for each instance of class `TransparentColor`, the computer stores four values: the values for fields `red`, `green`, `blue`, and `transparency`.
- Java requires that a constructor first initialize the superclass fields. Typically, this means calling a superclass constructor, using the special syntax `super(...)`.
  If no explicit `super(...)` call is written at the start of a constructor, an implicit zero-argument `super()` call is inserted by the compiler. If the superclass has
  no zero-argument constructor, the compiler reports an error.
- The implementation of method `equals` in class `TransparentColor` reuses the implementation of `equals` in class `Color` by calling it using the special
  `super.M(...)` syntax. In contrast to regular instance method calls, `super` calls are _statically bound_: the `super.equals` call in class `TransparentColor` is
  always bound to method `equals` in class `Color`.
- Since method `equals` in class `Color` checks that `this.getClass()` equals `other.getClass()`, we know that after the call of this method in method `equals` of class `TransparentColor` returns `true`,
  `other` is an instance of of class `TransparentColor` so we can safely cast it to type `TransparentColor`.
- Methods `getHue`, `getSaturation`, and `getValue` are simply _inherited_ by class `TransparentColor` from class `Color`. This means that calling
  `getHue` on a `TransparentColor` object O executes method `getHue` from class `Color` on O. This, in turn, means that inside such an execution of method `getHue`,
  `this` will refer to an instance of class `TransparentColor`.
