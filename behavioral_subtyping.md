# Behavioral subtyping: modular reasoning about programs that use dynamic binding

## Modular reasoning about programs

### Non-modular reasoning

In order to be able to deliver programs that exhibit correct behavior, we need to _reason_ about them, so as to convince ourselves that the program will exhibit the correct behavior in all circumstances.

For example, consider the following program:
```java
class Company {

    String[] getLocations() {
        return new String[] {"Brussels", "Paris", "Berlin"};
    }

}

class Program {

    static void printLocations(Company company) {
        String[] locations = company.getLocations();
        for (int i = 0; i < 3; i++)
            System.out.println(locations[i]);
    }

    public static void main(String[] args) {
        printLocations(new Company());
    }

}
```

As part of reviewing this program to convince ourselves that it behaves correctly, we need to convince ourselves that the array accesses in method `printLocations` will never be out of bounds.

A straightforward approach to this reasoning task is to perform _non-modular reasoning_: to determine the behavior of a method call, we look inside the called method's implementation. In the example, to determine the behavior of `company.getLocations()`, we look at the body of method `getLocations()` and see that it returns an array of length 3. From this observation, we can deduce that the array accesses in method `printLocation` will not fail.

This _non-modular reasoning_ approach is _brittle_: if we convince ourselves of
a program's correctness through non-modular reasoning, and then change the
implementation of any method anywhere in the program, we do not simply have to
re-check the modified method; we also have to find all of the method's callers,
and re-check them as well. Indeed, the reasoning we used to convince ourselves
of their correctness may have been invalidated by the modification. But it does not stop there: by the same argument, we have to re-check the callers' callers as well, and so on. In fact, it's even
worse: since we may have taken context information into account when reviewing
a method call, and the context may have changed due to the modification, we
have to review not just the direct and indirect callers of the modified method, but all
direct and indirect callees of the direct and indirect callers as well; that is, we effectively
have to re-review the entire program.

For example, if we change method `getLocations` to return an array of size two, the reasoning we used to establish the correctness of method `printLocations` is invalidated. Indeed, executing method `printLocations` will now cause an out-of-bounds array access.

Does this mean that method `printLocations` is incorrect? Or does it mean that method `getLocations` is incorrect? The answer is: neither. With non-modular reasoning, there is no notion of correctness of methods; there is only the correctness of the program as a whole.

## Modular reasoning

The solution, of course, is to perform _modular reasoning_ instead. In the modular reasoning approach, we assign a _specification_ to each method, which specifies the _correct behaviors_ of the method. This way, we define a notion of _correctness of a method_: a method M is correct if and only if all of its behaviors are allowed by its specification, _assuming that the method calls performed by M behave in accordance with the called methods' specifications_.

To convince ourselves of the correctness of a program, we simply need to check that each method complies with its specification, under the assumption that called methods comply with theirs. If each of a program's methods is correct in this way, and the main method's specification expresses the allowed behaviors of the program as a whole, then the correctness of the program as a whole follows as a corrollary.

If we have verified a program modularly, and then we modify one of its methods, we only need to re-check that that one method still complies with its original specification. If so, we can immediately conclude that the correctness of the program as a whole is preserved.

If the changed method no longer complies with its original specification, we need to update its specification and re-verify its callers as well. This "change propagation" stops when we reach a method whose original specification is preserved.

In the example, there are at least two possible specifications that we can assign to method `getLocations`:
- We can assign a strong specification:
  ```java
  /** @post | result != null && result.length == 3 && Arrays.stream(result).allMatch(e -> e != null) */
  String[] getLocations() {
      return new String[] {"Brussels", "Paris", "Berlin"};
  }
  ```
  Given this specification for method `getLocations`, methods `getLocations` and `printLocations` are both correct. If we then change method `getLocations`
  so that it returns an array of size two, the method no longer complies with
  its specification so we need to update its specification and re-verify
  callers as well. We will then discover that method `printLocations` needs to
  be updated as well.
- We can also assign a weaker specification:
  ```java
  /** @post | result != null && Arrays.stream(result).allMatch(e -> e != null) */
  String[] getLocations() {
      return new String[] {"Brussels", "Paris", "Berlin"};
  }
  ```
  Given this specification for method `getLocations`, method `getLocations` itself is correct but method `printLocations` is not correct. Indeed, from the specification of `getLocations` we cannot conclude that the array accesses performed by `printLocations` will not be out of bounds.

  Suppose we update method `printLocations` as follows:
  ```java
  /** @pre | company != null */
  static void printLocations(Company company) {
      String[] locations = company.getLocations();
      for (String location : locations)
          System.out.println(location);
  }
  ```
  This modified version of `printLocations` is correct. Furthermore, suppose we now
  change method `getLocations` to return an array of size two. This modified
  version of `getLocations` still complies with its original specification, so we can conclude immediately that the correctness of the program as a whole is preserved. In particular, since during our review of method `printLocations`, we assumed only the specification of method `getLocations` and did not look at its implementation, the reasoning we used to conclude the correctness of method `printLocations` still holds, so we do not have to review method `printLocations` again.

