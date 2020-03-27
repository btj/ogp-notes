# Multi-class entity-relationship abstractions

In [Entity-relationship abstractions](entity_relationship_abstractions.md), we
introduced the concept of entity-relationship abstractions. The examples we
discussed there involved entity graphs consisting of only a single type of
entity: `OOPStudent`. Such abstractions are built from groups of instances of
class `OOPStudent`. We refer to such abstractions as _single-class
entity-relationship abstractions_.

In this note, we consider the task of designing and implementing abstractions
that store entity graphs involving multiple entity types. We will declare a
separate class for each entity type. Such abstractions are therefore
_multi-class entity-relationship abstractions_.

To illustrate the concepts, we will consider a generalization of the OOP team
composition graphs example: we will consider graphs of project course students
and the teams they belong to. For simplicity, a team may have arbitrarily many
members, but each student may be a member of only one team.

Here is an initial attempt to implement an abstraction that stores such graphs:

```java
package bigteams;

public class ProjectCourseStudent {
    
    private Team team;
    
    public Team getTeam() { return team; }
    
    public ProjectCourseStudent() {}

    public void join(Team team) {
        if (this.team != null)
            throw new IllegalStateException("this student is already in a team");
        
        this.team = team;
        team.members.add(this);
    }

    public void leaveTeam() {
        if (this.team == null)
            throw new IllegalStateException("this student is not in a team");
        
        team.members.remove(this);
        team = null;
    }
}
```

```java
package bigteams;

public class Team {
    
    private HashSet<ProjectCourseStudent> members = new HashSet<>();
    
    public Set<ProjectCourseStudent> getMembers() { return Set.copyOf(members); }

    public Team() {}
    
}
```

```java
package bigteams;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class BigTeamsTest {

    @Test
    void test() {
        ProjectCourseStudent student1 = new ProjectCourseStudent();
        ProjectCourseStudent student2 = new ProjectCourseStudent();
        Team team = new Team();
        
        student1.join(team);
        assertEquals(team, student1.getTeam());
        assertEquals(Set.of(student1), team.getMembers());
        
        student2.join(team);
        assertEquals(team, student2.getTeam());
        assertEquals(Set.of(student1, student2), team.getMembers());
        
        student1.leaveTeam();
        assertEquals(Set.of(student2), team.getMembers());
        
        student2.leaveTeam();
        assertEquals(Set.of(), team.getMembers());
    }

}
```

