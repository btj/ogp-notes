# Modeloplossing examen OGP juni 2020

## Vraag 1

Zie aparte PDF.

## Vraag 2

### Basisantwoord

Het antwoord hieronder was voldoende om 19/20 te behalen op deze vraag.

Optionele elementen hoefde je niet te schrijven.

Gevorderde elementen hoefde je niet te schrijven om een 16/20 te behalen op de vraag.

```java
package exams_rooms;

import java.util.HashSet; // optioneel
import java.util.Set; // optioneel

import logicalcollections.LogicalSet; // optioneel

/**
 * @invar | getRooms() != null
 * @invar | getRooms().stream().allMatch(room -> room != null && room.getExams().contains(this))
 */
public class Exam {

	/**
	 * @invar | rooms != null
	 * @invar | rooms.stream().allMatch(room -> room != null && room.exams.contains(this))
	 * @representationObject // gevorderd
	 * @peerObjects // gevorderd
	 */
	Set<Room> rooms = new HashSet<>();
	
	/**
	 * @creates | result // optioneel
	 * @peerObjects // gevorderd
	 */
	public Set<Room> getRooms() {
		return Set.copyOf(rooms);
	}
	
	/**
	 * @post | getRooms().isEmpty()
	 */
	public Exam() {}
	
	/**
	 * @throws IllegalArgumentException | room == null
	 * @mutates_properties | getRooms(), room.getExams() // gevorderd
	 * @post | getRooms().equals(LogicalSet.plus(old(getRooms()), room))
	 * @post | room.getExams().equals(LogicalSet.plus(old(room.getExams()), this))
	 */
	public void linkTo(Room room) {
		if (room == null)
			throw new IllegalArgumentException("room is null");
		rooms.add(room);
		room.exams.add(this);
	}
	
	/**
	 * @pre | room != null
	 * @mutates_properties | getRooms(), room.getExams() // gevorderd
	 * @post | getRooms().equals(LogicalSet.minus(old(getRooms()), room))
	 * @post | room.getExams().equals(LogicalSet.minus(old(room.getExams()), this))
	 */
	public void unlinkFrom(Room room) {
		rooms.remove(room);
		room.exams.remove(this);
	}
	
}
```
```java
package exams_rooms;

import java.util.HashSet; // optioneel
import java.util.Set; // optioneel

/**
 * @invar | getExams() != null
 * @invar | getExams().stream().allMatch(exam -> exam != null && exam.getRooms().contains(this))
 */
public class Room {

	/**
	 * @invar | exams != null
	 * @invar | exams.stream().allMatch(exam -> exam != null && exam.rooms.contains(this))
	 * @representationObject // gevorderd
	 * @peerObjects // gevorderd
	 */
	Set<Exam> exams = new HashSet<Exam>();
	
	/**
	 * @creates | result // optioneel
	 * @peerObjects // gevorderd
	 */
	public Set<Exam> getExams() {
		return Set.copyOf(exams); 
	}
	
	/**
	 * @post | getExams().isEmpty()
	 */
	public Room() {}
	
}
```
```java
package exams_rooms.tests;

import static org.junit.jupiter.api.Assertions.*; // optioneel

import java.util.Set; // optioneel

import org.junit.jupiter.api.Test; // optioneel

import exams_rooms.Exam; // optioneel
import exams_rooms.Room; // optioneel

class ExamsRoomsTest {

	@Test
	void test() {
		// Minimal test script that tests all statements
		Exam exam1 = new Exam();
		assertEquals(Set.of(), exam1.getRooms());

		Room room1 = new Room();
		assertEquals(Set.of(), room1.getExams());
		
		exam1.linkTo(room1);
		assertEquals(Set.of(room1), exam1.getRooms());
		assertEquals(Set.of(exam1), room1.getExams());
		
		exam1.unlinkFrom(room1);
		assertEquals(Set.of(), exam1.getRooms());
		assertEquals(Set.of(), room1.getExams());
		
		// Optional additional test cases to cover more scenarios
		Room room2 = new Room();
		exam1.linkTo(room1);
		exam1.linkTo(room2);
		assertEquals(Set.of(room1, room2), exam1.getRooms());
		assertEquals(Set.of(exam1), room1.getExams());
		assertEquals(Set.of(exam1), room2.getExams());
		
		exam1.unlinkFrom(room1);
		assertEquals(Set.of(room2), exam1.getRooms());
		assertEquals(Set.of(), room1.getExams());
		assertEquals(Set.of(exam1), room2.getExams());
		
		Exam exam2 = new Exam();
		exam2.linkTo(room2);
		assertEquals(Set.of(room2), exam1.getRooms());
		assertEquals(Set.of(room2), exam2.getRooms());
		assertEquals(Set.of(), room1.getExams());
		assertEquals(Set.of(exam1, exam2), room2.getExams());
		
		exam1.unlinkFrom(room2);
		assertEquals(Set.of(), exam1.getRooms());
		assertEquals(Set.of(room2), exam2.getRooms());
		assertEquals(Set.of(), room1.getExams());
		assertEquals(Set.of(exam2), room2.getExams());
	}

}
```

