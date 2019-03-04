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

	public function new(fileReader:String->String, mainClass:String)
	{
		symbolTable = new SymbolTable();
		modules = [];
		this.fileReader = fileReader;
		this.mainClass = mainClass;
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

		// Map<file, [lineEndChar]>
		//var linesDatas:Map<String, Array<Int>>;

		var name = filename.withoutExtension();
		var types = [];
		var module = {
			name: name,
			types: types
		};

		// Add module to top level symbols
		symbolTable.addModule(module);
		modules.push(module);

		var parser = new HaxeParser(ByteData.ofString(fileReader(filename)), filename);
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

	/*
	function tracePosition(expr:Expr):TypedExpr
	{
		var file = expr.pos.file;

		if (!linesDatas.exists(file))
		{
			linesDatas.set(file, preparseLinesData(file));
		}

		var data = linesDatas.get(file);
		var bounds = {
			min: 0,
			max: data.length - 1
		};

		while (bounds.max - bounds.min > 1)
		{
			var i = Std.int((bounds.min + bounds.max) / 2);
			var end = data[i];

			if (expr.pos.min <= end)
			{
				bounds.max = i;
			}

			if (expr.pos.min >= end)
			{
				bounds.min = i;
			}
		}

		var line = bounds.max + 1;
		return makeTyped(expr, TConst(TString(file + ":" + line + ":")), BaseType.String);
	}

	function preparseLinesData(file:String):Array<Int>
	{
		return []; // TODO no sys access inside compiler
		var content = sys.io.File.getContent(file);
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
	*/
}
