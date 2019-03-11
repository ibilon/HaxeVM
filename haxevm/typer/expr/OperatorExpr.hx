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

/**
Do operator expressions typing.
**/
class OperatorExpr
{
	/**
	Type a binary operator.

	@param op The operator.
	@param lhs The left operand.
	@param rhs The right operand.
	**/
	public static function binop(op:Binop, lhs:Type, rhs:Type):Type
	{
		// Dispatch to the specific implementation.
		return switch (op)
		{
			case OpMod, OpMult, OpDiv, OpAdd, OpSub:
				binopArithmetic(op, lhs, rhs);

			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor:
				binopBitwise(op, lhs, rhs);

			case OpEq, OpNotEq, OpLt, OpLte, OpGt, OpGte, OpBoolAnd, OpBoolOr:
				binopBoolean(op, lhs, rhs);

			case OpAssign:
				lhs; // TODO check b unify with a

			case OpAssignOp(op):
				binop(op, lhs, rhs);

			case OpArrow, OpIn, OpInterval:
				throw "not supported";
		}
	}

	/**
	Type an arithmetic (+ - * /) binary operator.

	@param op The operator.
	@param lhs The left operand.
	@param rhs The right operand.
	**/
	static function binopArithmetic(op:Binop, lhs:Type, rhs:Type):Type
	{
		// String
		if (BaseType.isString(lhs) && BaseType.isString(rhs))
		{
			return switch (op)
			{
				case OpAdd:
					BaseType.tString;

				default:
					throw "cannot apply operator $op to strings";
			}
		}

		// Int and Float
		if (!BaseType.isNumeric(lhs) || !BaseType.isNumeric(rhs))
		{
			throw 'cannot apply operator $op to type $lhs and $rhs';
		}

		return switch (op)
		{
			case OpMod, OpMult, OpAdd, OpSub:
				if (BaseType.isFloat(lhs) || BaseType.isFloat(rhs))
				{
					BaseType.tFloat;
				}
				else
				{
					BaseType.tInt;
				}

			case OpDiv:
				BaseType.tFloat;

			default:
				throw "not arithmetic";
		}
	}

	/**
	Type a bitwise (<< >> >>> & | ^) binary operator.

	@param op The operator.
	@param lhs The left operand.
	@param rhs The right operand.
	**/
	static function binopBitwise(op:Binop, lhs:Type, rhs:Type):Type
	{
		return switch (op)
		{
			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor:
				if (!BaseType.isInt(lhs))
				{
					throw '$lhs should be Int';
				}

				if (!BaseType.isInt(rhs))
				{
					throw '$rhs should be Int';
				}

				BaseType.tInt;

			default:
				throw "not bitwise";
		}
	}

	/**
	Type an boolean (== != < <= > >= && ||) binary operator.

	@param op The operator.
	@param lhs The left operand.
	@param rhs The right operand.
	**/
	static function binopBoolean(op:Binop, lhs:Type, rhs:Type):Type
	{
		return switch (op)
		{
			case OpEq, OpNotEq:
				if (lhs == rhs || (BaseType.isNumeric(lhs) && BaseType.isNumeric(rhs)))
				{
					BaseType.tBool;
				}
				else
				{
					throw 'cannot compare $lhs and $rhs';
				}

			case OpLt, OpLte, OpGt, OpGte:
				if (BaseType.isNumeric(lhs) && BaseType.isNumeric(rhs))
				{
					BaseType.tBool;
				}
				else
				{
					throw 'cannot compare $lhs and $rhs';
				}

			case OpBoolAnd, OpBoolOr:
				if (!BaseType.isBool(lhs))
				{
					throw '$lhs should be Bool';
				}

				if (!BaseType.isBool(rhs))
				{
					throw '$rhs should be Bool';
				}

				BaseType.tBool;

			default:
				throw "not boolean";
		}
	}

	/**
	Type an unary operator.

	@param op The operator.
	@param expr The operand.
	**/
	public static function unop(op:Unop, expr:Type):Type
	{
		switch (op)
		{
			case OpDecrement, OpIncrement, OpNeg:
				if (!BaseType.isNumeric(expr))
				{
					throw 'type $expr doesn\'t have operator $op';
				}

			case OpNegBits:
				if (!BaseType.isInt(expr))
				{
					throw '$expr should be Int';
				}

			case OpNot:
				if (!BaseType.isBool(expr))
				{
					throw '$expr should be Bool';
				}
		}

		return expr;
	}
}