### Vaak gemaakte fouten

In dalende volgorde van hoe zwaar dit aangerekend is.

- Publieke mutatoren aanbieden die de invarianten, waaronder de consistentie van de bidirectionele associatie, niet bewaren. In het bijzonder: publieke mutatoren die een verbinding slechts in &eacute;&eacute;n richting opzetten.
- Een publieke getter lekt een verwijzing naar het collectie-object naar de klant (dit heet *representation exposure*), en een mutator van de andere klasse maakt hiervan gebruik. (Deze lekkage wordt dus uitgebuit door de module zelf.)
- Oneindige recursie door telkens naar de andere klasse te delegeren, zonder stopconditie.
- Een publieke getter lekt een verwijzing naar het collectie-object naar de klant, maar de module zelf maakt hier geen gebruik van.
- Sommige van de abstracte toestandsinvarianten niet vermelden, of sommige van de representatie-invarianten niet vermelden.
- Onvolledige postcondities, die de nieuwe toestand van de gemuteerde peer groups niet volledig specificeren.
- Geen postconditie voor de constructor.
- Schendingen van de zichtbaarheidsregel: als de documentatie voor een programma-element X verwijst naar een programma-element Y, dan moet voor elke partij voor wie X zichtbaar is, ook Y zichtbaar zijn. In het bijzonder mag je niet verwijzen naar private of package-toegankelijke velden in de documentatie voor publieke klassen, constructoren, of methodes.

### Perfect antwoord

