/**
Copyright (c) 2019 Valentin Lemière, Guillaume Desquesnes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/

package haxevm;

import haxe.io.Output;
import sys.FileSystem;
import sys.io.File;

using haxe.io.Path;

/**
Main class.
**/
class Main
{
	/**
	Entry point.
	**/
	static function main():Void
	{
		Sys.exit(run(Sys.args(), Sys.environment().exists("HAXELIB_RUN")) ? 0 : 1);
	}

	/**
	Main function, parse the arguments.

	@param arguments The command line arguments.
	@param out Optional, the normal output. If absent the process' stdout is used.
	@param err Optional, the error output. If absent the process' stderr is used.
	@param haxelib If run though haxelib, if true the last argument is used as cwd.
	**/
	public static function run(arguments:Array<String>, ?out:Output, ?err:Output, haxelib:Bool = false):Bool
	{
		var out:Output = out != null ? out : Sys.stdout();
		var err:Output = err != null ? err : Sys.stderr();
		var cwd = Sys.getCwd();

		if (haxelib)
		{
			switch (arguments.pop())
			{
				case null:
					throw "missing haxelib provided cwd";

				case value:
					Sys.setCwd(value);
			}
		}

		if (arguments.length == 0)
		{
			out.writeString("haxelib run haxevm filename.hx [-Ddefine[=val]]*\n");

			Sys.setCwd(cwd);
			return true;
		}

		var fname = arguments[0];

		if (!FileSystem.exists(fname))
		{
			err.writeString('File "$fname" doesn\'t exist\n');

			Sys.setCwd(cwd);
			return false;
		}

		var defines = new Map<String, String>();

		var i = 0;
		while (++i < arguments.length)
		{
			if (arguments[i] != "-D" || i == arguments.length - 1)
			{
				err.writeString('Invalid argument "${arguments[i]}"\n');

				Sys.setCwd(cwd);
				return false;
			}

			var define = arguments[++i].split("=");
			defines[define[0]] = define.length == 1 ? "1" : define[1];
		}

		runFile(fname, defines, out, err);

		Sys.setCwd(cwd);
		return true;
	}

	/**
	Compiles and runs a file.

	@param fname The file to run.
	@param defines The defines.
	@param out Optional, the normal output. If absent the process' stdout is used.
	@param err Optional, the error output. If absent the process' stderr is used.
	**/
	public static function runFile(fname:String, defines:Map<String, String>, ?out:Output, ?err:Output):Void
	{
		var mainClass = fname.withoutDirectory().withoutExtension();
		var classPath = fname.directory();

		var fileLoader = function(path:String)
		{
			return File.getContent(Path.join([classPath, path]));
		}

		var out:Output = out != null ? out : Sys.stdout();
		var err:Output = err != null ? err : Sys.stderr();

		var compilationOutput = new Compiler(fileLoader, mainClass, defines).compile();

		if (compilationOutput.errors.length != 0)
		{
			for (error in compilationOutput.errors)
			{
				err.writeString(error.toString());
				err.writeString("\n");
			}

			return;
		}

		new VM(compilationOutput, mainClass, out).run();

		for (warning in compilationOutput.warnings)
		{
			err.writeString(warning);
			err.writeString("\n");
		}
	}
}
