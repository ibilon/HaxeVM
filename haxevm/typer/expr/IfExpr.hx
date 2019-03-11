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
Type an if.
**/
class IfExpr
{
	/**
	Type an if.

	@param conditionExpr The condition expression.
	@param ifExpe The expression when the condition is true.
	@param elseExpr The expression whene the condition is false, optional.
	@param position The position of the if.
	@param symbolTable The compilation symbol table.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(conditionExpr:Expr, ifExpr:Expr, elseExpr:Null<Expr>, position:Position, symbolTable:SymbolTable, typeExpr:ExprTyperFn):TypedExpr
	{
		var conditionTyped;
		var ifTyped;
		var elseTyped;

		symbolTable.stack(() ->
		{
			conditionTyped = typeExpr(conditionExpr);

			if (!BaseType.isBool(conditionTyped.t))
			{
				throw "if condition must be bool is " + conditionTyped.t;
			}

			symbolTable.stack(() ->
			{
				ifTyped = typeExpr(ifExpr);
			});

			symbolTable.stack(() ->
			{
				elseTyped = elseExpr != null ? typeExpr(elseExpr) : null;
			});
		});

		return TIf(conditionTyped, ifTyped, elseTyped).makeTyped(position, BaseType.tVoid); // TODO check
	}
}
