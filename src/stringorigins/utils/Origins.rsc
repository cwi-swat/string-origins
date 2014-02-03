module stringorigins::utils::Origins

import String;
import util::Maybe;
import List;
import Exception;

alias Orgs = lrel[Maybe[loc], str];
alias SMap = lrel[str substring, loc target, loc origin];

loc origin(str x) = l when l <- originsOnly(x);

map[loc, str] decons(str src, loc output) = 
  ( l: x | <x, l, _> <- reconstruct(origins(src), output) );


str yield(SMap smap) = ( "" | it + x | <x, _, _> <- smap );


str subst(str src, map[loc,str] s) { 
  // temp hack until substring works correctly on orgstrings.
 //src = deleteOrigin(src);
 
 int shift = 0;
 str subst1(str src, loc x, str y) {
   delta = size(y) - x.length;
   src = src[0..x.offset+shift] + y + src[x.offset+x.length+shift..];
   shift += delta;
   return src; 
 }

 order = sort([ k | k <- s ], bool(loc a, loc b) { return a.offset < b.offset; });
 
 
 return ( src | subst1(it, x, s[x]) | x <- order );
}


//str substPaper(str src, map[loc,str] s) { 
// shift = 0;
// str subst1(str src, loc x, str y) {
//   delta = size(y) - x.length;
//   src = src[0..x.offset+shift] + y + src[x.offset+x.length+shift..];
//   shift += delta;
//   return src; 
// }
// return ( src | subst1(it, x, s[x]) | x <- sort(dom(s)) );
//}


@doc{

An lrel coming from origins()) maps (source or meta program) origins to 
output string fragments. This functions reconstructs the source locations
of each chunk according to occurence in the output. 
}
// str, loc (src loc), loc (origin)
lrel[str, loc, loc] reconstruct(lrel[Maybe[loc], str] orgs, loc src) {
  cur = |<src.scheme>://<src.authority><src.path>|(0, 0, <1, 0>, <1,0>);
 
  result = for (<org, str sub> <- orgs) {
    cur.length = size(sub);
    nls = size(findAll(sub, "\n"));
    cur.end.line += nls;
    if (nls != 0) {
      // reset
      cur.end.column = size(sub) - findLast(sub, "\n") - 1;
    }
    else {
      cur.end.column += size(sub);
    }
    if (just(loc l) := org) {
      // IMPORTANT: Propagate the query string
      if (l.query != "") {
        append <sub, cur[query=l.query], l>;
      }
      else {
        append <sub, cur, l>;
      }
    }
    else {
      throw AssertionFailed("No origin: \'<sub>\'");
    }
    cur.offset += size(sub);
    cur.begin.column = cur.end.column;
    cur.begin.line = cur.end.line;
  }
  
  return result;
}
