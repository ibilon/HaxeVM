# HaxeVM

Prototype compiler/virtual machine in Haxe for Haxe.

Currently support a very small subset of the language.
Can run files containing a single class with a single static function called main.

You can test it using haxelib:
```
haxelib git haxevm https://github.com/ibilon/HaxeVM.git
haxelib run haxevm path/to/file.hx
```

For example:

```haxe
class Main
{
	public static function main()
	{
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
	}
}
```

And gives the expected output (trace behave as a simple print):

```
Hello world
7
0
13
-2
hi
well hello
4.8
19.2
{sub: {hello: well hello}, a: 12, b: -7.2}
true
is true
0
false
is false
-1
10
9
8
8
false
7
6
4
3
2
1
```
