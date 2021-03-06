# HaxeVM

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/ibilon/HaxeVM.svg?branch=master)](https://travis-ci.org/ibilon/HaxeVM)
[![Issue Count](https://codeclimate.com/github/ibilon/HaxeVM/badges/issue_count.svg)](https://codeclimate.com/github/ibilon/HaxeVM)
[![Test Coverage](https://api.codeclimate.com/v1/badges/74d90b1dadf7b678d8a1/test_coverage)](https://codeclimate.com/github/ibilon/HaxeVM/test_coverage)

Prototype compiler/virtual machine in Haxe for Haxe. Requires Haxe 4.

Currently support a very small subset of the language.
Can run files containing a single class with a single static function called main.

You can test it using haxelib:
```
haxelib git haxevm https://github.com/ibilon/HaxeVM.git
haxelib run haxevm path/to/file.hx
```
Or from the repository:
```
git clone https://github.com/ibilon/HaxeVM.git
cd HaxeVM
haxe extraParams.hxml --run haxevm.Main path/to/file.hx
```

For example:

```haxe
class Main
{
	public static function main()
	{
		trace("Hello world");

		var a = [7, 5, 6];
		function t(a:Int)
		{
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

		function boolTest(b:Bool)
		{
			if (b)
			{
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

		while (--i >= 0)
		{
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

		for (i in 0...5)
		{
			if (i == 2)
			{
				continue;
			}

			trace(i * 2);

			if (i == 4)
			{
				break;
			}
		}
	}
}

```

gives the expected output:

```
test/samples/Main.hx:5: Hello world
test/samples/Main.hx:10: 7
test/samples/Main.hx:10: 0
test/samples/Main.hx:15: 13
test/samples/Main.hx:17: -2
test/samples/Main.hx:19: hi
test/samples/Main.hx:22: well hello
test/samples/Main.hx:23: 4.8
test/samples/Main.hx:24: 19.2
test/samples/Main.hx:25: {sub: {hello: well hello}, a: 12, b: -7.2}
test/samples/Main.hx:43: true
test/samples/Main.hx:34: is true
test/samples/Main.hx:44: 0
test/samples/Main.hx:45: false
test/samples/Main.hx:37: is false
test/samples/Main.hx:46: -1
test/samples/Main.hx:49: 10
test/samples/Main.hx:50: 9
test/samples/Main.hx:51: 8
test/samples/Main.hx:52: 8
test/samples/Main.hx:53: false
test/samples/Main.hx:62: 7
test/samples/Main.hx:62: 6
test/samples/Main.hx:62: 4
test/samples/Main.hx:62: 3
test/samples/Main.hx:62: 2
test/samples/Main.hx:62: 1
test/samples/Main.hx:134: 0
test/samples/Main.hx:134: 2
test/samples/Main.hx:134: 6
test/samples/Main.hx:134: 8
```
