# Iterators

In the preceding chapters, we have studied how to define and document APIs, of increasing complexity.
Defining, implementing and interacting with APIs are important skills for software engineers.
In this chapter and the next, we discuss two more advanced techniques that are widely used in practical APIs: iterators and generics.
The former are a design pattern for offering a standard API for iterating over different data structures (like arrays, linked lists or balanced trees).
The latter are a programming language feature that allows defining APIs that are parameterised by argument types.

_Iterators_ are a solution to an _API design problem_: how to introduce an _abstract API_ between a collection implementation and its clients, that hides the data structure used to implement the collection, without increasing the time or space (memory) usage of clients that iterate over the elements of the collection?

## The problem

We illustrate the problem by means of the example of two data structures for storing a collection of objects, and a client that iterates over both of them:

```java
public class ArrayList {

    public Object[] elements;

}
```
```java
public class LinkedList {

    public static class Node {
        public Object value;
        public Node next;
    }

    public Node firstNode;

}
```
```java
public class ClientProgram {

    public void printAll(ArrayList arrayList) {
        for (int i = 0; i < arrayList.elements.length; i++)
            System.out.println(arrayList.elements[i]);
    }

    public void printAll(LinkedList linkedList) {
        for (LinkedList.Node node = linkedList.firstNode;
             node != null;
             node = node.next)
            System.out.println(node.value);
    }

    public void printBoth(ArrayList arrayList, LinkedList linkedList) {
        printAll(arrayList);
        printAll(linkedList);
    }

}
```
Notice the following:
- No abstraction or encapsulation is applied to the two data structures; clients have direct access to the representation. Of course, it is recommended to apply abstraction and encapsulation
  as much as possible. However, in this example we do not yet apply it because it is the point of this text to figure out how such an abstraction should be designed in the first place.
- The class of linked list nodes is defined as a _static nested class_ within the class of linked lists. This is essentially equivalent to defining it in the usual way outside of another class,
  except that in order to refer to it from outside of the enclosing class, you need to qualify its name by the name of the enclosing class. For example, in the client program the class is referred to as `LinkedList.Node`. More details about static and non-static nested classes will follow later in this text.
- When passing an object as an argument, `System.out.println` calls `toString()` on it and prints the resulting string to the screen.
- The two invocations of `printAll` will be resolved to the two overloaded implementations based on the static type of the argument.

Notice also that the client program has to duplicate the logic of printing all elements for the two data structures. The question we consider in this text is: how can we introduce an API that generalizes the two data structures, and allows the client to write the logic for printing all elements only once and apply it unchanged to both data structures, without hurting performance?

Let's first consider two approaches that are not a solution:
- We could introduce a method into both data structures that returns the elements as an array; the client could call it and then iterate over the array to print all elements.
  However, this would increase the memory usage of the client: temporarily converting the linked list to an array would require an amount of extra memory linear in the number of elements in the collection.
- Alternatively, we could implement a method `getElement(int i)` in the `LinkedList` class that returns the `i`th element of the list.
  `printAll` could then use this method to iterate over the list in the same way as it iterates over the array.
  The downside of this approach is that it increases the time complexity: `getElement(i)` requires a number of steps linear in the length of the list, which would give `printAll` quadratic time complexity.
  
To see the solution, carefully consider both `printAll` methods and notice that they follow a similar pattern: they use some piece of data to track where they are in the data structure: respectively an index into the array and a pointer to the current node of the list.
Then, they perform a test on the piece of data to see whether they have reached the end of the data structure; they retrieve the current element pointed to by the piece of data; and they update the piece of data to point to the next element.

## Iterators

The solution, then, is to encapsulate this piece of data into an object, which we will call an _iterator_, and provide methods to allow clients to test whether the iterator has reached the end of the data structure, to retrieve the current element, and to mutate the iterator so that it points to the next element.

Such an _iterator API_ can take a few different forms, depending on whether and how some of these functionalities are combined into a single method. Whereas most programming languages define some kind of standard iterator API, they do so in different ways. However, in the end all of these forms are essentially equivalent.

We show the styles used by some of the most popular programming languages (translated into Java syntax) below:

