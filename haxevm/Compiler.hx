package haxevm;

import byte.ByteData;
import haxeparser.HaxeParser;
import haxevm.typer.ClassTyper;
import haxevm.typer.ModuleTypeTyper;

using haxe.io.Path;

typedef CompilationOutput =
{
	symbolTable:SymbolTable,
	modules:Array<Module>,
	warnings:Array<String>
}

class Compiler
{
	public var symbolTable:SymbolTable;
	public var fileReader:String->String;
	public var defines:Map<String, String>;
	public var warnings:Array<String>;

	var modules:Array<Module>;
	var mainClass:String;

	public function new(fileReader:String->String, mainClass:String, defines:Map<String, String>)
	{
		symbolTable = new SymbolTable();
		modules = [];
		warnings = [];

		this.fileReader = fileReader;
		this.mainClass = mainClass;
		this.defines = defines;
	}

	public function compile():CompilationOutput
	{
		compileFile('${mainClass}.hx');

		return {
			symbolTable: symbolTable,
			modules: modules,
			warnings: warnings
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
		var decls:Array<ModuleTypeTyper> = [];

		for (i in 0...file.decls.length)
		{
			var decl = file.decls[i];

			switch (decl.decl)
			{
				case EClass(d):
					var clst = new ClassTyper(this, module, d);
					decls.push(clst);

					var type = clst.preType();
					symbolTable.addType(d.name, type);
					types.push(type);

				default:
					throw "not supported";
			}
		}

		// Second pass: type type symbols
		for (decl in decls)
		{
			decl.fullType();
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
