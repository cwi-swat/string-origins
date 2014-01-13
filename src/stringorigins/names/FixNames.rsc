module stringorigins::names::FixNames

import String;
import util::Maybe;
import List;
import IO;

alias Renaming = map[loc org, Rename rename];
alias Rename = tuple[str old, str new];
alias Orgs = lrel[Maybe[loc], str];
alias SourceMap = lrel[str substring, loc target, loc origin];

str fixNames(str src, loc input, loc output, rel[str,loc](str, loc) extract, set[str] keywords = {}, str suf = "_") {
  smap = reconstruct(origins(src), output);

  // Rename keywords without having to parse the code
  <smap, renaming> = fixKeywords(smap, input, keywords, suf);

  // Extract names according to target language syntax
  names = extract(yield(smap), output);

  // Undo false positives: things that are not a name, but were renamed
  smap = unrenameNonNames(smap, renaming, names, output);
  
  // Ensure that source names are disjoint from other names.
  smap = fixSemanticNames(smap, names, input, output, suf);

  return yield(smap);
}


tuple[SourceMap result, Renaming renaming] fixKeywords(SourceMap smap, loc input, set[str] keywords, str suf) {
  rel[str, loc] srcNames0 = { <x, org> | <x, _, org> <- smap, org.path == input.path }; 
  
  set[str] allNames0 = srcNames0<0>;
  map[loc, Rename] renaming = ();

  for (str x <- srcNames0<0> & keywords) {
    str newName = fresh(x, allNames0, suf);
    allNames0 += {newName};
    renaming += ( org: <x, newName> | <x, org> <- srcNames0 );
  } 

  return <rename(smap, renaming), renaming>;
}

SourceMap unrenameNonNames(SourceMap smap, Renaming renaming, rel[str, loc] names, loc output) {
  unrename = ( l: renaming[org]  | loc org <- renaming, <str x, loc l, org> <- smap, <x, l> notin names );
  
  // TODO (?): offsets l are wrong now, but since we do not need to 
  // extract names again, this does not matter, otherwise implement
  // unrename same as rename.
  return [ <l in unrename ? unrename[l].old : x, l, org> | <x, l, org> <- smap ];
}


SourceMap fixSemanticNames(SourceMap smap, rel[str,loc] names, loc input, loc output, str suf) {
  rel[str, loc] srcNames = { <x, l> | <x, l> <- names, <x, l, org> <- smap, org.path == input.path };
  rel[str, loc] otherNames = names - srcNames;
  
  set[str] clashed = srcNames<0> & otherNames<0>;
  set[str] allNames = srcNames<0> + otherNames<0>;
  
  renaming = ();
  for (str x <- clashed) {
    str newName = fresh(x, allNames, suf);
    allNames += {newName};
    renaming += ( org: <x, newName> | <x, l> <- srcNames, <x, l, org> <- smap );
  }
 
  return rename(smap, renaming);
} 


