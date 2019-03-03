package haxevm.vm;

import haxe.macro.Expr;
import haxe.macro.Type;

typedef Context = Map<Int, EVal>;

typedef EvalFn = TypedExpr->Map<Int, EVal>->EVal;

typedef ValRet =
{
	val:EVal,
	ret:EVal
};

enum OperatorType
{
	Arithmetic;
	Bitwise;
	Comparison;
	Boolean;
	Assignation;
	Arrow;
	In;
	Interval;
}

class Operator
{
	public static function binop(op:Binop, a:TypedExpr, b:TypedExpr, context:Context, eval:EvalFn):EVal
	{
		return switch (typeOf(op))
		{
			case Arithmetic, Bitwise, Comparison:
				doBinop(eval(a, context), op, eval(b, context));

			case Boolean:
				binopBoolean(op, a, b, context, eval);

			case Assignation:
				binopAssign(op, a, b, context, eval);

			case Arrow, In, Interval:
				throw "not supported";
		}
	}

	public static function binopAssign(op:Binop, a:TypedExpr, b:TypedExpr, context:Context, eval:EvalFn):EVal
	{
		var v2 = eval(b, context);

		return switch (op)
		{
			case OpAssign:
				// TODO check var can hold value?
				switch (a.expr)
				{
					case TLocal(v):
						context[v.id] = v2;

					case TField(e, fa):
						var fieldEVal = findField(e, fa, eval, context);
						fieldEVal.val = v2;

					case TArray(data, key):
						var dataEVal = eval(data, context);
						var keyEVal = eval(key, context);

						switch ([dataEVal, keyEVal])
						{
							case [EArray(_, values), EInt(i)]:
								if (i < 0)
								{
									throw 'Negative array index: $i';
								}

								if (i >= values.length)
								{
									for (j in values.length...i)
									{
										values[j] = ENull;
									}
								}

								values[i] = v2;

							default:
								throw 'Unexpected array access on ${data.t} with type ${key.t}';
						}

					default:
						throw "can only assign to var " + a.expr;
				}

			case OpAssignOp(subOp):
				switch (a.expr)
				{
					case TLocal(v):
						context[v.id] = doBinop(context[v.id], subOp, v2);

					case TField(e, fa):
						var fieldEVal = findField(e, fa, eval, context);
						fieldEVal.val = doBinop(fieldEVal.val, subOp, v2);

					case TArray(data, key):
						var dataEVal = eval(data, context);
						var keyEVal = eval(key, context);

						switch ([dataEVal, keyEVal])
						{
							case [EArray(_, values), EInt(i)]:
								if (i < 0)
								{
									throw 'Negative array index: $i';
								}

								if (i >= values.length)
								{
									doBinop(ENull, subOp, v2);
								}

								values[i] = doBinop(values[i], subOp, v2);

							default:
								throw 'Unexpected array access on ${data.t} with type ${key.t}';
						}

					default:
						throw "can only assign to var " + a.expr;
				}

			default:
				throw "not assign";
		}
	}

	public static function binopBoolean(op:Binop, a:TypedExpr, b:TypedExpr, context:Context, eval:EvalFn):EVal
	{
		var a = eval(a, context);
		var a = switch (a)
		{
			case EBool(b):
				b;

			default:
				throw 'expected EBool but got $a';
		}

		function getB():Bool
		{
			var val = eval(b, context);

			return switch (val)
			{
				case EBool(b):
					b;

				default:
					throw 'expected EBool but got $val';
			}
		}

		return switch (op)
		{
			case OpBoolAnd:
				EBool(a && getB());

			case OpBoolOr:
				EBool(a || getB());

			default:
				throw 'Unexpected operator ${op}';
		}
	}

	public static function typeOf(op:Binop) : OperatorType
	{
		return switch (op)
		{
			case OpMod, OpMult, OpDiv, OpAdd, OpSub:
				Arithmetic;

			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor:
				Bitwise;

			case OpEq, OpNotEq, OpLt, OpLte, OpGt, OpGte:
				Comparison;

			case OpBoolAnd, OpBoolOr:
				Boolean;

			case OpAssign, OpAssignOp(_):
				Assignation;

			case OpArrow:
				Arrow;

			case OpIn:
				In;

			case OpInterval:
				Interval;
		}
	}

