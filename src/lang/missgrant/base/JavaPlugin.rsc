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

import stringorigins::regions::Regions;


private str JAVAX_LANG = "Javax";
private str JAVAX_EXT = "javax";

void javaMain() {
  registerLanguage(JAVAX_LANG, JAVAX_EXT, Tree(str src, loc l) {
     regionsLoc = l[extension="regions"];
     originsLoc = l[extension="origins"];
     pt = parse(#start[CompilationUnit], src, l);
     lrel[Maybe[loc],str] theOrigins = [];
     list[Region] theRegions = [];
   	 if (exists(regionsLoc)){
   	 	theRegions = readTextValueFile(#lrel[int,int,str,str], regionsLoc);
   	 }
   	 pt = pt[@regions = theRegions];
   	 return pt; 	
  });

  contribs = {
		     builder(set[Message] (Tree pt) {
		       regionsLoc = (pt@\loc)[extension="regions"];
    		   regions = pt@regions;
    		   writeTextValueFile(regionsLoc, regions);
    		   return {};
    		 })
  };
  
  registerContributions(JAVAX_LANG, contribs);
}