```java
// Java
public interface Iterator {
    boolean hasNext();
    /**
     * Mutates the iterator to point to the next element and returns the current
     * element.
     */
    Object next();
}

// C#
public interface Enumerator {
    Object getCurrent();
    /**
     * Mutates the enumerator to point to the next element, or returns `false` if
     * the end has been reached.
     */
    boolean moveNext();
}

// C++
public interface Iterator {
    Object getCurrent(); // syntax in C++: *iterator
    void moveNext(); // syntax in C++: iterator++
    // in C++, to tell whether you have reached the end of the data structure, you
    // have to test equality with a special "one-past-the-end" iterator
    boolean equals(Iterator other);
}

// Python
public interface Iterator {
    /**
     * Throws a StopIteration exception if the end of the data structure has been
     * reached.
     */
    Object next();
}

// JavaScript
public interface Iterator {
    // Nested classes inside interfaces are implicitly public and static
    class NextResult { public Object value; public boolean done; }
    /**
     * If result.done is true, result.value is not an element but an "iterator
     * return value".
     */
    NextResult next();
}
```

Note: we also omitted some optional additional functionalities provided by some of the APIs. For example, Java's iterator API optionally supports removing the current element, and C#'s API optionally supports resetting the iterator so that it again points to the first element of the collection. In each case, the extra method throws an exception if the iterator object does not support the operation.

In the remainder of this text, we use the Java-style `Iterator` API.

We can implement iterators for `ArrayList` and `LinkedList` as follows:
```java
public class ArrayListIterator implements Iterator {

    public ArrayList arrayList;
    public int index;

    public ArrayListIterator(ArrayList arrayList) {
        this.arrayList = arrayList;
    }

    public boolean hasNext() { return index < arrayList.elements.length; }

    public Object next() { return arrayList.elements[index++]; }

}
```
```java
public class LinkedListIterator implements Iterator {

    public LinkedList.Node node;

    public LinkedListIterator(LinkedList linkedList) {
        node = linkedList.firstNode;
    }

    public boolean hasNext() { return node != null; }

    public Object next() {
        Object result = node.value;
        node = node.next;
        return result;
    }

}
```
Again, for now we do not apply any encapsulation.

This way, the client can now reuse the logic for printing all elements:
```java
public class ClientProgram {

    public void printAll(Iterator iterator) {
        while (iterator.hasNext())
            System.out.println(iterator.next());
    }

    public void printBoth(ArrayList arrayList, LinkedList linkedList) {
        printAll(new ArrayListIterator(arrayList));
        printAll(new LinkedListIterator(linkedList));
    }

}
```

## Iterables

We can perform a further step of generalization, and further simplify the client code, by introducing an interface to be implemented by
any collection that supports iteration:
```java
public interface Iterable {
    /** Returns a new iterator that points to the start of the data structure. */
    Iterator iterator();
}
```
We can easily update classes `ArrayList` and `LinkedList` to implement this interface. For example, we can update class
`ArrayList` as follows:
```java
public class ArrayList implements Iterable {

    public Object[] elements;

    public Iterator iterator() { return new ArrayListIterator(this); }

}
```
This allows us to simplify the client code as follows:
```java
public class ClientProgram {

    public void printAll(Iterable iterable) {
        for (Iterator iterator = iterable.iterator(); iterator.hasNext(); )
            System.out.println(iterator.next());
    }

    public void printBoth(Iterable collection1, Iterable collection2) {
        printAll(collection1);
        printAll(collection2);
    }

}
```
Notice that the client no longer even needs to know that it is dealing with an array-based list and a linked list.

## Applying nested classes

### Static nested classes

Classes `ArrayList` and `ArrayListIterator` are not really independent classes; rather, they together implement the `Iterable` abstraction. To make this explicit, it makes sense
to instead define `ArrayListIterator` as a _nested class_ inside of class `ArrayList`:

```java
public class ArrayList implements Iterable {

    private Object[] elements;

    private static class IteratorImpl implements Iterator {

        private ArrayList arrayList;
        private int index;

        private IteratorImpl(ArrayList arrayList) { this.arrayList = arrayList; }

        public boolean hasNext() { return index < arrayList.elements.length; }

        public Object next() { return arrayList.elements[index++]; }

    }

    public Iterator iterator() { return new IteratorImpl(this); }

    // Constructors and mutators not shown

}
```

