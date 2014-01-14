module stringorigins::names::FixJavaNamesAST

import String;
import util::Maybe;
import lang::missgrant::base::CompileAST;
import lang::missgrant::base::Implode;
import lang::java::jdt::m3::AST;

import IO;
import List;
import ParseTree;
import stringorigins::names::FixNamesAST;

loc missgrant = |project://string-origins/src/input/missgrantclash.ctl|;
str missgrantClass = "missgrantclash";
loc missgrantJava = |project://string-origins/src/input/missgrantclash.java|;

void missgrantJavaNames() {
  fixCtl(missgrant);
}


Declaration fixCtl(loc file) {
   ctl = load(file);
   javaFile = file[extension="java"];
   ast = compile(setOrigins(split(".", file.file)[0], [javaFile]), ctl);
   ast2 = fixNames(ast, javaKeywords(), file);
   writeFile(javaFile[extension="ast"], ast);
   //iprintln(ast2);
   return ast2;
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


