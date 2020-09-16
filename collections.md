# Lists, Sets, and Maps

In this chapter, we consider three important examples of the use of inheritance to generalize over different implementations of an _abstract datatype_. In the first example, the `List` interface generalizes over the `ArrayList` and `LinkedList` implementations; in the second example, the `Set` interface generalizes over the `ArraySet` and `HashSet` implementations; and in the third example, the `Map` interface generalizes over the `ArrayMap` and `HashMap` implementations. Besides serving as illustrations of inheritance and behavioral subtyping, they also emphasize the difference between API and implementation by showing how in each case, exactly the same API is implemented in two very different ways. Furthermore, these examples are important in their own right; they are some of the most useful and most widely used data structures and should be known by every programmer.

The examples are simplified versions of the corresponding interfaces and classes in the `java.util` package of the Java Platform API; see the discussion at the end of the chapter.

## Lists

If a Java program needs to store a sequence of values, an array can be used. However, the number of operations available for working with arrays is limited. For example, it is not possible to add or remove elements. To solve this problem, we can define a *list* abstraction, with operations for adding and removing elements in arbitrary positions.

There are multiple ways to implement such an abstraction, that each have different performance characteristics. For example, implementing the list abstraction by storing the elements in an array supports looking up an element at a given index and removing the last element in constant time, and adding an element to the end in amortized constant time, but adding an element to the front or removing the first element takes time proportional to the size of the list. Implementing the list abstraction by storing the elements in a doubly-linked list data structure, on the other hand, supports adding an element to the front or the back and removing an element from the front or the back in constant time, but looking up the element at a given index takes time proportional to the size of the list in the worst case. As a result, different implementations are appropriate for different applications. Therefore, we will implement both an `ArrayList` class and a `LinkedList` class. At the same time, code that manipulates instances of the abstraction should be able to work with either implementation. Therefore, we will introduce an interface `List` that generalizes over the implementations. Code that accepts objects of type `List` can be used with `ArrayList` objects, `LinkedList` objects, or any other implementation of the `List` interface we may build in the future.

We define interface `List` as follows:
```java
package collections;

import java.util.Arrays;
import java.util.stream.IntStream;
import java.util.stream.Stream;

/**
 * @invar | Arrays.stream(toArray()).allMatch(e -> e != null)
 */
public interface List {
	
	/**
	 * @inspects | this
	 * @creates | result
	 * @post | result != null
	 */
	Object[] toArray();
	
	default Stream<Object> stream() { return Arrays.stream(toArray()); }
	
	/**
	 * @inspects | this
	 * @post | result == toArray().length
	 */
	int size();
	
	/**
	 * @pre | 0 <= index
	 * @pre | index < size()
	 * @post | result == toArray()[index]
	 */
	Object get(int index);

	/**
	 * @pre | value != null
	 * @inspects | this
	 * @post | result == Arrays.stream(toArray()).anyMatch(e -> e.equals(value))
	 */
	boolean contains(Object value);
	
	/**
	 * @pre | 0 <= index
	 * @pre | index <= size()
	 * @pre | value != null
	 * @mutates | this
	 * @post | size() == old(size()) + 1
	 * @post | Arrays.equals(toArray(), 0, index, old(toArray()), 0, index)
	 * @post | Arrays.equals(toArray(), index + 1, size(),
	 *       |     old(toArray()), index, old(size()))
	 * @post | get(index).equals(value)
	 */
	void add(int index, Object value);
	
	/**
	 * @pre | value != null
	 * @mutates | this
	 * @post | size() == old(size()) + 1
	 * @post | Arrays.equals(toArray(), 0, old(size()),
	 *       |     old(toArray()), 0, old(size()))
	 * @post | get(old(size())).equals(value)
	 */
	default void add(Object value) { add(size(), value); }
	
	/**
	 * @pre | 0 <= index
	 * @pre | index < size()
	 * @mutates | this
	 * @post | Arrays.equals(toArray(), 0, index, old(toArray()), 0, index)
	 * @post | Arrays.equals(toArray(), index, size(),
	 *       |     old(toArray()), index + 1, old(size()))
	 */
	void remove(int index);

	/**
	 * @pre | value != null
	 * @mutates | this
	 * @post | Arrays.equals(toArray(),
	 *       |     IntStream.range(0, old(size()))
	 *       |         .filter(i -> i == old(IntStream.range(0, size())
	 *       |             .filter(i -> get(i).equals(value))
	 *       |             .findFirst().orElse(-1)))
	 *       |         .mapToObj(i -> old(toArray())[i]).toArray())
	 */
	void remove(Object value);
	
}
```

