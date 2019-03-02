class While
{
	public static function main()
	{
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
	}
}
