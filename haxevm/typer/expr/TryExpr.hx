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
import haxevm.utils.TVarUtils;

using haxevm.utils.ComplexTypeUtils;
using haxevm.utils.TypedExprUtils;

/**
Type a try.
**/
class TryExpr
{
	/**
	Type a try.

	@param expr The try body expression.
	@param catches The cacthes.
	@param position The position of the try.
	@param symbolTable The compilation symbol table.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(expr:Expr, catches:Array<Catch>, position:Position, symbolTable:SymbolTable, typeExpr:ExprTyperFn):TypedExpr
	{
		var typed;
		var typedCatches:Array<{ v:TVar, expr:TypedExpr }> = [];

		symbolTable.stack(() ->
		{
			typed = typeExpr(expr);

			for (c in catches)
			{
				symbolTable.stack(() ->
				{
					var varType = c.type.toType();
					var sid = symbolTable.addVar(c.name, varType);
					var type = typeExpr(c.expr);

					typedCatches.push({
						v: TVarUtils.make(sid, c.name, varType),
						expr: type
					});
				});
			}
		});

		return TTry(typed, typedCatches).makeTyped(position, BaseType.tVoid); // TODO check
	}
}
