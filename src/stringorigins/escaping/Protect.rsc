module stringorigins::escaping::Protect

import String;
import util::Maybe;
import List;
import Set;
import ParseTree;

alias Region = tuple[int, int, str, str];

anno list[Region] Tree @ regions;

str PROTECTED = "protected";
str ORIGINS = "origins";

str protected(str s, str label) = tagString(s, PROTECTED, label);

public list[Region] calculateRegions(lrel[Maybe[loc], str] theOrigins) {
	result = [];
	int offset = 0;
	for (<maybe, originalText> <- theOrigins){
		if (just(l) := maybe){
			if (l.query != ""){
				if (isInQueryStr(l, PROTECTED)){
					protectedName = getParameterValue(l, PROTECTED);
					result += <offset, String::size(originalText), protectedName, originalText>;
				}
			}
		}
		offset += String::size(originalText);
	}
	return result;
}

str plugRegions(list[Region] regions, lrel[Maybe[loc],str] generatedOrigins){
	newstr = "";
	map[str,str] extractedBlocks = (name:content | <_, _, name, content> <-regions);
	for (tup <- generatedOrigins){
		switch (tup){
			case <just(l), chunk> :{
				if (isInQueryStr(l, "protected")){
					v = getParameterValue(l, "protected");
					if (v in extractedBlocks)
						newstr += extractedBlocks[v];
					else
						newstr += chunk;
				}else{
					newstr += chunk;
				};
			}
			case <_, chunk>:{
				newstr += chunk;
			}
		}
	};
	return newstr;
}

bool isInQueryStr(loc l, str parameter) = parameter in {p | /<p:.*>=.*/ <- split("&",l.query) };

str getParameterValue(loc l, str parameter) = Set::getOneFrom({v | /<parameter>=<v:.*>/ <- split("&",l.query) });

