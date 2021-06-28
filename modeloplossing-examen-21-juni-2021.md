# Modeloplossing examen OGP 21 juni 2021

## Vraag 1

Zie aparte PDF.

## Vraag 2

### Basisantwoord

Het antwoord hieronder was voldoende om 19/20 te behalen op deze vraag.

Optionele elementen hoefde je niet te schrijven.

Gevorderde elementen hoefde je niet te schrijven om 12/20 te behalen voor deze vraag.

```java
package bestandssysteem;

import java.util.List; // optioneel

/**
 * @invar | getOuder() == null || getOuder().getIngangen().values().contains(this)
 */
public abstract class Knoop {

	/**
	 * @invar | ouder == null || ouder.ingangen.values().contains(this)
	 * 
	 * @peerObject // gevorderd
	 */
	Directory ouder;

	/**
	 * @peerObject // gevorderd
	 */
	public Directory getOuder() { return ouder; }
	
	Knoop() {}

	public abstract Knoop zoekOp(List<String> pad);
	
}
```
```java
package bestandssysteem;

import java.util.Arrays; // optioneel
import java.util.List; // optioneel

/**
 * @invar | getInhoud() != null
 */
public class Bestand extends Knoop {
	
	/**
	 * @invar | inhoud != null
	 * @representationObject
	 */
	byte[] inhoud = {};

	/**
	 * @creates | result // gevorderd
	 */
	public byte[] getInhoud() { return inhoud.clone(); }
	
	/**
	 * @post | getOuder() == null
	 * @post | getInhoud().length == 0
	 */
	public Bestand() {}

	/**
	 * @pre | inhoud != null
	 * @mutates_properties | getInhoud() // gevorderd
	 * @post | Arrays.equals(getInhoud(), inhoud)
	 */
	public void setInhoud(byte[] inhoud) {
		this.inhoud = inhoud.clone();
	}
	
	@Override
	public Knoop zoekOp(List<String> pad) {
		if (pad.isEmpty())
			return this;
		return null;
	}
	
}
```
```java
package bestandssysteem;

import java.util.HashMap; // optioneel
import java.util.List; // optioneel
import java.util.Map; // optioneel

import logicalcollections.LogicalMap; // optioneel

/**
 * @invar | getIngangen() != null
 * @invar | getIngangen().keySet().stream().allMatch(naam -> naam != null)
 * @invar | getIngangen().values().stream().allMatch(kind -> kind != null && kind.getOuder() == this)
 * @invar | getIngangen().values().stream().distinct().count() == getIngangen().size() // gevorderd
 */
public class Directory extends Knoop {

	/**
	 * @invar | ingangen != null
	 * @invar | ingangen.keySet().stream().allMatch(naam -> naam != null)
	 * @invar | ingangen.values().stream().allMatch(kind -> kind != null && kind.ouder == this)
	 * @invar | ingangen.values().stream().distinct().count() == ingangen.size() // gevorderd
	 * @representationObject
	 * @peerObjects | ingangen.values() // gevorderd
	 */
	Map<String, Knoop> ingangen = new HashMap<>();
	
	/**
	 * @creates | result // gevorderd
	 * @peerObjects | result.values() // gevorderd
	 */
	public Map<String, Knoop> getIngangen() { return Map.copyOf(ingangen); }
	
	/**
	 * @post | getOuder() == null
	 * @post | getIngangen().isEmpty()
	 */
	public Directory() {}

	/**
	 * @pre | naam != null
	 * @pre | kindknoop != null
	 * @pre | !getIngangen().containsKey(naam)
	 * @pre | kindknoop.getOuder() == null
	 * @mutates_properties | getIngangen(), kindknoop.getOuder() // gevorderd
	 * @post | getIngangen().equals(LogicalMap.plus(old(getIngangen()), naam, kindknoop))
	 * @post | kindknoop.getOuder() == this
	 */
	public void addIngang(String naam, Knoop kindknoop) {
		ingangen.put(naam, kindknoop);
		kindknoop.ouder = this;
	}
	
	/**
	 * @pre | getIngangen().containsKey(naam)
	 * @mutates_properties | getIngangen(), getIngangen().get(naam).getOuder() // gevorderd
	 * @post | getIngangen().equals(LogicalMap.minus(old(getIngangen()), naam))
	 * @post | old(getIngangen().get(naam)).getOuder() == null
	 */
	public void removeIngang(String naam) {
		ingangen.get(naam).ouder = null;
		ingangen.remove(naam);
	}

	@Override
	public Knoop zoekOp(List<String> pad) {
		if (pad.isEmpty())
			return this;
		Knoop kind = ingangen.get(pad.get(0));
		if (kind == null)
			return null;
		return kind.zoekOp(pad.subList(1, pad.size()));
	}
	
}
```
```java
package bestandssysteem;

import java.util.HashSet; // optioneel
import java.util.Iterator; // optioneel
import java.util.Set; // optioneel
import java.util.function.Consumer; // optioneel
import java.util.stream.Collectors; // optioneel
import java.util.stream.Stream; // optioneel

public class KnoopUtils {
	
	// basisoplossing
	public static Set<Knoop> getAfstammelingen(Knoop knoop) {
		Set<Knoop> result = new HashSet<>();
		if (knoop instanceof Directory) {
			for (Knoop kind : ((Directory)knoop).getIngangen().values()) {
				result.add(kind);
				result.addAll(getAfstammelingen(kind));
			}
		}
		return result;
	}
	
	// gevorderde oplossing
	public static Stream<Knoop> getAfstammelingenStream(Knoop knoop) {
		if (knoop instanceof Directory) {
			return ((Directory)knoop)
					.getIngangen().values().stream().flatMap(k ->
						Stream.concat(Stream.of(k), getAfstammelingenStream(k)));
		} else
			return Stream.of();
	}
	
	public static Set<Knoop> getAfstammelingen(Knoop knoop) {
		return getAfstammelingenStream(knoop).collect(Collectors.toSet());
	}
	
	// gevorderd
	public static Iterator<Byte> bytesIterator(Bestand bestand) {
		return new Iterator<Byte>() {
			byte[] bytes = bestand.getInhoud();
			int index = 0;
			public boolean hasNext() { return index < bytes.length; }
			public Byte next() { return bytes[index++]; }
		};
	}
	
	// gevorderd
	public static void forEachKind(Directory directory, Consumer<? super Knoop> consumer) {
		for (Knoop kind : directory.getIngangen().values())
			consumer.accept(kind);
	}

}
```
```java
package bestandssysteem.tests;

import static org.junit.jupiter.api.Assertions.*; // optioneel

import java.util.ArrayList; // optioneel
import java.util.Arrays; // optioneel
import java.util.HashSet; // optioneel
import java.util.Iterator; // optioneel
import java.util.List; // optioneel
import java.util.Map; // optioneel
import java.util.Set; // optioneel

import org.junit.jupiter.api.Test; // optioneel

import bestandssysteem.Bestand; // optioneel
import bestandssysteem.Directory; // optioneel
import bestandssysteem.Knoop; // optioneel
import bestandssysteem.KnoopUtils; // optioneel

class BestandssysteemTest { // optioneel

	@Test // optioneel
	void test() { // optioneel
		Bestand priemgetallen = new Bestand();
		assertEquals(null, priemgetallen.getOuder());
		assertArrayEquals(new byte[] {}, priemgetallen.getInhoud());
		
		priemgetallen.setInhoud(new byte[] {2, 3, 5, 7, 11});
		assertArrayEquals(new byte[] {2, 3, 5, 7, 11}, priemgetallen.getInhoud());
		
		Directory documenten = new Directory();
		assertEquals(null, documenten.getOuder());
		assertEquals(Map.of(), documenten.getIngangen());
		
		documenten.addIngang("priemgetallen", priemgetallen);
		assertEquals(Map.of("priemgetallen", priemgetallen), documenten.getIngangen());
		assertEquals(documenten, priemgetallen.getOuder());
		
		Directory jan = new Directory();
		jan.addIngang("Documenten", documenten);
		
		assertEquals(priemgetallen, jan.zoekOp(List.of("Documenten", "priemgetallen")));
		assertEquals(null, jan.zoekOp(List.of("Documenten", "onbestaand_bestand")));
		assertEquals(null, jan.zoekOp(List.of("Documenten", "priemgetallen", "fout_pad")));
		assertEquals(jan, jan.zoekOp(List.of()));
		
		assertEquals(Set.of(documenten, priemgetallen), KnoopUtils.getAfstammelingen(jan));
		
		ArrayList<Byte> bytes = new ArrayList<>();
		for (Iterator<Byte> i = KnoopUtils.bytesIterator(priemgetallen); i.hasNext(); )
			bytes.add(i.next());
		assertEquals(Arrays.asList(new Byte[] {2, 3, 5, 7, 11}), bytes);
		
		HashSet<Knoop> kinderen = new HashSet<>();
		KnoopUtils.forEachKind(jan, kind -> {
			assertFalse(kinderen.contains(kind));
			kinderen.add(kind);
		});
		assertEquals(Set.of(documenten), kinderen);
	} // optioneel

} // optioneel
```

