class ConditionalCompilation
{
	public static function main()
	{
		#if test
		trace("test");
		#else
		trace("normal");
		#end

		var i = #if test 2 #else "hello" #end;
		trace(i);
	}
}
