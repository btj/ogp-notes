# Generics

## Basic concept

In this note, we introduce Java's support for _generic_ classes, interfaces, and methods. We motivate and illustrate the concepts by means of the example task of implementing a class `University` that has the following methods:

```java
class University {

    void addStudent(Student student) { ... }

    boolean hasStudent(Student student) { ... }

    /** Returns the number of students that have obtained at least 120 credits. */
    int getNbFinishers() { ... }

    void addStaff(Staff staff) { ... }

    boolean hasStaff(Staff staff) { ... }

    /**
     * Returns the average number of scientific publications authored by this
     * university's staff members.
     */
    int getAvgNbPubs() { ... }

}
```

(In this note, we mostly ignore issues of encapsulation and documentation, to focus on the topic of generics.)

Class `University` uses classes `Student` and `Staff`:

```java
class Student { int nbCredits; }
class Staff { int nbPubs; }
```

### Approach 1: Duplicate collection classes

To implement class `University`, we need to implement a data structure for storing the current set of students, and a data structure for storing the current set of staff members. A data structure for storing a set of students could look like this:
```java
class LinkedListOfStudent implements IterableOfStudent {

    static class Node {
        Student element;
        Node next;

        Node(Student element, Node next) {
            this.element = element;
            this.next = next;
        }
    }

    Node firstNode;

    boolean contains(Student student) {
        for (Node node = firstNode; node != null; node = node.next)
            if (node.element == student)
                return true;
        return false;
    }

    public IteratorOfStudent iterator() {
        return new IteratorOfStudent() {
            Node node = firstNode;
            public boolean hasNext() { return node != null; }
            public Student next() {
                Student result = node.element;
                node = node.next;
                return result;
            }
        };
    }

    void addFirst(Student student) {
        firstNode = new Node(student, firstNode);
    }
}
```
This class uses the interfaces `IterableOfStudent` and `IteratorOfStudent` defined as follows:
```java
interface IterableOfStudent {

    IteratorOfStudent iterator();

}

interface IteratorOfStudent {

    boolean hasNext();

    Student next();

}
```

Assuming we also implement analogous types `LinkedListOfStaff`, `IterableOfStaff` and `IteratorOfStaff`, we can implement class `University` as follows:
```java
class University {
    
    private LinkedListOfStudent students = new LinkedListOfStudent();
    private LinkedListOfStaff staffMembers = new LinkedListOfStaff();

    void addStudent(Student student) {
        students.addFirst(student);
    }

    boolean hasStudent(Student student) {
        return students.contains(student);
    }

    /** Returns the number of students that have obtained at least 120 credits. */
    int getNbFinishers() {
        int result = 0;
        for (IteratorOfStudent iterator = students.iterator();
             iterator.hasNext(); ) {
            Student student = iterator.next();
            if (student.nbCredits >= 120)
                result++;
        }
        return result;
    }

    void addStaff(Staff staff) {
        staffMembers.addFirst(staff);
    }

    boolean hasStaff(Staff staff) {
        return staffMembers.contains(staff);
    }

    /**
     * Returns the average number of scientific publications authored by this
     * university's staff members.
     */
    int getAvgNbPubs() {
        int nbStaff = 0;
        int totalNbPubs = 0;
        for (IteratorOfStaff iterator = staffMembers.iterator();
             iterator.hasNext(); ) {
            Staff staff = iterator.next();
            nbStaff++;
            totalNbPubs += staff.nbPubs;
        }
        return totalNbPubs / nbStaff;
    }

}
```

Obviously, we would like to avoid having to introduce a separate linked list implementation, and separate types for iterables and iterators, for each element type.

### Approach 2: Using subtype polymorphism