### Vaak gemaakte fouten

In dalende volgorde van hoe zwaar dit aangerekend is.

- Publieke mutatoren aanbieden die de invarianten, waaronder de consistentie van de bidirectionele associatie, niet bewaren. In het bijzonder: publieke mutatoren die een verbinding slechts in &eacute;&eacute;n richting opzetten.
- Representatie-blootstelling: een publieke getter lekt een verwijzing naar een representatie-object naar de klant, of een publieke mutator installeert een object van de klant als representatie-object. Deze fout is zeer vaak gemaakt in methode `setInhoud`.
- Sommige van de abstracte toestandsinvarianten niet vermelden, of sommige van de representatie-invarianten niet vermelden.
- Niet correct statisch getypeerde code door het ontbreken van typecasts.
- Het gebruiken van private elementen van een klasse in een andere klasse.
- Onvolledige postcondities, die de nieuwe toestand van de gemuteerde peer groups niet volledig specificeren.
- Geen postconditie voor de constructor.
- Schendingen van de zichtbaarheidsregel: als de documentatie voor een programma-element X verwijst naar een programma-element Y, dan moet voor elke partij voor wie X zichtbaar is, ook Y zichtbaar zijn. In het bijzonder mag je niet verwijzen naar private of package-toegankelijke velden in de documentatie voor publieke klassen, constructoren, of methodes.

### Perfect antwoord

Om 20/20 te behalen moest je geneste abstracties toepassen. Zie een modeloplossing hiervoor [op GitHub](https://github.com/btj/bestandssysteem/tree/geneste_abstracties/bestandssysteem/src/bestandssysteem).

Merk op: veel studenten hebben weliswaar private velden gebruikt en package-accessible mutatoren voorzien, maar er is pas sprake van geneste abstracties als er aparte class-level en package-level representation invariants en abstract state invariants voorzien zijn, en als de package-accessible mutatoren voorzien zijn van een volledige documentatie en de nodige controles doen of precondities specificeren om de class-level representation invariants te bewaren. De class-level representation invariants mogen niet spreken over de toestand van peer objects van andere klassen (aangezien die invarianten niet zichtbaar zijn voor die andere klassen, en de ontwikkelaars van die klassen dus niet kunnen weten dat ze zich aan die invarianten moeten houden). Dit betekent dat de invarianten die de consistentie van de bidirectionele associatie uitdrukken, package-level invarianten moeten zijn.
