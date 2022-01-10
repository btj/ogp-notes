# First, clone https://github.com/btj/jlearner and set JLEARNERPATH
cp $JLEARNERPATH/language.md $JLEARNERPATH/*.png .

pandoc -o course-notes.html -f gfm \
  intro.md \
  README.md \
  programming.md \
  language.md \
  lecture2part1.md \
  lecture2part2.md \
  complexity_modularity_abstraction.md \
  representation_objects.md \
  single_object_doc_instr.md \
  polymorphism.md \
  dynamic_binding.md \
  behavioral_subtyping.md \
  interfaces.md \
  implementation_inheritance.md \
  collections.md \
  entity_relationship_abstractions.md \
  multi_class_abstractions.md \
  multi_object_doc_instr.md \
  iterators.md \
  generics.md
pandoc --wrap=none -V documentclass=book --toc --template=latex.template --listings -o course-notes.tex course-notes.html
sed -i'' \
  -e 's/\\chapter{Object-Oriented Programming}/\\chapter{Overview}/' \
  -e 's/\\chapter{First Steps in Modular Programming (Part I)}/\\part{Part I: Single-Object Abstractions}\\chapter{First Steps in Modular Programming (Part I)}/' \
  -e 's/\\chapter{Managing Complexity through Modularity and Abstraction}/\\chapter[Managing Complexity: Modularity \\\& Abstraction]{Managing Complexity through Modularity and Abstraction}/' \
  -e 's/\\section{FractionLists: Representation Exposure Breaks Consistency}/\\section[Representation Exposure Breaks Consistency]{FractionLists: Representation Exposure Breaks Consistency}/' \
  -e 's/\\chapter{How to properly document single-object abstractions}/\\chapter[How to document single-object abstractions]{How to properly document single-object abstractions}/' \
  -e 's/\\chapter{Polymorphism}/\\part{Part II: Inheritance}\\chapter{Polymorphism}/' \
  -e 's/\\chapter{Entity-relationship abstractions}/\\part{Part III: Multi-Object Abstractions}\\chapter{Entity-relationship abstractions}/' \
  -e 's/\\section{Nesting class-encapsulated and package-encapsulated abstractions}/\\section[Nesting class-level and package-level abstractions]{Nesting class-encapsulated and package-encapsulated abstractions}/' \
  -e 's/\\chapter{How to properly document multi-object abstractions}/\\chapter[How to document multi-object abstractions]{How to properly document multi-object abstractions}/' \
  -e 's/\\chapter{Behavioral subtyping: modular reasoning about programs that use dynamic binding}/\\chapter[Modular reasoning about dynamic binding]{Behavioral subtyping: modular reasoning about programs that use dynamic binding}/' \
  -e 's/\\section{Modular reasoning about programs that use dynamic binding}/\\section[Modular reasoning about dynamic binding]{Modular reasoning about programs that use dynamic binding}/' \
  -e 's/\\chapter{Iterators}/\\part{Part IV: Advanced Topics}\\chapter{Iterators}/' \
  course-notes.tex
pdflatex course-notes.tex
pdflatex course-notes.tex
