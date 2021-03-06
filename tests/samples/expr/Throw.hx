/**
Copyright (c) 2019 Valentin Lemière, Guillaume Desquesnes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/

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
