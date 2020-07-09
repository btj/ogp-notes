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

## Question 3

The following solution would yield a perfect score for this question.

You did not need to write the elements marked as optional.

```java
package node_appearances; // optional

import java.awt.Color; // optional

public abstract class NodeAppearance {
	
	private final Color color;
	
	public Color getColor() { return color; }
	
	public NodeAppearance(Color color) {
		this.color = color;
	}
	
	@Override
	public boolean equals(Object other) {
		if (this == other)
			return true;
		if (other == null)
			return false;
		if (getClass() != other.getClass())
			return false;
		return color.equals(((NodeAppearance)other).color);
	}
	
	@Override
	public int hashCode() { // optional
		return color.hashCode();
	}

}
```
```java
package node_appearances; // optional

import java.awt.Color; // optional
import java.util.Objects; // optional

public class SquareNodeAppearance extends NodeAppearance {

	private final int width;
	
	public int getWidth() { return width; }
	
	public SquareNodeAppearance(Color color, int width) {
		super(color);
		this.width = width;
	}
	
	@Override
	public boolean equals(Object other) {
		if (!super.equals(other))
			return false;
		return width == ((SquareNodeAppearance)other).width;
	}
	
	@Override
	public int hashCode() { // optional
		return Objects.hash(getColor(), width);
	}
	
}
```
```java
package node_appearances; // optional

import java.awt.Color; // optional
import java.util.Objects; // optional

public class CircularNodeAppearance extends NodeAppearance {
	
	private final int radius;
	
	public int getRadius() { return radius; }
	
	public CircularNodeAppearance(Color color, int radius) {
		super(color);
		this.radius = radius;
	}
	
	@Override
	public boolean equals(Object other) {
		if (!super.equals(other))
			return false;
		return radius == ((CircularNodeAppearance)other).radius;
	}
	
	@Override
	public int hashCode() { // optional
		return Objects.hash(getColor(), radius);
	}

}
```
```java
package node_appearances.tests; // optional

import static org.junit.jupiter.api.Assertions.*; // optional

import java.awt.Color; // optional

import org.junit.jupiter.api.Test; // optional

import node_appearances.CircularNodeAppearance; // optional
import node_appearances.SquareNodeAppearance; // optional

class NodeAppearancesTest { // optional

	@Test // optional
	void test() { // optional
		SquareNodeAppearance a1 = new SquareNodeAppearance(Color.red, 5);
		assertEquals(Color.red, a1.getColor());
		assertEquals(5, a1.getWidth());
		
		assertEquals(a1, new SquareNodeAppearance(Color.red, 5));
		assertNotEquals(a1, new SquareNodeAppearance(Color.green, 5));
		assertNotEquals(a1, new SquareNodeAppearance(Color.red, 7));
		
		assertEquals(a1.hashCode(), new SquareNodeAppearance(Color.red, 5).hashCode()); // optional
		
		CircularNodeAppearance a2 = new CircularNodeAppearance(Color.blue, 9);
		assertEquals(Color.blue, a2.getColor());
		assertEquals(9, a2.getRadius());
		
		assertEquals(a2, new CircularNodeAppearance(Color.blue, 9));
		assertNotEquals(a2, new CircularNodeAppearance(Color.cyan, 9));
		assertNotEquals(a2, new CircularNodeAppearance(Color.blue, 11));
		
		assertEquals(a2.hashCode(), new CircularNodeAppearance(Color.blue, 9).hashCode()); // optional
		
		assertNotEquals(a1, a2);
		assertNotEquals(a2, a1);
	}

}
```
