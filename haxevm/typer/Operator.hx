package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type.Type;

class Operator
{
	public static function binop(op:Binop, a:Type, b:Type):Type
	{
		return switch (op)
		{
			case OpMod, OpMult, OpDiv, OpAdd, OpSub:
				binopArithmetic(op, a, b);

			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor:
				binopBitwise(op, a, b);

			case OpEq, OpNotEq, OpLt, OpLte, OpGt, OpGte, OpBoolAnd, OpBoolOr:
				binopBoolean(op, a, b);

			case OpAssign:
				a; // TODO check b unify with a

			case OpAssignOp(op):
				binop(op, a, b);

			case OpArrow, OpIn, OpInterval:
				throw "not supported";
		}
	}

	public static function binopArithmetic(op:Binop, a:Type, b:Type):Type
	{
		if (!BaseType.isNumeric(a) || !BaseType.isNumeric(b))
		{
			throw 'cannot apply operator $op to type $a and $b';
		}

		return switch (op)
		{
			case OpMod, OpMult, OpAdd, OpSub:
				if (BaseType.isFloat(a) || BaseType.isFloat(b))
				{
					BaseType.Float;
				}
				else
				{
					BaseType.Int;
				}

			case OpDiv:
				BaseType.Float;

			default:
				throw "not arithmetic";
		}
	}

	public static function binopBitwise(op:Binop, a:Type, b:Type):Type
	{
		return switch (op)
		{
			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor:
				if (!BaseType.isInt(a))
				{
					throw '$a should be Int';
				}

				if (!BaseType.isInt(b))
				{
					throw '$b should be Int';
				}

				BaseType.Int;

			default:
				throw "not bitwise";
		}
	}

	public static function binopBoolean(op:Binop, a:Type, b:Type):Type
	{
		return switch (op)
		{
			case OpEq, OpNotEq:
				if (a == b || (BaseType.isNumeric(a) && BaseType.isNumeric(b)))
				{
					BaseType.Bool;
				}
				else
				{
					throw 'cannot compare $a and $b';
				}

			case OpLt, OpLte, OpGt, OpGte:
				if (BaseType.isNumeric(a) && BaseType.isNumeric(b))
				{
					BaseType.Bool;
				}
				else
				{
					throw 'cannot compare $a and $b';
				}

			case OpBoolAnd, OpBoolOr:
				if (!BaseType.isBool(a))
				{
					throw '$a should be Bool';
				}

				if (!BaseType.isBool(b))
				{
					throw '$b should be Bool';
				}

				BaseType.Bool;

			default:
				throw "not boolean";
		}
	}

	public static function unop(op:Unop, a:Type):Type
	{
		switch (op)
		{
			case OpDecrement, OpIncrement, OpNeg:
				if (!BaseType.isNumeric(a))
				{
					throw 'type $a doesn\'t have operator $op';
				}

			case OpNegBits:
				if (!BaseType.isInt(a))
				{
					throw '$a should be Int';
				}

			case OpNot:
				if (!BaseType.isBool(a))
				{
					throw '$a should be Bool';
				}
		}

		return a;
	}
}
