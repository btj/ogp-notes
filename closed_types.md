# Closed types

Classes and interfaces are typically *open-ended*, both in the sense of having an open-ended number of instances (e.g. clients can create arbitrarily many instances of class `ArrayList`) and in the sense of having an open-ended number of direct subtypes (e.g. client can define arbitrarily many classes that implement interface `List`).

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
    private int value;

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
