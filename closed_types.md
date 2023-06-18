# Closed types

Classes and interfaces are typically *open-ended*, both in the sense of having an open-ended number of instances (e.g. clients can create arbitrarily many instances of class `ArrayList`) and in the sense of having an open-ended number of direct subtypes (e.g. client can define arbitrarily many classes that implement interface `List`).

However, sometimes it makes more sense for a type to be *closed*, either in the sense of not allowing clients to create new instances, or  in the sense of not allowing clients to define new direct subtypes, or both.

## Closed set of instances

For example, consider a class `GamePlayerScore` whose instances represent the possible scores that a  player can have during a game in a  tennis match: 0 (*love*), 15, 30, and 40. We can define such a class as follows:
```java
public class GamePlayerScore {
    public static final GamePlayerScore LOVE = new GamePlayerScore(0, "LOVE", 0, "love");
    public static final GamePlayerScore FIFTEEN = new GamePlayerScore(1, "FIFTEEN", 15, "fifteen");
```
