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

package tests;

import haxe.CallStack;
import haxe.PosInfos;
import haxe.io.Encoding;
import haxe.io.Output;
import mcover.coverage.MCoverage;
import mcover.coverage.client.LcovPrintClient;
import sys.io.Process;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

using haxe.io.Path;

/**
The output produced by a test (compilation + run).
**/
typedef RunResult =
{
	/**
	The normal output.
	**/
	var out:String;

	/**
	The error output.
	**/
	var err:String;
}

/**
Output storing its content in a string buffer.
Only supports `writeString`.

Can be retrieved by calling `toString`.
**/
class StringBufferOutput extends Output
{
	/**
	The buffer storing the output.
	**/
	var buf:StringBuf;

	/**
	Construct a StringBufferOutput.
	**/
	public function new()
	{
		buf = new StringBuf();
	}

	/**
	Write a string to the output.

	The encoding is ignored.

	@param value The value to output.
	**/
	override public function writeString(value:String, ?_:Encoding):Void
	{
		buf.add(value);
	}

	/**
	The output's content.
	**/
	public function toString():String
	{
		return buf.toString();
	}
}

/**
Main class for the tests.
**/
class Test extends utest.Test
{
	/**
	The tests' entry point.
	**/
	public static function main()
	{
		// Add the tests.
		var r = new Runner();

		r.addCase(new AbstractTest());
		r.addCase(new ClassTest());
		r.addCase(new EnumTest());
		r.addCase(new ErrorTest());
		r.addCase(new ExprTest());
		r.addCase(new MiscTest());
		r.addCase(new TypedefTest());

		// Generate coverage information.
		MCoverage.getLogger().addClient(new LcovPrintClient("Coverage report"));
		r.onComplete.add(_ -> { MCoverage.getLogger().report(); });

		// Run the tests and display results.
		Report.create(r, NeverShowSuccessResults, AlwaysShowHeader);
		r.run();
	}

	/**
	Run a file through the real Haxe compiler interp mode.

	@param file The file to run.
	@param defines The defines.
	**/
	function runHaxe(file:String, defines:Map<String, String>):RunResult
	{
		var cwd = Sys.getCwd();
		Sys.setCwd(file.directory());

		var arguments = ["haxe", "-main", file.withoutDirectory().withoutExtension(), "--interp"];

		for (k => v in defines)
		{
			arguments.push("-D");
			arguments.push('$k=$v');
		}

		// There's some issue with escaping when using arg array.
		var process = new Process(arguments.join(" "));

		var out = process.stdout.readAll().toString();
		var err = process.stderr.readAll().toString();

		process.close();
		Sys.setCwd(cwd);

		return {
			out: out,
			err: err
		}
	}

	/**
	Run a file through the HaxeVM interpreter.

	@param file The file to run.
	@param defines The defines.
	**/
	function runFile(file:String, defines:Map<String, String>):RunResult
	{
		var out = new StringBufferOutput();
		var err = new StringBufferOutput();

		var arguments = [file];

		for (k => v in defines)
		{
			arguments.push("-D");
			arguments.push('$k=$v');
		}

		try
		{
			haxevm.Main.run(arguments, out, err);
		}
		catch (a:Any)
		{
			err.writeString(Std.string(a));
			var es = CallStack.exceptionStack();
			es.reverse();
			err.writeString(CallStack.toString(es));
		}

		return {
			out: out.toString(),
			err: err.toString()
		}
	}

	/**
	Run a file in both the real Haxe and HaxeVM and assert that their output are equal.

	@param file The file to run.
	@param defines The defines, optional.
	**/
	function compareFile(file:String, ?defines:Map<String, String>, ?stripErrorPosition:Bool, ?pos:PosInfos)
	{
		var defines = defines != null ? defines : new Map<String, String>();
		var real = runHaxe(file, defines);
		var haxevm = runFile(file, defines);

		Assert.equals(real.out, haxevm.out, pos);

		if (stripErrorPosition == true)
		{
			function stripPosition(message:String):String
			{
				return message.substr(message.lastIndexOf(":") + 2);
			}

			function clean(err:String):String
			{
				return err.split("\n").map(stripPosition).join("\n");
			}

			Assert.equals(clean(real.err), clean(haxevm.err));
		}
		else
		{
			Assert.equals(real.err, haxevm.err, pos);
		}
	}
}
