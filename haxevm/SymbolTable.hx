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

import haxe.macro.Type;
import haxevm.impl.Ref;
import haxevm.typer.BaseType;
import haxevm.typer.Error;
import haxevm.typer.Monomorph;

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
	SType(type:ModuleType, from:Module);

	/**
	A symbol representing a field.
	**/
	SField(field:ClassField, from:ClassType, isStatic:Bool);

	/**
	A symbol representing a local variable.
	**/
	SVar(type:Type);
}

/**
The compilation symbol table.
**/
@:forward(traceID, thisID)
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
		this.traceID = addVar("trace", TFun([arg], BaseType.tVoid));

		// Reserve symbol ID 1 for `this`.
		this.thisID = addVar("this", this.thisUnboundType);
	}

	/**
	Add a field.

	@param field The field to add.
	@param from The class the field belongs to.
	@param isStatic If the field is a static or member.
	**/
	public inline function addField(field:ClassField, from:ClassType, isStatic:Bool):Int
	{
		return addSymbol(field.name, SField(field, from, isStatic));
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
	Add a function's argument symbols.
	To be used by the VM to allocate the value in the context.

	@param classField The function's field.
	@param ids The argument symbols.
	**/
	public inline function addFunctionArgumentSymbols(classField:ClassField, ids:Array<Int>):Void
	{
		this.functionsArgumentSymbols[classField.pos.hash()] = ids;
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
	public inline function addType(name:String, type:ModuleType, from:Module):Int
	{
		return addSymbol(name, SType(type, from));
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
				throw 'symbol $key doesn\'t exist in symbol table';

			case value:
				value;
		}
	}

	/**
	Get a function's argument symbols.
	Used by the VM to allocate the value in the context.

	@param classField The function's field.
	**/
	public inline function getFunctionArgumentSymbols(classField:ClassField):Array<Int>
	{
		return switch (this.functionsArgumentSymbols[classField.pos.hash()])
		{
			case null:
				throw "unknown classfield";

			case value:
				value;
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
	Set the `this` type for this stack.

	@param classType The class to bind `this` to.
	**/
	public inline function setThis(classType:ClassType):Void
	{
		this.symbols[this.thisID] = SVar(TInst(Ref.make(classType), []));
		this.current["this"] = this.thisID;
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

		// Reset `this` if leaving member function.
		if (!this.current.exists("this"))
		{
			this.symbols[this.thisID] = SVar(this.thisUnboundType);
		}
	}
}

/**
Data class for the SymbolTable.
**/
@:allow(haxevm.SymbolTable)
private class SymbolTableData
{
	/**
	The current stack, linking a name to its id.
	**/
	public var current(default, null):Map<String, Int>;

	/**
	The next free symbol id.
	**/
	public var nextId(default, null):Int;

	/**
	The successive stacks of symbols.
	**/
	public var stacks(default, null):Array<Map<String, Int>>;

	/**
	The list of symbol id for the static function's argument variables.
	**/
	public var functionsArgumentSymbols(default, null):Map<String, Array<Int>>;

	/**
	The symbol associated to the id.
	**/
	public var symbols(default, null):Map<Int, Symbol>;

	/**
	The symbol reserved for `this`.
	**/
	public var thisID(default, null):Int;

	/**
	Type representing an unbound this (outside a member function).
	**/
	public var thisUnboundType(default, null):Type;

	/**
	The symbol reserved for `trace`.
	**/
	public var traceID(default, null):Int;

	/**
	Construct the data.
	**/
	public inline function new()
	{
		this.current = new Map<String, Int>();
		this.nextId = 0;
		this.stacks = [current];
		this.functionsArgumentSymbols = [];
		this.symbols = new Map<Int, Symbol>();
		this.thisID = -1;
		this.thisUnboundType = TLazy(() -> throw "Can't access this outside member function");
		this.traceID = -1;
	}
}
