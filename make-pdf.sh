# First, clone https://github.com/btj/jlearner and set JLEARNERPATH
cp $JLEARNERPATH/language.md $JLEARNERPATH/*.png .

pandoc -o course-notes.html -f gfm \
  part-0-preface.md \
   intro.md \
   README.md \
  part-1-single-object-abstractions.md \
   programming.md \
   language.md \
   lecture2part1.md \
   lecture2part2.md \
   complexity_modularity_abstraction.md \
   representation_objects.md \
   single_object_doc_instr.md \
  part-2-inheritance.md \
   polymorphism.md \
   dynamic_binding.md \
   behavioral_subtyping.md \
   interfaces.md \
   implementation_inheritance.md \
   collections.md \
  part-3-multi-object-abstractions.md \
   entity_relationship_abstractions.md \
   multi_class_abstractions.md \
   multi_object_doc_instr.md \
  part-4-advanced-topics.md \
   iterators.md \
   generics.md
pandoc --wrap=none -V documentclass=book --toc --template=latex.template --listings -o course-notes.tex course-notes.html
sed -i '' \
  -e 's/\chapter{Managing Complexity through Modularity and Abstraction}/\chapter[Managing Complexity: Modularity \\\& Abstraction]{Managing Complexity through Modularity and Abstraction}/' \
  -e 's/\section{FractionLists: Representation Exposure Breaks Consistency}/\section[Representation Exposure Breaks Consistency]{FractionLists: Representation Exposure Breaks Consistency}/' \
  -e 's/\chapter{How to properly document single-object abstractions}/\chapter[How to document single-object abstractions]{How to properly document single-object abstractions}/' \
  -e 's/\section{Nesting class-encapsulated and package-encapsulated abstractions}/\section[Nesting class-level and package-level abstractions]{Nesting class-encapsulated and package-encapsulated abstractions}/' \
  -e 's/\chapter{How to properly document multi-object abstractions}/\chapter[How to document multi-object abstractions]{How to properly document multi-object abstractions}/' \
  -e 's/\chapter{Behavioral subtyping: modular reasoning about programs that use dynamic binding}/\chapter[Modular reasoning about dynamic binding]{Behavioral subtyping: modular reasoning about programs that use dynamic binding}/' \
  -e 's/\section{Modular reasoning about programs that use dynamic binding}/\section[Modular reasoning about dynamic binding]{Modular reasoning about programs that use dynamic binding}/' \
  course-notes.tex
pdflatex course-notes.tex
pdflatex course-notes.tex
