class Throw
{
	public static function main()
	{
		function testThrow(a:Int, b:Bool)
		{
			if (a == 0)
			{
				if (b)
				{
					throw "zero";
				}
				else
				{
					throw 0;
				}
			}
			else if (a == 1 && b)
			{
				trace("one");
			}
			else if (a == 2 && a > 0)
			{
				trace("two");
			}
			else
			{
				throw b;
			}
		}

		function test(a:Int, b:Bool)
		{
			try
			{
				testThrow(a, b);
			}
			catch (i:Int)
			{
				trace("got an int thrown");
				trace(i);
			}
			catch (b:Bool)
			{
				trace("got a bool thrown");
				trace(b);
			}
			catch (s:String)
			{
				trace("got a string thrown");
				trace(s);
			}
		}

		test(0, false);
		test(1, false);
		test(2, false);
		test(3, false);
		test(0, true);
		test(1, true);
		test(2, true);
		test(3, true);
	}
}
