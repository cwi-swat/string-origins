module stringorigins::icmt2014::Examples

import IO;
import String;

import stringorigins::icmt2014::tests::ToVCARD;
import stringorigins::icmt2014::Core;
import stringorigins::icmt2014::Utils;

import lang::missgrant::base::Compile;
import lang::missgrant::base::Implode;
import lang::missgrant::base::AST;

/*********************************************************
 * Code Examples                                         *
 * Tracing Program Transformations with String Origins   *
 *                                                       *
 * Pablo Inostroza and Tijs van der Storm                *
 * CWI, Amsterdam, The Netherlands                       *
 *                                                       *
 *********************************************************/

// §3.2 Example on extraction of editable regions
void section_3_2_extract(){
	loc src = |project://string-origins/src/input/missgrant.ctl|;
	loc out = |project://string-origins/src/input/missgrant.java|;
	Controller ctl = load(src);
	str generated = compile(setOrigins("missgrant", [src]), ctl);
	Regions rs = extract(generated, out);
	iprintln(rs);
}

// §3.2 Example on plugging arbitrary text into an existing editable region
void section_3_2_plug(){
	loc src = |project://string-origins/src/input/missgrant.ctl|;
	loc out = |project://string-origins/src/input/missgrant.java|;
	Controller ctl = load(src);
	str generated = compile(setOrigins("missgrant", [src]), ctl);
	Contents newContent = ("lockDoor":"// Example of plugging some code in for the command lockDoor");
	str plugged = plug(generated, out, newContent);
	printBeforeAfter(generated, plugged);
}

// §3.3
void section_3_3(){
	Ref resolve(Controller ctl) {  
  		sds = { <x, origin(x)> | state(x, _, _) <- ctl.states };
  		eds = { <x, origin(x)> | event(x, _) <- ctl.events };
  		v = range(sds) + range(eds);
  		e = { <origin(e),ed>, <origin(s),sd> 
              | /transition(e, s) := ctl,
                <e, ed> <- eds, <s, sd> <- sds};
  		return <v, e>;
  	};
	loc src = |project://string-origins/src/input/missgrant.ctl|;
	loc out = |project://string-origins/src/input/missgrant.java|;
	Controller ctl = load(src);
	str generated = compile(setOrigins("missgrant", [src]), ctl);
  	Ref rgraph = resolve(ctl);
	iprintln(rgraph);
}

// §3.3
void section_3_4(){
  	loc src = |project://string-origins/src/input/missgrantclash2.ctl|;
	loc out = |project://string-origins/src/input/missgrantclash2.java|;
	Controller ctl = load(src);
	str generated = compile(setOrigins("missgrant", [src]), ctl);
	str fixed = fix(generated, index(generated, out), src);
	printBeforeAfter(generated, fixed);
}

void printBeforeAfter(str before, str after){
  	println("BEFORE");
  	println("------");
  	println(before);
  	println();
  	println("AFTER");
  	println("-----");
  	println(after);
}
