package haxevm.typer;

import haxe.macro.Type.Ref;

class RefImpl<T>
{
	public static function make<T>(value:T):Ref<T>
	{
		return new RefImpl(value);
	}

	var value:T;

	function new(value:T)
	{
		this.value = value;
	}

	public function get():T
	{
		return value;
	}

	public function toString():String
	{
		return Std.string(value);
	}
}
