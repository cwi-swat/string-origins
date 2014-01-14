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
  mgg = string2sourceMapGenerator(js, input, output);
  mg = evalJS(mgg);
  println(mg);
  writeFile(srcmap, mg);
}

str string2sourceMapGenerator(str src, loc input, loc output, set[str] names = {}) {
  recon = reconstruct(origins(src), output);
  mappings = [ mapping(l, org, x in names ? x : "") | 
               <x, l, org> <- recon, org.path == input.path,
               /break/ := org.query ];
  return
    "var map = new sourceMap.SourceMapGenerator({file: \"<output.file>\"});
    '<for (m <- mappings) {>map.addMapping(<m>);
    '<}>
    'map.toString();";
}

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
