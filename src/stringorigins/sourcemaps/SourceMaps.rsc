module stringorigins::sourcemaps::SourceMaps

import String;
import util::Maybe;
import stringorigins::names::FixNames; // for reconstruct
import util::ShellExec;
import IO;
import lang::missgrant::base::Compile2JS;
import lang::missgrant::base::Implode;
import lang::missgrant::base::AST;


void mapGen() {
  loc srcmap = |project://string-origins/src/input/missgrant.js.map|;
  loc input = |project://string-origins/src/input/missgrant.ctl|;
  loc output = |project://string-origins/src/input/missgrant.js|;

  ast = load(input);
  
  ast = visit (ast) {
    case c:command(_, str tk) => c[token=tagString(c.token, "break", "true")]
    case e:event(_, str tk) => e[token=tagString(e.token, "break", "true")]
  }
  
  js = compile2js("missgrant", ast);
  writeFile(output, js);
  mg = string2sourceMap(js, [input], output);
  println(mg);
  writeFile(srcmap, mg);
}

str string2sourceMap(str src, list[loc] inputs, loc output, set[str] names = {}) {
  println("Constructing sourcemap for <output>");
  recon = reconstruct(origins(src), output);
  mappings = [ x in names ? mapping(l, org,  x) : mapping(l, org) | 
               <x, l, org> <- recon, any(i <- inputs, 
               org.path == i.path, /break/ := org.query ) ];
  iprintln(mappings);
  return generateSourceMap(sourceMap(output.file, mappings));
}

data SourceMap
  = sourceMap(str file, list[Mapping] mappings)
  ;
  
data Mapping
  = mapping(loc generated, loc original)
  | mapping(loc generated, loc original, str name)
  ;
 
@javaClass{stringorigins.sourcemaps.SourceMap}
java str generateSourceMap(SourceMap sourceMap);
 
