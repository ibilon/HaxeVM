import sys.io.Process;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

using haxe.io.Path;

class Test extends utest.Test
{
	public static function main()
	{
		var r = new Runner();

		r.addCase(new ExprTest());

		Report.create(r, NeverShowSuccessResults, AlwaysShowHeader);
		r.run();
	}

	function runFile(file:String, realHaxe:Bool) : String
	{
		var args = if (realHaxe)
		{
			["-cp", file.directory(), "-main", file.withoutDirectory().withoutExtension(), "--interp"];
		}
		else
		{
			["extraParams.hxml", "--run", "haxevm.Main", file];
		}

		var process = new Process("haxe", args);

		var output = process.stdout.readAll().toString();
		var error = process.stderr.readAll().toString();

		if (error != "")
		{
			Assert.fail(error);
		}

		process.close();

		return output;
	}

	function compareFile(file:String)
	{
		Assert.equals(runFile(file, true), runFile(file, false));
	}
}
