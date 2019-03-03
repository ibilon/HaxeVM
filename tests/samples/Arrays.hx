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

		var a = [0,1,2];
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

		var a = ["0","1","2"];
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
