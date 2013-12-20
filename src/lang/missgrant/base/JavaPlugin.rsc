module lang::missgrant::base::JavaPlugin

import lang::java::\syntax::Java15;

import util::IDE;
import util::Maybe;
import Message;
import ParseTree;
import Set;
import String;
import List;
import IO;
import ValueIO;

import stringorigins::escaping::Protect;


private str JAVAX_LANG = "Javax";
private str JAVAX_EXT = "javax";

void javaMain() {
  registerLanguage(JAVAX_LANG, JAVAX_EXT, Tree(str src, loc l) {
     regionsLoc = l[extension="regions"];
     originsLoc = l[extension="origins"];
     pt = parse(#start[CompilationUnit], src, l);
     lrel[Maybe[loc],str] theOrigins = [];
     list[Region] theRegions = [];
   	 if (exists(originsLoc)){
    	try{
    		theOrigins = readBinaryValueFile(#lrel[Maybe[loc],str], originsLoc);	
    	} catch e:{
    		println(e);
    	};
     }
   	 if (exists(regionsLoc)){
   	 	try{
    		theRegions = readBinaryValueFile(#list[tuple[int,int,str,str]], regionsLoc);
    	} catch e:{
    		println(e);
    	};
   	 }
   	if (List::size(theOrigins)>0)
   	 	pt = pt[@origins = theOrigins];
   	if (List::size(theRegions)>0)
   	 	pt = pt[@regions = theRegions];
   	return pt; 	
  });

  contribs = {
		     builder(set[Message] (Tree pt) {
		       regionsLoc = (pt@\loc)[extension="regions"];
    		   regions = pt@regions;
    		   writeFile(regionsLoc, regions);
    		   return {};
    		 })
  };
  
  registerContributions(JAVAX_LANG, contribs);
}
