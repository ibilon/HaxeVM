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

class ErrorTest extends Test
{
	public function testArrayAccessNotAllowed():Void
	{
		compareFile("tests/samples/error/ArrayAccessNotAllowed.hx");
	}

	public function testBackwardIterating():Void
	{
		compareFile("tests/samples/error/BackwardIterating.hx");
	}

	public function testCantCompare():Void
	{
		compareFile("tests/samples/error/CantCompare.hx");
	}

	public function testCustomPropertyAccessorGet():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/CustomPropertyAccessorGet.hx", true);
	}

	public function testCustomPropertyAccessorSet():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/CustomPropertyAccessorSet.hx", true);
	}

	public function testDuplicateDefault():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/DuplicateDefault.hx", true);
	}

	public function testFieldNotFoundAnon():Void
	{
		compareFile("tests/samples/error/FieldNotFoundAnon.hx");
	}

	public function testFieldNotFoundStatic():Void
	{
		compareFile("tests/samples/error/FieldNotFoundStatic.hx");
	}

	public function testMissingPropertyAccessorGet():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/MissingPropertyAccessorGet.hx", true);
	}

	public function testMissingPropertyAccessorSet():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/MissingPropertyAccessorSet.hx", true);
	}

	public function testMissingSemicolon():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/MissingSemicolon.hx", true);
	}

	@Ignored // TODO need better position + unification error message
	public function testMixedTypeArray():Void
	{
		compareFile("tests/samples/error/MixedTypeArray.hx");
	}

	public function testModuleWithoutMainType():Void
	{
		compareFile("tests/samples/error/ModuleWithoutMainType.hx");
	}

	public function testNoFunctionExpr():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/NoFunctionExpr.hx", true);
	}

	public function testNoMain():Void
	{
		// TODO missing position
		compareFile("tests/samples/error/NoMain.hx", true);
	}

	public function testTypeIsNotCallable():Void
	{
		compareFile("tests/samples/error/TypeIsNotCallable.hx");
	}

	#if cpp @Ignored #end // TODO wrong position on cpp
	public function testUnexpectedBracket():Void
	{
		compareFile("tests/samples/error/UnexpectedBracket.hx");
	}

	public function testUnificationError():Void
	{
		compareFile("tests/samples/error/UnificationError.hx");
	}

	public function testUnresolvedIdentifier():Void
	{
		compareFile("tests/samples/error/UnresolvedIdentifier.hx");
	}
}
