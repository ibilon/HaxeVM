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

class Other
{
	public static var e = 0;

	public static var i = 0;

	public static function a():Int
	{
		MultiClassStatic.e++;

		return if (i > 2)
		{
			i;
		}
		else
		{
			i = 8;
		}
	}

	public static function b(i:Int, a:Bool):Float
	{
		return a ? i / 2 : i * 1.7;
	}
}

class MultiClassStatic
{
	public static var i:Int;
	public static var e = 0;
	public static var h = "hi";

	public static function main()
	{
		trace(h);
		trace(e);

		i = 77;
		trace(i);

		trace(Other.e);
		trace(++Other.i);

		a(0);

		trace(e);
		trace(Other.e);

		trace(i);
		trace(Other.i);
	}

	static function a(i:Float):Float
	{
		e++;

		if (i > 0)
		{
			i = b(i - 1);
		}
		else if (i == 0)
		{
			i = Other.a();
		}

		return i;
	}

	static function b(i:Float):Float
	{
		e++;

		i = i > 0 ? a(i / 2) : 0;

		return i;
	}

	static function p():Float
	{
		return Other.b(i, false) * Other.b(i, true) + 4;
	}
}
