class Switch
{
	public static function main()
	{
		function testSwitchThrow(a:Int, b:Bool)
		{
			switch (a)
			{
				case 0:
					if (b)
					{
						throw "zero";
					}
					else
					{
						throw 0;
					}

				case 1 if (b):
					trace("one");

				case 2 if (a > 0):
					trace("two");

				default:
					throw b;
			}
		}

		function test(a:Int, b:Bool)
		{
			try
			{
				testSwitchThrow(a, b);
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

		//TODO haxe doesn't give the same results
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
