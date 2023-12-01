# Closed types

Classes and interfaces are typically *open-ended*, both in the sense of having an open-ended number of instances (e.g. clients can create arbitrarily many instances of class `ArrayList`) and in the sense of having an open-ended number of direct subtypes (e.g. clients can define arbitrarily many classes that implement interface `List`).

However, sometimes it makes more sense for a type to be *closed*, either in the sense of not allowing clients to create new instances, or  in the sense of not allowing clients to define new direct subtypes, or both.

## Types with a closed set of instances

For example, consider a class `Score` whose instances represent the possible scores that a player can have during a game in a tennis match: 0 (*love*), 15, 30, and 40. We can define such a class as follows:
```java
public final class Score {
    public static final Score LOVE = new Score(0, "LOVE", 0);
    public static final Score FIFTEEN = new Score(1, "FIFTEEN", 15);
    public static final Score THIRTY = new Score(2, "THIRTY", 30);
    public static final Score FORTY = new Score(3, "FORTY", 40) {
        @Overrride
        public Score next() { throw new UnsupportedOperationException("There is no next score"); }
    };
    private static final Score[] values = {LOVE, FIFTEEN, THIRTY, FORTY};

    public static Score[] values() { return values.clone(); }

    private final int ordinal;
    private final String name;
    private final int value;

    public int ordinal() { return ordinal; }
    public String name() { return name; }
    public int value() { return value; }
    public Score next() { return values[ordinal + 1]; }

    private Score(int ordinal, String name, int value) {
        this.ordinal = ordinal;
        this.name = name;
        this.value = value;
    }
}
```

We declare the constructor as `private` so that clients cannot create new instances.

### Enum classes

In fact, Java supports a more concise syntax for declaring such classes with an enumerated set of instances:
```java
public enum Score {
    LOVE(0),
    FIFTEEN(15),
    THIRTY(30),
    FORTY(40) {
        @Override
        public Score next() { throw new UnsupportedOperationException("There is no next score"); }
    };

    private final int value;

    public int value() { return value; }
    public Score next() { return values()[ordinal() + 1]; }

    private Score(int value) { this.value = value; }
}
```

### Switching over an enum class instance

Java has convenient syntax for performing case analysis on an enum class instance, in the form of *switch statements* and *switch expressions*:
```java
public String getScoreInFrench(Score score) {
    switch (score) {
        case LOVE -> { return "zéro"; }
        case FIFTEEN -> { return "quinze"; }
        case THIRTY -> { return "trente"; }
        default -> { return "quarante"; }
    }
}
```
```java
public String getScoreInFrench(Score score) {
    return switch (score) {
        case LOVE -> "zéro";
        case FIFTEEN -> "quinze";
        case THIRTY -> "trente";
        case FORTY -> "quarante";
    };
}
```

## Types with a closed set of direct subtypes

Consider an interface GameState whose instances are intended to represent the various states that a game of tennis can be in:
```java
public interface GameState {
    public record Regular(Score servingPlayerScore, Score receivingPlayerScore) implements GameState {
        Regular { Objects.requireNonNull(servingPlayerScore); Objects.requireNonNull(receivingPlayerScore); }
    }
    public record Advantage(boolean servingPlayer) implements GameState {}
    public record Won(boolean servingPlayer) implements GameState {}
}
```
We can prevent clients from defining additional classes that implement interface GameState by declaring it as *sealed*:
```java
public sealed interface GameState permits GameState.Regular, GameState.Advantage, GameState.Won { /* ... */ }
```
In this example, we can in fact just leave out the `permits` clause. This means only direct subtypes declared in the same file are allowed:
```java
public sealed interface GameState { /* ... */ }
```

### Switching over a sealed type

We can use switch statements or switch expressions to perform case analysis on an instance of a sealed type:
```java
public String toString(GameState state) {
    return switch (state) {
        case GameState.Regular(var servingPlayerScore, var receivingPlayerScore) ->
                servingPlayerScore.value() + "-" + receivingPlayerScore.value();
        case GameState.Advantage(var servingPlayer) ->
                "advantage " + (servingPlayer ? "serving" : "receiving") + " player";
        case GameState.Won(var servingPlayer) ->
                "won by the " + (servingPlayer ? "serving" : "receiving") + " player";
    };
}
```
