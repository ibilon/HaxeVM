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
	public function testAnonSample():Void
	{
		compareFile("tests/samples/Anon.hx");
	}

	public function testArraysSample():Void
	{
		compareFile("tests/samples/Arrays.hx");
	}

	public function testForSample():Void
	{
		compareFile("tests/samples/For.hx");
	}

	public function testHelloWorldSample():Void
	{
		compareFile("tests/samples/HelloWorld.hx");
	}

	public function testLocalFunctionSample():Void
	{
		compareFile("tests/samples/LocalFunction.hx");
	}

	public function testMainSample():Void
	{
		compareFile("tests/samples/Main.hx");
	}

	public function testOperatorsSample():Void
	{
		compareFile("tests/samples/Operators.hx");
	}

	public function testRecursiveFunctionSample():Void
	{
		compareFile("tests/samples/RecursiveFunction.hx");
	}

	public function testSwitchSample():Void
	{
		compareFile("tests/samples/Switch.hx");
	}

	public function testThrowSample():Void
	{
		compareFile("tests/samples/Throw.hx");
	}

	public function testWhileSample():Void
	{
		compareFile("tests/samples/While.hx");
	}
}
