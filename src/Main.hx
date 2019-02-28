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
					return 0;
				} else {
					trace("is false");
				}

				return -1;
			}
			trace(a);
			trace(boolTest(a));
			trace(b);
			trace(boolTest(b));
			var i = 10;
			trace(i--);
			trace(i);
			trace(--i);
			trace(i);
			trace(i < 0);
			while (--i >= 0) {
				if (i == 5)
				{
					continue;
				}

				trace(i);

				if (i < 2)
				{
					break;
				}
			}
		}';

		var parser = new HaxeParser(ByteData.ofString(f), "test.hxs");
		var expr = parser.expr();
		var typed = new Typer().typeExpr(expr);
		Display.displayTExpr(typed);
		VM.evalExpr(typed);
	}
}
