module stringorigins::sourcemaps::SourceMaps

import String;
import util::Maybe;
import util::ShellExec;
import IO;
import stringorigins::utils::Origins; 

str generateSourceMap(str js, loc input, loc output, set[str] names = {})
  = evalJS(string2sourceMapGenerator(js, input, output, names));

<<<<<<< Updated upstream
str string2sourceMapGenerator(str src, loc input, loc output, set[str] names) {
  recon = reconstruct(origins(src), output);
  mappings = for (<x, l, org> <- recon) {
    if (org.path == input.path) {
      append mapping(l, org, x in names ? x : "");
    }
    else {
      append mapping(l);
    } 
  }
  return
    "var map = new sourceMap.SourceMapGenerator({file: \"<output.file>\"});
    '<for (m <- mappings) {>map.addMapping(<m>);
    '<}>
    'map.toString();";
=======
void mapGen() {
  loc srcmap = |project://string-origins/src/input/missgrant.js.map|;
  loc input = |project://string-origins/src/input/missgrant.ctl|;
  loc output = |project://string-origins/src/input/missgrant.js|;

  ast = load(input);
  js = compile2js("missgrant", ast);
  mg = string2sourceMap(js, input, output);
  println(mg);
  writeFile(output, js);
  writeFile(srcmap, mg);
}

str string2sourceMap(str src, loc input, loc output, set[str] names = {}) {
  recon = reconstruct(origins(src), output);
  mappings = [ x in names ? mapping(l, org,  x) : mapping(l, org) | 
               <x, l, org> <- recon, bprintln("x = <x>, l = <l>, org = <org>"), org.path == input.path ];
  iprintln(mappings);
  return generateSourceMap(sourceMap(output.file, mappings));
>>>>>>> Stashed changes
}

str mapping(loc gen) 
  = "{
    '  generated: {
    '    line: <gen.begin.line>,
    '    column: <gen.begin.column>
    '  }
    '}";

str mapping(loc gen, loc org, str name) 
  = "{
    '  generated: {
    '    line: <gen.begin.line>,
    '    column: <gen.begin.column>
    '  },
    '  source: \"<org.file>\",
    '  original: {
    '    line: <org.begin.line>,
    '    column: <org.begin.column>
    '  }<if (name != "") {>,
    '  name: \"<name>\"<}>
    '}";

data SourceMap
  = sourceMap(str file, list[Mapping] mappings)
  ;
  
data Mapping
  = mapping(loc generated, loc original)
  | mapping(loc generated, loc original, str name)
  ;
 
@javaClass{stringorigins.utils.EvalJS}
java str evalJS(str x);
