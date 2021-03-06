/**
Copyright (c) 2019 Valentin Lemière, Guillaume Desquesnes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/

package tests;

/**
Test expression related features.
**/
class ExprTest extends Test
{
	public function testAnon():Void
	{
		compareFile("tests/samples/expr/Anon.hx");
	}

	public function testArrays():Void
	{
		compareFile("tests/samples/expr/Arrays.hx");
	}

	public function testFor():Void
	{
		compareFile("tests/samples/expr/For.hx");
	}

	public function testHelloWorld():Void
	{
		compareFile("tests/samples/expr/HelloWorld.hx");
	}

	public function testLocalFunction():Void
	{
		compareFile("tests/samples/expr/LocalFunction.hx");
	}

	public function testMain():Void
	{
		compareFile("tests/samples/expr/Main.hx");
	}

	public function testOperators():Void
	{
		compareFile("tests/samples/expr/Operators.hx");
	}

	public function testRecursiveFunction():Void
	{
		compareFile("tests/samples/expr/RecursiveFunction.hx");
	}

	public function testSwitch():Void
	{
		compareFile("tests/samples/expr/Switch.hx");
	}

	public function testThrow():Void
	{
		compareFile("tests/samples/expr/Throw.hx");
	}

	public function testWhile():Void
	{
		compareFile("tests/samples/expr/While.hx");
	}
}