One major advantage of defining the iterator API implementation as a nested class is that since nested classes have access to the private members of their enclosing class, we can now encapsulate
the `elements` field. Another major advantage is that the nested class itself can be made private; it is now hidden from other toplevel classes, even if they are in the same package.

### Inner classes

We can simplify the implementation of class `ArrayList` by turning class
`IteratorImpl` into a _nonstatic nested class_, more commonly referred to as an
_inner class_. In the same way that a nonstatic method takes an implicit `this`
argument that points to an instance of the enclosing class, an inner class has
an implicit `EnclosingClass.this` field that points to an instance of the
enclosing class. Furthermore, each constructor takes an implicit
`EnclosingClass.this` argument and uses it to initialize the implicit field:

```java
public class ArrayList implements Iterable {

    private Object[] elements;

    private class IteratorImpl implements Iterator {

        private int index;

        private IteratorImpl() {}

        public boolean hasNext() { return index < ArrayList.this.elements.length; }

        public Object next() { return ArrayList.this.elements[index++]; }

    }

    public Iterator iterator() { return new IteratorImpl(); }

    // Constructors and mutators not shown

}
```

This new version of `IteratorImpl` is entirely equivalent to the previous one;
it is in fact identical, except that the explicit field `arrayList` has been
replaced by an implicit field `ArrayList.this` and the explicit
constructor parameter `arrayList` has been replaced by an implicit one.

In fact, inside an inner class, we can refer to members of the enclosing class using their simple names; in case of nonstatic members, they are implicitly prefixed by `EnclosingClass.this`.
This means we can further simplify the implementation of class `ArrayList` as follows:

```java
public class ArrayList implements Iterable {

    private Object[] elements;

    private class IteratorImpl implements Iterator {

        private int index;

        public boolean hasNext() { return index < elements.length; }

        public Object next() { return elements[index++]; }

    }

    public Iterator iterator() { return new IteratorImpl(); }

    // Constructors and mutators not shown

}
```

We also left out the constructor, which is now generated implicitly.

### Local classes

In fact, since class `IteratorImpl` is only referred to inside method `iterator()`, it is cleaner to define it as a _local class_ inside method `iterator()`:

```java
public class ArrayList implements Iterable {

    private Object[] elements;

    public Iterator iterator() {

        class IteratorImpl implements Iterator {

            private int index;

            public boolean hasNext() { return index < elements.length; }

            public Object next() { return elements[index++]; }

        }

        return new IteratorImpl();
    }

    // Constructors and mutators not shown

}
```
Note: local classes are not visible outside the enclosing method, so there would be no point in adding
the `private` keyword, and in fact this is not allowed.

As we will see later, an additional advantage of local classes is that they can (under certain conditions) refer to the parameters and local
variables of the enclosing method.

### Anonymous classes

We can apply one more simplification: since in our example class `IteratorImpl` is referred to in only one place, to create an instance of it, we can replace it by an _anonymous class_.
This relieves us from the need to invent a name for it:

```java
public class ArrayList implements Iterable {

    private Object[] elements;

    public Iterator iterator() {

        return new Iterator() {

            private int index;

            public boolean hasNext() { return index < elements.length; }

            public Object next() { return elements[index++]; }

        };

    }

    // Constructors and mutators not shown

}
```
As you can see, an _anonymous class instance creation expression_ consists of:
- the keyword `new`
- the name of a class or interface to be implemented by the anonymous class
- a constructor argument list
- a class body

## Enhanced `for` loops

The interfaces `Iterator` and `Iterable` defined above exist in the Java Platform API in packages `java.util` and `java.lang`, respectively. When using those,
client code like
```java
for (Iterator iterator = iterable.iterator(); iterator.hasNext(); ) {
    Object element = iterator.next();
    System.out.println(element);
}
```
can be written more concisely using an _enhanced `for` loop_, as follows:
```java
for (Object element : iterable) {
    System.out.println(element);
}
```
All collection classes in package `java.util`, such as `java.util.ArrayList` and `java.util.HashSet`, implement interface `java.lang.Iterable` and can therefore be iterated over using an enhanced `for` loop.

