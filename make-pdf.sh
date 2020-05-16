# First, copy the files from https://github.com/btj/jlearner
# (in particular: language.md and the .png files)
# into the current directory

pandoc -o course-notes.html -f gfm \
  README.md \
  intro.md \
  programming.md \
  language.md \
  lecture2part1.md \
  lecture2part2.md \
  complexity_modularity_abstraction.md \
  drawit_doc_instr.md \
  entity_relationship_abstractions.md \
  multi_class_abstractions.md \
  inheritance.md \
  behavioral_subtyping.md \
  interfaces.md \
  implementation_inheritance.md \
  iterators.md \
  generics.md
pandoc -V documentclass=book -V classoption=oneside --toc --template=latex.template --listings -o course-notes.tex course-notes.html
pdflatex course-notes.tex
pdflatex course-notes.tex
