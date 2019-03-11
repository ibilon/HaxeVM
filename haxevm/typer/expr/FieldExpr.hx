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
import haxevm.impl.Ref;
import haxevm.typer.ExprTyper;

using haxevm.utils.TypedExprUtils;

/**
Type a field access.
**/
class FieldExpr
{
	/**
	Type a field access.

	@param expr The object expression.
	@param fieldName The field's name.
	@param position The position of the field access.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(expr:Expr, fieldName:String, position:Position, typeExpr:ExprTyperFn):TypedExpr
	{
		var typed = typeExpr(expr);

		// TODO class
		switch (typed.t)
		{
			case TAnonymous(_.get() => anonType):
				for (field in anonType.fields)
				{
					if (field.name == fieldName)
					{
						return TField(typed, FAnon(Ref.make(field))).makeTyped(position, field.type);
					}
				}

				throw "object has no field " + fieldName;

			case TInst(_.get() => classType, _):
				for (staticField in classType.statics.get())
				{
					if (staticField.name == fieldName)
					{
						return TField(typed, FStatic(Ref.make(classType), Ref.make(staticField))).makeTyped(position, staticField.type);
					}
				}

				throw "class has no field " + fieldName;

			default:
				throw "field access not implemented " + typed.t;
		}
	}
}
