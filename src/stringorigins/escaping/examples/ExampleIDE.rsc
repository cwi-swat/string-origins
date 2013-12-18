module stringorigins::escaping::examples::ExampleIDE

import IO;
import ValueIO;
import String;
import util::IDE;
import lang::java::\syntax::Java15;
import ParseTree;
import util::Maybe;

str JAVA_LANG = "Javax";
str JAVA_EXT = "javax";

public void setupIDEForJavax() {

   registerLanguage(JAVA_LANG, JAVA_EXT, Tree(str src, loc l) {
   	loc originsLoc = l;
   	originsLoc.extension = "origins";
    if (exists(originsLoc)){
    	try{
    		theOrigins = readBinaryValueFile(#lrel[Maybe[loc],str], originsLoc);
    		return parse(#start[CompilationUnit], src, l)[@origins = theOrigins];	
    	} catch e:{
    		println(e);
    	};
    }
  	return parse(#start[CompilationUnit], src, l);	
  });
}

