package typer;

import haxe.macro.Expr;
import haxe.macro.Type;

class Operator
{
	public static function binop(op:Binop, a:Type, b:Type) : Type
	{
		return switch (op)
		{
			case OpMod, OpMult, OpDiv, OpAdd, OpSub: binopArithmetic(op, a, b);
			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor: binopBitwise(op, a, b);
			case OpEq, OpNotEq, OpLt, OpLte, OpGt, OpGte, OpBoolAnd, OpBoolOr: binopBoolean(op, a, b);
			case OpAssign: a; //TODO check b unify with a
			case OpAssignOp(op): binop(op, a, b);
			case OpArrow, OpIn, OpInterval: throw "not supported";
		}
	}

	public static function binopArithmetic(op:Binop, a:Type, b:Type) : Type
	{
		if (!typer.BaseType.isNumeric(a) || !typer.BaseType.isNumeric(b))
		{
			throw 'cannot apply operator $op to type $a and $b';
		}

		return switch (op)
		{
			case OpMod, OpMult, OpAdd, OpSub:
				if (typer.BaseType.isFloat(a) || typer.BaseType.isFloat(b))
				{
					typer.BaseType.Float;
				}
				else
				{
					typer.BaseType.Int;
				}

			case OpDiv: typer.BaseType.Float;

			default: throw "not arithmetic";
		}
	}

	public static function binopBitwise(op:Binop, a:Type, b:Type) : Type
	{
		return switch (op)
		{
			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor:
				if (!typer.BaseType.isInt(a))
				{
					throw '$a should be Int';
				}

				if (!typer.BaseType.isInt(b))
				{
					throw '$b should be Int';
				}

				typer.BaseType.Int;

			default: throw "not bitwise";
		}
	}

	public static function binopBoolean(op:Binop, a:Type, b:Type) : Type
	{
		return switch (op)
		{
			case OpEq, OpNotEq:
				if (a == b)
				{
					typer.BaseType.Bool;
				}
				else
				{
					throw 'cannot compare $a and $b';
				}

			case OpLt, OpLte, OpGt, OpGte:
				if (typer.BaseType.isNumeric(a) && typer.BaseType.isNumeric(b))
				{
					typer.BaseType.Bool;
				}
				else
				{
					throw 'cannot compare $a and $b';
				}

			case OpBoolAnd, OpBoolOr:
				if (!typer.BaseType.isBool(a))
				{
					throw '$a should be Bool';
				}

				if (!typer.BaseType.isBool(b))
				{
					throw '$b should be Bool';
				}

				typer.BaseType.Bool;

			default: throw "not boolean";
		}
	}

	public static function unop(op:Unop, a:Type) : Type
	{
		switch (op)
		{
			case OpDecrement, OpIncrement, OpNeg:
				if (!typer.BaseType.isNumeric(a))
				{
					throw 'type $a doesn\'t have operator $op';
				}

			case OpNegBits:
				if (!typer.BaseType.isInt(a))
				{
					throw '$a should be Int';
				}

			case OpNot:
				if (!typer.BaseType.isBool(a))
				{
					throw '$a should be Bool';
				}
		}

		return a;
	}
}