*Note: the documentation for `java.util.Iterator` specifies that the `next` method shall throw a `NoSuchElementException` if there are no elements left. For simplicity, in this course we ignore this requirement.*

## Internal iterators: `forEach` methods

The kind of iterators we have seen so far are referred to as _external iterators_: the client requests an iterator object and then interacts with the iterator object to retrieve the successive elements of the collection. Another common type of iterator API is known as _internal iterators_. This is the primary type of iterators in the Ruby programming language. In the case of internal iterators, the client passes a _consumer object_ to the collection; the collection then repeatedly calls the consumer object's `accept` method, passing each element of the collection in turn as an argument.

This leads to an alternative definition of `Iterable`:
```java
public interface Iterable {
    void forEach(Consumer consumer);
}
```
where interface `Consumer` is defined as follows:
```java
public interface Consumer {
    void accept(Object value);
}
```
We can trivially make class `ArrayList` implement this interface as follows:
```java
public class ArrayList implements Iterable {

    public Object[] elements;

    public void forEach(Consumer consumer) {
        for (int i = 0; i < elements.length; i++)
            consumer.accept(elements[i]);
    }

}
```

We can adapt the client program to use this API as follows:
```java
public class ClientProgram {

    public void printAll(Iterable iterable) {
        iterable.forEach(new Consumer() {

            public void accept(Object value) {
                System.out.println(value);
            }

        });
    }

    public void printBoth(Iterable collection1, Iterable collection2) {
        printAll(collection1);
        printAll(collection2);
    }

}
```
Notice that the client program implements interface `Consumer` with an anonymous class whose `accept` method prints the element to the screen.

### Java's Iterable

It is worth pointing out that external iteration and internal iteration are not mutually exclusive.
In fact, Java's `Iterable` interface provides both an `iterator()` method and a `forEach()` method:
```java
public interface Iterable {
    Iterator iterator();
    default void forEach(Consumer consumer) {
        for (Iterator i = iterator(); i.hasNext(); )
            consumer.accept(i.next());
    }
}
```

### Lambda expressions

We can write this client program even more concisely using a _lambda expression_:
```java
public class ClientProgram {

    public void printAll(Iterable iterable) {
        iterable.forEach((Object value) -> { System.out.println(value); });
    }

    public void printBoth(Iterable collection1, Iterable collection2) {
        printAll(collection1);
        printAll(collection2);
    }

}
```
This lambda expression is exactly equivalent to the anonymous class instance creation expression it replaces; it is a very concise way
to implement a _functional interface_, an interface with a single abstract method. Interface `Consumer` is a functional interface.
The lambda expression in the example implements interface `Consumer` because this is the type of object that method `forEach` expects to receive as an argument;
this is known as _target typing_.

In general, a lambda expression consists of a parameter list, an arrow, and a method body. We can, however, leave out the parameter types; furthermore,
if the method body is of the form `{ E; }` or `{ return E; }`, where `E` is an expression, we can instead write just `E`, and if there is only a single parameter,
we can leave out the parentheses:
```java
iterable.forEach(value -> System.out.println(value));
```

### Capturing outer variables

Local classes, anonymous classes, and lambda expressions can refer to parameters and local variables from the enclosing method. Their value is copied into an implicit field of the resulting object; this is known as _capturing_.

For example, suppose we want to print only the elements that satisfy some condition, given by a `Predicate` object:
```java
public class ClientProgram {

    public void printAll(Predicate condition, Iterable iterable) {
        iterable.forEach(value -> {
            if (condition.test(value))
                System.out.println(value);
        });
    }

    public void printBoth(Predicate condition,
            Iterable collection1, Iterable collection2) {
        printAll(condition, collection1);
        printAll(condition, collection2);
    }

}
```
The `Consumer` object that results from evaluating the lambda expression has an implicit field that holds a copy of parameter `condition`.

Java allows only _effectively final_ variables to be captured this way. A variable is effectively final if it is not mutated after initialization.
