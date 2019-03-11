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

package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxevm.typer.BaseType;
import haxevm.typer.expr.ArrayExpr;
import haxevm.typer.expr.ConstExpr;
import haxevm.typer.expr.FieldExpr;
import haxevm.typer.expr.ForExpr;
import haxevm.typer.expr.FunctionExpr;
import haxevm.typer.expr.IfExpr;
import haxevm.typer.expr.ObjectExpr;
import haxevm.typer.expr.OperatorExpr;
import haxevm.typer.expr.SwitchExpr;
import haxevm.typer.expr.TryExpr;
import haxevm.typer.expr.VarExpr;
import haxevm.typer.expr.WhileExpr;

using haxevm.utils.ArrayUtils;
using haxevm.utils.ComplexTypeUtils;
using haxevm.utils.PositionUtils;
using haxevm.utils.TypedExprUtils;
using haxevm.utils.TypeUtils;

/**
The type of an expression typing function.
**/
typedef ExprTyperFn = (parentExpr:Expr)->TypedExpr;

/**
Do expression typing.
**/
class ExprTyper
{
	/**
	Link to the compiler doing the compilation.
	**/
	var compiler:Compiler;

	/**
	The expression to type.
	**/
	var expr:Null<Expr>;

	/**
	The module this expression is part of.
	**/
	var module:Module;

	/**
	The class this expression is part of.
	**/
	var typedClass:ClassType;

	/**
	Construct an expr typer.

	@param compiler
	@param module
	@param typedClass
	@param expr
	**/
	public function new(compiler:Compiler, module:Module, typedClass:ClassType, expr:Null<Expr>)
	{
		this.compiler = compiler;
		this.expr = expr;
		this.module = module;
		this.typedClass = typedClass;
	}

	/**
	Type the expression.
	**/
	public function type():TypedExpr
	{
		if (expr != null)
		{
			return typeExpr(expr);
		}
		else
		{
			return TypedExprUtils.makeEmpty();
		}
	}

	/**
	Type an expression.

	@param parentExpr The expression to type.
	**/
	function typeExpr(parentExpr:Expr):TypedExpr
	{
		return switch (parentExpr.expr)
		{
			case EArray(array, key):
				ArrayExpr.typeAccess(array, key, parentExpr.pos, typeExpr);

			case EArrayDecl(values):
				ArrayExpr.typeDeclaration(values, parentExpr.pos, typeExpr);

			case EBinop(op, lhs, rhs):
				var lhs = typeExpr(lhs);
				var rhs = typeExpr(rhs);

				TBinop(op, lhs, rhs).makeTyped(parentExpr.pos, OperatorExpr.binop(op, lhs.t, rhs.t));

			case EBlock(exprs):
				var elems:Array<TypedExpr>;

				compiler.symbolTable.stack(() ->
				{
					elems = exprs.map(e -> typeExpr(e));
				});

				TBlock(elems).makeTyped(expr.pos, elems.length > 0 ? elems.last().t : BaseType.tVoid);

			case EBreak:
				TBreak.makeTyped(parentExpr.pos, BaseType.tVoid);

			case ECall(_ => { expr: EConst(CIdent("$type")) }, params) if (params.length == 1):
				var typed = typeExpr(params[0]);
				compiler.warnings.push('${params[0].pos.toString(module, true)} Warning : ${typed.t.prettyName()}');
				typed;

			case ECall(expr, params):
				FunctionExpr.typeCall(expr, params, parentExpr.pos, module, typeExpr);

			case ECast(expr, _):
				TCast(typeExpr(expr), null).makeTyped(parentExpr.pos, Monomorph.make());

			case ECheckType(expr, type):
				TParenthesis(typeExpr(expr)).makeTyped(parentExpr.pos, type.toType());

			case EConst(constant):
				ConstExpr.type(constant, parentExpr.pos, module, typedClass, compiler.symbolTable, typeExpr);

			case EContinue:
				TContinue.makeTyped(parentExpr.pos, BaseType.tVoid);

			case EDisplay(_, _), EDisplayNew(_):
				throw "cannot get display info";

			case EField(expr, field):
				FieldExpr.type(expr, field, parentExpr.pos, typeExpr);

			case EFor(iterator, expr):
				ForExpr.type(iterator, expr, parentExpr.pos, compiler.symbolTable, typeExpr);

			case EFunction(name, fn):
				FunctionExpr.typeDeclaration(name, fn, parentExpr.pos, compiler.symbolTable, typeExpr);

			case EIf(conditionExpr, ifExpr, elseExpr):
				IfExpr.type(conditionExpr, ifExpr, elseExpr, parentExpr.pos, compiler.symbolTable, typeExpr);

			case EMeta(meta, expr):
				var typed = typeExpr(expr);

				TMeta(meta, typed).makeTyped(parentExpr.pos, typed.t);

			case ENew(_, _):
				throw "no class support";

			case EObjectDecl(fields):
				ObjectExpr.type(fields, parentExpr.pos, typeExpr);

			case EParenthesis(expr):
				var typed;

				compiler.symbolTable.stack(() ->
				{
					typed = typeExpr(expr);
				});

				TParenthesis(typed).makeTyped(parentExpr.pos, typed.t);

			case EReturn(expr):
				var typed = expr != null ? typeExpr(expr) : null;

				TReturn(typed).makeTyped(parentExpr.pos, typed != null ? typed.t : BaseType.tVoid);

			case ESwitch(expr, cases, defaultExpr):
				SwitchExpr.type(expr, cases, defaultExpr, parentExpr.pos, typeExpr);

			case ETernary(conditionExpr, ifExpr, elseExpr):
				IfExpr.type(conditionExpr, ifExpr, elseExpr, parentExpr.pos, compiler.symbolTable, typeExpr);

			case EThrow(expr):
				TThrow(typeExpr(expr)).makeTyped(parentExpr.pos, BaseType.tVoid);

			case ETry(expr, catches):
				TryExpr.type(expr, catches, parentExpr.pos, compiler.symbolTable, typeExpr);

			case EUnop(op, postFix, expr):
				var typed = typeExpr(expr);

				TUnop(op, postFix, typed).makeTyped(parentExpr.pos, OperatorExpr.unop(op, typed.t));

			case EUntyped(_):
				throw "Untyped is not supported";

			case EVars(vars):
				VarExpr.type(vars, parentExpr.pos, compiler.symbolTable, typeExpr);

			case EWhile(conditionExpr, expr, normalWhile):
				WhileExpr.type(conditionExpr, expr, normalWhile, parentExpr.pos, compiler.symbolTable, typeExpr);
		}
	}
}
