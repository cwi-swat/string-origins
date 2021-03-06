module stringorigins::escaping::Protect

import String;
import util::Maybe;
import List;
import Set;
import ParseTree;

str regionize(str s, str key) = tagString(s, "region", key);

alias R = map[str key,tuple[str txt, loc pos] contents];

bool isRegion(str x) = /region/ := origin(x).query;

str getName(str x) = n
  when /region=<n:.*>/ := origin(x).query;

R extract(map[loc, str] m) = 
  ( getName(x): <x, l> | <x, l> <- m, isRegion(x) ); 

str plug(str src, R rs) {
  r = ( l: regions[k].txt | <l, x> <- smap(m), isRegion(x),
           k := getName(x), k in rs );
  return subst(src, r);
}


//public list[Region] calculateRegions(lrel[Maybe[loc], str] theOrigins) {
//	result = [];
//	int offset = 0;
//	for (<maybe, originalText> <- theOrigins){
//		if (just(l) := maybe){
//			if (l.query != ""){
//				if (isInQueryStr(l, PROTECTED)){
//					protectedName = getParameterValue(l, PROTECTED);
//					result += <offset, String::size(originalText), protectedName, originalText>;
//				}
//			}
//		}
//		offset += String::size(originalText);
//	}
//	return result;
//}
//
//str plugRegions(list[Region] regions, lrel[Maybe[loc],str] generatedOrigins){
//	newstr = "";
//	map[str,str] extractedBlocks = (name:content | <_, _, name, content> <-regions);
//	for (tup <- generatedOrigins){
//		switch (tup){
//			case <just(l), chunk> :{
//				if (isInQueryStr(l, "protected")){
//					v = getParameterValue(l, "protected");
//					if (v in extractedBlocks)
//						newstr += protected(setOrigins(extractedBlocks[v], [l]), v);
//					else
//						newstr += chunk;
//				}else{
//					newstr += chunk;
//				};
//			}
//			case <_, chunk>:{
//				newstr += chunk;
//			}
//		}
//	};
//	return newstr;
//}
//
//bool isInQueryStr(loc l, str parameter) = parameter in {p | /<p:.*>=.*/ <- split("&",l.query) };
//
//str getParameterValue(loc l, str parameter) = Set::getOneFrom({v | /<parameter>=<v:.*>/ <- split("&",l.query) });
//
