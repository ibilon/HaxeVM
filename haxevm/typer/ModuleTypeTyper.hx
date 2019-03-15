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

package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxeparser.Data;

/**
Interface used to store the module type typers and call their passes.
**/
interface TwoPassTyper
{
	/**
	Construct the module type's typed data, but don't type its fields' expression.
	**/
	function firstPass():ModuleType;

	/**
	Type the module type's fields' expression.
	**/
	function secondPass():Void;
}

/**
Common part to all ModuleType typer.
**/
class ModuleTypeTyper<DefinitionFlag, DefinitionData, DataType> implements TwoPassTyper
{
	/**
	Link to the compiler doing the compilation.
	**/
	var compiler:Compiler;

	/**
	The definition of the module type.
	**/
	var definition:Definition<DefinitionFlag, DefinitionData>;

	/**
	The module this module type is part of.
	**/
	var module:Module;

	/**
	The module type' position.
	**/
	var position:Position;

	/**
	The typed data.
	**/
	var typedData:Null<DataType>;

	/**
	Construct a module type typer.

	@param compiler The compiler doing the compilation.
	@param module The module this module type is part of.
	@param definition The definition of the module type.
	@param position The module type's position.
	**/
	function new(compiler:Compiler, module:Module, definition:Definition<DefinitionFlag, DefinitionData>, position:Position)
	{
		this.compiler = compiler;
		this.definition = definition;
		this.module = module;
		this.position = position;
		this.typedData = null;
	}

	/**
	Construct the module type's typed data, but don't type its fields' expression.
	**/
	public function firstPass():ModuleType
	{
		throw "abstract function";
	}

	/**
	Type the module type's fields' expression.
	**/
	public function secondPass():Void {}
}
