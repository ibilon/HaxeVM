package haxevm;

import haxe.io.Output;
import sys.FileSystem;
import sys.io.File;

using haxe.io.Path;

class Main
{
	static function main()
	{
		var args = Sys.args();

		if (Sys.environment().exists("HAXELIB_RUN"))
		{
			switch (args.pop())
			{
				case null:
					throw "missing haxelib provided cwd";

				case value:
					Sys.setCwd(value);
			}
		}

		if (args.length == 0)
		{
			Sys.println("haxelib run haxevm filename.hx [-Ddefine[=val]]*");
			Sys.exit(0);
		}

		var fname = args[0];

		if (!FileSystem.exists(fname))
		{
			Sys.println('File "$fname" doesn\'t exist');
			Sys.exit(0);
		}

		var defines = new Map<String, String>();

		var i = 0;
		while (++i < args.length)
		{
			if (args[i] != "-D" || i == args.length - 1)
			{
				Sys.println('Invalid argument "${args[i]}"');
				Sys.exit(1);
			}

			var define = args[++i].split("=");
			defines[define[0]] = define.length == 1 ? "1" : define[1];
		}

		runFile(fname, defines);
	}

	public static function runFile(fname:String, defines:Map<String, String>, ?output:Output)
	{
		var mainClass = fname.withoutDirectory().withoutExtension();
		var classPath = fname.directory();

		var fileLoader = function(path:String)
		{
			return File.getContent(Path.join([classPath, path]));
		}

		var compilationOutput = new Compiler(fileLoader, mainClass, defines).compile();

		var output:Output = output != null ? output : Sys.stdout();
		new VM(compilationOutput, mainClass, output).run();
	}
}