One way to achieve reuse of collection classes is by exploiting the fact that all objects are of type `Object`, so we can use a data structure with element type `Object` to store any collection:
```java
interface Iterable {

    Iterator iterator();

}

interface Iterator {

    boolean hasNext();

    Object next();

}

class LinkedList implements Iterable {

    static class Node {
        Object element;
        Node next;

        Node(Object element, Node next) {
            this.element = element;
            this.next = next;
        }
    }

    Node firstNode;

    boolean contains(Object element) {
        for (Node node = firstNode; node != null; node = node.next)
            if (node.element == element)
                return true;
        return false;
    }

    public Iterator iterator() {
        return new Iterator() {
            Node node = firstNode;
            public boolean hasNext() { return node != null; }
            public Object next() {
                Object result = node.element;
                node = node.next;
                return result;
            }
        };
    }

    void addFirst(Object element) {
        firstNode = new Node(element, firstNode);
    }
}
```
We can use class `LinkedList` to implement class `University`. Note, however, that we do have to insert a typecast in methods `getNbFinishers()` and `getAvgNbPubs()`:
```java
class University {
    
    private LinkedList students = new LinkedList();
    private LinkedList staffMembers = new LinkedList();

    void addStudent(Student student) {
        students.addFirst(student);
    }

    boolean hasStudent(Student student) {
        return students.contains(student);
    }

    /** Returns the number of students that have obtained at least 120 credits. */
    int getNbFinishers() {
        int result = 0;
        for (Iterator iterator = students.iterator(); iterator.hasNext(); ) {
            Student student = (Student)iterator.next(); // Typecast!
            if (student.nbCredits >= 120)
                result++;
        }
        return result;
    }

    void addStaff(Staff staff) {
        staffMembers.addFirst(staff);
    }

    boolean hasStaff(Staff staff) {
        return staffMembers.contains(staff);
    }

    /**
     * Returns the average number of scientific publications authored by this
     * university's staff members.
     */
    int getAvgNbPubs() {
        int nbStaff = 0;
        int totalNbPubs = 0;
        for (Iterator iterator = staffMembers.iterator(); iterator.hasNext(); ) {
            Staff staff = (Staff)iterator.next(); // Typecast!
            nbStaff++;
            totalNbPubs += staff.nbPubs;
        }
        return totalNbPubs / nbStaff;
    }

}
```
Note also that with this approach, we lose much of the benefit of Java's static type checker: many programming errors that would be caught by the static type checker before we run the program when using Approach 1 are only detected, if at all, during execution of the program when using Approach 2. This includes the following errors:
- Adding the student to `staffMembers` instead of `students` in method `addStudent`. This would lead to a `ClassCastException` in `getAvgNbPubs()` if and when that method gets called.
- Calling `contains` on `staffMembers` instead of `students` in method `hasStudent`. This would not cause an exception; instead, it would silently produce wrong results.
- Iterating over `staffMembers` instead of `students` in method `getNbFinishers`. This would lead to a `ClassCastException` in `getNbFinishers()`, except if `staffMembers` is empty. In the latter case, it would silently produce wrong results.
- The corresponding errors in `addStaff`, `hasStaff`, and `getAvgNbPubs`.

### Approach 3: Generics

