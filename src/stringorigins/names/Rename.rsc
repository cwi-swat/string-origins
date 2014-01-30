module stringorigins::names::Rename

import stringorigins::names::Relation;
import stringorigins::names::Names;
import String;
import List;
import IO;

loc origin(str x) = l
  when l <- originsOnly(x);

str rename(str src, loc x, str y, rel[loc, loc] g) {
 locs = { u | <u, x> <- g }
      + { u, d | d <- g[x], <u, d> <- g };
 return subst(src, (l: y | l <- locs));
}


str rename_old(str src, ID old, str new, NameGraph g) {
 assert old in g.V;
 
 ID def = old in usesOf(g) ? refOf(old, g) : old;

 toSubst = [def] + [ use | use <- usesOf(g), refOf(use, g) == def ];
 return subst(src, ( x: new | x <- toSubst ));
}


str renamePaper(str src, loc old, str new, NameGraph g) {
 ID def = old in usesOf(g) ? refOf(old, g) : old;
 locs = [def] + [ use | use <- usesOf(g), refOf(use, g) == def ];
 return subst(src, (x: new | x <- locs ));
}