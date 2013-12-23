package stringorigins.sourcemaps;

import org.eclipse.imp.pdb.facts.type.Type;
import org.eclipse.imp.pdb.facts.type.TypeFactory;
import org.eclipse.imp.pdb.facts.type.TypeStore;

public class Factory {
	public static final TypeStore sourceMaps = new TypeStore();
	private static final TypeFactory tf = TypeFactory.getInstance();

	public static final Type SourceMap = tf.abstractDataType(sourceMaps,
			"SourceMap");
	public static final Type Mapping = tf.abstractDataType(sourceMaps,
			"Mapping");

	public static final Type SourceMap_sourceMap = tf.constructor(sourceMaps,
			SourceMap, "sourceMap", tf.stringType(), "file",
								tf.listType(Mapping), "mappings");

	public static final Type SourceMap_mapping = tf.constructor(sourceMaps, 
			Mapping, "mapping", tf.sourceLocationType(), "generated",
								tf.sourceLocationType(), "original");

	public static final Type SourceMap_mappingWithName = tf.constructor(sourceMaps, 
			Mapping, "mapping", tf.sourceLocationType(), "generated",
								tf.sourceLocationType(), "original",
								tf.stringType(), "name");

}
