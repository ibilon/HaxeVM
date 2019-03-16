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

class Anon
{
	public static function main()
	{
		var obj = { sub: { hello: "well hello" }, a: 12, b: -7.2, t: true, f: false };

		// $type(obj); // TODO figure out the ordering of eval
		$type(obj.sub.hello);
		$type(obj.a);
		$type(obj.b);

		trace(obj.sub.hello);
		trace(obj.a + obj.b);
		trace(obj.a - obj.b);
		$type(obj.a - obj.b);

		trace(obj.a);
		trace(-obj.a);

		trace(obj.a--);
		trace(obj.a);
		trace(--obj.a);
		trace(obj.a);

		trace(obj.a++);
		trace(obj.a);
		trace(++obj.a);
		trace(obj.a);

		trace(obj.a < 0);
		trace(obj.a <= 0);
		trace(obj.a > 0);
		trace(obj.a >= 0);
		trace(obj.a == 0);
		trace(obj.a != 0);
		trace(obj.a < obj.b);
		trace(obj.a <= obj.b);
		trace(obj.a > obj.b);
		trace(obj.a >= obj.b);
		trace(obj.a == obj.b);
		trace(obj.a != obj.b);
		$type(obj.a != obj.b);

		trace(obj.a % 2);
		trace(obj.a % -2);
		trace(125 % obj.a);
		trace(125 % -obj.a);

		trace(obj.a * obj.b);
		trace(obj.a * -obj.b);
		trace(-obj.a * obj.b);
		trace(-obj.a * -obj.b);
		trace(obj.b * obj.a);
		trace((obj.a + 2) * (obj.b - 1));

		trace(obj.a / obj.b);
		trace(obj.a / -obj.b);
		trace(-obj.a / obj.b);
		trace(-obj.a / -obj.b);

		trace(obj.a - obj.b);
		trace(obj.a - -obj.b);
		trace(-obj.a - obj.b);
		trace(-obj.a - -obj.b);

		trace(obj.a + obj.b);
		trace(obj.a + -obj.b);
		trace(-obj.a + obj.b);
		trace(-obj.a + -obj.b);

		trace(obj.a << 2);
		trace(obj.a >> 2);
		trace(obj.a >>> 2);
		trace(obj.a & (obj.a + 1));
		trace(obj.a | (obj.a + 1));
		trace(obj.a ^ (obj.a + 1));
		trace(~obj.a);

		obj.a += 2;
		trace(obj.a);
		obj.a -= 1;
		trace(obj.a);
		obj.a *= 10;
		trace(obj.a);
		obj.b /= 5;
		trace(obj.b);

		trace(obj.t == obj.t);
		trace(obj.t == obj.f);
		trace(obj.t != obj.t);
		trace(obj.t != obj.f);

		trace(obj.t && true);
		trace(obj.t || true);
		trace(obj.f && true);
		trace(obj.f || true);
		trace(obj.t && false);
		trace(obj.t || false);
		trace(obj.f && false);
		trace(obj.f || false);
	}
}
