# First Steps in Modular Programming (Part I)

### Contents

- [Installing Eclipse and FSC4J](#installing-eclipse-and-fsc4j)
- [Building and running our first program in Eclipse](#building-and-running-our-first-program-in-Eclipse)
- [The problem](#the-problem)
- [Encapsulating the fields of class Interval](#encapsulating-the-fields-of-class-interval)
- [Moving the methods inside class Interval](#moving-the-methods-inside-class-interval)
- [Enforcing encapsulation: accessibility modifiers](#enforcing-encapsulation-accessibility-modifiers)
- [Instance methods](#instance-methods)

In the previous lecture, we used the JLearner tool to make acquaintance with the Java programming language. We used variables, arrays, and class objects to store and process data. From this perspective, Java is not much different from Python. The main difference is that Java is statically typed, which means that we need to specify the type of each local variable, method parameter, method result, array element, and class field in our program. The types we have seen are `int`, the type of integers, `int[]`, the type of arrays of integers, `int[][]`, the type of arrays of arrays of integers, and the various class types corresponding to the classes we declared, such as `Node` and `List`.

In this lecture, we will move on to _modular programming_. In modular programming, we split our program into _modules_, with the goal of being able to build, understand, verify, and evolve each module separately and in parallel with the other modules of the program. To achieve this, it is necessary that we clearly specify the _API_ between a module and its _clients_ (the modules that use the module).

To illustrate this, let's write a program that stores and manipulates _intervals_ of integers. An interval is defined by a lower bound and an upper bound, so we declare a class `Interval`, with fields `lowerBound` and `upperBound`:

```java
class Interval {
    int lowerBound;
    int upperBound;
}
```

Here is a program that manipulates an interval:

```java
Interval interval = new Interval();
interval.lowerBound = 3;
interval.upperBound = 7;

int width = interval.upperBound - interval.lowerBound;
assert width == 4;
```

The `assert` statement checks if a given expression evaluates to `true`. If not, it reports an error.

We can run this program directly in [JLearner](https://btj.github.io/jlearner/), but since JLearner does not support Java's modularity features, at this point, we will switch to a more complex but more powerful tool: the Eclipse IDE (Integrated Development Environment).

## Installing Eclipse and FSC4J

We recommend that you use the [Eclipse Installer](https://www.eclipse.org/downloads/packages/installer) to install the latest Eclipse IDE for Java Developers; it will also install a matching Java Development Kit (JDK) if one is not yet present on your system.

Once you have installed Eclipse, we recommend that you install the [Formal Specifications Checker for Java (FSC4J)](https://fsc4j.github.io/fsc4j), that we are developing. It is a modified version of the Java Development Tools component of Eclipse that gives you feedback about the formal documentation you write. To install it, just follow the instructions on the FSC4J website.

## Building and running our first program in Eclipse

Once Eclipse is installed, start it by double-clicking the Eclipse program. First, if you see the _Welcome to the Eclipse IDE for Java Developers_ screen, uncheck the _Always show Welcome at start up_ box in the bottom right corner of the screen, and then click the _Workbench_ button in the top right corner of the screen.

In Eclipse, to create a program you must first create a project. To do so, in the File menu, choose New -> Java Project. Enter `interval` as the project name and click _Finish_. In the _Create module-info.java_ dialog box, choose _Don't Create_. The project will now appear in your _Package Explorer_ view. If you do not see the Package Explorer view, in the Window menu, choose Show View -> Package Explorer.

In the Package Explorer, if the node for project `interval` is collapsed, expand it by clicking the node. You will see that the project has an `src` folder. This is where you will store all of the program's source code files. (In Java, names of source code files end with `.java`.) Any `.java` file outside the `src` folder will be ignored by Eclipse.

In Java, each class must be in its own file. Let's create a source code file for the `Interval` class. Right-click the `interval` project's `src` node in the Project Explorer and choose New -> Class. In the _New Java Class_ dialog box, enter `Interval` as the class name and choose _Finish_. You will see that a new node corresponding to a new source file `Interval.java` appears in the Project Explorer, and an editor appears for editing the new source files. Notice that the source file node is below a new node `interval`. This node represents the _package_ `interval`. Indeed, Eclipse by default adds new classes in a project `xyz` to a _package_ named `xyz`. In Java, packages serve to group classes. We will learn more about packages later.

The initial contents of the `Interval.java` source file are as follows:
```java
package interval;

public class Interval {

}
```

For now, replace the given class declaration by the one shown above:
```java
package interval;

class Interval {
    int lowerBound;
    int upperBound;
}
```

We now want to write the code that uses the `Interval` class. In JLearner, statements and expressions can be written directly in the respective boxes. In real Java, however, all statements and expressions must be inside _methods_, and all methods must be inside _classes_. Therefore, we will create a class to hold our program. In the Package Explorer, right-click on the `interval` package and choose New -> JUnit Test Case. A JUnit test case is a class intended to just contain some code that we want to run. Enter `IntervalTest` as the name for the test case, and choose _Finish_. If Eclipse asks whether to add JUnit to the build path, choose OK.

The initial contents of source file `IntervalTest` are as follows:
```java
package interval;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class IntervalTest {

	@Test
	void test() {
		fail("Not yet implemented");
	}

}
```

We can write our code inside the `test` method. Replace the existing code by the code we wrote above:
```java
package interval;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class IntervalTest {

	@Test
	void test() {
		Interval interval = new Interval();
		interval.lowerBound = 3;
		interval.upperBound = 7;

		int width = interval.upperBound - interval.lowerBound;
		assert width == 4;
	}

}
```

We are now ready to run our code. Right-click on the `IntervalTest.java` node in the Package Explorer, and choose Run As -> JUnit Test. The JUnit view should appear and show a green bar, indicating that our program was executed successfully, without detecting any errors.

To see what happens if an error is detected, change `width == 4` to `width == 5` and run the program again. A shortcut for running the same program again is to simply click the green Play button in the Eclipse toolbar. Notice that you now get a red bar in the JUnit view. The Failure Trace part of the JUnit view tells you what went wrong. In this case an `AssertionError` occurred at `IntervalTest.java:16`, meaning line 16 of file `IntervalTest.java`. Double-click this message in the Failure Trace to highlight this line in the editor. If we change `width == 5` back to `width == 4` and run the program again, we again get a green bar.

## The problem

We have now written a program consisting of two source files: `Interval.java` and `IntervalTest.java`. However, our program is not modular: we cannot change the structure of class `Interval` without breaking the `IntervalTest` program. For example, suppose we decide that it is better to store intervals by storing their lower bound and their width, rather than their lower bound and their upper bound. Update file `Interval.java` as follows:

```java
package interval;

class Interval {
	int lowerBound;
	int width;
}
```

Even though, conceptually, the class stores the same information as before, just in a different form, we have now broken our _client code_ (i.e. the code that uses our class). Indeed, Eclipse now shows a red wavy line below the references to field `upperBound` in `IntervalTest.java`; these references are now broken since this field no longer exists. These red wavy lines are known as _compilation errors_. They are errors that the programming environment detects even before we run the program. Errors detected only while running a program are called _run-time errors_. We here see a major advantage of statically typed programming languages: many errors can be detected even before we run the program.

## Encapsulating the fields of class Interval

This experiment shows that we should never access the fields of another class directly. Instead, we should access the information we need from an object through _methods_. This is known as _encapsulation_. Let's update our program in `IntervalTest` to use methods to access the properties of `Interval` objects. First, define methods for inspecting and updating the properties of an interval:

```java
package interval;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class IntervalTest {

	int getLowerBound(Interval interval) {
		return interval.lowerBound;
	}
	
	int getUpperBound(Interval interval) {
		return interval.lowerBound + interval.width;
	}
	
	int getWidth(Interval interval) {
		return interval.width;
	}
	
	void setLowerBound(Interval interval, int value) {
		interval.lowerBound = value;
	}
	
	void setUpperBound(Interval interval, int value) {
		interval.width = value - interval.lowerBound;
	}
	
	void setWidth(Interval interval, int value) {
		interval.width = value;
	}

	@Test
	void test() {
		Interval interval = new Interval();
		interval.lowerBound = 3;
		interval.upperBound = 7;

		int width = interval.upperBound - interval.lowerBound;
		assert width == 4;
	}

}
```

Then, in the program, use these methods (known as _getters_ and _setters_) instead of accessing the fields of the `Interval` object directly:

```java
package interval;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class IntervalTest {

	int getLowerBound(Interval interval) {
		return interval.lowerBound;
	}
	
	int getUpperBound(Interval interval) {
		return interval.lowerBound + interval.width;
	}
	
	int getWidth(Interval interval) {
		return interval.width;
	}
	
	void setLowerBound(Interval interval, int value) {
		interval.lowerBound = value;
	}
	
	void setUpperBound(Interval interval, int value) {
		interval.width = value - interval.lowerBound;
	}
	
	void setWidth(Interval interval, int value) {
		interval.width = value;
	}

	@Test
	void test() {
		Interval interval = new Interval();
		setLowerBound(interval, 3);
		setUpperBound(interval, 7);

		int width = getWidth(interval);
		assert width == 4;
	}

}
```

Notice that Eclipse does not show any compilation errors anymore. Furthermore, if we run the program, we get a green bar. More importantly, though, if we now decide to change the structure of class Interval again, we only need to update the relevant getters and setters, and we do not need to touch our client program in method `test` at all. Indeed, replace field `int width` by field `int upperBound` in `Interval.java`. Eclipse will show compilation errors in the places where field `width` is referenced in file `IntervalTest.java`, but notice that these references are all inside the getters and setters. Updating those eliminates the errors:

```java
package interval;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class IntervalTest {
	
	int getLowerBound(Interval interval) {
		return interval.lowerBound;
	}
	
	int getUpperBound(Interval interval) {
		return interval.upperBound;
	}
	
	int getWidth(Interval interval) {
		return interval.upperBound - interval.lowerBound;
	}
	
	void setLowerBound(Interval interval, int value) {
		interval.lowerBound = value;
	}
	
	void setUpperBound(Interval interval, int value) {
		interval.upperBound = value;
	}
	
	void setWidth(Interval interval, int value) {
		interval.upperBound = interval.lowerBound + value;
	}

	@Test
	void test() {
		Interval interval = new Interval();
		setLowerBound(interval, 3);
		setUpperBound(interval, 7);

		int width = getWidth(interval);
		assert width == 4;
	}

}
```

## Moving the methods inside class Interval

We now have two modules: one module consists of file `Interval.java` plus the getters and setters in file `IntervalTest.java`, and the other module consists of method `test` in file `IntervalTest.java`. We can change the way we store the interval properties in the first module without breaking the second module. However, it would of course be much better if each module is in its own file. For this reason, Java allows us to define the methods that belong together with a given class inside the class itself. To move a method into a class, however, we need to prefix it with the keyword `static`:

```java
package interval;

class Interval {
	int lowerBound;
	int upperBound;

	static int getLowerBound(Interval interval) {
		return interval.lowerBound;
	}
	
	static int getUpperBound(Interval interval) {
		return interval.upperBound;
	}
	
	static int getWidth(Interval interval) {
		return interval.upperBound - interval.lowerBound;
	}
	
	static void setLowerBound(Interval interval, int value) {
		interval.lowerBound = value;
	}
	
	static void setUpperBound(Interval interval, int value) {
		interval.upperBound = value;
	}
	
	static void setWidth(Interval interval, int value) {
		interval.upperBound = interval.lowerBound + value;
	}

}
```

(You will understand later why we did not need to write the `static` keyword when we defined the getters and setters in class `IntervalTest` originally.)

Furthermore, in file `IntervalTest.java`, we now need to tell Java that it needs to look inside class `Interval` to find the getters and setters. We do so by putting the class name and a dot in front of the method name:

```java
package interval;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class IntervalTest {
	
	@Test
	void test() {
		Interval interval = new Interval();
		Interval.setLowerBound(interval, 3);
		Interval.setUpperBound(interval, 7);

		int width = Interval.getWidth(interval);
		assert width == 4;
	}

}
```

## Enforcing encapsulation: accessibility modifiers

We have now cleanly separated our interval module and our client module into separate files and separate classes. If we want to change the way we store the interval properties again, we only need to update the `Interval` class; this is thanks to the fact that the `IntervalTest` class accesses the interval properties only via the getters and setters, not by directly accessing the fields of class `Interval`.

However, there is currently nothing that prevents the authors of `IntervalTest` from (perhaps accidentally) changing the program to access the fields of `Interval` directly, thus breaking modularity. Fortunately, Java offers a way to make this impossible: it allows us to indicate that certain elements defined inside a given class (called _members_ of the class) are only for use by other members of the same class, by using the `private` keyword:

```java
package interval;

class Interval {
	private int lowerBound;
	private int upperBound;

	static int getLowerBound(Interval interval) {
		return interval.lowerBound;
	}
	
	static int getUpperBound(Interval interval) {
		return interval.upperBound;
	}
	
	static int getWidth(Interval interval) {
		return interval.upperBound - interval.lowerBound;
	}
	
	static void setLowerBound(Interval interval, int value) {
		interval.lowerBound = value;
	}
	
	static void setUpperBound(Interval interval, int value) {
		interval.upperBound = value;
	}
	
	static void setWidth(Interval interval, int value) {
		interval.upperBound = interval.lowerBound + value;
	}

}
```

Now, if we replace `Interval.setUpperBound(interval, 7)` by `interval.upperBound = 7` in class `IntervalTest`, we immediately get a compilation error: _The field `Interval.upperBound` is not visible._ Fix the error by restoring the setter call.

By making the fields of class `Interval` private, we now get the guarantee that any client code of class `Interval` that has no compilation errors will not break if we change the way we store the interval properties. If our module is used by many clients around the world, this is an extremely valuable guarantee.

## Instance methods

Notice that all of the methods of class `Interval` take a reference to an `Interval` object as their first argument. This is of course a very common phenomenon. For that reason, Java supports a more concise notation for this case, known as _instance methods_. An instance method is a method declared without the `static` keyword. (A method that does have the `static` keyword is known as a _static method_.) An instance method declared in a class C has an _implicit_ parameter of type C, called the _receiver_. To refer to the receiver in the body of an instance method, use the keyword `this`. When calling an instance method, the receiver object is written before the method name, with a dot in between the two:

```java
package interval;

class Interval {
	private int lowerBound;
	private int upperBound;

	int getLowerBound() {
		return this.lowerBound;
	}
	
	int getUpperBound() {
		return this.upperBound;
	}
	
	int getWidth() {
		return this.upperBound - this.lowerBound;
	}
	
	void setLowerBound(int value) {
		this.lowerBound = value;
	}
	
	void setUpperBound(int value) {
		this.upperBound = value;
	}
	
	void setWidth(int value) {
		this.upperBound = this.lowerBound + value;
	}

}
```

```java
package interval;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class IntervalTest {
	
	@Test
	void test() {
		Interval interval = new Interval();
		interval.setLowerBound(3);
		interval.setUpperBound(7);

		int width = interval.getWidth();
		assert width == 4;
	}

}
```

So, `Interval.setLowerBound(interval, 3)` becomes `interval.setLowerBound(3)`. Here, `interval` is the receiver for the call of method `setLowerBound`. Since `interval` is of type `Interval`, Java will look in class `Interval` to find method `setLowerBound`.

Notice that both the method declarations and the method calls become much more concise this way. But remember that the meaning is exactly the same as before; it's just a shorter way to write the same program.

In fact, we can use an additional Java shorthand to write class `Interval` even more concisely: instead of writing `this.lowerBound`, we can just write `lowerBound`. When Java encounters the name `lowerBound`, used as an expression in an instance method, and the method declares no parameter or local variable named `lowerBound`, then it will look for a field called `lowerBound` in the receiver object. This means we can write class `Interval` as follows:

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

So, again, this program has exactly the same meaning as the previous ones, and will behave in exactly the same way; it's just shorter. Notice that Eclipse tells you whether it interprets a name as a reference to a local variable or a reference to a field: references to fields are shown in blue, references to local variables in black.
