# HaxeVM

Prototype compiler/virtual machine in Haxe for Haxe.

Currently support a very small subset of the language, can run the following example:

```haxe
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
	var b = "hi";
	trace(b);
}
```

And gives the expected output (trace behave as a simple print):

```
Hello world
7
0
13
hi
```
