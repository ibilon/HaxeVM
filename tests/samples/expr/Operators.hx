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

class Operators
{
	public static function main()
	{
		var i = 10;
		var b = -5;

		trace(i);
		trace(-i);

		trace(-7);
		trace(-(7));

		trace(i--);
		trace(i);
		trace(--i);
		trace(i);

		trace(i++);
		trace(i);
		trace(++i);
		trace(i);

		trace(i < 0);
		trace(i <= 0);
		trace(i > 0);
		trace(i >= 0);
		trace(i == 0);
		trace(i != 0);
		trace(i < b);
		trace(i <= b);
		trace(i > b);
		trace(i >= b);
		trace(i == b);
		trace(i != b);

		trace(i % 2);
		trace(i % -2);
		trace(125 % i);
		trace(125 % -i);

		trace(i * b);
		trace(i * -b);
		trace(-i * b);
		trace(-i * -b);
		trace(b * i);
		trace((i + 2) * (b - 1));

		trace(i / b);
		trace(i / -b);
		trace(-i / b);
		trace(-i / -b);

		trace(i - b);
		trace(i - -b);
		trace(-i - b);
		trace(-i - -b);

		trace(i + b);
		trace(i + -b);
		trace(-i + b);
		trace(-i + -b);

		trace(i << 2);
		trace(i >> 2);
		trace(i >>> 2);
		trace(i & b);
		trace(i | b);
		trace(i ^ b);
		trace(i & (b + 2));
		trace(i | (b + 2));
		trace(i ^ (b + 2));
		trace(~i);

		i += 2;
		trace(i);
		i -= 1;
		trace(i);
		i *= 10;
		trace(i);
		var f = 1.2;
		f /= 5;
		trace(f);

		var a = true;
		var b = false;

		trace(a == a);
		trace(a == b);
		trace(a != a);
		trace(a != b);

		trace(!a);
		trace(!b);

		trace(a && true);
		trace(a || true);
		trace(b && true);
		trace(b || true);
		trace(a && false);
		trace(a || false);
		trace(b && false);
		trace(b || false);

		function no()
		{
			throw "shouldn't";
			return false; // Return type hint doesn't work yet
		}
		$type(no);

		trace(true || no());
		trace(false && no());
	}
}
