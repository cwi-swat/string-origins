package stringorigins.sourcemaps;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;

import org.eclipse.imp.pdb.facts.IConstructor;
import org.eclipse.imp.pdb.facts.IList;
import org.eclipse.imp.pdb.facts.ISourceLocation;
import org.eclipse.imp.pdb.facts.IString;
import org.eclipse.imp.pdb.facts.IValue;
import org.rascalmpl.values.IRascalValueFactory;

import com.google.debugging.sourcemap.FilePosition;
import com.google.debugging.sourcemap.SourceMapFormat;
import com.google.debugging.sourcemap.SourceMapGenerator;
import com.google.debugging.sourcemap.SourceMapGeneratorFactory;

public class SourceMap {
	private final IRascalValueFactory values;
	
	public SourceMap(IRascalValueFactory values){
		super();
		this.values = values;
	}


	public IString generateSourceMap(IConstructor sourceMap) {
		SourceMapGenerator gen = SourceMapGeneratorFactory.getInstance(SourceMapFormat.V3);
		IList mappings = (IList)sourceMap.get("mappings");
		IString file = (IString) sourceMap.get("file");
		for (IValue v: mappings) {
			IConstructor mapping = (IConstructor)v;
			ISourceLocation generated = (ISourceLocation) mapping.get("generated");
			ISourceLocation original = (ISourceLocation) mapping.get("original");
			/*
			 * void addMapping(String sourceName, @Nullable String symbolName,
           FilePosition sourceStartPosition,
           FilePosition outputStartPosition, FilePosition outputEndPosition);
			 */
			String name = null;
			if (mapping.has("name")) {
				name = ((IString)mapping.get("name")).getValue();
			}
			gen.addMapping(new File(original.getPath()).getName(), name, 
					new FilePosition(original.getBeginLine(), original.getBeginColumn()),
					new FilePosition(generated.getBeginLine(), generated.getBeginColumn()),
					new FilePosition(generated.getEndLine(), generated.getEndColumn()));
		}
		StringWriter str = new StringWriter();
		try {
			gen.appendTo(str, file.getValue());
		} catch (IOException e) {
			throw new AssertionError();
		}
		return values.string(str.toString());
	}
	
	
}
