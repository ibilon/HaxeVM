package haxevm;

import haxe.macro.Type.ClassField;
import haxe.macro.Type.ModuleType;
import haxe.macro.Type.Type;

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

		var sid = addVar("trace");
		var arg = {
			t: TMono(new haxevm.typer.RefImpl(null)),
			opt: false,
			name: "value"
		};
		this.data[sid] = SVar(TFun([arg], haxevm.typer.BaseType.Void));
	}

	@:arrayAccess
	inline function get(key:Int):Symbol
	{
		return this.data[key];
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

	public inline function addType(name:String):Int
	{
		return this.addSymbol(name, SType(null));
	}

	public inline function addField(name:String):Int
	{
		return this.addSymbol(name, SField(null));
	}

	public inline function addVar(name:String):Int
	{
		return this.addSymbol(name, SVar(null));
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

	public inline function getType(id:Int):ModuleType
	{
		return switch (get(id))
		{
			case SType(t):
				t;

			default:
				throw "symbol isn't of type SVar";
		}
	}

	public inline function getField(id:Int):ClassField
	{
		return switch (get(id))
		{
			case SField(f):
				f;

			default:
				throw "symbol isn't of type SVar";
		}
	}

	public inline function getVar(id:Int):Type
	{
		return switch (get(id))
		{
			case SVar(t):
				t;

			default:
				throw "symbol isn't of type SVar";
		}
	}
}

private class SymbolTableData
{
	var nextId:Int;
	var current:Map<String, Int>;
	var levels:Array<Map<String, Int>>;
	public var data:Map<Int, Symbol>;

	public inline function new()
	{
		nextId = 0;
		current = new Map<String, Int>();
		levels = [current];
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
		return current[name];
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
