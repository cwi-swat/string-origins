module stringorigins::sourcemaps::SourceMaps

import String;
import util::Maybe;
import stringorigins::names::FixNames; // for reconstruct
import util::ShellExec;
import IO;

str generateSourceMap(str js, loc input, loc output, set[str] names = {})
  = evalJS(string2sourceMapGenerator(js, input, output, names));

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
