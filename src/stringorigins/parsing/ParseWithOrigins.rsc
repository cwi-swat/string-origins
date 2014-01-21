module stringorigins::parsing::ParseWithOrigins

import ParseTree;
import util::Maybe;
import List;
import String;
import IO;

Tree orgParse(lrel[Maybe[loc], str] orgs, loc src) {
  cur = |<src.scheme>://<src.authority>/<src.path>|(0, 0, <1, 0>, <1,0>);

  Tree toTree(str x, loc l) {
    if (l.scheme != "rascal") { 
      // input substring
      return toTree(x, {\tag("category"("MetaAmbiguity"))});
    }
    return toTree(x);
  }
  
  Tree toTree(str x) = toTree(x, {});
  
  Tree toTree(str x, set[Attr] as) 
    = appl(prod(\lex("Unknown"), [], as), [\char(c) | c <- chars(x) ]);
  
  loc convert(loc l) {
    if (l.scheme == "rascal") {
      s = replaceAll(l.authority, "::", "/") + ".rsc";
      l = |project://string-origins/src/<s>|(l.offset, l.length,
            <l.begin.line, l.begin.column>, <l.end.line, l.end.column>);
    }
    return l;
  }
  
  args = for (<org, str sub> <- orgs) {
    cur.length = size(sub);
    nls = size(findAll(sub, "\n"));
    cur.end.line += nls;
    if (nls !=  0) {
      // reset
      cur.end.column = size(sub) - findLast("\n", sub);
    }
    else {
      cur.end.column += size(sub);
    }
    if (just(loc l) := org) {
      append toTree(sub, l)[@link=convert(l)][@\loc=cur];
    }
    else {
      append toTree(sub)[@\loc=cur];
    }
    cur.offset += size(sub);
    cur.begin.column = cur.end.column;
    cur.begin.line = cur.end.line;
  }
  
  return appl(prod(sort("Top"), [], {}), args)[@\loc=cur];
}


  
Tree orgParse(lrel[Maybe[loc], str] orgs, loc src) {
  cur = |<src.scheme>://<src.authority>/<src.path>|(0, 0, <1, 0>, <1,0>);

  Tree toTree(str x, loc l) {
    if (l.scheme != "rascal") { 
      // input substring
      return toTree(x, {\tag("category"("MetaVariable"))});
    }
    return toTree(x);
  }
  
  Tree toTree(str x) = toTree(x, {});
  
  Tree toTree(str x, set[Attr] as) 
    = appl(prod(\lex("Unknown"), [], as), [\char(c) | c <- chars(x) ]);
  
  args = for (<org, str sub> <- orgs) {
    cur.length = size(sub);
    nls = size(findAll(sub, "\n"));
    cur.end.line += nls;
    if (nls !=  0) {
      // reset
      cur.end.column = size(sub) - findLast("\n", sub);
    }
    else {
      cur.end.column += size(sub);
    }
    if (just(loc l) := org) {
      append toTree(sub, l)[@link=l][@\loc=cur];
    }
    else {
      append toTree(sub)[@\loc=cur];
    }
    cur.offset += size(sub);
    cur.begin.column = cur.end.column;
    cur.begin.line = cur.end.line;
  }
  
  return appl(prod(sort("Top"), [], {}), args)[@\loc=cur];
}


