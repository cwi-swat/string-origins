module stringorigins::names::FixJavaNames

import String;
import util::Maybe;
import lang::missgrant::base::Compile;
import lang::missgrant::base::Implode;
import IO;
import List;
import ParseTree;
import lang::java::\syntax::Java15;
import stringorigins::names::FixNames;

rel[str, loc] extractJavaNames(CompilationUnit u) = 
  { <"<x>", x@\loc> | /Id x := u };

loc missgrant = |project://string-origins/src/input/missgrantclash.ctl|;
str missgrantClass = "missgrantclash";
loc missgrantJava = |project://string-origins/src/input/missgrantclash.java|;

void missgrantJavaNames() {
  fixCtl(missgrant);
}


str fixCtl(loc file) {
   ctl = load(file);
   javaFile = file[extension="java"];
   src = compile(setOrigins(split(".", file.file)[0], [javaFile]), ctl);
   
   rel[str,loc] extract(str x, loc l) 
     = extractJavaNames(parse(#start[CompilationUnit], x, l).top);
   
   src = fixNames(src, file, javaFile, extract, keywords = javaKeywords());
   writeFile(javaFile, src);
   return src;
}

test bool keywordIsRenamed() {
  fixCtl(|project://string-origins/src/input/nametests/keywordIsRenamed.ctl|);
  return true; 
}

test bool keywordIsRenamedButNotToSourceName() {
  fixCtl(|project://string-origins/src/input/nametests/keywordIsRenamedButNotToSourceName.ctl|);
  return true;
}

test bool keywordIsRenamedButNotToGenName() {
  fixCtl(|project://string-origins/src/input/nametests/keywordIsRenamedButNotToGenName.ctl|);
  return true;
}

test bool disjointSourceSynth() {
  fixCtl(|project://string-origins/src/input/nametests/disjointSourceSynth.ctl|);
  return true;
}

test bool renameKnowsSourceNames() {
  fixCtl(|project://string-origins/src/input/nametests/renameKnowsSourceNames.ctl|);
  return true;
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


