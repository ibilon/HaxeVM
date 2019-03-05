package haxevm.vm;

@:forward(stack, unstack)
abstract Context(ContextData)
{
	public function new()
	{
		this = new ContextData();
	}

	@:arrayAccess
	inline function get(key:Int):EVal
	{
		return switch (this.current[key])
		{
			case null:
				throw "symbol doesn't exist";

			case value:
				value;
		}
	}

	@:arrayAccess
	inline function set(key:Int, value:EVal):EVal
	{
		return this.current[key] = value;
	}

	public inline function exists(key:Int):Bool
	{
		return this.current.exists(key);
	}
}

private class ContextData
{
	public var stacks : Array<Map<Int, EVal>>;
	public var current : Map<Int, EVal>;

	public function new()
	{
		current = new Map<Int, EVal>();
		stacks = [current];
	}

	public function stack()
	{
		current = current.copy();
		stacks.push(current);
	}

	public function unstack()
	{
		stacks.pop();
		current = stacks[stacks.length - 1];
	}
}
