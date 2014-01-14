module stringorigins::names::FixNamesAST

import String;
import IO;

tuple[set[&T],set[&T]] split(list[&T] s, bool(&T) pred) 
  = < { x | x <- s, pred(x) }, { x | x <- s, !pred(x) }>; 


str fresh(str x, set[str] names) {
  while (x in names) 
    x = x + "_";
  return x;
}


// assumes all strings in ASTs are names. 
&T fixNames(&T ast, set[str] keywords, loc input) 
  = fixNames(ast, [ x | /str x := ast ], keywords, input);
 
&T fixNames(&T ast, list[str] names, set[str] keywords, loc input) {
  bool isSrc(str x) = any(l <- originsOnly(x), l.path == input.path);
  
  <src, other> = split(names, isSrc);
  foreign = other + keywords;
  allNames = src + foreign;
  clashed = src & foreign;
  
  map[str,str] renaming = ();
  str rename(str x) {
    if (x notin renaming) {
      renaming[x] = fresh(x, allNames);
    }
    bprintln("Renaming <x> to <renaming[x]>");
    return renaming[x];
  } 
  
  return visit (ast) {
    case str x => rename(x)
      when x in clashed, isSrc(x)
  }
}