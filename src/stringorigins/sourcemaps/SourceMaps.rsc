module stringorigins::sourcemaps::SourceMaps

import String;
import util::Maybe;
import stringorigins::names::FixNames; // for reconstruct
import util::ShellExec;
import IO;

str sourceMapGenerator(str src, loc input, loc output, set[str] names = {}) {
  recon = reconstruct(origins(src), output);
  mappings = [ mapping(l, org, x in names ? x : "") | 
               <x, l, org> <- recon, org.path == input.path ];
  return
    "var src = require(\'source-map\');
    'var map = new src.SourceMapGenerator({file: \"<output.file>\"});
    '<for (m <- mappings) {>map.addMapping(<m>);
    '<}>
    'console.log(map.toString());";
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
  
  
