module stringorigins::names::FixNamesAST

tuple[set[&T],set[&T]] split(set[&T] s, bool(&T) pred) 
  = < { x | x <- s, pred(x) }, { x | x <- s, !pred(x) }>; 

// assumes all strings in ASTs are names. 
&T fixNames(&T ast, set[str] keywords, loc input) 
  = fixNames(ast, [ x | /str x := ast ], keywords, input);
 
&T fixNames(&T ast, list[str] names, set[str] keywords, loc input) {
  bool isSrc(str x) = any(l <- originsOnly(x), l.path == input.path);
  
  <src, other> = split(names, isSrc);
  foreign = other + keywords;
  allNames = src + foreign;
  clashed = src & foreign;
  
  str rename(str x) {
    x = fresh(allNames, x);
    allNames += x;
    return x;
  }
  
  return visit (ast) {
    case str x => rename(x)
      when x in clashed, isSrc(x)
  }
}