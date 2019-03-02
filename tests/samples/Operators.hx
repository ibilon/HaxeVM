class Operators
{
	public static function main()
	{
		var i = 10;

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
