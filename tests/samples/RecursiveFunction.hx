class RecursiveFunction
{
	public static function main()
	{
		function fibonacci(n:Int):Int
		{
			if (n <= 1)
			{
				return n;
			}

			trace(n);

			return fibonacci(n - 1) + fibonacci(n - 2);
		}

		trace(fibonacci(12));

		var b;

		function a(i:Float):Float
		{
			trace(i);

			if (i > 0)
			{
				i = b(i - 1);
			}

			return i;
		}

		b = function(i:Float):Float
		{
			trace(i);

			if (i > 0)
			{
				i = a(i / 2);
			}

			return i;
		}

		a(12);
	}
}
