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
import haxevm.typer.BaseType;
import haxevm.typer.ExprTyper;
import haxevm.utils.TVarUtils;

using haxevm.utils.ComplexTypeUtils;
using haxevm.utils.PositionUtils;
using haxevm.utils.TypedExprUtils;

/**
Type a function.
**/
class FunctionExpr
{
	/**
	Type a function call.

	@param expr The function expression.
	@param arguments The arguments expressions.
	@param position The position of the function call.
	@param module The module the expression is in.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function typeCall(expr:Expr, arguments:Array<Expr>, position:Position, module:Module, typeExpr:ExprTyperFn):TypedExpr
	{
		var typed = typeExpr(expr);
		var elems = arguments.map(typeExpr);

		var returnType = switch (typed.t)
		{
			case TFun(_, ret):
				ret;

			case TMono(ref):
				var mono = Monomorph.make();
				(cast ref : Ref<Type>).set(TFun(elems.map(arg -> { name: "", opt: null, t: arg.t }), mono));
				mono;

			default:
				throw "Can only call functions " + typed.t;
		}

		if (expr.expr.match(EConst(CIdent("trace"))))
		{
			elems.unshift(TConst(TString(position.toString(module))).makeTyped(position, BaseType.tString));
		}

		return TCall(typed, elems).makeTyped(position, returnType); // TODO check function sign and param
	}

	/**
	Type a function declaration.

	@param name The function name, optional.
	@param fn The function.
	@param position The position of the function declaration.
	@param symbolTable The compilation symbol table.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function typeDeclaration(name:Null<String>, fn:Function, position:Position, symbolTable:SymbolTable, typeExpr:ExprTyperFn):TypedExpr
	{
		var argumentsTyped:Array<{ name:String, opt:Bool, t:Type }> = [];
		var argumentsVariable = [];

		var fnId = name != null ? symbolTable.addVar(name, TLazy(() -> throw "not typed yet")) : -1;
		var typed;

		symbolTable.stack(() ->
		{
			for (arg in fn.args)
			{
				var sid = symbolTable.addVar(arg.name, arg.type.toType());
				var type = switch (symbolTable.getVar(sid))
				{
					case null:
						throw "symbol doesn't exist";

					case value:
						value;
				}

				argumentsTyped.push({
					name: arg.name,
					opt: arg.opt != null ? arg.opt : false,
					t: type
				});

				argumentsVariable.push({
					value: null,
					v: TVarUtils.make(sid, arg.name, type)
				});
			}

			if (fnId != -1 && fn.ret != null)
			{
				symbolTable[fnId] = SVar(TFun(argumentsTyped, fn.ret.toType()));
			}

			typed = fn.expr != null ? typeExpr(fn.expr) : TypedExprUtils.makeEmpty();
		});

		var fnType = TFun(argumentsTyped, typed.t); // TODO doing double work? see previous if

		var fnTyped = TFunction({
			args: argumentsVariable,
			expr: typed,
			t: typed.t
		}).makeTyped(position, fnType);

		if (name != null)
		{
			symbolTable[fnId] = SVar(fnType);
			return TVar(TVarUtils.make(fnId, name, fnType), fnTyped).makeTyped(position, fnType);
		}
		else
		{
			return fnTyped;
		}
	}
}
