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
import haxevm.SymbolTable.Symbol;
import haxevm.impl.Ref;
import haxevm.typer.Error;
import haxevm.typer.ExprTyper;

using haxevm.utils.ComplexTypeUtils;
using haxevm.utils.ModuleTypeUtils;
using haxevm.utils.PositionUtils;
using haxevm.utils.TypeUtils;
using haxevm.utils.TypedExprUtils;

/**
Type a class instantiation.
**/
class NewExpr
{
	/**
	Type a class instantiation.

	@param t The class TypePath.
	@param arguments The arguments expressions.
	@param position The position of the function call.
	@param module The module the expression is in.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(t:TypePath, arguments:Array<Expr>, position:Position, module:Module, typeExpr:ExprTyperFn):TypedExpr
	{
		var typePathHash = '${t.pack.join('.')}#${t.name}#${t.sub == null ? t.name : t.sub}';
		var params = t.params.map(typeParamToType);
		var elems = arguments.map(typeExpr);
		var classType:Null<Ref<ClassType>> = null;
		for (type in module.types)
		{
			switch (type)
			{
				case TClassDecl(c):
					if (type.hash() == typePathHash)
					{
						classType = cast c;
						break;
					}

				default:
					continue;
			}
		}
		if (classType == null)
		{
			throw 'Type not found : ${t.sub == null ? t.name : t.sub}';
		}
		return TNew(classType, params, elems).makeTyped(position, TInst(classType, params));
	}

	/**
	Convert a type param to a type

	@param tp The type param.
	**/
	private static function typeParamToType(tp:TypeParam):Type
	{
		return switch (tp)
		{
			case TPType(t):
				return t.toType();
			case TPExpr(_):
				throw "Unsupported type param";
		}
	}
}