We can achieve reuse without sacrificing static type checking by defining types `Iterator`, `Iterable`, and `LinkedList` as _generic types_ with a _type parameter_ `T`:
```java
interface Iterable<T> {

    Iterator<T> iterator();

}

interface Iterator<T> {

    boolean hasNext();

    T next();

}

class LinkedList<T> implements Iterable<T> {

    static class Node<T> {
        T element;
        Node<T> next;

        Node(T element, Node<T> next) {
            this.element = element;
            this.next = next;
        }
    }

    Node<T> firstNode;

    boolean contains(T element) {
        for (Node<T> node = firstNode; node != null; node = node.next)
            if (node.element == element)
                return true;
        return false;
    }

    public Iterator<T> iterator() {
        return new Iterator<T>() {
            Node<T> node = firstNode;
            public boolean hasNext() { return node != null; }
            public T next() {
                T result = node.element;
                node = node.next;
                return result;
            }
        };
    }

    void addFirst(T element) {
        firstNode = new Node<T>(element, firstNode);
    }
}
```
We can obtain classes equivalent to classes `LinkedListOfStudent` and `LinkedListOfStaff` above, simply by _instantiating_ generic class `LinkedList` with _type argument_ `Student` and `Staff`, respectively, to obtain _parameterized types_ `LinkedList<Student>` and `LinkedList<Staff>`:
```java
class University {
    
    private LinkedList<Student> students = new LinkedList<Student>();
    private LinkedList<Staff> staffMembers = new LinkedList<Staff>();

    void addStudent(Student student) {
        students.addFirst(student);
    }

    boolean hasStudent(Student student) {
        return students.contains(student);
    }

    /** Returns the number of students that have obtained at least 120 credits. */
    int getNbFinishers() {
        int result = 0;
        for (Iterator<Student> iterator = students.iterator();
             iterator.hasNext(); ) {
            Student student = iterator.next();
            if (student.nbCredits >= 120)
                result++;
        }
        return result;
    }

    void addStaff(Staff staff) {
        staffMembers.addFirst(staff);
    }

    boolean hasStaff(Staff staff) {
        return staffMembers.contains(staff);
    }

    /**
     * Returns the average number of scientific publications authored by this
     * university's staff members.
     */
    int getAvgNbPubs() {
        int nbStaff = 0;
        int totalNbPubs = 0;
        for (Iterator<Staff> iterator = staffMembers.iterator();
             iterator.hasNext(); ) {
            Staff staff = iterator.next();
            nbStaff++;
            totalNbPubs += staff.nbPubs;
        }
        return totalNbPubs / nbStaff;
    }

}
```
Note: if the type arguments for an instance creation expression can be derived from the context, they can be omitted: in the example above, instead of `new LinkedList<Student>()`, we can simply write
`new LinkedList<>()`; this is known as _diamond notation_.

## Bounded type parameters

Suppose we want to store the university's students sorted by number of credits obtained, and the staff members sorted by number of publications. We want to develop a class `SortedLinkedList<T>`
as a subclass of `LinkedList<T>`. For class `SortedLinkedList<T>` to be able to compare its elements, its elements should implement interface `Comparable<T>`, defined as follows:
```java
interface Comparable<T> {
    
    /**
     * Returns a negative number, zero, or a positive number if this object
     * compares as less than, equal to, or greater than {@code other}.
     */
    int compareTo(T other);
    
}
```
We can let the static type checker enforce this by declaring `Comparable<T>` as an _upper bound_ of the type parameter of `SortedLinkedList`:
```java
class SortedLinkedList<T extends Comparable<T>> extends LinkedList<T> {
    
    @Override
    void addFirst(T element) {
        Node<T> sentinel = new Node<T>(null, firstNode);
        Node<T> node = sentinel;
        while (node.next != null && node.next.element.compareTo(element) < 0)
            node = node.next;
        node.next = new Node<T>(element, node.next);
        firstNode = sentinel.next;
    }
    
}
```
Notice that thanks to the upper bound, the static type checker allows us to call the `compareTo` method on expressions of type `T`.

We can update class `University` to use class `SortedLinkedList` by updating the field declarations as follows:
```java
private LinkedList<Student> = new SortedLinkedList<>();
private LinkedList<Staff> = new SortedLinkedList<>();
```

The static type checker will allow this only after we extend classes `Student` and `Staff` to implement interface `Comparable`:
```java
class Student implements Comparable<Student> {
    
    int nbCredits;
    
    public int compareTo(Student other) { return nbCredits - other.nbCredits; }
    
}

class Staff implements Comparable<Staff> {
    
    int nbPubs;
    
    public int compareTo(Staff other) { return nbPubs - other.nbPubs; }
    
}
```

(The term "upper bound" refers to the image of superclasses being "above" subclasses.)

## Invariance

