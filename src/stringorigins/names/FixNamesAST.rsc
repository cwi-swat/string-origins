module stringorigins::names::FixNamesAST

import String;
import IO;

tuple[set[&T],set[&T]] partition(list[&T] s, bool(&T) pred) 
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
  
  <src, other> = partition(names, isSrc);
  foreign = other + keywords;
  clashed = src & foreign;
  
  allNames = src + foreign;
  map[str,str] renaming = ();
  str rename(str x) {
    if (x notin renaming) {
      y = fresh(x, allNames);
      renaming[x] = y;
      allNames += y;
    }
    return renaming[x];
  } 
  
  return visit (ast) {
    case str x => rename(x)
      when x in clashed, isSrc(x)
  }
}

str fix(str s, map[loc, str] ns, set[str] kws, loc input) {
  bool isSrc(str x) = 
    origin(x).path == input.path;
  
  <src, other> = partition(ns, isSrc);
  notSrc = other<1> + kws;
  
  bool toFix(str x) = 
    x in src<1> && x in notSrc; 
    
  return subst(s, renaming(src, ns, src<1> + notSrc, toFix));
}

map[loc, str] renaming(map[loc, str] ns, set[str] allNs, bool(str) pred) {
  void rename(map[loc, str] ren, loc l, str x) {
    if (l notin ren) {
      y = fresh(x, allNs);
      ren[l] = y;
      allNs += y;
    }
    return ren;
  } 
  return ( () | rename(it, l, ns[l]) | l <- ns, pred(ns[l]) );
}


