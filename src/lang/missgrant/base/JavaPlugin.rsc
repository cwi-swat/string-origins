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

import stringorigins::icmt2014::Core;

anno Regions Tree@regions;
anno Contents Tree@contents;

private str JAVAX_LANG = "Javax";
private str JAVAX_EXT = "javax";

void javaMain() {
  registerLanguage(JAVAX_LANG, JAVAX_EXT, Tree(str src, loc l) {
     regionsLoc = l[extension="regions"];
     pt = parse(#start[CompilationUnit], src, l);
     lrel[Maybe[loc],str] theOrigins = [];
     if (exists(regionsLoc)){
   	 	Regions theRegions = readTextValueFile(#Regions, regionsLoc);
   	 	pt = pt[@regions = theRegions];
   	 }
   	 return pt; 	
  });

  contribs = {
		     builder(set[Message] (Tree pt) {
		       regionsLoc = (pt@\loc)[extension="regions"];
		       contentsLoc = (pt@\loc)[extension="contents"];
    		   regions = pt@regions;
    		   contents = pt@contents;
    		   writeTextValueFile(regionsLoc, regions);
    		   writeTextValueFile(contentsLoc, contents);
    		   return {};
    		 })
  };
  
  registerContributions(JAVAX_LANG, contribs);
}
