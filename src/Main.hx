import byte.ByteData;
import haxeparser.HaxeParser;
import sys.io.File;

class Main
{
	static function main()
	{
		var fname = "test/samples/Main.hx";
		var parser = new HaxeParser(ByteData.ofString(File.getContent(fname)), fname);
		var file = parser.parse();

		for (d in file.decls)
		{
			switch (d.decl)
			{
				case EClass(d):
					if (d.name != "Main")
					{
						throw "not supported";
					}

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
