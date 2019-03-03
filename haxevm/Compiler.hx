package haxevm;

import byte.ByteData;
import haxe.macro.Type;
import haxeparser.HaxeParser;
import haxevm.typer.ClassTyper;
import haxevm.typer.RefImpl;
import sys.io.File;

using haxe.io.Path;

typedef Module = {
	name : String,
	types : Array<ModuleType>,
	mainType : ClassType,
}

class Compiler
{
	public static function compileFile(filename:String) : Module
	{
		var name = filename.withoutDirectory().withoutExtension();
		var types = [];
		var mainType = null;

		var parser = new HaxeParser(ByteData.ofString(File.getContent(filename)), filename);
		var file = parser.parse();

		for (d in file.decls)
		{
			switch (d.decl)
			{
				case EClass(d):
					var cls = new ClassTyper().typeClass(name, d);
					types.push(TClassDecl(new RefImpl(cls)));

					if (d.name == name)
					{
						if (mainType == null)
						{
							mainType = cls;
						}
						else
						{
							throw "two main types?";
						}
					}

				case EEnum(d):
					throw "not supported";

				case EAbstract(a):
					throw "not supported";

				case EImport(sl, mode):
					throw "not supported";

				case ETypedef(d):
					throw "not supported";

				case EUsing(path):
					throw "not supported";
			}
		}

		return { name: name, types: types, mainType: mainType };
	}
}
