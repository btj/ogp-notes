# OGP Project Assignment Part 3

In Part 3 of the OGP Project, you will apply inheritance in five ways:

## 1. Introduce ShapeGroup subclasses

A shape group is either a leaf shape group or a nonleaf shape group. In Part 2, both kinds of shape groups were represented by instances of the same class `ShapeGroup`. This class has fields and methods that pertain to both kinds of shape groups, but it also has fields, constructors, and methods that pertain only to leaf shape groups (such as method `getShape`), and fields, constructors, and methods that pertain only to nonleaf shape groups (such as method `getSubgroupAt`). This is a poor design choice. It is better to move the class members that pertain only to leaf shape groups into a _subclass_ `LeafShapeGroup`, and to move the class members that pertain only to nonleaf shape groups into a subclass `NonleafShapeGroup`. Do so.

Note that this means that the shape group graph entity-relationship abstraction becomes a [multi-class abstraction](multi_class_abstractions.md). Therefore, you will need to apply package-level encapsulation, instead of just class-level encapsulation. It is best to apply encapsulation at both levels (an approach we call _nested abstractions_), but you need to do this only if you are going for a top score.
  
You shall apply this refactoring both to `drawit.shapegroups1.ShapeGroup` and `drawit.shapegroups2.ShapeGroup`.

You shall create proper internal and public documentation for the `ShapeGroup` class and its subclasses.
  
## 2. Introduce a Shape class hierarchy

In the DrawIt GUI, a drawing consists of a list of rounded polygons and shape groups. Furthermore, the list of selected items is a list of rounded polygons and shape groups. Therefore, it is convenient, when programming the DrawIt GUI, to be able to treat rounded polygons and shape groups uniformly as much as possible. However, we do not want to modify classes `RoundedPolygon` or `ShapeGroup`. Instead, create wrapper classes `RoundedPolygonShape` and `ShapeGroupShape` as well as an _interface_ `Shape` that generalizes `RoundedPolygonShape` and `ShapeGroupShape`. See the Javadoc for the classes and interfaces you should create [here](https://btj.github.io/drawit_part3_docs/index.html).

You shall create a package `drawit.shapes1` where a `ShapeGroupShape` stores a `drawit.shapegroups1.ShapeGroup` reference and an analogous package `drawit.shapes2` where a `ShapeGroupShape` stores a `drawit.shapegroups2.ShapeGroup` reference.

You need not write any documentation for this package or its contents.

**Note:** the constraints imposed upon clients in the documentation of method `createControlPoints` are to be interpreted as _preconditions_. You can rely on it that the client (= the DrawIt GUI) will comply with these restrictions; you need not write any code to check or enforce them.

## 3. Create a ShapeGroup exporter

Create a package `drawit.shapegroups1.exporter` with a class `ShapeGroupExporter` that has a method
```java
public static Object toPlainData(ShapeGroup shapeGroup)
```
that takes a `drawit.shapegroups1.ShapeGroup` object and returns a data structure built from `java.util.List<Object>`,
`java.util.Map<String, Object>`, and `java.lang.Integer` objects that contains all of the data stored by the `ShapeGroup` object.
  
For example, if the method is called with an argument that is a `NonleafShapeGroup` object that contains two `LeafShapeGroup` objects, the returned object might be equal to an object produced by the following expression:
```java
Map.of(
    "originalExtent", Map.of("left", 10, "top", 20, "right", 100, "bottom", 200),
    "extent", Map.of("left", 5, "top", 7, "right", 99, "bottom", 88),
    "subgroups", List.of(
        Map.of(
            "originalExtent", Map.of("left", 30, "top", 40, "right", 90, "bottom", 190),
            "extent", Map.of("left", 40, "top", 50, "right", 60, "bottom", 70),
            "shape", Map.of(
                "vertices", List.of(
                    Map.of("x", 40, "y", 40),
                    Map.of("x", 50, "y", 40),
                    Map.of("x", 40, "y", 50)),
                "radius", 5,
                "color", Map.of("red", 255, "green", 255, "blue", 255))),
        Map.of(
            "originalExtent", Map.of("left", 35, "top", 45, "right", 95, "bottom", 195),
            "extent", Map.of("left", 45, "top", 55, "right", 65, "bottom", 75),
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

## 4. Create a RoundedPolygonContainsTestStrategy class hierarchy

Add code to class `RoundedPolygon` so that it stores a _bounding box_ for its vertices, i.e. a `drawit.shapegroups1.Extent` object that represents the smallest nonempty axis-aligned rectangle that contains all of the polygon's vertices. (If the polygon has less than three vertices, there may be multiple different smallest nonempty axis-aligned rectangles that contain all of the vertices; in that case, any one of them is a valid bounding box.) Each mutator that mutates the list of vertices should also update the bounding box.

Furthermore, create an interface `RoundedPolygonContainsTestStrategy` with a method `boolean contains(RoundedPolygon polygon, IntPoint point)`, and two implementing classes, named `FastRoundedPolygonContainsTestStrategy` and `PreciseRoundedPolygonContainsTestStrategy`, that implement method `contains` by calling `contains` on the bounding box and by calling `contains` on the `RoundedPolygon` object itself, respectively. Class `FastRoundedPolygonContainsTestStrategy` shall deal with `null` arguments contractually; class `PreciseRoundedPolygonContainsTestStrategy` shall deal with `null` arguments defensively.
  
The challenge is to write proper documentation for interface `RoundedPolygonContainsTestStrategy` and its subclasses while adhering to the principle of behavioral subtyping. The documentation for method `contains` of interface `RoundedPolygonContainsTestStrategy` should be as precise as possible (but not more precise than that).

As always, you can use calls of side-effect-free public methods inside the documentation for other public methods. In particular, you can use calls of method `contains` of class `RoundedPolygon` to document your hierarchy. Generally, any methods you refer to inside documentation should be properly documented themselves; an exception is that you still need not write documentation for method `contains` of class `RoundedPolygon`.

Add this hierarchy to package `drawit`.

## 5. Override `Object` methods `equals`, `hashCode`, `toString` in class `Extent`

Extend class `drawit.shapegroups1.Extent` with methods that override methods `equals`, `hashCode`, and `toString` from class `java.lang.Object`. These should not distinguish two `drawit.shapegroups1.Extent` objects that represent the same rectangle.

Extend class `drawit.shapegroups2.Extent` analogously.

Write test cases that check that your extended `Extent` objects exhibit the correct behavior when used as elements of collections from the Java Collections API (such as `java.util.ArrayList` and `java.util.HashSet`). For example, method `contains` of classes `ArrayList` and `HashSet` shall return `true` if the collection contains an `Extent` object that represents the same rectangle as the given `Extent` object.

You need not write any documentation for these methods.

## General comment

As usual, for all of the features you implement, you shall also develop a comprehensive test suite.
