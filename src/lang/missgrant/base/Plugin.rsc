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

import stringorigins::escaping::Protect;

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
    		   out = (pt@\loc)[extension="javax"];
    		   regions = (pt@\loc)[extension="regions"];
    		   class = split(".", out.file)[0];
    		   generated = compile(class, ctl);
    		   if (exists(regions)){
    		     theRegions = readTextValueFile(#lrel[int, int, str, str], regions);
    		     generated = plugRegions(theRegions, origins(generated));
    		   }
    		   theOrigins = origins(generated); // NB: origins after plugging
    		   newRegions = calculateRegions(theOrigins);
    		   iprintln(newRegions);
    		   writeTextValueFile(regions, newRegions);
    		   writeFile(out, generated);
    		   writeFile((pt@\loc)[extension="java"], generated);
               writeFile((pt@\loc)[extension="string"], generated);
               writeBinaryValueFile((pt@\loc)[extension="origins"], theOrigins);
               
               writeFile((pt@\loc)[extension="js"], compile2js(class, ctl));
               return {};
    		 }),
    		 
    		 outliner(node (Tree input) {
                 return outline(implode(input));
             })
             
  };
  
  registerContributions(CONTROLLER_LANG, contribs);
}
