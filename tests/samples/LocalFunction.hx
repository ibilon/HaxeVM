class LocalFunction
{
	public static function main()
	{
		function t(a:Int)
		{
			trace(a);
		}

		t(1);
		t(7);

		var u = function(a:Bool)
		{
			if (a)
			{
				trace("a");
			}
			else
			{
				trace("not a");
			}
		}

		u(true);
		u(false);

		var u = 7;
		trace(u);

		function fibonacci (n:Int) : Int
		{
			if ( n <= 1)
			{
				return n;
			}
			return fibonacci(n-1) + fibonacci(n-2);
		}
		trace(fibonacci(12));
	}
}
