module lang::missgrant::base::Plugin

import lang::missgrant::base::Syntax;
import lang::missgrant::base::Parse;
import lang::missgrant::base::Implode;
import lang::missgrant::base::Check;
import lang::missgrant::base::Desugar;
import lang::missgrant::base::Compile;
import lang::missgrant::base::Compile2JS;
import lang::missgrant::base::Rename;
import lang::missgrant::base::Visualize;
import lang::missgrant::base::Extract;
import lang::missgrant::base::Outline;
import lang::missgrant::base::XRef;

import util::IDE;
import util::Prompt;
import vis::Render;
import Message;
import ParseTree;
import List;
import String;
import IO;
import ValueIO;

import stringorigins::icmt2014::Core;
import stringorigins::sourcemaps::SourceMaps;

private str CONTROLLER_LANG = "Controller";
private str CONTROLLER_EXT = "ctl";

set[Message] check(Controller ctl)
  = check([undefinedStates()
  , undefinedEvents()
  , undefinedCommands()
  , resetsInTransition()
  , duplicateStates()
  , duplicateEvents()
  , duplicateCommands()
  , unreachableStates()
  , nonDeterministicStates()
  , unusedEvents()
  , unusedCommands()
  , deadendStates()], ctl);

void main() {
  registerLanguage(CONTROLLER_LANG, CONTROLLER_EXT, Tree(str src, loc l) {
     return parse(src, l);
  });

  contribs = {
		     popup(
			       menu(CONTROLLER_LANG,[

	    		     action("Visualize", void (Tree pt, loc l) {
	    		       renderController(implode(pt));
	    		     }),
	    		     edit("Rename...", rename)])
	    	  ),

    		 annotator(Tree (Tree pt) {
    		   pt = xrefController(pt);
    		   return pt[@messages = check(implode(pt))];
    		 }),

    		 builder(set[Message] (Tree pt) {
    		   ctl = desugar([resetEvents(), retries()], implode(pt));
    		   javaLoc = (pt@\loc)[extension="javax"];
    		   regions = (pt@\loc)[extension="regions"];
    		   contents = (pt@\loc)[extension="contents"];
    		   class = split(".", javaLoc.file)[0];
    		   generated = compile(setOrigins(class, [pt@\loc]), ctl);
    		   if (exists(regions)){
    		     theRegions = readTextValueFile(#Regions, regions);
    		     theContents = readTextValueFile(#Contents, contents);
    		     theContentsWithOrgs = setOriginsForContents(theContents, theRegions);
    		     generated = plug(generated, javaLoc, theContentsWithOrgs);
    		   }
    		   newRegions = extract(generated, javaLoc);
    		   newContents = extractContents(generated, javaLoc, newRegions);
    		   writeTextValueFile(regions, newRegions);
    		   writeTextValueFile(contents, newContents);
    		   writeFile(javaLoc, generated);
    		   writeFile((pt@\loc)[extension="string"], generated);
       		   writeBinaryValueFile((pt@\loc)[extension="origins"], origins(generated));
               
       		   jsloc = (pt@\loc)[extension="js"];
       		   js = compile2js(setOrigins(class, [pt@\loc]), ctl);
       		   writeFile(jsloc, js);
               
       		   mg = ctlSourceMap(js, pt@\loc, jsloc, { x | /str x := ctl });
       		   maploc = (pt@\loc)[extension="js.map"];
       		   writeFile(maploc, mg);
       		   return {};
    		 }),
    		 
    		 outliner(node (Tree input) {
                 return outline(implode(input));
             })
             
  };
  
  registerContributions(CONTROLLER_LANG, contribs);
}
