import haxe.CallStack;
import haxe.io.Output;
import mcover.coverage.MCoverage;
import sys.io.Process;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

using haxe.io.Path;

enum RunResult
{
	Success(output:String);
	Error(output:String);
}

class StringBufferOutput extends Output
{
	var buf:StringBuf;

	public function new()
	{
		buf = new StringBuf();
	}

	override public function writeString(value:String, ?encoding):Void
	{
		buf.add(value);
	}

	public function toString():String
	{
		return buf.toString();
	}
}

class Test extends utest.Test
{
	public static function main()
	{
		var r = new Runner();

		r.addCase(new ClassTest());
		r.addCase(new ExprTest());
		r.addCase(new MiscTest());

		r.onComplete.add(_ -> { trace("a"); MCoverage.getLogger().report(); });
		//Report.create(r, NeverShowSuccessResults, AlwaysShowHeader);
		r.run();
	}

	function runHaxe(file:String, defines:Map<String, String>):RunResult
	{
		var cwd = Sys.getCwd();
		Sys.setCwd(file.directory());

		var args = ["-main", file.withoutDirectory().withoutExtension(), "--interp"];

		for (k in defines.keys())
		{
			args.push("-D");
			args.push('$k=${defines[k]}');
		}

		var process = new Process("haxe", args);

		var output = process.stdout.readAll().toString();
		var error = process.stderr.readAll().toString();

		process.close();
		Sys.setCwd(cwd);

		if (error != "")
		{
			return Error(error);
		}

		return Success(output);
	}

	function runFile(file:String, defines:Map<String, String>):RunResult
	{
		var output = new StringBufferOutput();

		try
		{
			haxevm.Main.runFile(file, defines, output);
			return Success(output.toString());
		}
		catch (a:Any)
		{
			return Error(CallStack.toString(CallStack.exceptionStack()));
		}
	}

	function compareFile(file:String, ?defines:Map<String, String>)
	{
		var defines = defines != null ? defines : new Map<String, String>();
		var real = runHaxe(file, defines);
		var haxevm = runFile(file, defines);

		switch ([real, haxevm])
		{
			case [Success(oreal), Success(ovm)]:
				Assert.equals(oreal, ovm);

			case [Error(oreal), Error(ovm)]:
				Assert.equals(oreal, ovm);

			case [Success(oreal), Error(ovm)]:
				Assert.fail('Should have compiled but failed with "$ovm"');

			case [Error(oreal), Success(ovm)]:
				Assert.fail('Should have errored with "$oreal" but compiled');
		}
	}
}
