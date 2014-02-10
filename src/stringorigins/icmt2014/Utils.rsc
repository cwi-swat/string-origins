module stringorigins::icmt2014::Utils

set[&X] domain(rel[&X,&Y] relation) = { x | <x, _> <- relation };
set[&Y] range(rel[&X,&Y] relation) = { y | <_, y> <- relation };
