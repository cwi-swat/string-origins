module stringorigins::names::Names

import String;
import util::Maybe;
import lang::java::jdt::m3::Core;
import lang::missgrant::base::Compile;
import lang::missgrant::base::Implode;
import IO;
import List;

loc missgrant = |project://string-origins/src/input/missgrantclash.ctl|;
str missgrantClass = "missgrantclash";
loc missgrantJava = |project://string-origins/src/input/missgrantclash.java|;

rel[str, loc] physicalNames(M3 m) = m@names o (m@uses<1,0> + m@declarations);

str missgrantJavaNames() {
   ctl = load(missgrant);
   src = compile(missgrantClass, ctl);
   src = fixJavaNameClashes(src, missgrant, missgrantJava);
   writeFile(missgrantJava, src);
   return src;
}

str fixJavaNameClashes(str src, loc input, loc output) {
   writeFile(output, src);
   M3 m3 = createM3FromFile(output);
   names = physicalNames(m3);
   return fixNameClashes(src, input, output, names);
}

str fixNameClashes(str src, loc input, loc output, rel[str, loc] names) {
   orgs = origins(src);
   recon = reconstruct(orgs, output);
   srcNames = { <x, l> | <x, l> <- names, <x, l, org> <- recon, 
                    org.path == input.path };
   otherNames = names - srcNames;
   overlap = srcNames<0> & otherNames<0>; 
   if (overlap != {}) {
     allNames = names<0>;
     for (str x <- overlap) {
       newName = fresh(x, allNames);
       allNames += {newName};
       println("Renaming <x> to <newName>");
       for (<x, l> <- srcNames, <x, l, org> <- recon) {
         orgs = rename(orgs, org, newName);
       }  
     }
   }
   return ( "" | it + x | <_, str x> <- orgs );
}


str fresh(str x, set[str] names) {
  while (x in names) {
    x = "<x>_";
  }
  return x;
}


lrel[Maybe[loc], str] rename(lrel[Maybe[loc], str] src, loc l, str new) {
  return for (<org, str n> <- src) {
    if (just(l) := org) {
      append <org, new>;
    }
    else {
      append <org, n>;
    }
  }
}


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
      append <sub, cur, l>;
    }
    else {
      throw "No origin: \'<sub>\'";
    }
    cur.offset += size(sub);
    cur.begin.column = cur.end.column;
    cur.begin.line = cur.end.line;
  }
  
  return result;
}