We can implement this API by storing the elements in an array, as follows:
```java
package collections;

import java.util.Arrays;

public class ArrayList implements List {

	/**
	 * @invar | elements != null
	 * @invar | 0 <= size
	 * @invar | size <= elements.length
	 * @invar | Arrays.stream(elements, 0, size).allMatch(e -> e != null)
	 * @invar | Arrays.stream(elements, size, elements.length)
	 *        |     .allMatch(e -> e == null)
	 * 
	 * @representationObject
	 */
	private Object[] elements = new Object[10];
	private int size;
	
	/**
	 * @post | size() == 0
	 */
	public ArrayList() {}
	
	public Object[] toArray() {
		return Arrays.copyOf(elements, size);
	}

	public int size() {
		return size;
	}

	public Object get(int index) {
		return elements[index];
	}

	private int indexOf(Object value) {
		for (int i = 0; i < size; i++)
			if (elements[i].equals(value))
				return i;
		return -1;
	}

	public boolean contains(Object value) {
		return indexOf(value) != -1;
	}

	public void add(int index, Object value) {
		if (elements.length == size) {
			Object[] newElements = new Object[elements.length * 2];
			System.arraycopy(elements, 0, newElements, 0, size);
			elements = newElements;
		}
		System.arraycopy(elements, index, elements, index + 1, size - index);
		elements[index] = value;
		size++;
	}

	public void remove(int index) {
		size--;
		System.arraycopy(elements, index + 1, elements, index, size - index);
		elements[size] = null;
	}

	public void remove(Object value) {
		int index = indexOf(value);
		if (index != -1)
			remove(index);
	}

}
```
We can also implement the same API by storing the elements in a doubly-linked chain of `Node` objects:
```java
package collections;

public class LinkedList implements List {
	
	private class Node {
		/**
		 * @invar | (element == null) == (this == sentinel)  
		 * @invar | previous != null
		 * @invar | next != null
		 * @invar | next.previous == this
		 * @invar | previous.next == this
		 * 
		 * @peerObject
		 */
		private Node previous;
		private Object element;
		/** @peerObject */
		private Node next;
		
		private int getLength() { return this == sentinel ? 0 : 1 + next.getLength(); }
	}
	
	/**
	 * @invar | sentinel != null
	 * @invar | size == sentinel.next.getLength()
	 */
	private int size;
	/** @representationObject */
	private Node sentinel;
	
	private Node getNode(int index) {
		Node node = sentinel;
		if (index <= size / 2)
			for (; index >= 0; index--)
				node = node.next;
		else
			for (; index < size; index++)
				node = node.previous;
		return node;
	}
	
	/**
	 * @post | size() == 0
	 */
	public LinkedList() {
		sentinel = new Node();
		sentinel.previous = sentinel;
		sentinel.next = sentinel;
	}

	public Object[] toArray() {
		Object[] result = new Object[size];
		int i = 0;
		for (Node node = sentinel.next; node != sentinel; node = node.next)
			result[i++] = node.element;
		return result;
	}

	public int size() {
		return size;
	}

	public Object get(int index) {
		return getNode(index).element;
	}

	public boolean contains(Object value) {
		for (Node node = sentinel.next; node != sentinel; node = node.next)
			if (node.element.equals(value))
				return true;
		return false;
	}

	public void add(int index, Object value) {
		Node next = getNode(index);
		Node node = new Node();
		node.element = value;
		node.next = next;
		node.previous = next.previous;
		node.next.previous = node;
		node.previous.next = node;
		size++;
	}

	public void add(Object value) {
		add(size, value);
	}

	public void remove(int index) {
		Node node = getNode(index);
		node.next.previous = node.previous;
		node.previous.next = node.next;
		size--;
	}

	public void remove(Object value) {
		Node node = sentinel.next;
		for (;;) {
			if (node == sentinel)
				return;
			if (node.element.equals(value)) {
				node.next.previous = node.previous;
				node.previous.next = node.next;
				size--;
				return;
			}
			node = node.next;
		}
	}

}
```

## Sets

Checking whether an `ArrayList` or `LinkedList` object contains a given value and removing a given value from an `ArrayList` or `LinkedList` take time proportional to the size of the list. If those operations are important in a given application, a *hash table* may be more appropriate. Assuming a good *hash function* is used, checking for the presence of an element, adding an element if it is not yet present, and removing an element take (amortized) constant expected time. Therefore, hash tables are ideal for implementing a *set* abstract data type.

