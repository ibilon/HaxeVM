package haxevm;

class Main
{
	static function main()
	{
		var args = Sys.args();

		if (Sys.environment().exists("HAXELIB_RUN"))
		{
			Sys.setCwd(args.pop());
		}

		switch (args.length)
		{
			case 0: Sys.println("haxelib run haxevm filename.hx");
			case 1: runFile(args[0]);
			default: Sys.println("too much args");
		}
	}

	static function runFile(filename:String)
	{
		var module = Compiler.compileFile(filename);

		if (module.mainType == null)
		{
			throw "no main class";
		}

		for (s in module.mainType.statics.get())
		{
			if (s.name == "main")
			{
				var typed = s.expr();
				//Display.displayTExpr(typed);
				VM.evalExpr(typed);
				return;
			}
		}

		throw "no main function";
	}
}