Om 20/20 te behalen moest je geneste abstracties toepassen. Zie een modeloplossing hiervoor [op GitHub](https://github.com/btj/exams_rooms/tree/master/exams_rooms/src/exams_rooms).

Merk op: veel studenten hebben weliswaar private velden gebruikt en package-accessible mutatoren voorzien, maar er is pas sprake van geneste abstracties als er aparte class-level en package-level representation invariants en abstract state invariants voorzien zijn, en als de package-accessible mutatoren voorzien zijn van een volledige documentatie en de nodige controles doen of precondities specificeren om de class-level representation invariants te bewaren. De class-level representation invariants mogen niet spreken over de toestand van peer objects van andere klassen (aangezien die invarianten niet zichtbaar zijn voor die andere klassen, en de ontwikkelaars van die klassen dus niet kunnen weten dat ze zich aan die invarianten moeten houden). Dit betekent dat de invarianten die de consistentie van de bidirectionele associatie uitdrukken, package-level invarianten moeten zijn.

# Vraag 3

## Basisantwoord

Het onderstaande antwoord was voldoende om 12/20 te behalen op deze vraag.

Merk op: opdat collecties die gebruik maken van hashing, zoals `HashSet`, correct zouden werken, moet elke klasse waarvan de instanties mogelijks gebruikt worden met dergelijke collecties ervoor zorgen dat instanties die gelijk zijn volgens `equals(Object)` ook gelijke hashcodes toegekend krijgen door `hashCode`. Het afwezig zijn van een `hashCode`-methode is echter niet aangerekend.

Merk op: dit is niet het enige mogelijke juiste antwoord. Vele andere antwoorden, waaronder antwoorden met een structuur die sterk verschilt van deze modeloplossing, zijn ook juist gerekend.

Optionele elementen hoefde je niet te schrijven.

```java
public abstract class Sequence {
	
	public abstract int getLength();

}
```
```java
public class EmptySequence extends Sequence {

	@Override
	public int getLength() { return 0; }
	
	@Override
	public boolean equals(Object other) { return other instanceof EmptySequence; }
	
	@Override
	public int hashCode() { return 0; } // optioneel
	
}
```
```java
import java.util.Objects; // optioneel

public class NonemptySequence extends Sequence {

	private final Object head;
	private final Sequence tail;
	
	public Object getHead() { return head; }
	public Sequence getTail() { return tail; }
	
	@Override
	public int getLength() { return 1 + tail.getLength(); }

	@Override
	public boolean equals(Object other) { // <<< parametertype Object!!!
		if (!(other instanceof NonemptySequence))
			return false;
		NonemptySequence otherSequence = (NonemptySequence)other; // <<< typecast!!!
		return Objects.equals(head, otherSequence.head) && tail.equals(otherSequence.tail);
	}
	
	@Override
	public int hashCode() { return Objects.hash(head, tail); } // optioneel

	public NonemptySequence(Object head, Sequence tail) {
		if (tail == null) throw new IllegalArgumentException("tail is null"); // optioneel
		this.head = head;
		this.tail = tail;
	}
	
}
```
```java
import static org.junit.jupiter.api.Assertions.*;

import java.util.HashSet;
import java.util.List;

import org.junit.jupiter.api.Test;

class SequencesTest {

	@Test
	void test() {
		// Minimal test suite that tests all statements
		EmptySequence empty = new EmptySequence();
		assertEquals(0, empty.getLength());
		assertEquals(empty, new EmptySequence());
		assertTrue(new HashSet<>(List.of(empty)).contains(new EmptySequence()));
		
		NonemptySequence c = new NonemptySequence("c", empty);
		assertEquals("c", c.getHead());
		assertEquals(empty, c.getTail());
		assertEquals(1, c.getLength());
		assertEquals(c, new NonemptySequence("c", new EmptySequence()));
		assertNotEquals(empty, c);
		assertNotEquals(c, empty);
		assertNotEquals(c, new NonemptySequence("b", new EmptySequence()));
		assertNotEquals(c, new NonemptySequence("c", new NonemptySequence("d", new EmptySequence())));
		assertTrue(new HashSet<>(List.of(c)).contains(new NonemptySequence("c", new EmptySequence())));
	}

}
```

### Vaak gemaakte fouten

Twee ernstige fouten zijn zeer vaak gemaakt:
- Geen `equals`-methode met parametertype `Object`. Een `equals`-methode met een ander parametertype dan `Object`, of met meerdere parameters, overschrijft **niet** de `Object.equals`-methode en wordt **niet** opgeroepen door de `assertEquals`-methode van JUnit, of door bv. de `contains`-methode van de collecties van de Java Collections API.
- Het verwijzen naar velden of methodes gedefinieerd in een subklasse via een referentie met als statisch type de superklasse, zonder een typecast. Dit gebeurde zeer vaak in de `equals`-methode.

### Perfect antwoord

Zie een modeloplossing die uitwendige en inwendige iteratie ondersteunt, en generics gebruikt met flexibele types, [op GitHub](https://github.com/btj/sequences/tree/master/sequences/src).

Vele studenten hadden fouten in hun iterators. De volgende fouten kwamen vaak voor:
- `hasNext` kijkt na dat de *staart* niet leeg is, niet dat de lijst zelf niet leeg is. Hierdoor zal de iteratie &eacute;&eacute;n element te vroeg stoppen.
- `next` geeft het huidige element terug, maar muteert het iterator-object niet om te wijzen naar het volgende element.
