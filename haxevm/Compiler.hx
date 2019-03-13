/**
Copyright (c) 2019 Valentin Lemière, Guillaume Desquesnes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/

package haxevm;

import byte.ByteData;
import haxeparser.HaxeParser;
import haxevm.typer.ClassTyper;
import haxevm.typer.EnumTyper;
import haxevm.typer.Error;
import haxevm.typer.ModuleTypeTyper;
import haxevm.typer.TypedefTyper;

using haxe.io.Path;
using haxevm.utils.PositionUtils;

/**
The output of the compilation process.
**/
typedef CompilationOutput =
{
	/**
	The errors generated during the compilation.
	**/
	var errors:Array<Error>;

	/**
	The modules compiled.
	**/
	var modules:Array<Module>;

	/**
	The symbole table.
	**/
	var symbolTable:SymbolTable;

	/**
	The warnings generated during the compilation.
	**/
	var warnings:Array<String>;
}

/**
The type of the file reader function.
**/
typedef FileReader = (filename:String)->String;

/**
Execute a compilation.
**/
class Compiler
{
	/**
	The defines.
	**/
	var defines:Map<String, String>;

	/**
	The generated errors.
	**/
	var errors:Array<Error>;

	/**
	The function returning a file's content.
	**/
	var fileReader:FileReader;

	/**
	The path of the main class.
	**/
	var mainClass:String;

	/**
	The modules compiled.
	**/
	var modules:Array<Module>;

	/**
	The symbol of table for this compilation.
	**/
	@:allow(haxevm.typer)
	var symbolTable:SymbolTable;

	/**
	The generated warnings.
	**/
	@:allow(haxevm.typer)
	var warnings:Array<String>;

	/**
	Construct a compilation process.

	@param fileReader The function returning a file's content.
	@param mainClass The path of the main class.
	@param defines The defines.
	**/
	public function new(fileReader:FileReader, mainClass:String, defines:Map<String, String>)
	{
		this.defines = defines;
		this.errors = [];
		this.fileReader = fileReader;
		this.mainClass = mainClass;
		this.modules = [];
		this.symbolTable = new SymbolTable();
		this.warnings = [];
	}

	/**
	Launch the compilation.
	**/
	public function compile():CompilationOutput
	{
		compileFile('${mainClass}.hx');

		return {
			errors: errors,
			modules: modules,
			symbolTable: symbolTable,
			warnings: warnings
		}
	}

	/**
	Compile a file.

	@param filename The file to compile.
	**/
	function compileFile(filename:String):Void
	{
		symbolTable.stack(() ->
		{
			try
			{
				var name = filename.withoutExtension();
				var types = [];
				var module = {
					file: filename,
					name: name,
					types: types,
					newLinesPositions: []
				};

				// Add module to top level symbols
				symbolTable.addModule(module);
				modules.push(module);

				var content = fileReader(filename);
				module.newLinesPositions = PositionUtils.preparseLinesData(content);

				var parser = new HaxeParser(ByteData.ofString(content), filename);

				for (key => value in defines)
				{
					parser.define(key, value);
				}

				var file = try
				{
					parser.parse();
				}
				catch (parserError:ParserError)
				{
					var message = switch (parserError.msg)
					{
						case MissingSemicolon:
							"Missing ;";

						case MissingType:
							"Missing type";

						case DuplicateDefault:
							"Duplicate default";

						case UnclosedMacro:
							"Unclosed macro";

						case Unimplemented:
							"Unimplemented";

						case Custom(s), SharpError(s):
							s;
					}

					errors.push(new Error(ParsingError(message), module, parserError.pos));
					return;
				}

				// First pass: add types symbols
				var declarationsTyper:Array<ModuleTypeTyper> = [];

				for (i in 0...file.decls.length)
				{
					var declaration = file.decls[i];

					switch (declaration.decl)
					{
						case EClass(classDeclaration):
							var classTyper = new ClassTyper(this, module, classDeclaration, declaration.pos);
							declarationsTyper.push(classTyper);

							var type = classTyper.firstPass();
							symbolTable.addType(classDeclaration.name, type);
							types.push(type);

						case EEnum(enumDeclaration):
							var enumTyper = new EnumTyper(this, module, enumDeclaration, declaration.pos);
							declarationsTyper.push(enumTyper);

							var type = enumTyper.firstPass();
							symbolTable.addType(enumDeclaration.name, type);
							types.push(type);

						case ETypedef(typedefDeclaration):
							var typedefTyper = new TypedefTyper(this, module, typedefDeclaration, declaration.pos);
							declarationsTyper.push(typedefTyper);

							var type = typedefTyper.firstPass();
							symbolTable.addType(typedefDeclaration.name, type);
							types.push(type);

						default:
							throw "not supported";
					}
				}

				// Second pass: type type symbols
				for (typer in declarationsTyper)
				{
					typer.secondPass();
				}
			}
			catch (typingError:Error)
			{
				errors.push(typingError);
				return;
			}
		});
	}
}
