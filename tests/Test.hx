import haxe.CallStack;
import haxe.io.Output;
import mcover.coverage.MCoverage;
import mcover.coverage.client.LcovPrintClient;
import sys.io.Process;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

using haxe.io.Path;

typedef RunResult =
{
	stdout:String,
	stderr:String,
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

		MCoverage.getLogger().addClient(new LcovPrintClient("Coverage report"));
		r.onComplete.add(_ -> { MCoverage.getLogger().report(); });

		Report.create(r, NeverShowSuccessResults, AlwaysShowHeader);
		r.run();
	}

	function runHaxe(file:String, defines:Map<String, String>):RunResult
	{
		var cwd = Sys.getCwd();
		Sys.setCwd(file.directory());

		var args = ["haxe", "-main", file.withoutDirectory().withoutExtension(), "--interp"];

		for (k => v in defines)
		{
			args.push("-D");
			args.push('$k=$v');
		}

		// There's some issue with escaping when using arg array
		var process = new Process(args.join(" "));

		var stdout = process.stdout.readAll().toString();
		var stderr = process.stderr.readAll().toString();

		process.close();
		Sys.setCwd(cwd);

		return {
			stdout: stdout,
			stderr: stderr
		}
	}

	function runFile(file:String, defines:Map<String, String>):RunResult
	{
		var stdout = new StringBufferOutput();
		var stderr = new StringBufferOutput();

		try
		{
			haxevm.Main.runFile(file, defines, stdout, stderr);
		}
		catch (a:Any)
		{
			stderr.writeString(CallStack.toString(CallStack.exceptionStack()));
		}

		return {
			stdout: stdout.toString(),
			stderr: stderr.toString()
		}
	}

	function compareFile(file:String, ?defines:Map<String, String>)
	{
		var defines = defines != null ? defines : new Map<String, String>();
		var real = runHaxe(file, defines);
		var haxevm = runFile(file, defines);

		Assert.equals(real.stdout, haxevm.stdout);
		Assert.equals(real.stderr, haxevm.stderr);
	}
}