	public static function unop(op:Unop, postFix:Bool, e:TypedExpr, context:Context, eval:EvalFn):EVal
	{
		return switch (op)
		{
			case OpDecrement, OpIncrement:
				function update(before:EVal):ValRet
				{
					switch (before)
					{
						case EInt(i):
							var after = op.match(OpDecrement) ? EVal.EInt(i - 1) : EVal.EInt(i + 1);
							var ret = postFix ? before : after;

							return {
								ret: ret,
								val: after
							};

						default:
							throw "unexpected type, want EInt, got " + before;
					}
				}

				switch (e.expr)
				{
					case TConst(_):
						throw "requires a variable";

					case TLocal(v):
						var val = context[v.id];
						var result = update(val);
						context[v.id] = result.val;
						result.ret;

					case TField(e, fa):
						var fieldEVal = findField(e, fa, eval, context);
						var result = update(fieldEVal.val);
						fieldEVal.val = result.val;
						result.ret;

					default:
						throw "not implemented";
				}

			case OpNeg:
				function update (before:EVal):EVal
				{
					return switch (before)
					{
						case EInt(i):
							EInt(-i);

						case EFloat(f):
							EFloat(-f);

						default:
							throw "unexpected type, want EInt or EFloat, got " + before;
					}
				}

				switch (e.expr)
				{
					case TConst(TInt(i)):
						EInt(-i);

					case TLocal(v):
						var val = context[v.id];
						update(val);

					case TField(e, fa):
						var fieldEVal = findField(e, fa, eval, context);
						update(fieldEVal.val);

					default:
						throw "not implemented";
				}

			case OpNegBits:
				function update (before:EVal):EVal
				{
					return switch (before)
					{
						case EInt(i):
							EInt(~i);

						default:
							throw "unexpected type, want EInt, got " + before;
					}
				}

				switch (e.expr)
				{
					case TConst(TInt(i)):
						EInt(~i);

					case TLocal(v):
						var val = context[v.id];
						update(val);

					case TField(e, fa):
						var fieldEVal = findField(e, fa, eval, context);
						update(fieldEVal.val);

					default:
						throw "not implemented";
				}

			case OpNot:
				function update(before:EVal):EVal
				{
					return switch (before)
					{
						case EBool(b):
							EBool(!b);

						default:
							throw "unexpected type, want EBool, got " + before;
					}
				}

				switch (e.expr)
				{
					case TConst(TBool(b)):
						EBool(!b);

					case TLocal(v):
						var val = context[v.id];
						update(val);

					case TField(e, fa):
						var fieldEVal = findField(e, fa, eval, context);
						update(fieldEVal.val);

					default:
						throw "not implemented";
				}
		}
	}

	public static function doBinop(a:EVal, op:Binop, b:EVal) : EVal
	{
		return switch (typeOf(op))
		{
			case Arithmetic:
				var i = intOrFloat(a, op);
				var j = intOrFloat(b, op);

				var isFloat = i.isFloat || j.isFloat;

				switch (op)
				{
					case OpMod:
						if (isFloat)
						{
							EFloat(i.f % j.f);
						}
						else
						{
							EInt(i.i % j.i);
						}

					case OpMult:
						if (isFloat)
						{
							EFloat(i.f * j.f);
						}
						else
						{
							EInt(i.i * j.i);
						}

					case OpDiv:
						EFloat(i.f / j.f);

					case OpAdd:
						if (isFloat)
						{
							EFloat(i.f + j.f);
						}
						else
						{
							EInt(i.i + j.i);
						}

					case OpSub:
						if (isFloat)
						{
							EFloat(i.f - j.f);
						}
						else
						{
							EInt(i.i - j.i);
						}

					default:
						throw 'Unexpected operator ${op}';
				}

			case Bitwise:
				switch ([a, b])
				{
					case [EInt(i), EInt(j)]:
						switch (op)
						{
							case OpShl:
								EInt(i << j);

							case OpShr:
								EInt(i >> j);

							case OpUShr:
								EInt(i >>> j);

							case OpAnd:
								EInt(i & j);

							case OpOr:
								EInt(i | j);

							case OpXor:
								EInt(i ^ j);

							default:
								throw 'Unexpected operator ${op}';
						}

					default:
						throw 'Bitwise operations are only between EInt, not ${a} and ${b}';
				}

			case Comparison:
				switch (op)
				{
					case OpEq, OpNotEq:
						switch ([a, b])
						{
							case [EFloat(i), EInt(j)]:
								EBool(op == OpEq ? i == j : i != j);

							case [EInt(i), EFloat(j)]:
								EBool(op == OpEq ? i == j : i != j);

							default:
								if (EValTools.isSameType(a, b))
								{
									var eq = a.equals(b);
									EBool(op == OpEq ? eq : !eq);
								}
								else
								{
									throw '${a} and ${b} cannot be compared';
								}
						}

					case OpLt, OpLte, OpGt, OpGte:
						var i = intOrFloat(a, op);
						var j = intOrFloat(b, op);

						switch (op)
						{
							case OpLt:
								EBool((i.isFloat ? i.f : i.i) < (j.isFloat ? j.f : j.i));

							case OpLte:
								EBool((i.isFloat ? i.f : i.i) <= (j.isFloat ? j.f : j.i));

							case OpGt:
								EBool((i.isFloat ? i.f : i.i) > (j.isFloat ? j.f : j.i));

							case OpGte:
								EBool((i.isFloat ? i.f : i.i) >= (j.isFloat ? j.f : j.i));

							default:
								throw 'unexpected operator ${op}';
						}

					default:
						throw 'Unexpected operator ${op}';
				}

			case Assignation:
				throw "Value cannot be reassigned";

			default:
				throw "not supported";
		}
	}

	static function intOrFloat (val:EVal, op:Binop):{ i:Int, f:Float, isFloat:Bool }
	{
		return switch (val)
		{
			case EInt(i):
				{
					i:i,
					f:i,
					isFloat:false
				};

			case EFloat(f):
				{
					i:0,
					f:f,
					isFloat:true
				};

			default:
				throw 'Operator ${op} expect EInt or EFloat, got ${val}';
		}
	}

	static function findField(parent:TypedExpr, fa:FieldAccess, eval:EvalFn, context:Context):{ name:String, val:EVal }
	{
		switch (eval(parent, context))
		{
			case EObject(fields):
				var name = VM.nameOf(fa);

				for (f in fields)
				{
					if (f.name == name)
					{
						return f;
					}
				}

			default:
		}

		throw 'Field access on non object "${parent.t}"';
	}
}
