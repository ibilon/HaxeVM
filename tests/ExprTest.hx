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

import haxe.PosInfos;

/**
Test expression related features.
**/
class ExprTest extends Test
{
	public function testAnonSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/Anon.hx", pos);
	}

	public function testArraysSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/Arrays.hx", pos);
	}

	public function testForSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/For.hx", pos);
	}

	public function testHelloWorldSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/HelloWorld.hx", pos);
	}

	public function testLocalFunctionSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/LocalFunction.hx", pos);
	}

	public function testMainSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/Main.hx", pos);
	}

	public function testOperatorsSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/Operators.hx", pos);
	}

	public function testRecursiveFunctionSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/RecursiveFunction.hx", pos);
	}

	public function testSwitchSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/Switch.hx", pos);
	}

	public function testThrowSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/Throw.hx", pos);
	}

	public function testWhileSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/While.hx", pos);
	}
}
