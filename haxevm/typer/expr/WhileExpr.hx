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
Type a while loop.
**/
class WhileExpr
{
	/**
	Type a while loop.

	@param conditionExpr The expression of the loop condition.
	@param expr The expression of the loop body.
	@param normalWhile If the while is normal, or a do while.
	@param position The position of the while.
	@param symbolTable The compilation symbol table.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(conditionExpr:Expr, expr:Expr, normalWhile:Bool, position:Position, symbolTable:SymbolTable, typeExpr:ExprTyperFn):TypedExpr
	{
		var conditionTyped;
		var typed;

		symbolTable.stack(() ->
		{
			conditionTyped = typeExpr(conditionExpr);
			Unification.unify(BaseType.tBool, conditionTyped.t, true);

			symbolTable.stack(() ->
			{
				typed = typeExpr(expr);
			});
		});

		return TWhile(conditionTyped, typed, normalWhile).makeTyped(position, BaseType.tVoid); // TODO check
	}
}
