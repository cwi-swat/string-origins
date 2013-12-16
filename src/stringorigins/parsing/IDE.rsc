module stringorigins::parsing::IDE

import stringorigins::parsing::ParseWithOrigins;
import util::IDE;
import String;
import ParseTree;
import IO;
import ValueIO;
import util::Maybe;

void main() {
  registerLanguage("Strings", "string", Tree(str src, loc l) {
     orgLoc = l[extension="origins"];
     if (exists(orgLoc)) {
       orgs = readBinaryValueFile(#lrel[Maybe[loc],str], orgLoc);
       return orgParse(orgs, l);
     }
     throw "No origins found";
  });
  
  
  contribs = {
    		 annotator(Tree (Tree pt) {
    		   return pt;
    		 })             
  };
  
  registerContributions("Strings", contribs);
}