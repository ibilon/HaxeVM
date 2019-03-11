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
import haxe.macro.Expr.Position as BasePosition;
import haxe.macro.Type;
import haxevm.impl.MetaAccess;
import haxevm.impl.Position;
import haxevm.impl.Ref;
import haxevm.typer.ExprTyper;

using haxevm.utils.TypedExprUtils;

/**
Type an object declaration.
**/
class ObjectExpr
{
	/**
	Type an object declaration.

	@param fields The fields of the object.
	@param position The position of the object declaration.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(fields:Array<ObjectField>, position:BasePosition, typeExpr:ExprTyperFn):TypedExpr
	{
		var objectFields = [];
		var objectFieldsType = [];

		for (field in fields)
		{
			var typed = typeExpr(field.expr);
			var name = field.field;

			objectFields.push({
				name: name,
				expr: typed
			});

			objectFieldsType.push({
				doc: null,
				isExtern: false,
				isFinal: false,
				isPublic: true,
				kind: FVar(AccNormal, AccNormal),
				meta: MetaAccess.make(null),
				name: name,
				overloads: Ref.make([]),
				params: [],
				pos: Position.makeEmpty(),
				type: typed.t,
				expr: () -> typed
			});
		}

		return TObjectDecl(objectFields).makeTyped(position, TAnonymous(Ref.make({
			fields: objectFieldsType,
			status: AConst
		})));
	}
}
