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
import haxevm.utils.TVarUtils;

using haxevm.utils.SymbolUtils;
using haxevm.utils.TypedExprUtils;

/**
Type a constant.
**/
class ConstExpr
{
	/**
	Type a constant.

	@param constant The constant to type.
	@param position The position of the constant.
	@param module The module the expression is in.
	@param typedClass The class the expression is in.
	@param symbolTable The compilation symbol table.
	@param typeExpr The expression typing function, should be `ExprTyper.typeExpr`.
	**/
	public static function type(constant:Constant, position:BasePosition, module:Module, typedClass:ClassType, symbolTable:SymbolTable, typeExpr:ExprTyperFn):TypedExpr
	{
		return switch (constant)
		{
			case CFloat(f):
				TConst(TFloat(f)).makeTyped(position, BaseType.tFloat);

			case CIdent("false"):
				TConst(TBool(false)).makeTyped(position, BaseType.tBool);

			case CIdent("null"):
				TConst(TNull).makeTyped(position, Monomorph.make());

			case CIdent("super"):
				TConst(TSuper).makeTyped(position, Monomorph.make());

			case CIdent("this"):
				TConst(TThis).makeTyped(position, symbolTable.getVar(symbolTable.thisID));

			case CIdent("true"):
				TConst(TBool(true)).makeTyped(position, BaseType.tBool);

			case CIdent(ident):
				var sid = symbolTable.getSymbol(ident);
				var symbol = symbolTable[sid];

				switch (symbol)
				{
					case SField(_, from, isStatic):
						if (isStatic)
						{
							typeExpr({ expr: EField({ expr: EConst(CIdent(from.name)), pos: Position.makeEmpty() }, ident), pos: Position.makeEmpty() });
						}
						else
						{
							typeExpr({ expr: EField({ expr: EConst(CIdent("this")), pos: Position.makeEmpty() }, ident), pos: Position.makeEmpty() });
						}

					case SModule(_):
						throw "not implemented";
						/*
						for (type in module.types)
						{
							switch (type)
							{
								case TClassDecl(_.get() => classType):
									if (classType.name == ident)
									{
										return TTypeExpr(type).makeTyped(position, symbol.toType());
									}

								default:
									throw "not implemented";
							}
						}

						throw ErrorMessage.ModuleWithoutMainType(module);
						*/

					case SType(type, from):
						if (from == module)
						{
							// Type is in current module.
							return TTypeExpr(type).makeTyped(position, symbol.toType());
						}

						typeExpr({ expr: EField({ expr: EConst(CIdent(from.name)), pos: Position.makeEmpty() }, ident), pos: Position.makeEmpty() });

					case SVar(type):
						TLocal(TVarUtils.make(sid, ident, type)).makeTyped(position, type);
				}

			case CInt(v):
				var value = switch (Std.parseInt(v))
				{
					case null:
						throw "invalid integer";

					case value:
						value;
				}

				TConst(TInt(value)).makeTyped(position, BaseType.tInt);

			case CRegexp(_, _):
				throw "no regex support";

			case CString(s):
				TConst(TString(s)).makeTyped(position, BaseType.tString);
		}
	}
}
