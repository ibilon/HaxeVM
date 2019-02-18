import byte.ByteData;
import haxeparser.HaxeParser;

class Main
{
	static function main()
	{
		var f = '{
			trace("Hello world");
			var a = [7, 5, 6];
			function t(a:Int) {
				trace(a);
			}
			t(a[0]);
			t(0);
			var b = a[1] + 8.0;
			trace(b);
			var b = "hi";
			trace(b);
		}';

		var parser = new HaxeParser(ByteData.ofString(f), "test.hxs");
		var expr = parser.expr();
		var typed = new Typer().typeExpr(expr);
		Display.displayTExpr(typed);
		VM.evalExpr(typed);
	}
}
