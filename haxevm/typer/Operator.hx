package haxevm.typer;

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
		if (!haxevm.typer.BaseType.isNumeric(a) || !haxevm.typer.BaseType.isNumeric(b))
		{
			throw 'cannot apply operator $op to type $a and $b';
		}

		return switch (op)
		{
			case OpMod, OpMult, OpAdd, OpSub:
				if (haxevm.typer.BaseType.isFloat(a) || haxevm.typer.BaseType.isFloat(b))
				{
					haxevm.typer.BaseType.Float;
				}
				else
				{
					haxevm.typer.BaseType.Int;
				}

			case OpDiv: haxevm.typer.BaseType.Float;

			default: throw "not arithmetic";
		}
	}

	public static function binopBitwise(op:Binop, a:Type, b:Type) : Type
	{
		return switch (op)
		{
			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor:
				if (!haxevm.typer.BaseType.isInt(a))
				{
					throw '$a should be Int';
				}

				if (!haxevm.typer.BaseType.isInt(b))
				{
					throw '$b should be Int';
				}

				haxevm.typer.BaseType.Int;

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
					haxevm.typer.BaseType.Bool;
				}
				else
				{
					throw 'cannot compare $a and $b';
				}

			case OpLt, OpLte, OpGt, OpGte:
				if (haxevm.typer.BaseType.isNumeric(a) && haxevm.typer.BaseType.isNumeric(b))
				{
					haxevm.typer.BaseType.Bool;
				}
				else
				{
					throw 'cannot compare $a and $b';
				}

			case OpBoolAnd, OpBoolOr:
				if (!haxevm.typer.BaseType.isBool(a))
				{
					throw '$a should be Bool';
				}

				if (!haxevm.typer.BaseType.isBool(b))
				{
					throw '$b should be Bool';
				}

				haxevm.typer.BaseType.Bool;

			default: throw "not boolean";
		}
	}

	public static function unop(op:Unop, a:Type) : Type
	{
		switch (op)
		{
			case OpDecrement, OpIncrement, OpNeg:
				if (!haxevm.typer.BaseType.isNumeric(a))
				{
					throw 'type $a doesn\'t have operator $op';
				}

			case OpNegBits:
				if (!haxevm.typer.BaseType.isInt(a))
				{
					throw '$a should be Int';
				}

			case OpNot:
				if (!haxevm.typer.BaseType.isBool(a))
				{
					throw '$a should be Bool';
				}
		}

		return a;
	}
}
