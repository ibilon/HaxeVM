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
import haxevm.typer.BaseType;
import haxevm.typer.ExprTyper;

using haxevm.utils.TypedExprUtils;

/**
Type a for loop.
**/
class ForExpr
{
	/**
	Type a for loop.

	@param iterator The iterator expression.
	@param expr The body expression.
	@param position The position of the for loop.
	@param symbolTable The compilation symbol table.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(iterator:Expr, expr:Expr, position:BasePosition, symbolTable:SymbolTable, typeExpr:ExprTyperFn):TypedExpr
	{
		var loopVarName;
		var from = 0;
		var to = 0;

		switch (iterator.expr)
		{
			case EBinop(OpIn, lhs, rhs):
				loopVarName = switch (lhs.expr)
				{
					case EConst(CIdent(ident)):
						ident;

					default:
						throw "unsuported for syntax";
				}

				switch (rhs.expr)
				{
					case EBinop(OpInterval, lhs, rhs):
						switch (lhs.expr)
						{
							case EConst(CInt(i)):
								from = switch (Std.parseInt(i))
								{
									case null:
										throw "invalid integer";

									case value:
										value;
								}

							default:
								throw "unsuported for syntax";
						}

						switch (rhs.expr)
						{
							case EConst(CInt(i)):
								to = switch (Std.parseInt(i))
								{
									case null:
										throw "invalid integer";

									case value:
										value;
								}

							default:
								throw "unsuported for syntax";
						}

					default:
						throw "unsuported for syntax";
				}

			default:
				throw "unsuported for syntax";
		}

		if (from > to)
		{
			throw "can't iterate backwards";
		}

		var block = [];

		if (from < to)
		{
			symbolTable.stack(() ->
			{
				var from = {
					expr: EConst(CInt('${from - 1}')),
					pos: Position.makeEmpty()
				};

				var loopVarCreation = typeExpr({
					expr: EVars([{
						name: loopVarName,
						expr: from,
						type: null
					}]),
					pos: Position.makeEmpty()
				});

				var loopVar = {
					expr: EConst(CIdent(loopVarName)),
					pos: Position.makeEmpty()
				};

				var iterator = {
					expr: EUnop(OpIncrement, false, loopVar),
					pos: Position.makeEmpty()
				};

				var condition = {
					expr: EBinop(OpLte, iterator, {
						expr: EConst(CInt('$to')),
						pos: Position.makeEmpty()
					}),
					pos: Position.makeEmpty()
				};

				var whileLoop = typeExpr({
					expr: EWhile(condition, expr, true),
					pos: Position.makeEmpty()
				});

				block = [loopVarCreation, whileLoop];
			});
		}

		return TBlock(block).makeTyped(position, BaseType.tVoid); // TODO check
	}
}