Suppose, now, that we want to extend class `University` with a method `getMembers()` that returns a collection containing all members of the university. First, we introduce class `Member` as a superclass of `Student` and `Staff`:
```java
class Member {}

class Student extends Member implements Comparable<Student> { ... }

class Staff extends Member implements Comparable<Staff> { ... }
```
For the purpose of illustrating various aspects of generics, we implement method `getMembers()` as follows:
```java
class University {

    // ...

    LinkedList<Member> getMembers() {
    	LinkedList<Member> members = new LinkedList<>();
    	members.addAll(students);
    	staffMembers.copyInto(members);
    	return members;
    }

}
```
We make a first attempt at defining methods `addAll` and `copyInto` in class `LinkedList` as follows:
```java
class LinkedList<T> implements Iterable<T> {

    // ...

    void addAll(LinkedList<T> other) {
    	for (Iterator<T> iterator = other.iterator(); iterator.hasNext(); )
    		addFirst(iterator.next());
    }
    
    void copyInto(LinkedList<T> other) {
    	for (Iterator<T> iterator = this.iterator(); iterator.hasNext(); )
    		other.addFirst(iterator.next());
    }

}
```
This, however, does not work, for two reasons.

- Firstly, the static type checker complains about the call of `addAll` in method `getMembers()`:
  its argument is of type `LinkedList<Student>`, which is _not_ assignable to parameter `other` of type `LinkedList<Member>`.
  Indeed, `LinkedList<Student>` is not a subtype of `LinkedList<Member>`, even though `Student` is a subtype of `Member`.
  In other words, `LinkedList<T>` is not _covariant_ in T.

  There is a good reason for this: if `LinkedList<T>` were covariant, the static type checker would not complain if we incorrectly tried to add the university's staff members to its collection
  of students, as follows:
  ```java
  LinkedList<Member> studentsAsMembers = university.students;
  studentsAsMembers.addAll(university.staffMembers);
  ```
  Indeed, an object of type `LinkedList<Member>` must accept the addition of arbitrary new elements of type `Member`. An object of type `LinkedList<Student>` does not satisfy that condition:
  it accepts only `Student` objects.

- Secondly, the static type checker also complains about the call of `copyInto` in method `getMembers()`:
  its argument is of type `LinkedList<Member>`, which is not assignable to parameter `other` of type `LinkedList<Staff>`.
  Indeed, `LinkedList<Member>` is not a subtype of `LinkedList<Staff>`, even though `Member` is a supertype of `Staff`.
  In other words, `LinkedList<T>` is not _contravariant_ in T.
  
  The reason for this is obvious: a `LinkedList<Staff>` must contain only `Staff` objects, whereas a `LinkedList<Member>` object may additionally contain other `Member` objects, such as `Student` objects.

In summary, generic types are neither covariant nor contravariant in their type parameter. In other words, they are _invariant_.

## Wildcards

### Upper-bounded wildcards

Even though `LinkedList<Student>` is not a subtype of `LinkedList<Member>`, it is in fact safe for the call of `members.addAll` to pass `students` as an argument: indeed, `addAll` only retrieves
elements from its argument; it does not add new elements to it. For that reason, it is safe for `addAll` to take as an argument a `LinkedList<U>` object, for any subtype `U` of `T`. We can express
this by using an _upper-bounded wildcard_:

```java
void addAll(LinkedList<? extends T> other) {
    for (Iterator<? extends T> iterator = other.iterator(); iterator.hasNext(); )
	    addFirst(iterator.next());
}
```

Wildcard type `LinkedList<? extends T>` generalizes over all types `LinkedList<U>`, for all subtypes `U` of `T`, as well as `LinkedList<T>` itself. It could be proncounced "linked list of some type that extends T".

### Lower-bounded wildcards

Even though `LinkedList<Member>` is not a subtype of `LinkedList<Staff>`, it is in fact safe for the call of `staffMembers.copyInto` to pass `members` as an argument: indeed, `copyInto` only puts
elements into its argument; it does not retrieve any elements from it. For that reason, it is safe for `copyInto` to take as an argument a `LinkedList<U>` object, for any supertype `U` of `T`. We can
express this by using a _lower-bounded wildcard_:

```java
void copyInto(LinkedList<? super T> other) {
    for (Iterator<T> iterator = this.iterator(); iterator.hasNext(); )
	    other.addFirst(iterator.next());
}
```

