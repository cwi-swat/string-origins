module stringorigins::names::Rename

import stringorigins::names::Relation;
import stringorigins::names::Names;
import String;
import List;
import IO;

loc origin(str x) = l
  when l <- originsOnly(x);

// TODO: how to avoid capture?
str rename(str src, ID old, str new, NameGraph g) {
 assert old in g.V;
 
 ID d = old in usesOf(g) ? refOf(old, g) : old;

 toRename = [d] + [ u | u <- usesOf(g), refOf(u, g) == d ];
 
 l = sort(toRename, bool(loc a, loc b) { return a.offset < b.offset; });
 iprintln(l);
 delta = size(new) - old.length;
 shift = 0;
 
 // temp hack until substring works correctly on orgstrings.
 src = deleteOrigin(src);
 for (occ <- l) {
   pre = src[0..occ.offset + shift];
   post = src[occ.offset + occ.length + shift..];
   src = pre + new + post;
   shift += delta;
 }
 return src;
}