module stringorigins::icmt2014::Core

import String;
import List;
import IO;
import Map;

loc origin(str x) = pos
	when <just(pos), _> := origins(x)[0];
	
bool isTagged(str x, str name) = /<name>/ := origin(x).query;

str getTagValue(str x, str name) = val
  when /<name>=<val:.*>/ := origin(x).query;

alias Index = rel[loc pos, str chunk];

Index index(str x, loc output){
  orgs = origins(x);
  cur = |<output.scheme>://<output.authority><output.path>|(0, 0, <1, 0>, <1,0>);
 
  result = for (<org, str sub> <- orgs) {
    cur.length = size(sub);
    nls = List::size(findAll(sub, "\n"));
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
        append <cur[query=l.query], sub>;
      }
      else {
        append <cur, sub>;
      }
    }
    else {
      throw AssertionFailed("No origin: \'<sub>\'");
    }
    cur.offset += size(sub);
    cur.begin.column = cur.end.column;
    cur.begin.line = cur.end.line;
  }
  
  return toSet(result);
}

alias Trace = rel[loc pos, loc org];

Trace trace(str s, loc out) = {<l, origin(x)> | <l, x> <- index(s, out)};

alias Regions = map[loc pos, str name];

Regions extract(str s, loc output) = (l : getTagValue(x, "editable") | <l,x> <-m, isTagged(x, "editable"))
	when m := index(s, output);

alias Contents = map[str name, str contents];

str buildString(str x, str name, map[str,loc] rs)
	= setOrigins(x, [rs[name]]);

Contents setOriginsForContents(Contents cs, Regions rs) =
	(name : buildString(x, name, inverted) | name <- cs, x := cs[name])
	when inverted := invertUnique(rs);

Contents extractContents(str s, loc output, Regions rs) = 
	setOriginsForContents(cs, rs)
	when m := index(s, output),
		 cs := (name : x | <l,x> <-m, isTagged(x, "editable"), name := getTagValue(x, "editable"));

str plug(str s, loc l, Contents c) = substitute(s, extract(s, l) o c);

alias Ref = tuple[set[loc] names, rel[loc use, loc def] refs];

str substitute(str src, map[loc,str] s) { 
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

tuple[str, set[str]] fresh(str x, set[str] names){
	while (x in names) x = x +"0";
	return <x, {x} + names>;	
}

str fix(str gen, Index names, loc inp) {
  	bool isSrc(str x) = origin(x).path == inp.path;
  	set[str] other = { x | <_, x> <- names, !isSrc(x) };
  	set[str] allNames = { x | <_, x> <- names };
  	map[loc,str] subst = (); 
	map[str,str] renaming = (); 
	for (<l, x> <- names, isSrc(x), x in other) {	
    	if (x notin renaming) {
    		<y, allNames> = fresh(x, allNames);
      		renaming[x] = y;
   		}
    	subst[l] = renaming[x];
  	}
  	return substitute(gen, subst);
}