Notice that we use a [`HashSet`](https://docs.oracle.com/en/java/javase/13/docs/api/java.base/java/util/HashSet.html) to store the members of a team.
Class `HashSet` is a _generic class_; it takes the type of its elements as a _type parameter_. In the _parameterized type_ `HashSet<ProjectCourseStudent>`,
`ProjectCourseStudent` is the _type argument_ for generic class `HashSet`.

Type `HashSet<T>` is a _subtype_ of type `Set<T>`. This means that every instance of `HashSet<T>` is also an instance of `Set<T>`.

Notice also that we implement a bidirectional association between classes `ProjectCourseStudent` and class `Team`, and we make sure that its
_consistency_ is preserved at all times: if a `ProjectCourseStudent` instance S refers to a `Team` instance T, then T also refers to S, and vice versa.

Unfortunately, the code above is rejected by Java's static type checker. Indeed, class `ProjectCourseStudent` accesses class `Team`'s private field
`members`. The private fields of a class may be accessed by the class itself only. We could make field `members` `public` but this would break
the abstraction's _encapsulation_: clients would see the abstraction's internal implementation details and could modify the field without respecting the abstraction's
representation invariants. For example, a client could set the `members` field of some `Team` instance T to `null` or could add a `ProjectCourseStudent` instance S to its `HashSet` without
updating S's `team` field to point to T, thus breaking the consistency of the bidirectional association and the validity of the abstraction's representation.

What we need is some way to make field `members` accessible to class `ProjectCourseStudent` without making it accessible to clients. In Java, this can be done
by putting classes `ProjectCourseStudent` and `Team` into a _package_ by themselves, and making field `members` _package-accessible_. A Java program element is package-accessible by
default; that is, if you do not specify any accessibility modifier (such as `private` or `public`) for a program element, the program element is package-accessible. This means
it may be accessed by any code in the same package.

We conclude that to implement multi-class abstractions, we generally need to implement them using a _package_ as the unit of encapsulation rather than a _class_. We apply this
principle to the example by moving the example client (class `BigTeamsTest`) out of package `bigteams` and by making the fields of class `ProjectCourseStudent` and `Team` package-accessible.
Analogously to class-encapsulated abstractions, we specify package representation invariants (using `@invar` clauses in the fields' Javadoc comments) and package abstract state invariants (using `@invar` clauses in the classes' Javadoc comments):

```java
package bigteams;

import logicalcollections.LogicalSet;

/**
 * Each instance of this class represents a student in a project course,
 * as part of a student-team graph.
 * 
 * @invar If a student is in a team, it is among its members.
 *    | getTeam() == null || getTeam().getMembers().contains(this)
 */
public class ProjectCourseStudent {
    
    /**
     * @invar | true // Phase 1 representation invariant
     * @invar | team == null || team.members.contains(this) // Phase 2 representation invariant
     * 
     * @peerObject
     */
    Team team;
    
    /**
     * Returns this student's team, or {@code null} if they are not in a team.
     * 
     * @peerObject
     */
    public Team getTeam() { return team; }
    
    /**
     * Initializes this object as representing a student who is not in a team.
     */
    public ProjectCourseStudent() {}

    /**
     * Make this student a member of the given team.
     *
     * @pre {@code team} is not null.
     *      (Cannot make this a @throws for now because of https://github.com/fsc4j/fsc4j/issues/6 .)
     *    | team != null
     * @throws IllegalStateException if this student is already in a team.
     *    | getTeam() != null
     * 
     * @mutates_properties | this.getTeam(), team.getMembers()
     * 
     * @post The given team's members equal its old members plus this student.
     *    | team.getMembers().equals(LogicalSet.plus(old(team.getMembers()), this))
     */
    public void join(Team team) {
        if (this.team != null)
            throw new IllegalStateException("this student is already in a team");
        
        this.team = team;
        team.members.add(this);
    }

    /**
     * Make this student no longer be a member of their team.
     * 
     * @pre This student is in a team.
     *      (Cannot make this a @throws for now because of https://github.com/fsc4j/fsc4j/issues/6 .)
     *    | getTeam() != null
     * 
     * @mutates_properties | this.getTeam(), this.getTeam().getMembers()
     * 
     * @post This student is not in a team.
     *    | getTeam() == null
     * @post This student's old team's members are its old members minus this student.
     *    | old(getTeam()).getMembers().equals(LogicalSet.minus(old(getTeam().getMembers()), this))
     */
    public void leaveTeam() {
        if (this.team == null)
            throw new IllegalStateException("this student is not in a team");
        
        team.members.remove(this);
        team = null;
    }
}
```

```java
package bigteams;

import java.util.HashSet;
import java.util.Set;

/**
 * Each instance of this class represents a team in a student-team graph.
 * 
 * @invar Each of this team's members has this team has its team.
 *    | getMembers().stream().allMatch(s -> s != null && s.getTeam() == this)
 */
public class Team {
    
    /**
     * @invar | members != null // Phase 1 representation invariant
     * @invar | members.stream().allMatch(s -> s != null && s.team == this) // Phase 2 representation invariant
     * 
     * @representationObject
     * @peerObjects
     */
    HashSet<ProjectCourseStudent> members = new HashSet<>();
    
    /**
     * Returns this team's set of members.
     * 
     * @post | result != null
     * @creates | result
     * @peerObjects
     */
    public Set<ProjectCourseStudent> getMembers() { return Set.copyOf(members); }

    /**
     * Initializes this object as representing an empty team.
     * 
     * @mutates | this
     * @post This team has no members.
     *    | getMembers().isEmpty()
     */
    public Team() {}
    
}
```

```java
package bigteams.tests;

import static org.junit.jupiter.api.Assertions.*;

import java.util.Set;

import org.junit.jupiter.api.Test;

import bigteams.ProjectCourseStudent;
import bigteams.Team;

class BigTeamsTest {

    @Test
    void test() {
        ProjectCourseStudent student1 = new ProjectCourseStudent();
        ProjectCourseStudent student2 = new ProjectCourseStudent();
        Team team = new Team();
        
        student1.join(team);
        assertEquals(team, student1.getTeam());
        assertEquals(Set.of(student1), team.getMembers());
        
        student2.join(team);
        assertEquals(team, student2.getTeam());
        assertEquals(Set.of(student1, student2), team.getMembers());
        
        student1.leaveTeam();
        assertEquals(Set.of(student2), team.getMembers());
        
        student2.leaveTeam();
        assertEquals(Set.of(), team.getMembers());
    }

}
```

Notice the following:
- We define each object's peer group by putting a `@peerObject` tag in the Javadoc comment for field `team` and a `@peerObjects` tag in the Javadoc comment for field `members`. The latter means that each element of `X.members` is a peer object of `X`.
- We also let our clients know each object's peer group by also putting a `@peerObject` tag in the Javadoc comment for getter `getTeam()` and a `@peerObjects` tag in the Javadoc comment for getter `getMembers()`.
- The representation invariant `team == null || team.members.contains(this)` declared in class `ProjectCourseStudent` is not well-defined if `team.members` is null. This invariant should be guarded by another invariant that says that `team.members` is not null, and that is checked first. There is a representation invariant `members != null` in class `Team`. We can use it to guard the invariant in class `ProjectCourseStudent` by defining the order of checking the representation invariants of a peer group as follows: first, the Phase 1 representation invariant of each peer object is checked; then, the Phase 2 representation invariant of each peer object is checked; and so on, until all representation invariants have been checked. We simply define the Phase 1 representation invariant of an object to be the first representation invariant defined in the object's class, and so on. This is why we insert a dummy representation invariant `true` into class `ProjectCourseStudent`; this ensures that the invariant that relies on `team.members` being non-null is a Phase 2 invariant.


