# Modeloplossing examen OGP 2 juni 2021

## Vraag 1

Zie aparte PDF.

## Vraag 2

### Basisantwoord

Het antwoord hieronder was voldoende om 19/20 te behalen op deze vraag.

Optionele elementen hoefde je niet te schrijven.

Gevorderde elementen hoefde je niet te schrijven om 12/20 te behalen voor deze vraag.

```java
package document;

import java.util.HashSet; // optioneel
import java.util.Set; // optioneel
import logicalcollections.LogicalList; // optioneel

/**
 * @invar | getOuder() == null || getOuder().getKinderen().contains(this)
 * @invar | !getVoorouders().contains(this)
 */
public abstract class Knoop {

	/**
	 * @invar | true
	 * @invar | true
	 * @invar | ouder == null || ouder.kinderen.contains(this)
	 * @invar | !getVooroudersInternal().contains(this) // gevorderd
	 * 
	 * @peerObject // gevorderd
	 */
	Element ouder;
	
	Set<Element> getVooroudersInternal() {
		Set<Element> result = new HashSet<>();
		Element e = ouder;
		while (e != null && !result.contains(e)) {
			result.add(e);
			e = e.ouder;
		}
		return result;
	}
	
	/**
	 * @peerObject // gevorderd
	 */
	public Element getOuder() { return ouder; }
	
	public Set<Element> getVoorouders() {
		return getVooroudersInternal();
	}
	
	Knoop() {}
	
	/**
	 * @pre | getOuder() != null
	 * 
	 * @mutates_properties | getOuder(), getOuder().getKinderen() // gevorderd
	 * 
	 * @post | getOuder() == null
	 * @post | old(getOuder()).getKinderen().equals(LogicalList.minus(old(getOuder().getKinderen()), this))
	 */
	public void verwijderVanOuder() {
		ouder.kinderen.remove(this);
		ouder = null;
	}
	
}
```
```java
package document;

/**
 * @invar | getTekst() != null
 */
public class Tekstknoop extends Knoop {
	
	/** @invar | tekst != null */
	String tekst;
	
	/** @immutable */
	public String getTekst() { return tekst; }
	
	/**
	 * @throws IllegalArgumentException | tekst == null
	 * 
	 * @post | getOuder() == null
	 * @post | getTekst().equals(tekst)
	 */
	public Tekstknoop(String tekst) {
		if (tekst == null)
			throw new IllegalArgumentException("`tekst` is null");
		this.tekst = tekst;
	}
	
	@Override
	public String toString() {
		return tekst;
	}

}
```
```java
package document;

import java.util.ArrayList; // optioneel
import java.util.List; // optioneel

import logicalcollections.LogicalList; // optioneel

/**
 * @invar | getTag() != null
 * @invar | getKinderen() != null
 * @invar | LogicalList.distinct(getKinderen()) // gevorderd
 * @invar | getKinderen().stream().allMatch(kind -> kind != null && kind.getOuder() == this)
 */
public final class Element extends Knoop {
	
	/**
	 * @invar | tag != null
	 * @invar | kinderen != null
	 * @invar | LogicalList.distinct(kinderen) // gevorderd
	 * @invar | kinderen.stream().allMatch(kind -> kind != null && kind.ouder == this)
	 */
	String tag;
	/**
	 * @representationObject
	 * @peerObjects // gevorderd
	 */
	List<Knoop> kinderen = new ArrayList<>();

	/**
	 * @immutable
	 */
	public String getTag() { return tag; }
	
	/**
	 * @creates | result // gevorderd
	 * @peerObjects // gevorderd
	 */
	public List<Knoop> getKinderen() { return List.copyOf(kinderen); }
	
	/**
	 * @throws IllegalArgumentException | tag == null
	 * @post | getOuder() == null
	 * @post | getTag().equals(tag)
	 * @post | getKinderen().isEmpty()
	 */
	public Element(String tag) {
		if (tag == null)
			throw new IllegalArgumentException("`tag` is null");
		this.tag = tag;
	}
	
	/**
	 * @pre | 0 <= index && index <= getKinderen().size()
	 * @pre | kind != null && kind.getOuder() == null && kind != this && !getVoorouders().contains(kind)
	 * 
	 * @mutates_properties | getKinderen(), kind.getOuder() // gevorderd
	 * 
	 * @post | kind.getOuder() == this
	 * @post | getKinderen().equals(LogicalList.plusAt(old(getKinderen()), index, kind))
	 */
	public void addKind(int index, Knoop kind) {
		kinderen.add(index, kind);
		kind.ouder = this;
	}
	
	@Override
	public String toString() {
		String result = "<" + tag + ">";
		for (Knoop kind : kinderen)
			result += kind;
		result += "</" + tag + ">";
		return result;
	}
	
}
```
```java
package document;

import java.util.Iterator; // optioneel
import java.util.List; // optioneel
import java.util.function.Consumer; // optioneel
import java.util.stream.Collectors; // optioneel

public class KnoopUtils {

	public static String getPlatteTekst(Knoop knoop) {
		if (knoop instanceof Tekstknoop)
			return ((Tekstknoop)knoop).getTekst();
		else if (((Element)knoop).getTag().equals("verborgen")) {
			return "";
		} else {
			// basisoplossing
			String result = "";
			for (Knoop kind : ((Element)knoop).getKinderen())
				result += getPlatteTekst(kind);
			return result;

			// gevorderde oplossing
			return ((Element)knoop).getKinderen().stream()
					.map(kind -> getPlatteTekst(kind))
					.collect(Collectors.joining());
		}
	}
	
	// gevorderd
	public static Iterator<Element> getVooroudersIterator(Knoop k) {
		return new Iterator<Element>() {
			Element e = k.getOuder();
			@Override
			public boolean hasNext() {
				return e != null;
			}
			@Override
			public Element next() {
				Element result = e;
				e = e.getOuder();
				return result;
			}
		};
	}
	
	// gevorderd
	public static void forEachAfstammeling(Knoop knoop, Consumer<? super Knoop> consumer) {
		if (knoop instanceof Element) {
			Element e = (Element)knoop;
			for (Knoop kind : e.getKinderen()) {
				consumer.accept(kind);
				forEachAfstammeling(kind, consumer);
			}
		}
	}
}
```
```java
package document.tests;

import static org.junit.jupiter.api.Assertions.assertEquals; // optioneel

import java.util.ArrayList; // optioneel
import java.util.Iterator; // optioneel
import java.util.List; // optioneel

import org.junit.jupiter.api.Test; // optioneel

import document.Element; // optioneel
import document.Knoop; // optioneel
import document.KnoopUtils; // optioneel
import document.Tekstknoop; // optioneel

class DocumentTest { // optioneel

	@Test // optioneel
	void test() { // optioneel
		Element k1 = new Element("paragraaf");
		assertEquals(null, k1.getOuder());
		assertEquals("paragraaf", k1.getTag());
		assertEquals(List.of(), k1.getKinderen());
		
		Tekstknoop k2 = new Tekstknoop("De Franse filosoof ");
		assertEquals(null, k2.getOuder());
		assertEquals("De Franse filosoof ", k2.getTekst());
		
		k1.addKind(0, k2);
		assertEquals(k1, k2.getOuder());
		assertEquals(List.of(k2), k1.getKinderen());
		
		Element k3 = new Element("vetgedrukt");
		k1.addKind(1, k3);
		assertEquals(List.of(k2, k3), k1.getKinderen());
		
		Tekstknoop k4 = new Tekstknoop("René Descartes");
		k3.addKind(0, k4);
		
		assertEquals("<paragraaf>De Franse filosoof <vetgedrukt>René Descartes</vetgedrukt></paragraaf>", k1.toString());
		assertEquals("De Franse filosoof René Descartes", KnoopUtils.getPlatteTekst(k1));
		
		k2.verwijderVanOuder();
		assertEquals(null, k2.getOuder());
		assertEquals(List.of(k3), k1.getKinderen());
		
		k3.addKind(0, k2);
		assertEquals("<paragraaf><vetgedrukt>De Franse filosoof René Descartes</vetgedrukt></paragraaf>", k1.toString());
		
		Element k5 = new Element("verborgen");
		k5.addKind(0, k1);
		assertEquals("", KnoopUtils.getPlatteTekst(k5));
		
		ArrayList<Element> voorouders = new ArrayList<>();
		for (Iterator<Element> i = KnoopUtils.getVooroudersIterator(k4); i.hasNext(); )
			voorouders.add(i.next());
		assertEquals(List.of(k3, k1, k5), voorouders);
		
		ArrayList<Knoop> afstammelingen = new ArrayList<>();
		KnoopUtils.forEachAfstammeling(k5, k -> afstammelingen.add(k));
		assertEquals(List.of(k1, k3, k2, k4), afstammelingen);
	} // optioneel

} // optioneel
```

