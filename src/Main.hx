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
			b = -2;
			trace(b);
			var b = "hi";
			trace(b);
			var obj = { sub: { hello: "well hello" }, a: 12, b: -7.2 };
			trace(obj.sub.hello);
			trace(obj.a + obj.b);
			trace(obj.a - obj.b);
			trace(obj);
			var a = true;
			var b = false;
			function boolTest(b:Bool) {
				if (b) {
					trace("is true");
				} else {
					trace("is false");
				}
			}
			trace(a);
			boolTest(a);
			trace(b);
			boolTest(b);
		}';

		var parser = new HaxeParser(ByteData.ofString(f), "test.hxs");
		var expr = parser.expr();
		var typed = new Typer().typeExpr(expr);
		Display.displayTExpr(typed);
		VM.evalExpr(typed);
	}
}
