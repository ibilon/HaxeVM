import sys.io.Process;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

using haxe.io.Path;

enum CompileResult
{
	Success(output:String);
	Error(output:String);
}

class Test extends utest.Test
{
	public static function main()
	{
		var r = new Runner();

		r.addCase(new ExprTest());

		Report.create(r, NeverShowSuccessResults, AlwaysShowHeader);
		r.run();
	}

	function runFile(file:String, realHaxe:Bool) : CompileResult
	{
		var cwd = Sys.getCwd();

		var args = if (realHaxe)
		{
			Sys.setCwd(file.directory());
			["-main", file.withoutDirectory().withoutExtension(), "--interp"];
		}
		else
		{
			["extraParams.hxml", "--run", "haxevm.Main", file];
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

	function compareFile(file:String)
	{
		var real = runFile(file, true);
		var haxevm = runFile(file, false);

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
