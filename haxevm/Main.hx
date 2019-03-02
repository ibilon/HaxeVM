package haxevm;

import byte.ByteData;
import haxeparser.HaxeParser;
import sys.io.File;

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

	static function runFile(fname:String)
	{
		var parser = new HaxeParser(ByteData.ofString(File.getContent(fname)), fname);
		var file = parser.parse();

		for (d in file.decls)
		{
			switch (d.decl)
			{
				case EClass(d):
					for (d in d.data)
					{
						switch (d.kind)
						{
							case FFun(f):
								if (d.name == "main" && f.args.length == 0)
								{
									var typed = new Typer().typeExpr(f.expr);
									//Display.displayTExpr(typed);
									VM.evalExpr(typed);
								}

							default:
								throw "not supported";
						}
					}

				default:
					throw "not supported";
			}
		}
	}
}