@doc{
This function ensures that the names in `src` which originate
from `input` are disjoint from `keywords` and any other names
occuring in `src` (according to `extract`). 

Assumptions:
- source names are used consistently (i.e. there is no
  intentional capture of synthesized names) 
- source names occur as single chunks in the origin lrel of `src`
- synthesized names are ok, and will never renamed

Notes:
- this is a conservative fixing operation: it will rename any source
  name that might possibly clash with keywords, clash with synthesized
  names, be captured by synthesized names, or capture synthesized names. 
- it does *not* require name analysis on either source language or 
  target language. However, it does require a way to extract all names
  from the generated `src` after keyword collisions have been resolved
  (e.g. through name analysis, or parsing and finding all identifiers).
}
str fixNames_monolith(str src, loc input, loc output, 
             rel[str,loc](str, loc) extract, 
             set[str] keywords = {}, str suf = "_") {

  lrel[Maybe[loc], str] orgs = origins(src);
  
  // Conservatively approximate the set of source names from `orgs`
  // We assume that sourcenames in `orgs` are individual chunks
  // so we find all of them, but maybe more (e.g., in concatenated
  // names <x>_something; in this case the substring will be renamed
  // as well, but this is not a problem because it will happen
  // consistently everywhere). In fact, even if no clash exists
  // (because, say, there's only "while_object" and never "while")
  // we will still rename "while_object" to "while__object". IOW
  // this strategy is conservative: it might rename more than needed. 
  // Note that after `extract` a concatenated
  // name will be seen as one name, which will not be in `recon` 
  // (cf. below), hence it will then act as a synthesized name and
  // never be renamed.  
  // NB: this approximation is needed to avoid introducing clashes
  // of renamed keywords with other source names. For instance, renaming
  // source name "while" to "while_" introduces a clash if "while_"
  // is an existing source name. 
  rel[str, loc] srcNames0 = { <x, org> | <just(loc org), x> <- orgs, 
                              org.path == input.path }; 
  
  // Construct a renaming to rename source names to keywords.
  map[loc, Rename] renaming = ();
  
  // All "names" we now know of are source names.
  set[str] allNames0 = srcNames0<0>;
  
  for (str x <- srcNames0<0> & keywords) {
    str newName = fresh(x, allNames0, suf);
    println("Renaming keyword <x> to <newName>");
    allNames0 += {newName};
    renaming += ( org: <x, newName> | <x, org> <- srcNames0 );
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
  
  // Get the set of *real* source names (e.g. names as identified as such
  // by `extract` which originate from the source).
  // Note that this includes renamed keywords as per the previous phase,
  // which is as it should be, these renamings can still clash with
  // synthesized names. Example: renamed "while" to "while_" but now
  // there is a synthesized name "while_"; in this case the source name
  // "while_" will have to be renamed to "while__". 
  // NB: `srcNames` is in terms of output locations, not origins, so
  // that we can subtract from `names` to find synthesized names (see below).
  rel[str, loc] srcNames = { <x, l> | <x, l> <- names, <x, l, org> <- recon, 
                                      org.path == input.path };
                 
  
  unrename = ( l: renaming[org]  | loc org <- renaming, <str x, loc l, org> <- recon, <x, l> notin names ); 
  println("Renamed but not a name: ");
  iprintln(unrename);
  
  if (unrename != ()) {
    // Unrename things that are not names
    orgs = [ <just(org), l in unrename ? unrename[l].old : x> | <x, l, org> <- recon ];
    
    // Reconstruct again, because offsets in target locations might have changed
    // NB: this could be optimized by merging unrename and reconstruct.
    recon = reconstruct(orgs, output);
  }
  
  
    
  rel[str, loc] otherNames = names - srcNames;
  set[str] clashed = srcNames<0> & otherNames<0>;
  set[str] allNames = names<0>;
  
  // start with a clean renaming (keyword renamings have been applied on orgs)
  renaming = ();
  
  // rename all occurrences of source name `x` with a fresh name. 
  for (str x <- clashed) {
    str newName = fresh(x, allNames, suf);
    allNames += {newName};
    println("Renaming source name <x> to <newName>");
    renaming += ( org: <x, newName> | <x, l> <- srcNames, <x, l, org> <- recon );
  }
 
  return yield(rename(orgs, renaming));
}

str suffix(str x, str suf) = "<x><suf>";

str fresh(str x, set[str] names, str suf) {
  while (x in names) 
    x = suffix(x, suf);
  return x;
}


// TODO: this should be coded in Java, to avoid
// nesting of orgstrings in orgstrings. 
str yield(lrel[Maybe[loc], str] orgs) 
  = ( "" | it + x | <_, x> <- orgs );
  
str yield(SourceMap smap) 
  = ( "" | it + x | <x, _, _> <- smap );


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


Orgs rename(Orgs src, Renaming renaming) 
  = [ <org, just(loc l) := org && l in renaming ? renaming[l].new : n> | <org, n> <- SRC ];

SourceMap rename_(SourceMap src, Renaming renaming) 
  = [ <org in renaming ? renaming[org].new : x, l, org> | <x, l, org> <- src ]; 

  
  
  
SourceMap rename(SourceMap src, Renaming renaming) {
  shift = 0;
  return for (<x, l, org> <- src) {
    l.offset += shift;
    if (org in renaming) {
      delta = size(renaming[org].new) - size(renaming[org].old);
      l.length += delta;
      l.end.column += delta;
      shift += delta;
      append <renaming[org].new, l, org>;
    }
    else {
      append <x, l, org>;
    }
  }  
} 

  