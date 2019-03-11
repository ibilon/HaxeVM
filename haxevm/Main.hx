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

	/**
	Compiles and runs a file.

	@param fname The file to run.
	@param defines The defines.
	@param stdout Optional, the stdout output. If absent stdout is used.
	@param stderr Optional, the stderr output. If absent stderr is used.
	**/
	public static function runFile(fname:String, defines:Map<String, String>, ?stdout:Output, ?stderr:Output):Void
	{
		var mainClass = fname.withoutDirectory().withoutExtension();
		var classPath = fname.directory();

		var fileLoader = function(path:String)
		{
			return File.getContent(Path.join([classPath, path]));
		}

		var stdout:Output = stdout != null ? stdout : Sys.stdout();
		var stderr:Output = stderr != null ? stderr : Sys.stderr();

		var compilationOutput = new Compiler(fileLoader, mainClass, defines).compile();
		new VM(compilationOutput, mainClass, stdout).run();

		for (warning in compilationOutput.warnings)
		{
			stderr.writeString(warning);
			stderr.writeString("\n");
		}
	}
}
