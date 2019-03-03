class Operators
{
	public static function main()
	{
		var i = 10;
		var b = -9;

		trace(i);
		trace(-i);

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

		trace(true || no());
		trace(false && no());
	}
}
