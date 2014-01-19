module stringorigins::names::Rename

import stringorigins::names::Relation;
import stringorigins::names::Names;
import String;
import List;
import IO;

loc origin(str x) = l
  when l <- originsOnly(x);

str rename(str src, ID old, str new, NameGraph g) {
 assert old in g.V;
 
 ID def = old in usesOf(g) ? refOf(old, g) : old;

 toSubst = [def] + [ use | use <- usesOf(g), refOf(use, g) == def ];
 return subst(src, ( x: new | x <- toSubst ));
}


str subst(str src, map[loc,str] s) { 
  // temp hack until substring works correctly on orgstrings.
 src = deleteOrigin(src);
 
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


str substPaper(str src, map[loc,str] s) { 
 shift = 0;
 str subst1(str src, loc x, str y) {
   delta = size(y) - x.length;
   src = src[0..x.offset+shift] + y + src[x.offset+x.length+shift..];
   shift += delta;
   return src; 
 }
 return ( src | subst1(it, x, s[x]) | x <- sort(dom(s)) );
}


str renamePaper(str src, loc old, str new, NameGraph g) {
 ID def = old in usesOf(g) ? refOf(old, g) : old;
 locs = [def] + [ use | use <- usesOf(g), refOf(use, g) == def ];
 return subst(src, (x: new | x <- locs ));
}