## Dynamic binding

Before we discuss modular reasoning about programs that use dynamic binding, we briefly review the concept of dynamic binding.

For each method call in a Java program, the Java compiler checks, before program
execution starts, that there is a corresponding method in the program. It looks for this method
by considering the _static type_ of the target expression of the call (the expression before the dot) and the argument expressions. This process is known as _method call resolution_; we call the method found this way the _resolved_ method.

Consider the following example program:
```java
abstract class Company {

    abstract String[] getLocations();

}

class CompanyA extends Company {

    String[] getLocations() {
        return new String[] {"Brussels", "Paris", "Berlin"};
    }

}

class Program {

    static void printLocations(Company company) {
        String[] locations = company.getLocations();
        for (int i = 0; i < 3; i++)
            System.out.println(locations[i]);
    }

    public static void main(String[] args) {
        printLocations(new CompanyA());
    }

}
```

In this program, the resolved method of the call `printLocations(new CompanyA())` in method `main` is the method `printLocations` in class `Program`. The static type of argument expression `new CompanyA()` is `CompanyA`, which is a subtype of the parameter type `Company` of the method. If the argument expression was `"Hello"` instead, method call resolution would fail, because `String` is not a subtype of `Company`.

Similarly, the resolved method of the call `company.getLocations()` in method `printLocations` is method `getLocations` in class `Company`, because the static type of target expression `company` is `Company`.

These two calls illustrate the two different types of method calls in Java:
- Call `printLocations(new CompanyA())` is a _statically bound_ call: when the
  call expression is evaluated at run time, the method called is exactly the
  resolved method.
- Call `company.getLocations()` is a _dynamically bound_ call.
  When evaluating a dynamically bound method call expression,
  the method called is _either_ the resolved method _or_ some method that
  _overrides_ it. More specifically, to determine which method is called,
  the computer looks at the _target object_ of the call, obtained by evaluating
  the target expression:
  if the class of the target object declares or inherits a method that
  _overrides_ the resolved method, then this method is called instead of the resolved method.
  In the example program, when evaluating call expression
  `company.getLocations()`, the target object is an object of class `CompanyA` (because `main` calls `printLocations` with an instance of class `CompanyA` as an argument). Class `CompanyA`
  declares a method `getLocations` that overrides the one from class `Company`,
  so this is the one that is called.

## Modular reasoning about programs that use dynamic binding

### Applying basic modular reasoning

To reason about programs that use dynamic binding, such as the one shown above, we can simply apply the principle we introduced above: assign a specification to each method of the program, and check that each method's behavior complies with its specification, assuming that the behavior of method calls complies with the called methods' specifications. Suppose we assign the strong specification to method `getLocations` in class `CompanyA`:
```java
/** @post | result != null && result.length == 3 && Arrays.stream(result).allMatch(e -> e != null) */
String[] getLocations() {
    return new String[] {"Brussels", "Paris", "Berlin"};
}
```
When checking method `printLocations`, we need to determine which method is called by call `company.getLocations()`. Since the precondition of `printLocations` does not specify the precise class of argument `company`, we need to consider all possible callees. In this program, since the only method that overrides abstract method `getLocations` in class `Company` is the one in class `CompanyA`, we can assume the call complies with the specification of `getLocations` in class `CompanyA`. This way, we can conclude the correctness of `printLocations`.

This approach is modular, in the sense that if we modify a method, and the modified method still complies with its original specification, we can immediately conclude that the correctness of the program as a whole is preserved.

However, this approach does _not_ deal optimally with another type of program modification: adding a new class that extends an existing class.

Indeed, suppose we extend the example program with the following class:
```java
class CompanyB extends Company {
    /** @post | result != null && result.length == 2 && Arrays.stream(result).allMatch(e -> e != null) */
    String[] getLocations() {
        return new String[] {"Vienna", "Prague"};
    }
}
```

By adding this class, we have enlarged the set of possible callees of call `company.getLocations()` in method `printLocations`. As a result, we need to re-verify method `printLocations`. In this case, we discover that it is not correct as-is.

In general, when applying the simple modular reasoning approach defined above to a program with dynamically bound calls, after adding a class to the program we need to re-check all methods that perform dynamically bound calls.

We conclude that the basic modular reasoning approach defined above is not adequate for reasoning about programs that use dynamic binding.

