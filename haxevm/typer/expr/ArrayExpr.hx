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

package haxevm.typer.expr;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxevm.typer.BaseType;
import haxevm.typer.ExprTyper;

using haxevm.utils.TypedExprUtils;

/**
Type an array.
**/
class ArrayExpr
{
	/**
	Type an array access.

	@param array The array expression.
	@param key The key expression.
	@param position The position of the array access.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function typeAccess(array:Expr, key:Expr, position:Position, typeExpr:ExprTyperFn):TypedExpr
	{
		var array = typeExpr(array);
		var key = typeExpr(key);

		var of = switch (array.t)
		{
			case TInst(_, params) if (BaseType.isArray(array.t)):
				params[0];

			case TMono(_):
				Monomorph.make();

			default:
				throw "Array access only allowed on arrays " + array.t;
		}

		if (!BaseType.isInt(key.t))
		{
			throw "Array index must be int " + key.t;
		}

		return TArray(array, key).makeTyped(position, of);
	}

	/**
	Type an array declaration.

	@param values The values of the array.
	@param position The position of the array declaration.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function typeDeclaration(values:Array<Expr>, position:Position, typeExpr:ExprTyperFn):TypedExpr
	{
		var type:Null<Type> = null;
		var elems = [];

		for (value in values)
		{
			var value = typeExpr(value);
			elems.push(value);

			if (type == null)
			{
				type = value.t;
			}
			else
			{
				if (type != value.t) // TODO monomorph/unify
				{
					//throw "array must be of single type";
				}
			}
		}

		return TArrayDecl(elems).makeTyped(position, BaseType.tArray(type != null ? type : Monomorph.make()));
	}
}
