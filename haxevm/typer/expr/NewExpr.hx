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
import haxevm.typer.ExprTyper;
import haxevm.utils.TypeParamUtils;

using haxevm.utils.ModuleTypeUtils;
using haxevm.utils.TypedExprUtils;

/**
Type a class instantiation.
**/
class NewExpr
{
	/**
	Type a class instantiation.

	@param typePath The class TypePath.
	@param arguments The arguments expressions.
	@param position The position of the function call.
	@param module The module the expression is in.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(typePath:TypePath, arguments:Array<Expr>, position:Position, module:Module, typeExpr:ExprTyperFn):TypedExpr
	{
		var classTypeRef = module.findClass(typePath);
		var params = typePath.params.map(TypeParamUtils.toType);
		var arguments = arguments.map(typeExpr);

		return TNew(classTypeRef, params, arguments).makeTyped(position, TInst(classTypeRef, params));
	}
}
