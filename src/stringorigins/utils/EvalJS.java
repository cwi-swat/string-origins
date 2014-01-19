package stringorigins.utils;

import java.io.InputStream;
import java.io.InputStreamReader;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

import org.eclipse.imp.pdb.facts.IString;
import org.rascalmpl.interpreter.utils.RuntimeExceptionFactory;
import org.rascalmpl.values.IRascalValueFactory;

public class EvalJS {
	private static final String SOURCEMAP_JS = "source-map.js";
	
	private final IRascalValueFactory values;

	private final ScriptEngineManager mgr;
	private final ScriptEngine engine;
	
	public EvalJS(IRascalValueFactory values) {
		super();
		this.values = values;
		this.mgr = new ScriptEngineManager();
		this.engine = mgr.getEngineByName("JavaScript");
		try {
			InputStream srcMap = EvalJS.class.getResourceAsStream(SOURCEMAP_JS);
			engine.eval(new InputStreamReader(srcMap));
		} 
		catch (ScriptException e) {
			throw RuntimeExceptionFactory.io(values.string(e.getMessage()), null, null);
		}
 	}

	public IString evalJS(IString src) {
		try {
			Object result = engine.eval(src.getValue());
			return values.string(result.toString());
		} catch (ScriptException e) {
			throw RuntimeExceptionFactory.io(values.string(e.getMessage()), null, null);
		}
	}
	
}
