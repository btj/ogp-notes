# DrawIt Part 2 Assignment

## 1. Shape groups

You shall implement the API documented [here](https://btj.github.io/drawit_part2_oop_docs/index.html).
Note: some elements that have not changed since Part 1 are not documented.

You shall implement classes `Extent` and `ShapeGroup` and its subclasses twice: once in package `drawit.shapegroups1`, and once in package `drawit.shapegroups2`. Both versions shall implement exactly the same API. They shall be different only in their internal implementation approach:
- Class `drawit.shapegroups1.Extent` shall store the `left`, `top`, `right`, and `bottom` attributes and compute the `width` and `height` attributes, whereas class `drawit.shapegroups2.Extent` shall store the `left`, `top`, `width`, and `height` attributes and compute the `right` and `bottom` attributes.
- Class `drawit.shapegroups1.ShapeGroup` and its subclasses shall be implemented such that method `getSubgroup` runs in constant time, i.e. its running time shall not depend on the number of subgroups directly contained by the shape group. Class `drawit.shapegroups2.ShapeGroup` and its subclasses shall be implemented such that methods `bringToFront` and `sendToBack` run in constant time, i.e. their running time shall not depend on the number of subgroups directly contained by the shape group's parent.

Hint: for inspiration on how to implement `drawit.shapegroups2.ShapeGroup`, see the [HTML documents, linked list implementation](https://github.com/btj/html_ir/blob/f49255eb73ef7c921a29afc4870a778623200d71/html_ir/src/html_ir/Node.java) and [LinkedIntList](https://github.com/btj/intlist_inheritance/blob/master/intlist_inheritance/src/intlist_inheritance/LinkedIntList.java) examples. (But note the important difference between LinkedIntList and ShapeGroup: LinkedIntList is a single-object abstraction that uses a linked list as a representation internally, whereas ShapeGroup is a multi-object abstraction where the ShapeGroup objects themselves are the elements of the list of their parent's subgroups.)

Students who work alone need to implement either `drawit.shapegroups1.ShapeGroup` or `drawit.shapegroups2.ShapeGroup`, but not both. (They do need to implement both `drawit.shapegroups1.Extent` and `drawit.shapegroups2.Extent`.)

Both versions of classes `Extent` and `ShapeGroup` shall deal with illegal calls defensively. You can throw any exception you like, but of course you must document which exception you throw using a `@throws` clause. Typical exceptions thrown defensively include `IllegalArgumentException`, `IllegalStateException`, and `UnsupportedOperationException`. (The GUI catches only `IllegalArgumentException`, but this does not mean that throwing other exceptions is wrong.)

Note that the shape group graph entity-relationship abstraction is a [multi-class abstraction](multi_class_abstractions.md). Therefore, you will need to apply package-level encapsulation, instead of just class-level encapsulation. It is best to apply encapsulation at both levels (an approach we call _nested abstractions_), but you need to do this only if you are going for a perfect score.

Once you have finished implementing the API, you can run the [DrawIt GUI](https://github.com/btj/drawit_part2/releases/download/1/drawitgui_part2_oop.jar) against it. The `.jar` file contains two copies of the GUI: `drawitgui1.GUI` uses `drawit.shapegroups1`, and `drawitgui2.GUI` uses `drawit.shapegroups2`.

The GUI extends the Part 1 GUI with the following functionality:
- Shapes are filled with their current color rather than outlined.
- You can set a shape's color by selecting it and pressing `r` (red), `g` (green), or `b` (blue).
- You can put a shape inside a `ShapeGroup` by selecting it and pressing `G` (Shift-G). Then, you can transform the shape group by dragging the top-left and bottom-right controls.
- You can create a non-leaf `ShapeGroup` by selecting two or more `ShapeGroup`s and then pressing `G` (Shift-G). The entire non-leaf shape group can be transformed as one unit by dragging its controls.
- To select a child of a `ShapeGroup`, first select the `ShapeGroup` and then click inside the child.
- To bring a subgroup of a `ShapeGroup` to the front, select the subgroup and press `F` (Shift-F). To send it to the back, press `B` (Shift-B).

You shall create proper documentation for the API. See the [detailed documentation instructions](https://github.com/btj/ogp-notes/blob/master/drawit_part2_doc_instr.md). **Note: these instructions are mostly unchanged since Part 1. The main changes are in the list of exceptions at the top and the list of useful library methods towards the end.**

### Notes

- Class `RoundedPolygon` has been extended with a `color` property, and you now need to generate a `fill` command in `getDrawingCommands()`.
- For the `fill` drawing command to fill the shape defined by the preceding sequence of `line` and `arc` commands correctly, each next line or arc in the sequence should start where the preceding one finished. However, whether the shape is filled correctly is not important, so you are free to ignore this issue.

## 2. ShapeGroup exporter

Create a package `drawit.shapegroups1.exporter` with a class `ShapeGroupExporter` that has a method
```java
public static Object toPlainData(ShapeGroup shapeGroup)
```
that takes a `drawit.shapegroups1.ShapeGroup` object and returns a data structure built from `java.util.List<Object>`,
`java.util.Map<String, Object>`, and `java.lang.Integer` objects that contains all of the data stored by the `ShapeGroup` object.
  
For example, if the method is called with an argument that is a `NonleafShapeGroup` object that contains two `LeafShapeGroup` objects, the returned object might be equal to an object produced by the following expression:
```java
Map.of(
    "subgroups", List.of(
        Map.of(
            "shape", Map.of(
                "vertices", List.of(
                    Map.of("x", 40, "y", 40),
                    Map.of("x", 50, "y", 40),
                    Map.of("x", 40, "y", 50)),
                "radius", 5,
                "color", Map.of("red", 255, "green", 255, "blue", 255))),
        Map.of(
            "shape", Map.of(
                "vertices", List.of(
                    Map.of("x", 45, "y", 45),
                    Map.of("x", 55, "y", 45),
                    Map.of("x", 45, "y", 55)),
                "radius", 7,
                "color", Map.of("red", 128, "green", 128, "blue", 128)))))
```
You are not allowed to build support for this data format into class `ShapeGroup` or its subclasses directly. Instead, you must write code in method `toPlainData` to test if the argument is a `LeafShapeGroup` or a `NonleafShapeGroup` and then to build the correct data structure based on the outcome of that test.
  
You need not write any documentation for this package or its contents.

You need **not** implement an analogous exporter for `drawit.shapegroups2.ShapeGroup` objects.

## 3. Override `Object` methods `equals`, `hashCode`, `toString` in class `Extent`

Extend class `drawit.shapegroups1.Extent` with methods that override methods `equals`, `hashCode`, and `toString` from class `java.lang.Object`. These should not distinguish two `drawit.shapegroups1.Extent` objects that represent the same rectangle.

Extend class `drawit.shapegroups2.Extent` analogously.

Write test cases that check that your extended `Extent` objects exhibit the correct behavior when used as elements of collections from the Java Collections API (such as `java.util.ArrayList` and `java.util.HashSet`). For example, method `contains` of classes `ArrayList` and `HashSet` shall return `true` if the collection contains an `Extent` object that represents the same rectangle as the given `Extent` object.

## General comment

As usual, for all of the features you implement, you shall also develop a comprehensive test suite.
