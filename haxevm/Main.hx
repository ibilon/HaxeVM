package haxevm;

import sys.io.File;
using haxe.io.Path;

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
			case 0:
				Sys.println("haxelib run haxevm filename.hx");

			case 1:
				var mainClass = args[0].withoutDirectory().withoutExtension();
				var classPath = args[0].directory();

				var fileLoader = function(path:String)
				{
					return File.getContent(Path.join([classPath, path]));
				}

				var compilationOutput = new Compiler(fileLoader, mainClass).compile();
				new VM(compilationOutput, mainClass).run();

			default:
				Sys.println("too much args");
		}
	}
}
