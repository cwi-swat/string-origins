module stringorigins::names::Names

import String;
import util::Maybe;
import lang::missgrant::base::Compile;
import lang::missgrant::base::Implode;
import IO;
import List;
import ParseTree;
import lang::java::\syntax::Java15;

rel[str, loc] extractJavaNames(CompilationUnit u, loc file) { 
   loc fix(loc l) = l[path=file.path][scheme=file.scheme][authority=file.authority];
   
   return { <"<x>", fix(x@\loc)> | /Id x := u };
}

loc missgrant = |project://string-origins/src/input/missgrantclash.ctl|;
str missgrantClass = "missgrantclash";
loc missgrantJava = |project://string-origins/src/input/missgrantclash.java|;

str missgrantJavaNames() {
   ctl = load(missgrant);
   src = compile(missgrantClass, ctl);
   src = fixKeywordClashes(src, missgrant, missgrantJava, javaKeywords());
   src = fixJavaNameClashes(src, missgrant, missgrantJava);
   writeFile(missgrantJava, src);
   return src;
}

str fixJavaNameClashes(str src, loc input, loc output) {
   cu = parse(#start[CompilationUnit], src);
   names = extractJavaNames(cu.top, output);
   iprintln(names);
   return fixNameClashes(src, input, output, names);
}

str fixKeywordClashes(str src, loc input, loc output, set[str] keywords) {
   orgs = origins(src);
   recon = reconstruct(orgs, output);
   for (<x, l, org> <- recon, org.path == input.path, x in keywords) {
       println("Renaming keyword <x> to <x>$");
       orgs = rename(orgs, org, "<x>$");
   }
   return ( "" | it + x | <_, str x> <- orgs );
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




set[str] javaKeywords() =
{"abstract", "continue", "for", "new", "switch", "assert", "default",
"goto", "package", "synchronized", "boolean", "do", "if", "private",
"this", "break", "double", "implements", "protected", "throw", "byte",
"else", "import", "public", "throws", "case", "enum", "instanceof",
"return", "transient", "catch", "extends", "int", "short", "try",
"char", "final", "interface", "static", "void", "class", "finally",
"long", "strictfp", "volatile", "const", "float", "native", "super",
"while"};



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
