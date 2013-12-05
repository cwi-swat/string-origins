module stringorigins::escaping::examples::Examples

import lang::missgrant::base::Implode;
import lang::missgrant::base::Compile;
import stringorigins::escaping::Protect;
import IO;
import String;
import stringorigins::escaping::ProtectedTransformer;

void example1(){
	s1 = "Pablo";
	str(str) T = str(str src){ return "Hola <src>!!!!\n[<protected("Escribir aquí mensaje importante")>]";};
	o1 = T(s1);
	origins1 = origins(o1);
	o1prime = "Hola Pablo!!!!\n[Que bueno verte.]";
	s2 = "Juan";
	r = ptransform(T, s2, o1prime, origins1);
	println(r);
}



void example2(){
	loc originalSm = |project://string-origins/src/input/missgrantprotected.ctl|;
	loc originalOutput = |project://string-origins/src/input/missgrantprotected.java|;
	loc alteredSm = |project://string-origins/src/input/missgrantprotected.altered.ctl|;
	loc alteredOutput = |project://string-origins/src/input/missgrantprotected.altered.java|;
	loc alteredOutputCorrected = |project://string-origins/src/input/missgrantprotected.altered.corrected.java|;
	T = str(loc l){ return compile("example", load(l)); };
	
	str originalOutputStr = T(originalSm);
	writeFile(originalOutput, originalOutputStr);
	originalOutputOrigins = origins(originalOutputStr);
	r = ptransform(T, alteredSm, alteredOutput, originalOutputOrigins);
	writeFile(alteredOutputCorrected, r);
}
