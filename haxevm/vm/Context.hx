package haxevm.vm;

abstract Context (Map<Int, Array<EVal>>)
{
	public function new ()
	{
		this = new Map<Int, Array<EVal>>();
	}

	public inline function create (key:Int, value:EVal)
	{
		var tmp = this.exists(key) ? this.get(key) : [];
		tmp.push(value);
		this.set(key, tmp);
	}

	@:arrayAccess
	inline function _get(key:Int) : EVal
	{
		if (!this.exists(key))
		{
			throw "using unbound variable " + key;
		}
		var tmp = this.get(key);
		return tmp[tmp.length - 1];
	}

	@:arrayAccess
	public inline function _set(key:Int, value:EVal) : EVal
	{
		if (!this.exists(key))
		{
			throw "using unbound variable " + key;
		}
		var tmp = this.get(key);
		tmp[tmp.length - 1] = value;
		return value;
	}

	public inline function define(key:Int) : Bool
	{
		return this.exists(key);
	}

	public inline function undefine(key:Int) : Void
	{
		var tmp = this.get(key);
		if (tmp != null)
		{
			if (tmp.length <= 1)
			{
				this.remove(key);
			}
			else
			{
				tmp.pop();
			}
		}
	}
}