module stringorigins::\test::RegionsTest

import stringorigins::regions::Regions;
import IO;
import String;

str input = "Pablo Inostroza
			'pvaldera@cwi.nl";

str T(str input) = "VCARD:4.0
	'FN:<name>
	'EMAIL:<tagString(email,"region","email")>	
 	'END:VCARD"
	when [name,email] := split("\n", input);

public test bool test1(){
	str output = T(input);
	loc exLoc = |project://string-origins/src/stringorigins/regions/test1.vcard|;
	writeFile(exLoc, output);
	Regions rs = extract(output, exLoc);
	iprintln(rs);
	return ("email" in rs);
}


str input2 = "Pablo Inostroza Valdera
			'pvaldera@cwi.nl";

public test bool test2(){
	str output1 = T(input);
	str output2 = T(input2);
	loc exLoc = |project://string-origins/src/stringorigins/regions/test2.vcard|;
	writeFile(exLoc, output2);
	Regions rs = extract(output2, exLoc);
	generated = plug(output2, rs, exLoc);
	iprintln(rs);
	return ("email" in rs);
}