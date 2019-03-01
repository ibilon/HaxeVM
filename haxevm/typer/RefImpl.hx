package haxevm.typer;

class RefImpl<T>
{
	var value : T;

	public function new (value:T)
	{
		this.value = value;
	}

	public function get() : T
	{
		return value;
	}

	public function toString() : String
	{
		return Std.string(value);
	}
}
