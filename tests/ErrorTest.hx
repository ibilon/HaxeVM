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
	public function testClassCustomPropertyAccessorGet():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/class/CustomPropertyAccessorGet.hx", true);
	}

	public function testClassCustomPropertyAccessorSet():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/class/CustomPropertyAccessorSet.hx", true);
	}

	public function testClassFieldNotFoundStatic():Void
	{
		compareFile("tests/samples/error/class/FieldNotFoundStatic.hx");
	}

	public function testClassMissingPropertyAccessorGet():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/class/MissingPropertyAccessorGet.hx", true);
	}

	public function testClassMissingPropertyAccessorSet():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/class/MissingPropertyAccessorSet.hx", true);
	}

	public function testClassNoFunctionExpr():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/class/NoFunctionExpr.hx", true);
	}

	public function testExprArrayAccessNotAllowed():Void
	{
		compareFile("tests/samples/error/expr/ArrayAccessNotAllowed.hx");
	}

	public function testExprBackwardIterating():Void
	{
		compareFile("tests/samples/error/expr/BackwardIterating.hx");
	}

	public function testExprCantCompare():Void
	{
		compareFile("tests/samples/error/expr/CantCompare.hx");
	}

	public function testExprDuplicateDefault():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/expr/DuplicateDefault.hx", true);
	}

	public function testExprFieldNotFoundAnon():Void
	{
		compareFile("tests/samples/error/expr/FieldNotFoundAnon.hx");
	}

	@Ignored // TODO need better position + unification error message
	public function testExprMixedTypeArray():Void
	{
		compareFile("tests/samples/error/expr/MixedTypeArray.hx");
	}

	public function testExprTypeIsNotCallable():Void
	{
		compareFile("tests/samples/error/expr/TypeIsNotCallable.hx");
	}

	public function testExprUnificationError():Void
	{
		compareFile("tests/samples/error/expr/UnificationError.hx");
	}

	public function testExprUnresolvedIdentifier():Void
	{
		compareFile("tests/samples/error/expr/UnresolvedIdentifier.hx");
	}

	public function testOtherModuleWithoutMainType():Void
	{
		compareFile("tests/samples/error/other/ModuleWithoutMainType.hx");
	}

	public function testOtherNoMain():Void
	{
		// TODO missing position
		compareFile("tests/samples/error/other/NoMain.hx", true);
	}

	public function testParserMissingSemicolon():Void
	{
		// TODO wrong position
		compareFile("tests/samples/error/parser/MissingSemicolon.hx", true);
	}

	#if cpp @Ignored #end // TODO wrong position on cpp
	public function testParserUnexpectedBracket():Void
	{
		compareFile("tests/samples/error/parser/UnexpectedBracket.hx");
	}
}