Wildcard type `LinkedList<? super T>` generalizes over all types `LinkedList<U>`, for all supertypes `U` of `T`, as well as `LinkedList<T>` itself. It could be pronounced "linked list of some supertype of T".

## Generic methods

Suppose we add the following static method to class `LinkedList`:

```java
static void copyInto(LinkedList<...> from, LinkedList<...> to) {
    from.copyInto(to); // equivalently: to.addAll(from);
}
```

What type arguments should we write here?

Here, we need to link the two parameter types. To do so, we need to turn method `copyInto` into a _generic method_ by declaring a method-level type parameter `T`. Then, there are three equivalent ways to complete the method declaration:
```java
static <T> void copyInto(LinkedList<T> from, LinkedList<? super T> to) {
static <T> void copyInto2(LinkedList<? extends T> from, LinkedList<T> to) {
static <T> void copyInto3(LinkedList<? extends T> from, LinkedList<? super T> to) {
```

Assuming we pick the first declaration, we can rewrite method `getMembers()` in class `University` to use this method as follows:
```java
LinkedList<Member> getMembers() {
    LinkedList<Member> members = new LinkedList<>();
    LinkedList.<Student>copyInto(students, members);
    LinkedList.<Staff>copyInto(staffMembers, members);
    return members;
}
```
Notice that we can specify the type argument for the type parameter of the method being called by putting it between angle brackets _in front of the method name_.

In most cases, however, the type argument can be inferred from the argument types or from the context of the call; in these cases, we can omit the type argument:
```java
LinkedList<Member> getMembers() {
    LinkedList<Member> members = new LinkedList<>();
    LinkedList.copyInto(students, members);
    LinkedList.copyInto(staffMembers, members);
    return members;
}
```

We can also use a method-level type parameter to link the return type to a parameter type:
```java
static <T> LinkedList<T> copy(LinkedList<T> list) {
    LinkedList<T> result = new LinkedList<>();
    result.addAll(list);
    return result;
}
```

## Limitations

After the static type checker finishes checking a Java program, but before it is executed, all generics are _erased_ from it. That is, in generic type declarations, each type parameter is replaced by its upper bound (or `Object` if it has no explicit upper bound), and type arguments are simply removed. Typecasts are inserted as necessary to preserve well-typedness. For example, after erasing the example program from Approach 3, we obtain the example program from Approach 2. This involves inserting typecasts that cast the result of `iterator.next()` to the expected type.

This approach, called _erasure_, has the following implications:
- Type arguments must be subtypes of `Object`; using a primitive type (like `int`) as a type argument is not allowed. To store primitive values in a generic collection, you must first box them.
  For example, `ArrayList<int>` is not allowed, but `ArrayList<Integer>` is allowed. Java will convert `int` values to `Integer` objects and vice versa automatically. (However, the memory allocation involved in autoboxing may have a significant performance impact.)
- Since type arguments are not available at run time, they cannot be used in ways that affect the run-time type of an object or otherwise affect the program's run-time behavior. For example, if `T` is a type parameter, the expressions `new T()`, `new T[]`, `T.class`, or `... instanceof T`  are not allowed. However, `new LinkedList<T>()` is allowed, since the type argument `<T>` is removed during erasure anyway.
- Casts to types that are not run-time types (i.e. types that are different from their erasure, such as `T` (whose erasure is `Object`) or `LinkedList<T>` (whose erasure is `LinkedList`)) are allowed, but it may not be possible to fully check them at run time. In those cases, the static type checker generates an _unchecked cast warning_. For example, suppose `object` is a variable of type `Object`. The cast `(LinkedList<Student>)object` generates an unchecked cast warning, since it cannot be determined at run time whether the `LinkedList` object was created as a `LinkedList<Student>`, a `LinkedList<Staff>`, or with yet some other type argument. If `object` points to a `LinkedList` object that contains a `Staff` object, then `((LinkedList<Student>)object).iterator().next()` will throw a `ClassCastException` when the `next()` call returns, because this expression's erasure is `(Student)((LinkedList)object).iterator().next()` and the return value of the `next()` call is a `Staff` object.
