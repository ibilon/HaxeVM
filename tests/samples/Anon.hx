class Anon
{
	public static function main()
	{
		var obj = { sub: { hello: "well hello" }, a: 12, b: -7.2 };
		trace(obj.sub.hello);
		trace(obj.a + obj.b);
		trace(obj.a - obj.b);
		trace(obj);
	}
}
