# Introduction: Topic of the course

This is the course text for the course “Object-oriented programming” at KU Leuven, Belgium.
This course introduces students to three related topics:
* Object-Oriented Programming (OOP): a style of programming (often called a programming “model” or ”paradigm”) where a program consists of _classes_. Each class defines a number of _fields_ and _methods_; these determine the _state_ and _behavior_, respectively, of the _objects_ obtained by _instantiating_ these classes. _Inheritance_ between classes and _encapsulation_ are used to achieve modularity and reuse.
* The object-oriented programming language Java: a widely used, high-level programming language that was originally developed by James Gosling at Sun Microsystems, first released in 1995.
* Modular programming: a very general software engineering principle.
The latter, which we will explain further, is by far the most important topic.

Modular programming is the principal method by which software engineers manage the complexity of the task of building, maintaining, and evolving large software systems.
Modular programming means _decomposing_ software systems into a number of _modules_, which may be developed, understood, verified, and evolved independently from, and in parallel with, other modules.
By enabling this independent evolution, the principle allows building, maintaining and evolving software systems that are much larger and more complex than would otherwise be possible.

A module may interact with another module by invoking the latter's operations. (We then say the former is a _client module_ of the latter.) To make independent development possible, modular programming requires a clear and _abstract_ _specification_ of the _API_ offered by a module to its client modules, that is, of the _syntax_ and _semantics_ (behavior) of the operations defined by the module for use by clients.
Each module must then be _implemented_ such that it complies with its API specification.
Additionally, this _correctness_ must only depend on the specifications, not the implementations, of the modules whose program elements it uses.
Good specifications of module APIs are widely recognized as essential in software engineering, especially for important, long-lived APIs between separately developed modules.

For example, consider a student using an HP laptop running the Google Chrome web browser on Microsoft Windows to remotely attend a course via Blackboard Inc.'s `bbcollab.com` website. The software system running on this laptop consists of (at least) four modules:
- The web page downloaded from `bbcollab.com` contains JavaScript code that invokes operations defined by the web browser, as specified by the [DOM API](https://www.w3.org/TR/REC-DOM-Level-1/), such as [`createTextNode`](https://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#i-Document) to e.g. show chat messages.
- The web browser implements the DOM API by invoking the operations defined by Windows, as specified by the [Windows API](https://docs.microsoft.com/en-us/windows/win32/apiindex/windows-api-list), such as [`CreateWindow`](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowa) to show a window on the user's desktop.
- Windows implements the Windows API by invoking the operations defined by the device drivers for the laptop, as specified by the [Windows Driver API](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/), such as [`DrawPrimitive`](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/d3dumddi/nc-d3dumddi-pfnd3dddi_drawprimitive) to draw a line on the laptop's screen.
- The device drivers developed by HP for the laptop implement the Windows Driver API.

From time to time, Blackboard Inc., Google, Microsoft, and HP, independently and in parallel, develop new versions of their module and deploy them to the student's laptop. If the student's laptop keeps working correctly, this is thanks to the fact that the APIs between these modules have been specified clearly and carefully.

As shown by this example, the principle of modular programming is extremely general.
Specifically, its relevance is _not_ restricted to object-oriented programming or high-level languages like Java.
Nevertheless, this course covers modular software development in the context of OOP and particularly Java.
Both the OOP model and Java include principles (like encapsulation) and features (like static types) that facilitate modularity and defining APIs.
Additionally, both OOP and the Java community traditionally attach great value to modularity and specification of APIs.

The focus of this course will be on how to design and clearly define the syntax and semantics of module APIs.
For defining the syntax of APIs, we will make use of Java's strong support for this, particularly its strong static typing, and its support for encapsulation: the compiler and virtual machine (Java's execution environment) together enforce that a module is accessed only through its official API, and that the correct number and types of arguments are passed to each API call.
However, besides precisely defining the syntax of APIs, it is crucial to also precisely define a module API's _semantics_ (meaning), in terms of the behavior generated by API calls.
Therefore, in this course, we put a strong emphasis on how to write clear and comprehensive _documentation_ for APIs.

For the sake of clarity and precision, we will supplement informal documentation with formal specifications.
These express properties of APIs using a well-defined syntax that can be given a precise meaning.
Although such formal specifications are not standard (even in large projects that attach great value to modularity), we believe it is useful to expose students to them, because
they encourage students to be fully precise, think about corner cases and reason rigorously about correctness.
Because there is no widely accepted formalism, we use a minimal one designed specifically for this course.