### Vaak gemaakte fouten

In dalende volgorde van hoe zwaar dit aangerekend is.

- Publieke mutatoren aanbieden die de invarianten, waaronder de consistentie van de bidirectionele associatie, niet bewaren. In het bijzonder: publieke mutatoren die een verbinding slechts in &eacute;&eacute;n richting opzetten.
- Een publieke getter lekt een verwijzing naar het collectie-object naar de klant (dit heet *representation exposure*).
- Sommige van de abstracte toestandsinvarianten niet vermelden, of sommige van de representatie-invarianten niet vermelden.
- Niet correct statisch getypeerde code door het ontbreken van typecasts.
- Het gebruiken van private elementen van een klasse in een andere klasse.
- Onvolledige postcondities, die de nieuwe toestand van de gemuteerde peer groups niet volledig specificeren.
- Geen postconditie voor de constructor.
- Schendingen van de zichtbaarheidsregel: als de documentatie voor een programma-element X verwijst naar een programma-element Y, dan moet voor elke partij voor wie X zichtbaar is, ook Y zichtbaar zijn. In het bijzonder mag je niet verwijzen naar private of package-toegankelijke velden in de documentatie voor publieke klassen, constructoren, of methodes.

### Perfect antwoord

Om 20/20 te behalen moest je geneste abstracties toepassen. Zie een modeloplossing hiervoor [op GitHub](https://github.com/btj/document/tree/geneste_abstracties/document/src/document).

Merk op: veel studenten hebben weliswaar private velden gebruikt en package-accessible mutatoren voorzien, maar er is pas sprake van geneste abstracties als er aparte class-level en package-level representation invariants en abstract state invariants voorzien zijn, en als de package-accessible mutatoren voorzien zijn van een volledige documentatie en de nodige controles doen of precondities specificeren om de class-level representation invariants te bewaren. De class-level representation invariants mogen niet spreken over de toestand van peer objects van andere klassen (aangezien die invarianten niet zichtbaar zijn voor die andere klassen, en de ontwikkelaars van die klassen dus niet kunnen weten dat ze zich aan die invarianten moeten houden). Dit betekent dat de invarianten die de consistentie van de bidirectionele associatie uitdrukken, package-level invarianten moeten zijn.
