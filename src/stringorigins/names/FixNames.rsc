module stringorigins::names::FixNames

import String;
import util::Maybe;
import List;
import IO;

@doc{
This function ensures that the names in `src` which originate
from `input` are disjoint from `keywords` and any other names
occuring in `src` (according to `extract`). 
}
str fixNames(str src, loc input, loc output, 
             rel[str,loc](str, loc) extract, 
             set[str] keywords = {}, str suf = "_") {

  lrel[Maybe[loc], str] orgs = origins(src);
  
  // Construct renaming for source names that
  // are keywords.
  map[loc, str] renaming = 
    ( org: suffix(x, suf) /* x[0..-1] + "_"*/ 
          |  <just(loc org), x> <- orgs, 
              org.path == input.path, x in keywords);

  for (str x <- renaming<1>) {
    println("Renaming keyword name <x[0..-1]> to <x>");
  } 

  // Apply renaming of keyword identifiers
  orgs = rename(orgs, renaming);

  // Find the names in the generated code according target language.
  // Note: use renamed source, otherwise parse errors.
  rel[str, loc] names = extract(yield(orgs), output);
  
  // TODO: this should be a map
  // NB: offsets are *not* wrong in recon because reconstruct
  // computes them based on the string lengths in orgs,
  // not the length stored in the origin locations.
  // NB: if rename of keywords to a name with equal length of keyword,
  // this could be more robust. 
  lrel[str, loc, loc] recon = reconstruct(orgs, output);
  
  rel[str, loc] srcNames = { < x, l> | <x, l> <- names, <x, l, org> <- recon, 
                                      org.path == input.path,
                                      // exclude renamed keywords from srcNames 
                                      org notin renaming };
                 
  
  rel[str, loc] otherNames = names - srcNames;
  set[str] clashed = srcNames<0> & otherNames<0>;
  set[str] allNames = names<0>;
  
  // start with a clean renaming (keyword renaming have been applied)
  renaming = ();
  
  // rename all occurrences of source name `x` with a fresh name. 
  for (str x <- clashed) {
    str newName = fresh(x, allNames, suf);
    allNames += {newName};
    println("Renaming source name <x> to <newName>");
    renaming += ( org: newName | <x, l> <- srcNames, <x, l, org> <- recon );
  }
 
  return yield(rename(orgs, renaming));
}

str suffix(str x, str suf) = "<x><suf>";

str fresh(str x, set[str] names, str suf) {
  while (x in names) 
    x = suffix(x, suf);
  return x;
}


str yield(lrel[Maybe[loc], str] orgs) 
  = ( "" | it + x | <_, x> <- orgs );


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


lrel[Maybe[loc], str] rename(lrel[Maybe[loc], str] src, map[loc, str] renaming) {
  return for (<org, str n> <- src) {
    if (just(loc l) := org, l in renaming) {
      append <org, renaming[l]>;
    }
    else {
      append <org, n>;
    }
  }
}

