module stringorigins::names::FixNames

import String;
import util::Maybe;
import List;
import IO;

alias Renaming = map[loc org, Rename rename];
alias Rename = tuple[str old, str new];
alias Renamed = map[loc from, loc new];
alias Orgs = lrel[Maybe[loc], str];
alias SourceMap = lrel[str substring, loc target, loc origin];

@doc{

Assumptions:
- names from the source are copied into the generated code
- constructed names by concatenation do not generate keywords
  (e.g. if "<name>f" produces "if", it won't be detected as keyword)
- name binding is consistent; there's no intentional capture of synth names.
- the renaming of keywords will never overlap with synthesized names
  (e.g. don't use synthesized name "if_" and suffix "_" if "if" is an allowed 
  source name)
- synthesized names should be individual chunks otherwise they won't
  be recognized for keyword renaming [is this true? a source name
  will be renamed again in the second phase]
- note that this works even better on ASTs, because we then can *really* 
  distinguish source from generated names during keyword fixing (without
  having to approximate). 

}
str fixNames(str src, loc input, loc output, rel[str,loc](str, loc) extract, 
             set[str] keywords = {}, str suf = "_") {
  smap = reconstruct(origins(src), output);

  // Rename keywords without having to parse the code
  <smap, renamed, renaming> = fixKeywords(smap, input, keywords, suf);

  // Extract names according to target language syntax
  // At this point names are "compatible" with smap
  names = extract(yield(smap), output);

  // Update the renaming of keywords so that its domain
  // is in terms of locs *after* the renaming.
  renaming = ( renamed[l]: renaming[l] | l <- renaming );
  // Undo false positives: things that are not a name, but were renamed
  <smap, renamed> = unrenameNonNames(smap, renaming, names, output);
  
  // Make sure that locations of names extracted before unrename
  // are compatible with the target locations in smap.
  // NB: all source names of interest are in both names and in smap
  // so renamed will have the locs of all relevant names in its domain.
  names = { <x, l in renamed ? renamed[l] : l> | <x, l> <- names };
  
  // Ensure that source names are disjoint from other names.
  smap = fixSemanticNames(smap, names, input, output, suf);

  return yield(smap);

}



tuple[SourceMap,Renamed,Renaming] fixKeywords(SourceMap smap, loc input, set[str] keywords, str suf) {
  srcNames = { <x, l> | <x, l, org> <- smap, org.path == input.path }; 
  allNames = srcNames<0>;

  renaming = makeRenaming(srcNames<0> & keywords, allNames, srcNames, suf);

  <smap, renamed> = rename(smap, renaming);
  return <smap, renamed, renaming>;
}

tuple[SourceMap,Renamed] unrenameNonNames(SourceMap smap, Renaming renaming, 
                          rel[str, loc] names, loc output) {
  unrenaming = ( l: <renaming[l].new, renaming[l].old> | 
                   loc l <- renaming, 
                   <renaming[l].new, l> notin names );
  return rename(smap, unrenaming);
}

Renaming makeRenaming(set[str] toRename, set[str] allNames, rel[str,loc] srcNames, str suf) {
  renaming = ();  
  for (str x <- toRename) {
    newName = fresh(x, allNames, suf);
    allNames += {newName};
    renaming += ( l: <x, newName> | <x, l> <- srcNames );
  } 
  return renaming;
}

SourceMap fixSemanticNames(SourceMap smap, rel[str,loc] names, loc input, loc output, str suf) {
  srcNames = { <x, l> | <x, l, org> <- smap, 
                        <x, l> in names, org.path == input.path };
  
  otherNames = names - srcNames;
  
  renaming = makeRenaming(srcNames<0> & otherNames<0>, names<0>, srcNames, suf); 
  
  <smap, _> = rename(smap, renaming);
  return smap;
} 

str suffix(str x, str suf) = "<x><suf>";

str fresh(str x, set[str] names, str suf) {
  while (x in names) 
    x = suffix(x, suf);
  return x;
}


str yield(SourceMap smap) = ( "" | it + x | <x, _, _> <- smap );


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

tuple[SourceMap,Renamed] rename(SourceMap src, Renaming renaming) {
  shift = 0;
  renamed = ();
  src = for (<x, l, org> <- src) {
    newl = l;
    newl.offset += shift;
    if (l in renaming) {
      delta = size(renaming[l].new) - size(renaming[l].old);
      newl.length += delta;
      newl.end.column += delta;
      shift += delta;
      append <renaming[l].new, newl, org>;
    }
    else {
      append <x, newl, org>;
    }
    renamed[l] = newl;
  }
  return <src, renamed>;  
} 

  
  
  
  
  // Just for the comments.
  
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
  