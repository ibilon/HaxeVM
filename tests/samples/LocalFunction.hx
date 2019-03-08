class LocalFunction
{
	public static function main()
	{
		function t(a:Int)
		{
			trace(a);
		}

		$type(t);
		$type(t(0));

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

		$type(u);
		$type(u(true));

		u(true);
		u(false);

		var u = 7;
		trace(u);
	}
}
