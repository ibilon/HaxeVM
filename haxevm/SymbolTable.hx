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

import haxe.macro.Type.ClassField;
import haxe.macro.Type.ModuleType;
import haxe.macro.Type.Type;
import haxevm.impl.Ref;
import haxevm.typer.BaseType;
import haxevm.typer.Error;

using haxevm.utils.ArrayUtils;
using haxevm.utils.PositionUtils;

/**
A symbol.
**/
enum Symbol
{
	/**
	A symbol representing a module.
	**/
	SModule(module:Module);

	/**
	A symbol representing a type.
	**/
	SType(type:ModuleType);

	/**
	A symbol representing a field.
	**/
	SField(field:ClassField);

	/**
	A symbol representing a variable.
	**/
	SVar(type:Type);
}

/**
The compilation symbol table.
**/
abstract SymbolTable(SymbolTableData)
{
	/**
	Construct a new symbol table.
	**/
	public inline function new()
	{
		this = new SymbolTableData();

		var arg = {
			t: TMono(Ref.make(null)),
			opt: false,
			name: "value"
		};
		addVar("trace", TFun([arg], BaseType.tVoid));
	}

	/**
	Add a field.

	@param field The field to add.
	**/
	public inline function addField(field:ClassField):Int
	{
		return addSymbol(field.name, SField(field));
	}

	/**
	Add a module.

	@param module The module to add.
	**/
	public inline function addModule(module:Module):Int
	{
		return addSymbol(module.name, SModule(module));
	}

	/**
	Add a static function's argument symbols.
	To be used by the VM to allocate the value in the context.

	@param classField The static function's field.
	@param ids The argument symbols.
	**/
	public inline function addStaticFunctionArgumentSymbols(classField:ClassField, ids:Array<Int>):Void
	{
		this.staticFunctionsArgumentSymbols[classField.pos.hash()] = ids;
	}

	/**
	Add a symbol.

	@param name The symbol's name.
	@param symbol The symbol.
	**/
	inline function addSymbol(name:String, symbol:Symbol):Int
	{
		this.current[name] = this.nextId;
		this.symbols[this.nextId] = symbol;
		return this.nextId++;
	}

	/**
	Add a type.

	@param name The name of the type.
	@param type The type to add.
	**/
	public inline function addType(name:String, type:ModuleType):Int
	{
		return addSymbol(name, SType(type));
	}

	/**
	Add a variable.

	@param name The name of the variable.
	@param type The type of the variable.
	**/
	public inline function addVar(name:String, type:Type):Int
	{
		return addSymbol(name, SVar(type));
	}

	/**
	Array get operator.

	@param key The symbol to get.
	**/
	@:arrayAccess
	inline function get(key:Int):Symbol
	{
		return switch (this.symbols[key])
		{
			case null:
				throw "symbol doesn't exist";

			case value:
				value;
		}
	}

	/**
	Get a field.

	@param id The field's id.
	**/
	public inline function getField(id:Int):ClassField
	{
		return switch (get(id))
		{
			case SField(field):
				field;

			default:
				throw "symbol isn't of type SField";
		}
	}

	/**
	Get a module.

	@param id The module's id.
	**/
	public inline function getModule(id:Int):Module
	{
		return switch (get(id))
		{
			case SModule(module):
				module;

			default:
				throw "symbol isn't of type SModule";
		}
	}

	public inline function getStaticFunctionArgumentSymbols(cf:ClassField):Array<Int>
	{
		return switch (this.staticFunctionsArgumentSymbols[cf.pos.hash()])
		{
			case null:
				throw "unknown classfield";

			case value:
				value;
		}
	}

	/**
	Get a symbol's id.

	@param name The symbol's name.
	**/
	public inline function getSymbol(name:String):Int
	{
		return switch (this.current[name])
		{
			case null:
				throw ErrorMessage.UnresolvedIdentifier(name);

			case value:
				value;
		}
	}

	/**
	Get a type.

	@param id The type's id.
	**/
	public inline function getType(id:Int):ModuleType
	{
		return switch (get(id))
		{
			case SType(type):
				type;

			default:
				throw "symbol isn't of type SType";
		}
	}

	/**
	Get a variable.

	@param id The variable's id.
	**/
	public inline function getVar(id:Int):Type
	{
		return switch (get(id))
		{
			case SVar(type):
				type;

			default:
				throw "symbol isn't of type SVar";
		}
	}

	/**
	Array set operator.

	@param key The symbol to set.
	@param value The value to set to.
	**/
	@:arrayAccess
	inline function set(key:Int, value:Symbol):Symbol
	{
		return this.symbols[key] = value;
	}

	/**
	Stack a block, reverting the symbol table afterward.
	**/
	public inline function stack(block:Void->Void):Void
	{
		this.current = this.current.copy();
		this.stacks.push(this.current);

		block();

		this.stacks.pop();
		this.current = this.stacks.last();
	}
}

/**
Data class for the SymbolTable.
**/
private class SymbolTableData
{
	/**
	The current stack, linking a name to its id.
	**/
	public var current:Map<String, Int>;

	/**
	The next free symbol id.
	**/
	public var nextId:Int;

	/**
	The successive stacks of symbols.
	**/
	public var stacks:Array<Map<String, Int>>;

	/**
	The list of symbol id for the static function's argument variables.
	**/
	public var staticFunctionsArgumentSymbols:Map<String, Array<Int>>;

	/**
	The symbol associated to the id.
	**/
	public var symbols:Map<Int, Symbol>;

	/**
	Construct the data.
	**/
	public inline function new()
	{
		current = new Map<String, Int>();
		nextId = 0;
		stacks = [current];
		staticFunctionsArgumentSymbols = [];
		symbols = new Map<Int, Symbol>();
	}
}
