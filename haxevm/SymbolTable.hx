package haxevm;

import haxe.macro.Type.ClassField;
import haxe.macro.Type.ModuleType;
import haxe.macro.Type.Type;
import haxevm.typer.BaseType;
import haxevm.typer.RefImpl;

enum Symbol
{
	SModule(m:Module);
	SType(t:ModuleType);
	SField(f:ClassField);
	SVar(t:Type);
}

@:forward(enter, leave, getSymbol)
abstract SymbolTable(SymbolTableData)
{
	public inline function new()
	{
		this = new SymbolTableData();

		var arg = {
			t: TMono(RefImpl.make(null)),
			opt: false,
			name: "value"
		};
		addVar("trace", TFun([arg], BaseType.tVoid));
	}

	@:arrayAccess
	inline function get(key:Int):Symbol
	{
		return switch (this.data[key])
		{
			case null:
				throw "symbol doesn't exist";

			case value:
				value;
		}
	}

	@:arrayAccess
	inline function set(key:Int, value:Symbol):Symbol
	{
		return this.data[key] = value;
	}

	public inline function addModule(module:Module):Int
	{
		return this.addSymbol(module.name, SModule(module));
	}

	public inline function addType(name:String, type:ModuleType):Int
	{
		return this.addSymbol(name, SType(type));
	}

	public inline function addField(name:String, field:ClassField):Int
	{
		return this.addSymbol(name, SField(field));
	}

	public inline function addVar(name:String, type:Type):Int
	{
		return this.addSymbol(name, SVar(type));
	}

	public inline function getModule(id:Int):Module
	{
		return switch (get(id))
		{
			case SModule(m):
				m;

			default:
				throw "symbol isn't of type SModule";
		}
	}

	public inline function getType(id:Int):Null<ModuleType>
	{
		return switch (get(id))
		{
			case SType(t):
				t;

			default:
				throw "symbol isn't of type SType";
		}
	}

	public inline function getField(id:Int):Null<ClassField>
	{
		return switch (get(id))
		{
			case SField(f):
				f;

			default:
				throw "symbol isn't of type SField";
		}
	}

	public inline function getVar(id:Int):Null<Type>
	{
		return switch (get(id))
		{
			case SVar(t):
				t;

			default:
				throw "symbol isn't of type SVar";
		}
	}

	public inline function addFunctionArgSymbols(cf:ClassField, ids:Array<Int>)
	{
		this.statics[cf] = ids;
	}

	public inline function getFunctionArgSymbols(cf:ClassField):Array<Int>
	{
		return switch (this.statics[cf])
		{
			case null:
				throw "unknown classfield";

			case value:
				value;
		}
	}
}

private class SymbolTableData
{
	var nextId:Int;
	var current:Map<String, Int>;
	var levels:Array<Map<String, Int>>;
	public var statics:Map<ClassField, Array<Int>>;
	public var data:Map<Int, Symbol>;

	public inline function new()
	{
		nextId = 0;
		current = new Map<String, Int>();
		levels = [current];
		statics = [];
		data = new Map<Int, Symbol>();
	}

	public inline function addSymbol(name:String, symbol:Symbol):Int
	{
		current[name] = nextId;
		data[nextId] = symbol;
		return nextId++;
	}

	public inline function getSymbol(name:String):Int
	{
		return switch (current[name])
		{
			case null:
				throw 'symbol "$name" doesn\'t exist';

			case value:
				value;
		}
	}

	public inline function enter()
	{
		current = current.copy();
		levels.push(current);
	}

	public inline function leave()
	{
		levels.pop();
		current = levels[levels.length - 1];
	}
}