We first define interface `Set` as follows:
```java
package collections;

import java.util.Arrays;
import java.util.stream.Stream;

/**
 * @invar The set has no null elements.
 *     | Arrays.stream(toArray()).allMatch(e -> e != null)
 * @invar {@code toArray()} does not contain duplicates.
 *     | Arrays.stream(toArray()).distinct().count() == size()
 */
public interface Set {

	/**
	 * @inspects | this
	 * @creates | result
	 * @post | result != null
	 */
	Object[] toArray();
	
	default Stream<Object> stream() { return Arrays.stream(toArray()); } 

	/**
	 * @inspects | this
	 * @post | result == toArray().length
	 */
	int size();

	/**
	 * @pre | value != null
	 * @inspects | this
	 * @post | result == Arrays.stream(toArray()).anyMatch(e -> e.equals(value))
	 */
	boolean contains(Object value);
	
	/**
	 * @pre | value != null
	 * @mutates | this
	 * @post The given value is in the set.
	 *       | Arrays.stream(toArray()).anyMatch(e -> e.equals(value))
	 * @post No elements have disappeared from the set.
	 *       | Arrays.stream(old(toArray())).allMatch(eo ->
	 *       |     Arrays.stream(toArray()).anyMatch(e -> e.equals(eo)))
	 * @post No elements, other than the given value, have been added.
	 *       | Arrays.stream(toArray()).allMatch(e -> e.equals(value) ||
	 *       |     Arrays.stream(old(toArray())).anyMatch(eo -> e.equals(eo)))
	 */
	void add(Object value);

	/**
	 * @pre | value != null
	 * @mutates | this
	 * @post The given value is no longer in the set.
	 *       | Arrays.stream(toArray()).noneMatch(e -> e.equals(value))
	 * @post No elements, other than the given value, have disappeared
	 *       from the set.
	 *       | Arrays.stream(old(toArray())).allMatch(eo -> eo.equals(value) ||
	 *       |     Arrays.stream(toArray()).anyMatch(e -> e.equals(eo)))
	 * @post No elements have been added to the set.
	 *       | Arrays.stream(toArray()).allMatch(e ->
	 *       |     Arrays.stream(old(toArray())).anyMatch(eo -> e.equals(eo)))
	 */
	void remove(Object value);
	
}
```
A `Set` object implemented using a hash table with capacity K distributes its elements among K *buckets*. For each bucket, we need some other `Set` implementation to store the elements that belong to that bucket. For this purpose, we first define a simple `ArrayList`-based `Set` implementation:
```java
package collections;

public class ArraySet implements Set {
	
	/**
	 * @invar | elements != null
	 * @invar | elements.stream().distinct().count() == elements.size()
	 * 
	 * @representationObject
	 */
	private ArrayList elements = new ArrayList();
	
	/** @post | size() == 0 */
	public ArraySet() {}

	public Object[] toArray() { return elements.toArray(); }

	public int size() { return elements.size(); }

	public boolean contains(Object value) { return elements.contains(value); }

	public void add(Object value) {
		if (elements.contains(value))
			return;
		elements.add(value);
	}

	public void remove(Object value) { elements.remove(value); }

}
```
Notice that the `contains`, `add`, and `remove` operations of an `ArraySet` take time proportional to the size of the set. This will not matter, because assuming a good hash function is used, and assuming the hash table is not overloaded, the expected number of elements in each bucket is independent of the total number of elements in the hash table.

We can now define the hash table-based `Set` implementation:
```java
package collections;

import java.util.Arrays;
import java.util.stream.IntStream;

public class HashSet implements Set {
	
	/**
	 * @invar | buckets != null
	 * @invar | Arrays.stream(buckets).allMatch(b -> b != null)
	 * @invar | IntStream.range(0, buckets.length).allMatch(i ->
	 *        |     buckets[i].stream().allMatch(e ->
	 *        |         Math.floorMod(e.hashCode(), buckets.length) == i))
	 * 
	 * @representationObject
	 * @representationObjects Each bucket is a representation object
	 */
	private Set[] buckets;
	
	private Set getBucket(Object value) {
		return buckets[Math.floorMod(value.hashCode(), buckets.length)];
	}
	
	/**
	 * @pre | 0 < capacity
	 * @post | size() == 0
	 */
	public HashSet(int capacity) {
		buckets = new Set[capacity];
		for (int i = 0; i < buckets.length; i++)
			buckets[i] = new ArraySet();
	}

	public Object[] toArray() {
		Object[] result = new Object[size()];
		int offset = 0;
		for (int i = 0; i < buckets.length; i++) {
			Object[] bucketElements = buckets[i].toArray();
			System.arraycopy(bucketElements, 0,
				result, offset, bucketElements.length);
			offset += bucketElements.length;
		}
		return result;
	}

	public int size() {
		return Arrays.stream(buckets).mapToInt(b -> b.size()).sum();
	}

	public boolean contains(Object value) {
		return getBucket(value).contains(value);
	}

	public void add(Object value) {
		getBucket(value).add(value);
	}

	public void remove(Object value) {
		getBucket(value).remove(value);
	}

}
```
Notice that the `HashSet` object simply delegates the `contains`, `add`, and `remove` operations to the element's bucket, which is determined by retrieving its *hash code* using the `hashCode()` method and deriving the bucket index by taking the remainder of dividing the hash code by the number of buckets. If method `hashCode()` implements a good hash function, which means that the hash codes of the elements are uniformly distributed, then the expected number of elements in each bucket is proportional to the *load factor*, which is the total number of elements divided by the number of buckets. This means that if the load factor is bounded, then so is the expected number of elements in each bucket, and as a result, the expected time taken by `contains`, `add`, and `remove` is independent of the number of elements in the `HashSet` object. The `HashSet` implementation shown above has a fixed capacity; this works well if the maximum load (i.e. number of elements) of the `HashSet` object is known beforehand. If not, code should be added to increase the capacity and *rehash* (i.e. copy the elements from the old buckets to the new buckets) when the load factor exceeds some fixed threshold value.
