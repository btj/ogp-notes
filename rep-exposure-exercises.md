# Representation exposure: Exercises

## String (1)

The following String class is intended to implement an abstraction for representing pieces of text (i.e. sequences of characters) that is *immutable*,
i.e. a String instance should represent the same piece of text throughout its lifetime.
However, it has a flaw.

```java
public class String {

    private char[] characters;

    public char[] toArray() { return characters; }

    public String(char[] characters) {
        this.characters = characters.clone();
    }

}
```

### Exercise: Exploit the flaw

Complete the test case below that shows that instances of this class are, in fact, mutable:
```java
public class StringTest {

    @Test
    void testStringIsMutable() {
        // TODO: Add code
        String myString = // TODO: Add code
        assertEquals('H', myString.toArray()[0]);
        // TODO: Add code
        assertEquals('B', myString.toArray()[0]);
    }

}
```

### Exercise: Fix the flaw

Now, update the String class to fix the flaw and check that the exploit now fails.

## String (2)

The following String class is intended to implement an abstraction for representing pieces of text (i.e. sequences of characters) that is *immutable*,
i.e. a String instance should represent the same piece of text throughout its lifetime.
However, it has a flaw.

```java
public class String {

    private char[] characters;

    public char[] toArray() { return characters.clone(); }

    public String(char[] characters) {
        this.characters = characters;
    }

}
```

### Exercise: Exploit the flaw

Complete the test case below that shows that instances of this class are, in fact, mutable:
```java
public class StringTest {

    @Test
    void testStringIsMutable() {
        // TODO: Add code
        String myString = // TODO: Add code
        assertEquals('H', myString.toArray()[0]);
        // TODO: Add code
        assertEquals('B', myString.toArray()[0]);
    }

}
```

### Exercise: Fix the flaw

Now, update the String class to fix the flaw and check that the exploit now fails.

## Matrix (1)

The following Matrix class is intended to implement an abstraction for representing matrices that is *immutable*,
i.e. a Matrix instance should represent the same matrix throughout its lifetime.
However, it has a flaw.

```java
public class Matrix {
    private int nbRows;
    private int nbColumns;
    private double[][] rows;

    public double[][] getRows() {
        return rows.clone();
    }

    public Matrix(int nbRows, int nbColumns, double[][] rows) {
        this.nbRows = nbRows;
        this.nbColumns = nbColumns;
        this.rows = new double[nbRows][nbColumns];
        for (int rowIndex = 0; rowIndex < nbRows; rowIndex++)
            for (int columnIndex; columnIndex < nbColumns; columnIndex++)
                this.rows[rowIndex][columnIndex] = rows[rowIndex][columnIndex];
    }
}
```

### Exercise: Exploit the flaw

Complete the test case below that shows that instances of this class are, in fact, mutable:
```java
public class MatrixTest {

    @Test
    void testMatrixIsMutable() {
        // TODO: Add code
        Matrix myMatrix = // TODO: Add code
        assertEquals(42, myMatrix.getRows()[0][0]);
        // TODO: Add code
        assertEquals(24, myMatrix.getRows()[0][0]);
    }

}
```

### Exercise: Fix the flaw

Now, update the Matrix class to fix the flaw and check that the exploit now fails.

## Matrix (2)

The following Matrix class is intended to implement an abstraction for representing matrices that is *immutable*,
i.e. a Matrix instance should represent the same matrix throughout its lifetime.
However, it has a flaw.

```java
public class Matrix {
    private int nbRows;
    private int nbColumns;
    private double[][] rows;

    public double[][] getRows() {
        double[][] result = new double[nbRows][nbColumns];
        for (int rowIndex = 0; rowIndex < nbRows; rowIndex++)
            for (int columnIndex; columnIndex < nbColumns; columnIndex++)
                result[rowIndex][columnIndex] = rows[rowIndex][columnIndex];
        return result;
    }

    public Matrix(int nbRows, int nbColumns, double[][] rows) {
        this.nbRows = nbRows;
        this.nbColumns = nbColumns;
        this.rows = rows.clone();
    }
}
```

### Exercise: Exploit the flaw

Complete the test case below that shows that instances of this class are, in fact, mutable:
```java
public class MatrixTest {

    @Test
    void testMatrixIsMutable() {
        // TODO: Add code
        Matrix myMatrix = // TODO: Add code
        assertEquals(42, myMatrix.getRows()[0][0]);
        // TODO: Add code
        assertEquals(24, myMatrix.getRows()[0][0]);
    }

}
```

### Exercise: Fix the flaw

Now, update the Matrix class to fix the flaw and check that the exploit now fails.
