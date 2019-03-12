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
import haxevm.impl.Position;
import haxevm.typer.ExprTyper;
import haxevm.utils.ExprUtils;

/**
Type a switch.
**/
class SwitchExpr
{
	/**
	Type a switch.

	@param expr The switch expression.
	@param cases The cases.
	@param defaultExpr The default case expression, optional.
	@param position The position of the switch.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(expr:Expr, cases:Array<Case>, defaultExpr:Null<Expr>, position:BasePosition, typeExpr:ExprTyperFn):TypedExpr
	{
		// TODO cases exprs must be from the switch expr
		var eif = defaultExpr != null ? defaultExpr : ExprUtils.makeEmpty();
		var i = cases.length - 1;

		while (i >= 0)
		{
			var c = cases[i--];
			var cond = {
				expr: EBinop(OpEq, expr, c.values[0]),
				pos: Position.makeEmpty()
			}; // TODO OpEq wont work on anon type

			for (j in 1...c.values.length)
			{
				cond = {
					expr: EBinop(OpBoolOr, cond, {
						expr: EBinop(OpEq, expr, c.values[j]),
						pos: Position.makeEmpty()
					}),
					pos: Position.makeEmpty()
				};
			}

			if (c.guard != null)
			{
				var lhs = {
					expr: EParenthesis(cond),
					pos: Position.makeEmpty()
				}

				cond = {
					expr: EBinop(OpBoolAnd, lhs, c.guard),
					pos: Position.makeEmpty()
				};
			}

			eif = {
				expr: EIf(cond, c.expr != null ? c.expr : ExprUtils.makeEmpty(), eif),
				pos: Position.makeEmpty()
			};
		}

		return typeExpr(eif);
	}
}
