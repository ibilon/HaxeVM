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
import haxevm.typer.BaseType;
import haxevm.typer.ExprTyper;
import haxevm.utils.TVarUtils;

using haxevm.utils.ComplexTypeUtils;
using haxevm.utils.TypedExprUtils;

/**
Type a variable creation.
**/
class VarExpr
{
	/**
	Type a variable creation.

	Only a single var is supported for now.

	@param vars The variables created.
	@param position The position of the constant.
	@param symbolTable The compilation symbol table.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(vars:Array<Var>, position:Position, symbolTable:SymbolTable, typeExpr:ExprTyperFn):TypedExpr
	{
		var v = vars[0]; // TODO how to make multiple nodes from this?
		var sid = symbolTable.addVar(v.name, v.type.toType());

		var typed = v.expr != null ? typeExpr(v.expr) : null;
		var type = typed != null ? typed.t : Monomorph.make();

		if (BaseType.isVoid(type))
		{
			// TODO put error on the var's expression
			throw "variable can't have type Void";
		}

		symbolTable[sid] = SVar(type);

		return TVar(TVarUtils.make(sid, v.name, type), typed).makeTyped(position, type);
	}
}
