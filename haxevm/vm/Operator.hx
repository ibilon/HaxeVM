package haxevm.vm;

import haxe.macro.Expr;
import haxe.macro.Type;

typedef EvalFn = TypedExpr->Map<Int, EVal>->EVal;

class Operator
{
	public static function binop(op:Binop, a:TypedExpr, b:TypedExpr, context:Map<Int, EVal>, eval:EvalFn) : EVal
	{
		return switch (op)
		{
			case OpMod, OpMult, OpDiv, OpAdd, OpSub: binopArithmetic(op, a, b, context, eval);
			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor: binopBitwise(op, a, b, context, eval);
			case OpEq, OpNotEq, OpLt, OpLte, OpGt, OpGte: binopCompare(op, a, b, context, eval);
			case OpBoolAnd, OpBoolOr: binopBoolean(op, a, b, context, eval);
			case OpAssign, OpAssignOp(_): binopAssign(op, a, b, context, eval);
			case OpArrow, OpIn, OpInterval: throw "not supported";
		}
	}

	static function loadNumeric(v:EVal)
	{
		var out = { f: null, i: null, isInt: false };

		switch (v)
		{
			case EFloat(f):
				out.f = f;

			case EInt(i):
				out.f = out.i = i;
				out.isInt = true;

			default:
		}

		return out;
	}

	public static function binopArithmetic(op:Binop, a:TypedExpr, b:TypedExpr, context:Map<Int, EVal>, eval:EvalFn) : EVal
	{
		var v1 = loadNumeric(eval(a, context));
		var v2 = loadNumeric(eval(b, context));

		return switch (op)
		{
			case OpMod:
				if (!v1.isInt || !v2.isInt)
				{
					EFloat(v1.f % v2.f);
				}
				else
				{
					EInt(v1.i % v2.i);
				}

			case OpMult:
				if (!v1.isInt || !v2.isInt)
				{
					EFloat(v1.f * v2.f);
				}
				else
				{
					EInt(v1.i * v2.i);
				}

			case OpDiv:
				return EFloat(v1.f / v2.f);

			case OpAdd:
				if (!v1.isInt || !v2.isInt)
				{
					EFloat(v1.f + v2.f);
				}
				else
				{
					EInt(v1.i + v2.i);
				}

			case OpSub:
				if (!v1.isInt || !v2.isInt)
				{
					EFloat(v1.f - v2.f);
				}
				else
				{
					EInt(v1.i - v2.i);
				}

			default:
				throw "not arithmetic";
		}
	}

	public static function binopBitwise(op:Binop, a:TypedExpr, b:TypedExpr, context:Map<Int, EVal>, eval:EvalFn) : EVal
	{
		var v1 = switch (eval(a, context))
		{
			case EInt(i): i;
			default: throw "unexpected type";
		}

		var v2 = switch (eval(b, context))
		{
			case EInt(i): i;
			default: throw "unexpected type";
		}

		return switch (op)
		{
			case OpShl:
				EInt(v1 << v2);

			case OpShr:
				EInt(v1 >> v2);

			case OpUShr:
				EInt(v1 >>> v2);

			case OpAnd:
				EInt(v1 & v2);

			case OpOr:
				EInt(v1 | v2);

			case OpXor:
				EInt(v1 ^ v2);

			default:
				throw "not bitwise";
		}
	}

	public static function binopCompare(op:Binop, a:TypedExpr, b:TypedExpr, context:Map<Int, EVal>, eval:EvalFn) : EVal
	{
		var e1 = eval(a, context);
		var e2 = eval(b, context);

		var v1 = loadNumeric(e1);
		var v2 = loadNumeric(e2);

		return switch (op)
		{
			case OpEq:
				EBool(e1.equals(e2));

			case OpNotEq:
				EBool(!e1.equals(e2));

			case OpLt:
				EBool((v1.isInt ? v1.i : v1.f) < (v2.isInt ? v2.i : v2.f));

			case OpLte:
				EBool((v1.isInt ? v1.i : v1.f) <= (v2.isInt ? v2.i : v2.f));

			case OpGt:
				EBool((v1.isInt ? v1.i : v1.f) > (v2.isInt ? v2.i : v2.f));

			case OpGte:
				EBool((v1.isInt ? v1.i : v1.f) >= (v2.isInt ? v2.i : v2.f));

			default:
				throw "not compare";
		}
	}

	public static function binopBoolean(op:Binop, a:TypedExpr, b:TypedExpr, context:Map<Int, EVal>, eval:EvalFn) : EVal
	{
		var v1 = switch (eval(a, context))
		{
			case EBool(b): b;
			default: throw "unexpected value";
		}

		function evalV2()
		{
			return switch (eval(b, context))
			{
				case EBool(b): b;
				default: throw "unexpected value";
			}
		}

		return switch (op)
		{
			case OpBoolAnd:
				return EBool(v1 && evalV2());

			case OpBoolOr:
				return EBool(v1 || evalV2());

			default:
				throw "not boolean";
		}
	}

	public static function binopAssign(op:Binop, a:TypedExpr, b:TypedExpr, context:Map<Int, EVal>, eval:EvalFn) : EVal
	{
		var v2 = eval(b, context);

		return switch (op)
		{
			case OpAssign:
				//TODO check var can hold value?
				switch (a.expr)
				{
					//TODO make it work on field access
					case TLocal(v):
						context[v.id] = v2;

					default:
						throw "can only assign to var " + a.expr;
				}

			case OpAssignOp(subOp):
				throw "not supported";

			default:
				throw "not assign";
		}
	}

	public static function unop(op:Unop, postFix:Bool, e:TypedExpr, context:Map<Int, EVal>) : EVal
	{
		return switch (op)
		{
			case OpDecrement, OpIncrement:
				switch (e.expr)
				{
					case TConst(_):
						throw "requires a variable";

					case TLocal(v):
						var val = context[v.id];

						switch (val)
						{
							case EInt(i):
								var before = context[v.id];
								context[v.id] = op.match(OpDecrement) ? EVal.EInt(i - 1) : EVal.EInt(i + 1);
								postFix ? before : context[v.id];

							default:
								throw "unexpected type, want EInt, got " + val;
						}

					default:
						throw "not implemented";
				}

			case OpNeg:
				switch (e.expr)
				{
					case TConst(TInt(i)):
						EInt(-i);

					case TLocal(v):
						var val = context[v.id];

						switch (val)
						{
							case EInt(i):
								context[v.id] = EVal.EInt(-i);
								context[v.id];

							default:
								throw "unexpected type, want EInt, got " + val;
						}

					default:
						throw "not implemented";
				}

			case OpNegBits:
				switch (e.expr)
				{
					case TConst(TInt(i)):
						EInt(~i);

					case TLocal(v):
						var val = context[v.id];

						switch (val)
						{
							case EInt(i):
								context[v.id] = EVal.EInt(~i);
								context[v.id];

							default:
								throw "unexpected type, want EInt, got " + val;
						}

					default:
						throw "not implemented";
				}

			case OpNot:
				switch(e.expr)
				{
					case TConst(TBool(b)):
						EBool(!b);

					case TLocal(v):
						var val = context[v.id];

						switch (val)
						{
							case EBool(b):
								context[v.id] = EVal.EBool(!b);
								context[v.id];

							default:
								throw "unexpected type, want EBool, got " + val;
						}

					default:
						throw "not implemented";
				}
		}
	}
}
