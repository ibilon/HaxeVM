package haxevm;

import byte.ByteData;
import haxe.macro.Type.ModuleType;
import haxeparser.HaxeParser;
import haxevm.SymbolTable.Symbol;
import haxevm.typer.ClassTyper;
import haxevm.typer.RefImpl;

using haxe.io.Path;

typedef CompilationOutput =
{
	symbolTable:SymbolTable,
	modules:Array<Module>
}

class Compiler
{
	var symbolTable:SymbolTable;
	var modules:Array<Module>;
	var fileReader:String->String;
	var mainClass:String;
	var defines:Map<String, String>;

	public function new(fileReader:String->String, mainClass:String, defines:Map<String, String>)
	{
		symbolTable = new SymbolTable();
		modules = [];
		this.fileReader = fileReader;
		this.mainClass = mainClass;
		this.defines = defines;
	}

	public function compile():CompilationOutput
	{
		compileFile('${mainClass}.hx');

		return {
			symbolTable: symbolTable,
			modules: modules
		}
	}

	function compileFile(filename:String)
	{
		symbolTable.enter();

		var name = filename.withoutExtension();
		var types = [];
		var module = {
			file: filename,
			name: name,
			types: types,
			linesData: []
		};

		// Add module to top level symbols
		symbolTable.addModule(module);
		modules.push(module);

		var content = fileReader(filename);
		module.linesData = preparseLinesData(content);

		var parser = new HaxeParser(ByteData.ofString(content), filename);

		for (k => v in defines)
		{
			parser.define(k, v);
		}

		var file = parser.parse();

		// First pass: add types symbols
		var ids = new Map<String, Int>();

		for (decl in file.decls)
		{
			switch (decl.decl)
			{
				case EClass(d):
					ids[d.name] = symbolTable.addType(d.name);

				case EEnum(d):
					ids[d.name] = symbolTable.addType(d.name);

				case EAbstract(a):
					ids[a.name] = symbolTable.addType(a.name);

				case EImport(sl, mode):
					// TODO add imported types into symbol table
					throw "not supported";

				case ETypedef(d):
					ids[d.name] = symbolTable.addType(d.name);

				case EUsing(path):
					// TODO
					throw "not supported";
			}
		}

		// Second pass: type type symbols
		for (decl in file.decls)
		{
			switch (decl.decl)
			{
				case EClass(d):
					var cls = new ClassTyper(symbolTable, module, d).type();
					var type = ModuleType.TClassDecl(new RefImpl(cls));
					symbolTable[ids[d.name]] = Symbol.SType(type);
					types.push(type);

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

		symbolTable.leave();
	}

	function preparseLinesData(content:String):Array<Int>
	{
		var data = [];
		var i = 0;

		while (i < content.length)
		{
			switch (content.charAt(i++))
			{
				case "\r":
					if (content.charAt(i + 1) == "\n")
					{
						i++;
					}
					data.push(i);

				case "\n":
					data.push(i);

				default:
			}
		}

		data.push(i);
		return data;
	}
}
