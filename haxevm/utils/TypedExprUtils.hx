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

package haxevm.utils;

import haxe.macro.Expr.Position as BasePosition;
import haxe.macro.Type;
import haxevm.impl.Position;
import haxevm.typer.BaseType;

/**
Utilities for `TypedExpr`.
**/
class TypedExprUtils
{
	/**
	Make an empty typed expression which consist of an empty block.
	**/
	public static function makeEmpty():TypedExpr
	{
		return {
			expr: TBlock([]),
			pos: Position.makeEmpty(),
			t: BaseType.tVoid
		};
	}

	/**
	Make a typed expression from a `TypedExprDef`.

	@param expr The expression definition.
	@param position The position of the expression.
	@param type The type of the expression.
	**/
	public static function makeTyped(expr:TypedExprDef, position:BasePosition, type:Type):TypedExpr
	{
		return {
			expr: expr,
			pos: position,
			t: type
		};
	}
}
