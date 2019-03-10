class Static
{
	public static var i:Int;
	public static var e = 0;
	public static var h = "hi";

	public static function main()
	{
		trace(e);
		i = -678;
		trace(i);

		a(12);

		trace(h);
		h = "hello";
		trace(h);
		h += " world";
		trace(h);

		trace(i);
		trace(e);
	}

	static function a(i:Float):Float
	{
		trace(i);
		e++;

		if (i > 0)
		{
			i = b(i - 1);
		}

		return i;
	}

	static function b(i:Float):Float
	{
		trace(i);
		e++;

		if (i > 0)
		{
			i = a(i / 2);
		}

		return i;
	}
}
