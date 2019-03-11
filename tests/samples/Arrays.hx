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

class Arrays
{
	public static function main()
	{
		var a = [7, 5, 6];

		$type(a);
		$type(a[0]);

		trace(a[0]);
		trace(a[1]);
		trace(a[2]);

		var b = a[1] + 8.0;
		$type(b);
		trace(b);
		b = -2;
		trace(b);

		a[0] += 1;
		trace(a[0]);
		a[0] -= 2;
		trace(a[0]);
		a[0] *= 2;
		trace(a[0]);

		a[0] = 7;
		trace(a[0]);

		var a = [0, 1, 2];
		trace(a);
		trace(a[3]);
		trace(a);
		a[3] = 3;
		trace(a[3]);
		trace(a);
		a[6] = 6;
		trace(a[6]);
		trace(a);
		trace(a[8]);
		trace(a);

		var a = ["0", "1", "2"];
		$type(a);
		trace(a);
		trace(a[3]);
		trace(a);
		a[3] = "3";
		trace(a[3]);
		trace(a);
		a[6] = "6";
		trace(a[6]);
		trace(a);
		trace(a[8]);
		trace(a);
	}
}
