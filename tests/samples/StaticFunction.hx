class StaticFunction
{
	public static function main()
	{
		a(12);
	}

	static function a(i:Float):Float
	{
		trace(i);

		if (i > 0)
		{
			i = b(i - 1);
		}

		return i;
	}

	static function b(i:Float):Float
	{
		trace(i);

		if (i > 0)
		{
			i = a(i / 2);
		}

		return i;
	}
}
