package stringorigins.sourcemaps;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

import org.eclipse.imp.pdb.facts.IString;
import org.mozilla.javascript.Context;
import org.mozilla.javascript.Scriptable;
import org.rascalmpl.interpreter.utils.RuntimeExceptionFactory;
import org.rascalmpl.values.IRascalValueFactory;

public class RunRhino {
	private final IRascalValueFactory values;
	public RunRhino(IRascalValueFactory values){
		super();
		this.values = values;
	}


	public IString evalJS(IString src) {
		Context cx = Context.enter();
		Scriptable scope = cx.initStandardObjects();
		try {
			cx.evaluateReader(scope, new FileReader(new File("/Users/tvdstorm/CWI/string-origins/lib/source-map.js")), "source-map.js", 0, null);
		} catch (FileNotFoundException e) {
			throw RuntimeExceptionFactory.io(values.string(e.getMessage()), null, null);
		} catch (IOException e) {
			throw RuntimeExceptionFactory.io(values.string(e.getMessage()), null, null);
		}
		Object result = cx.evaluateString(scope, src.getValue(), "_UNKNOWN__", 0, null);
		Context.exit();
		return values.string(result.toString());
	}
	
}
