# Lists, sets, and maps

In this chapter, we consider three important examples of the use of inheritance to generalize over different implementations of an _abstract datatype_ (ADT). In the first example, the `List` interface generalizes over the `ArrayList` and `LinkedList` implementations; in the second example, the `Set` interface generalizes over the `ArraySet` and `HashSet` implementations; and in the third example, the `Map` interface generalizes over the `ArrayMap` and `HashMap` implementations. Besides serving as illustrations of inheritance and behavioral subtyping, they also emphasize the difference between API and implementation by showing how in each case, exactly the same API is implemented in two very different ways. Furthermore, these examples are important in their own right; they are some of the most useful and most widely used data structures and should be known by every programmer.

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

## Maps

Applications often need to store a set of *key-value pairs* (where distinct pairs have distinct keys) and efficiently add a pair and retrieve the value associated with a given key. In Java, such sets are known as *maps* and a key-value pair is called a *map entry*.

We first define the `Map` interface:
```java
package collections;

import java.util.Objects;

public interface Map {
	
	/** @immutable */
	class Entry {
		
		/**
		 * @invar | key != null
		 * @invar | value != null
		 */
		private final Object key;
		private final Object value;
		
		/** @post | result != null */
		public Object getKey() { return key; }
		/** @post | result != null */
		public Object getValue() { return value; }
		
		/**
		 * @pre | key != null
		 * @pre | value != null
		 * @post | getKey() == key
		 * @post | getValue() == value
		 */
		public Entry(Object key, Object value) {
			this.key = key;
			this.value = value;
		}
		
		@Override
		public boolean equals(Object other) {
			return other instanceof Entry
				&& key.equals(((Entry)other).getKey())
				&& value.equals(((Entry)other).getValue());
		}
		
		@Override
		public int hashCode() {
			return Objects.hash(key, value);
		}
		
	}
	
	/**
	 * @inspects | this
	 * @creates | result
	 * @post | result != null
	 * @post | result.stream().allMatch(e -> e instanceof Entry)
	 * @post No key appears twice.
	 *       | result.stream().map(e -> ((Entry)e).getKey()).distinct().count()
	 *       | == result.size()
	 */
	Set entrySet();
	
	/**
	 * @post | result == entrySet().stream()
	 *       |     .filter(e -> ((Entry)e).getKey().equals(key))
	 *       |     .findFirst().orElse(null)
	 */
	Object get(Object key);

	/**
	 * @pre | key != null
	 * @pre | value != null
	 * @mutates | this
	 * @post The given entry is in the entry set.
	 *       | entrySet().contains(new Entry(key, value))
	 * @post No entries, except for the updated one, have disappeared from the
	 *       entry set.
	 *       | old(entrySet()).stream().allMatch(e ->
	 *       |     ((Entry)e).getKey().equals(key) || entrySet().contains(e))
	 * @post No entries, except for the updated one, have been added to the entry
	 *       set.
	 *       | entrySet().stream().allMatch(e ->
	 *       |     ((Entry)e).getKey().equals(key) || old(entrySet()).contains(e))
	 */
	void put(Object key, Object value);
	
	/**
	 * @pre | key != null
	 * @mutates | this
	 * @post All entries in the entry set were already in the entry set and
	 *       have a key that is different from the given key. 
	 *       | entrySet().stream().allMatch(e -> !((Entry)e).getKey().equals(key)
	 *       |     && old(entrySet()).contains(e))
	 * @post All entries that were in the entry set, except for the specified one,
	 *       are still in the entry set.
	 *       | old(entrySet()).stream().allMatch(e ->
	 *       |     ((Entry)e).getKey().equals(key) || entrySet().contains(e))
	 */
	void remove(Object key);

}
```
We can implement this interface efficiently using a hash table. Again, we first need a separate `Map` implementation for storing the entries that belong to a particular bucket. For this purpose, we define a simple `ArrayList`-based implementation:
```java
package collections;

public class ArrayMap implements Map {

	/**
	 * @invar | entries != null
	 * @invar | entries.stream().allMatch(e -> e instanceof Entry)
	 * @invar | entries.stream().map(e -> ((Entry)e).getKey()).distinct().count()
	 *        | == entries.size()
	 * 
	 * @representationObject
	 */
	private ArrayList entries = new ArrayList();
	
	private int indexOf(Object key) {
		for (int i = 0; i < entries.size(); i++) {
			Entry entry = (Entry)entries.get(i);
			if (entry.getKey().equals(key))
				return i;
		}
		return -1;
	}
	
	public Set entrySet() {
		Set result = new ArraySet();
		for (int i = 0; i < entries.size(); i++)
			result.add(entries.get(i));
		return result;
	}

	public Object get(Object key) {
		int index = indexOf(key);
		return index == -1 ? null : ((Entry)entries.get(index)).getValue();
	}
	
	/**
	 * @post | entrySet().size() == 0
	 */
	public ArrayMap() {}

	public void put(Object key, Object value) {
		int index = indexOf(key);
		if (index != -1)
			entries.remove(index);
		entries.add(new Entry(key, value));
	}
	
	public void remove(Object key) {
		int index = indexOf(key);
		if (index != -1)
			entries.remove(index);
	}
	

}
```
We can now define the efficient hash table-based implementation:
```java
package collections;

import java.util.Arrays;
import java.util.stream.IntStream;

public class HashMap implements Map {
	
	/**
	 * @invar | buckets != null
	 * @invar | Arrays.stream(buckets).allMatch(b -> b != null)
	 * @invar | IntStream.range(0, buckets.length).allMatch(i ->
	 *        |     buckets[i].entrySet().stream().allMatch(e ->
	 *        |         Math.floorMod(((Entry)e).getKey().hashCode(),
	 *        |             buckets.length) == i))
	 * 
	 * @representationObject
	 * @representationObjects
	 */
	private Map[] buckets;
	
	private Map getBucket(Object key) {
		return buckets[Math.floorMod(key.hashCode(), buckets.length)];
	}

	public Set entrySet() {
		ArraySet result = new ArraySet();
		for (int i = 0; i < buckets.length; i++)
			for (Object entry : buckets[i].entrySet().toArray())
				result.add(entry);
		return result;
	}

	public Object get(Object key) {
		return getBucket(key).get(key);
	}
	
	/**
	 * @pre | 0 < capacity
	 * @post | entrySet().size() == 0
	 */
	public HashMap(int capacity) {
		buckets = new Map[capacity];
		for (int i = 0; i < capacity; i++)
			buckets[i] = new ArrayMap();
	}

	public void put(Object key, Object value) {
		getBucket(key).put(key, value);
	}

	public void remove(Object key) {
		getBucket(key).remove(key);
	}

}
```

