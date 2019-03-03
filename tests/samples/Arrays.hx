class Arrays
{
	public static function main()
	{
		var a = [7, 5, 6];
		trace(a[0]);
		trace(a[1]);
		trace(a[2]);

		var b = a[1] + 8.0;
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
	}
}
