# Exam OOP June 2020 Model Solution

## Question 1

See separate PDF.

## Question 2

The following solution would yield a perfect score for this question.

You did not need to write the elements marked as optional.

You needed to write the elements marked as advanced only to obtain a very high score.

```java
package networks; // optional

import java.util.HashSet; // optional
import java.util.Set; // optional

import logicalcollections.LogicalSet; // optional

/**
 * @invar | getNeighbors() != null
 * @invar | getNeighbors().stream().allMatch(neighbor -> neighbor != null && neighbor.getNeighbors().contains(this))
 */
public class Node {
	
	/**
	 * @invar | neighbors != null
	 * @invar | neighbors.stream().allMatch(neighbor -> neighbor != null && neighbor.neighbors.contains(this))
	 * 
	 * @representationObject // advanced
	 * @peerObjects // advanced
	 */
	private Set<Node> neighbors = new HashSet<>();
	
	/**
	 * @peerObjects // advanced
	 */
	public Set<Node> getNeighbors() { return Set.copyOf(neighbors); }

	/**
	 * @mutates | this // optional
	 * @post | getNeighbors().isEmpty()
	 */
	public Node() {}
	
	/**
	 * @throws IllegalArgumentException | other == null
	 * @mutates_properties | this.getNeighbors(), other.getNeighbors() // advanced
	 * @post | getNeighbors().equals(LogicalSet.plus(old(getNeighbors()), other))
	 * @post | other.getNeighbors().equals(LogicalSet.plus(old(other.getNeighbors()), this))
	 */
	public void linkTo(Node other) {
		if (other == null)
			throw new IllegalArgumentException("other is null");
		neighbors.add(other);
		other.neighbors.add(this);
	}
	
	/**
	 * @pre | other != null
	 * @mutates_properties | this.getNeighbors(), other.getNeighbors() // advanced
	 * @post | getNeighbors().equals(LogicalSet.minus(old(getNeighbors()), other))
	 * @post | other.getNeighbors().equals(LogicalSet.minus(old(other.getNeighbors()), this))
	 */
	public void unlinkFrom(Node other) {
		if (other == null)
			throw new IllegalArgumentException("other is null");
		neighbors.remove(other);
		other.neighbors.remove(this);
	}

}
```
```java
package networks.tests; // optional

import static org.junit.jupiter.api.Assertions.*; // optional

import java.util.Set; // optional

import org.junit.jupiter.api.Test; // optional

import networks.Node; // optional

class NodesTest { // optional

	@Test // optional
	void test() { // optional
		Node node1 = new Node();
		assertEquals(Set.of(), node1.getNeighbors());
		
		Node node2 = new Node();
		node1.linkTo(node2);
		assertEquals(Set.of(node2), node1.getNeighbors());
		assertEquals(Set.of(node1), node2.getNeighbors());
		
		Node node3 = new Node();
		node1.linkTo(node3);
		assertEquals(Set.of(node2, node3), node1.getNeighbors());
		assertEquals(Set.of(node1), node2.getNeighbors());
		assertEquals(Set.of(node1), node3.getNeighbors());
		
		node2.unlinkFrom(node1);
		assertEquals(Set.of(node3), node1.getNeighbors());
		assertEquals(Set.of(), node2.getNeighbors());
		assertEquals(Set.of(node1), node3.getNeighbors());
	}

}
```