## The Java Collections Framework

The [Java Platform API](https://docs.oracle.com/en/java/javase/15/docs/api/index.html) is a library of classes and interfaces that are available to every Java program. It is divided into *modules*, each of which is divided into *packages*. The [`java.util` package](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/package-summary.html) of the `java.base` module contains the Java Collections Framework, a library of interfaces representing abstract datatypes and classes that implement them. ADT interfaces include [`List`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/List.html), [`Set`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/Set.html), and [`Map`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/Map.html), and the classes include [`ArrayList`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/ArrayList.html), [`LinkedList`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/LinkedList.html), [`HashSet`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/HashSet.html), and [`HashMap`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/HashMap.html), and [many others](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/doc-files/coll-reference.html). The interfaces and classes we defined above are simplified versions of the ones in the Java Collections Framework.

Another notable interface is interface [`Collection`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/Collection.html), which generalizes over lists, sets, and other collections. `Map` objects are not `Collection` objects, but given a `Map` object `myMap`, its set of keys `myMap.keySet()`, its set of entries `myMap.entrySet()`, and its collection of values `myMap.values()` are `Collection` objects.

Like we did above, the classes from the Java Collections Framework use the `equals(Object)` method to compare a given value to the elements of the collection or the keys of the map. For example, if we call `myCollection.contains(myValue)`, the result is `true` if and only if there is an element `e` in the collection such that `myValue.equals(e)`. Furthermore, again like we did above, the hash table-based implementations use the `hashCode()` method of the elements/keys to distribute their elements/entries among the buckets of the hash table. For this to work correctly, it is crucial that equal elements have equal hash codes.

The interfaces and classes from the Java Collections Framework are *generic*: instead of just using `Object` as the element type, they take the element type as a *type argument*. For example, `ArrayList<Student>` has element type `Student`, and `Map<String, Course>` stores entries whose keys are `String` objects and whose values are `Course` objects.

In Java, type arguments have to be classes or interfaces; you cannot use the primitive types `boolean`, `byte`, `short`, `int`, `long`, `char`, `float`, or `double`  as a type argument. However, you can use the corresponding wrapper class `Boolean`, `Byte`, `Short`, `Integer`, `Long`, `Character`, `Float`, or `Double`. Java automatically converts between a primitive type and its wrapper class as necessary. For example:

```java
ArrayList<Integer> myInts = new ArrayList<Integer>();
myInts.add(10); // Java automatically wraps value 10 into an `Integer` object.
int x = myInts.get(0); // Java automatically retrieves the wrapped value from the wrapper object.
```

(Note: the object allocation involved in wrapping a primitive value into an object may cause a significant overhead in terms of time and space.)

You can iterate over any collection object using the enhanced `for` loop:
```java
Collection<Student> myStudents = ...;
for (Student student : myStudents)
    System.out.println(student.getName());
```

Some important methods and constructors:
- `List.of()`, `Set.of()`, and `Map.of()` create an empty immutable list, set, or map, respectively.
- `List.of(42)`, `Set.of(42)`, and `Map.of(42, "forty-two")` create a singleton immutable list or a singleton immutable set containing the element 42, or a singleton immutable map containing an entry with key 42 and value `"forty-two"`, respectively.
- `List.of(10, 20)`, `Set.of(10, 20)`, `Map.of(10, "ten", 20, "twenty")` create an immutable list or set containing the two elements 10 and 20, or an immutable map mapping 10 to `"ten"` and 20 to `"twenty"`, respectively.
- `List.copyOf(myList)` returns an immutable copy of `List` object `myList`; `Set.copyOf(mySet)` returns an immutable copy of `Set` object `mySet`; and `Map.copyOf(myMap)` returns an immutable copy of `Map` object `myMap`. These methods are useful to ensure encapsulation of representation objects. (In fact, `List.copyOf` and `Set.copyOf` accept arbitrary collections, not just lists or sets.)
- An alternative approach for ensuring encapsulation when returning a collection from an API is to use methods `Collections.unmodifiableList(myList)`, `Collections.unmodifiableSet(mySet)`, or `Collections.unmodifiableMap(myMap)`, which return an unmodifiable *view* of the given `List`, `Set`, or `Map` object. The mutator methods of the view object throw an `UnsupportedOperationException`, but changes made to the `myList`, `mySet`, or `myMap` objects are visible through the view.
- `new ArrayList<>(myCollection)`, `new HashSet<>(myCollection)`, and `new HashMap<>(myMap)` create a new `ArrayList`, `HashSet`, or `HashMap` object initialized with the elements of the given `Collection` or `Map` object, respectively.
- `Arrays.asList(myArray)` returns a `List` view of array `myArray`; changes to the array are visible through the `List` object, and vice versa. Calling a mutator on the `List` object that changes its size throws an `UnsupportedOperationException`.
- `myCollection.addAll(yourCollection)` adds all elements of `yourCollection` to `myCollection`.
- `Collections.sort(myList)` sorts `myList`.
- `Objects.equals(o1, o2)` returns `true` if and only if either `o1` and `o2` are both `null`, or `o1` is not null and `o1.equals(o2)` returns `true`.
- `myList.equals(myObject)` returns `true` if and only if `myObject` is a `List` object, has the same size as `myList`, and for element `e1` of `myList` and corresponding element `e2` of `myObject`, `Objects.equals(e1, e2)` returns `true`.
- Similarly, `mySet.equals(myObject)` returns `true` if and only if `myObject` is a `Set` object, has the same size as `mySet`, and for every element `e1` of `mySet`, there is an element `e2` in `myObject` such that `Objects.equals(e1, e2)` returns `true`.
- Similarly, `myMap.equals(myObject)` returns `true` if and only if `myObject` is a `Map` object and their entry sets are equal as defined above.

### Other notable data structures

- [`ArrayDeque`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/ArrayDeque.html) implements ADTs [`Queue`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/Queue.html) and [`Deque`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/Deque.html) (*double-ended queue*) using the *ring buffer* data structure. It supports adding to and removing from the front and the back in constant time, with better performance than `LinkedList`.
- When iterating over `HashSet` or `HashMap` objects, the order in which elements are returned is unspecified and may be different every time. [`LinkedHashSet`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/LinkedHashSet.html) and [`LinkedHashMap`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/LinkedHashMap.html) are like `HashSet` and `HashMap` except that the iteration order is well-defined: the elements are returned in the order in which they were added.

The following data structures require that the elements be *comparable*. Specifically, either the elements have to implement interface [`Comparable`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/lang/Comparable.html) or a [`Comparator`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/Comparator.html) must be specified. Java Platform API classes that implement interface `Comparable` include `Byte`, `Short`, `Integer`, `Long`, `Char`, `Float`, `Double`, and `String`.

- [`TreeSet`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/TreeSet.html) implements interface [`SortedSet`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/SortedSet.html) and [`TreeMap`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/TreeMap.html) implements interface [`SortedMap`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/SortedMap.html) using a *red-black tree* data structure (a type of *balanced search tree*). Lookups and mutations of elements/entries take time logarithmic in the number of elements/entries. When iterating over the elements/entries, they are returned in ascending order.
- [`PriorityQueue`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/PriorityQueue.html) implements interface [`Queue`](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/Queue.html) using a *priority heap* data structure. Adding an element and removing the least element take time logarithmic in the number of elements; looking up the least element takes constant time. It performs better in space and time than a search tree for these operations, but in contrast to a search tree, iteration over the elements does not return them in any particular order.
