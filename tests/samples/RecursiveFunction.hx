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
		$type(a);

		b = function(i:Float):Float
		{
			trace(i);

			if (i > 0)
			{
				i = a(i / 2);
			}

			return i;
		}
		// $type(b); // TODO propagate type to monomorphs

		a(12);
	}
}
