module stringorigins::escaping::ProtectedTransformer

import util::Maybe;
import String;
import Set;
import List;
import IO;

str findNext(str rest, lrel[Maybe[loc],str] origins){
	toFind = origins[0][1];
	found = findFirst(rest, toFind);
	if (found != -1){
		return substring(rest, 0, found);	
	}
	else
		throw "ERROR!!!";
}

bool isInQueryStr(loc l, str parameter) = parameter in {p | /<p:.*>=.*/ <- split("&",l.query) };

str getParameterValue(loc l, str parameter) = getOneFrom({v | /<parameter>=<v:.*>/ <- split("&",l.query) });

map[str, str] extractBlocks(str altered, lrel[Maybe[loc],str] origins){
	rest = deleteOrigin(altered);
	r = ();
	restOfOrigins = origins;
	for (<mloc, chunk> <- origins){
		csize = size(chunk);
		str token;
		if (csize <= size(rest)){
			token = substring(rest, 0, csize);
		}
		else{
			token = rest;
		}
		restOfOrigins = tail(restOfOrigins);
		if (chunk != token){
			if (just(lolo):=mloc){
				if (isInQueryStr(lolo, "protected")){
					str theBlock = findNext(token, restOfOrigins);
					str label = getParameterValue(lolo, "protected");
					rest = substring(rest, size(theBlock));
					r += (label:theBlock);
				}
				else{
					throw "Incorrect input";
				}
			}
			else{
				throw "Incorrect input";
			}
		}else
			rest = substring(rest, csize);	
		;
	};
	return r;
}

str replaceProtectedBlocks(lrel[Maybe[loc],str] originsNewOutput, map[str, str] extractedBlocks){
	newstr = "";
	for (tup <- originsNewOutput){
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


str ptransform(str(str) transform, str newSource, str currentOutput, lrel[Maybe[loc],str] savedOutputOrigins){
	extractedBlocks = extractBlocks(currentOutput, savedOutputOrigins);
	newOutput = transform(newSource);
	originsNewOutput = origins(newOutput);
	return replaceProtectedBlocks(originsNewOutput, extractedBlocks);
}

str ptransform(str(loc) transform, loc newSourceLoc, loc currentOutputLoc, lrel[Maybe[loc],str] savedOutputOrigins){
	newSource = readFile(newSourceLoc);
	currentOutput = readFile(currentOutputLoc);
	extractedBlocks = extractBlocks(currentOutput, savedOutputOrigins);
	newOutput = transform(newSourceLoc);
	originsNewOutput = origins(newOutput);
	return replaceProtectedBlocks(originsNewOutput, extractedBlocks);
}
