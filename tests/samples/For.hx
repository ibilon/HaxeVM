class For
{
	public static function main()
	{
		var i = "hi";
		trace(i);

		for (i in 0...5)
		{
			if (i == 2)
			{
				continue;
			}

			trace(i * 2);

			if (i == 4)
			{
				break;
			}
		}

		trace(i);

		for (i in 5...5)
		{
			trace(i);
		}

		trace(i);
	}
}
