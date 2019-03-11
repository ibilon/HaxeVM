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

class While
{
	public static function main()
	{
		var i = 0;
		var z = 3;

		while ((i += 2) < z * 2)
		{
			trace(i);
		}

		while (false)
		{
			throw "no";
		}

		var i = 10;

		while (--i >= 0)
		{
			if (i == 5)
			{
				continue;
			}

			trace(i);

			if (i < 2)
			{
				break;
			}
		}

		trace(i);

		do
		{
			trace("a");
		}
		while (false);

		var i = 2;

		do
		{
			trace(-i);
		}
		while (--i > 0);

		do
		{
			trace(i);

			if (i == 4)
			{
				continue;
			}
			else if (i == 6)
			{
				break;
			}
		}
		while (i++ < 10);
	}
}