### Modular reasoning about dynamic binding: basic principle

To solve this issue, we look, when checking a method, not at the specifications of the _called methods_ of the call expressions that appear in the method, but at the specifications of the _resolved methods_. For example, when checking method `printLocations`, we only look at the specification of method `getLocations` in class `Company`. Furthermore, we check, when checking a method, not just that it complies with its own specification, but also that it complies with the specifications of _all methods it overrides_. In the example, we check that method `getLocations` in class `CompanyA` complies both with its own specification, and with the specification of method `getLocations` in class `Company`.

When adding a new class, we only need to check that its methods comply with the specifications of all methods they override. If so, we can immediately conclude that the correctness of the program as a whole is preserved.

In the example, there are two cases:
- If we assign the strong specification (stating that the method returns an array of length three) to method `getLocations` in class `Company`, then method `printLocations` is correct, but adding class `CompanyB` is incorrect because its `getLocations` method does not comply with the specification of method `getLocations` in class `Company` which it overrides.
- If we assign the weak specification (which leaves the length of the array unspecified) to method `getLocations` in class `Company`, then we need to update method `printLocations`. After fixing method `printLocations`, the program is correct. When adding class `CompanyB`, we only need to check that its method `getLocations` complies with the specification of `getLocations` in `Company`. Since it does, we can immediately conclude that adding this class preserves the correctness of the program as a whole.

We summarize the basic principle of effective modular reasoning about programs with dynamic binding as follows:
- A method is correct if and only if its behaviors are allowed by its own specification and by the specifications of all methods it overrides, assuming that the behavior of each call it performs complies with the specification of the _resolved_ method of the call.
- If all of a program's methods are correct, and the specification of the program's main method expresses the allowed behaviors of the program as a whole, then correctness of the program as a whole follows as a corrollary.

### Derived principle: strengthening of specifications

If we apply this basic principe directly, we potentially have to verify a single method implementation against many different specifications. To avoid this, we can instead use a derived principle, that requires us to only check that 1) each method complies with its own specification, and 2) that each method's specification _strengthens_ the specifications of all methods it overrides. We say that a specification S strengthens another specification S' if and only if each imaginable method that complies with S also complies with S'.

If a specification consists of a precondition and a postcondition, then we have the following property: specification S strenghtens specification S' if 1) the precondition of S _weakens_ the precondition of S', and 2) the postcondition of S strengthens the postcondition of S'.

For example, in the following sequence of specifications for a method `abs`, each next specification strenghtens the preceding one:
```java
/**
 * @pre | false
 * @post | true
 */
public static int abs(int x)

/**
 * @pre | 0 <= x
 * @post | true
 */
public static int abs(int x)

/**
 * @pre | 0 <= x
 * @post | 0 <= result
 */
public static int abs(int x)

/**
 * @pre | true
 * @post | 0 <= result
 */
public static int abs(int x)

/**
 * @pre | true
 * @post | false
 */
public static int abs(int x)
```
The first specification is the weakest possible one: it does not allow any calls of the method, so the method is free to crash or exhibit any behavior whatsoever. The last one is the strongest possible one, because it is unimplementable: since there exists no method implementation that satisfies postcondition `false`, it is vacuously true that every such implementation has the desired behavior (for any definition of "desired behavior" whatsoever).

### Derived principle: behavioral subtyping

If we assign a specification to each method of a class, then in doing so, we define a _behavioral type_. We say an object O is of behavioral type C, if, for every method M of C, calls of M on O comply with the specification of M in C.

(Notice that the behavioral type defined by class is defined entirely by its _documentation_; the _implementation_ of a class is completely irrelevant to the behavioral type it defines. (But the implementation of class C _is_ relevant to the question of whether the instances of class C are of the behavioral type C.))

Using this definition, we can rephrase the principle of modular reasoning about programs with dynamic binding as follows:
- a method is correct if it complies with its specification, assuming that each object it interacts with is of the behavioral type given by its static type.
- (If all methods of a class C are correct in this way, then this implies that the instances of class C are of behavioral type C.)
- If a class D extends a class C, then behavioral type D is a _behavioral subtype_ of behavioral type C.

We say a behavioral type D is a behavioral subtype of a behavioral type C if each object that is of behavioral type D is also of behavioral type C.

If the specifications of the methods of D that override methods of C strengthen the specifications of the overridden methods, then it follows that behavioral type D is a behavioral subtype of type C.

We can then summarize the approach for dealing with dynamic binding as follows: Java's static type checker ensures that a subclass D of a class C is a _syntactic_ subtype of C; to achieve correct programs, we must ensure that D is a _behavioral_ subtype of C as well.
