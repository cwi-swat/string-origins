module stringorigins::regions::Regions

import String;
import stringorigins::utils::Origins;

import ParseTree;

//alias Regions = map[str key,tuple[str txt, loc pos] contents];
//alias Regions = lrel[int from, int to, str key, str val];
public alias Regions = map[str key,tuple[str txt, loc pos] contents];

anno Regions Tree@regions;

str regionize(str s, str key) = tagString(s, "region", key);

bool isRegion(str x) = /region/ := origin(x).query;

str getName(str x) = n
  when /region=<n:.*>/ := origin(x).query;

Regions extract(str x, loc output) = extract(decons(x, output));

Regions extract(map[loc, str] m) = ( getName(m[l]): <m[l], l> | l <- m, isRegion(m[l]) ); 

str plug(str src, Regions rs, loc output) {
  m = decons(src, output);
  r = ( l: setOrigins(rs[k].txt, [l]) | l <- m, isRegion(m[l]),
           k := getName(m[l]), k in rs );
  return subst(src, r);
}


//public list[Region] calculateRegions(lrel[Maybe[loc], str] theOrigins) {
//  result = [];
//  int offset = 0;
//  for (<maybe, originalText> <- theOrigins){
//      if (just(l) := maybe){
//          if (l.query != ""){
//              if (isInQueryStr(l, PROTECTED)){
//                  protectedName = getParameterValue(l, PROTECTED);
//                  result += <offset, String::size(originalText), protectedName, originalText>;
//              }
//          }
//      }
//      offset += String::size(originalText);
//  }
//  return result;
//}
//
//str plugRegions(list[Region] regions, lrel[Maybe[loc],str] generatedOrigins){
//  newstr = "";
//  map[str,str] extractedBlocks = (name:content | <_, _, name, content> <-regions);
//  for (tup <- generatedOrigins){
//      switch (tup){
//          case <just(l), chunk> :{
//              if (isInQueryStr(l, "protected")){
//                  v = getParameterValue(l, "protected");
//                  if (v in extractedBlocks)
//                      newstr += protected(setOrigins(extractedBlocks[v], [l]), v);
//                  else
//                      newstr += chunk;
//              }else{
//                  newstr += chunk;
//              };
//          }
//          case <_, chunk>:{
//              newstr += chunk;
//          }
//      }
//  };
//  return newstr;
//}
//
//bool isInQueryStr(loc l, str parameter) = parameter in {p | /<p:.*>=.*/ <- split("&",l.query) };
//
//str getParameterValue(loc l, str parameter) = Set::getOneFrom({v | /<parameter>=<v:.*>/ <- split("&",l.query) });
//
