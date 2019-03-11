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

package haxevm.vm.expr;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxevm.vm.EVal;

using haxevm.utils.EValUtils;
using haxevm.utils.FieldUtils;

/**
Eval operator expressions.
**/
class OperatorExpr
{
	/**
	Eval a binary operator expression.

	@param op The operator.
	@param lhs The left operand.
	@param rhs The right operand.
	@param context The context to use.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function binop(op:Binop, lhs:TypedExpr, rhs:TypedExpr, context:Context, eval:EvalFn):EVal
	{
		// Dispatch to the specific implementation.
		return switch (op)
		{
			case OpMod, OpMult, OpDiv, OpAdd, OpSub:
				binopArithmetic(op, eval(lhs), eval(rhs));

			case OpArrow:
				throw "not supported";

			case OpAssign, OpAssignOp(_):
				binopAssignation(op, lhs, rhs, context, eval);

			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor:
				binopBitwise(op, eval(lhs), eval(rhs));

			case OpBoolAnd, OpBoolOr:
				binopBoolean(op, lhs, rhs, eval);

			case OpEq, OpNotEq, OpLt, OpLte, OpGt, OpGte:
				binopComparison(op, eval(lhs), eval(rhs));

			case OpIn:
				throw "not supported";

			case OpInterval:
				throw "not supported";
		}
	}

	/**
	Eval a binary arithmetic (+ - * /) operator expression.

	@param op The operator.
	@param lhsValue The left operand's value.
	@param rhsValue The right operand's value.
	**/
	static function binopArithmetic(op:Binop, lhsValue:EVal, rhsValue:EVal):EVal
	{
		return switch (op)
		{
			case OpMod, OpMult, OpDiv, OpAdd, OpSub:
				switch ([lhsValue, op, rhsValue])
				{
					case [EString(sa), OpAdd, EString(sb)]:
						return EString(sa + sb);

					default:
						// pass
				}

				var lhsValue = intOrFloat(lhsValue);
				var rhsValue = intOrFloat(rhsValue);

				var isFloat = lhsValue.isFloat || rhsValue.isFloat;

				switch (op)
				{
					case OpAdd:
						if (isFloat)
						{
							EFloat(lhsValue.f + rhsValue.f);
						}
						else
						{
							EInt(lhsValue.i + rhsValue.i);
						}

					case OpDiv:
						EFloat(lhsValue.f / rhsValue.f);

					case OpMod:
						if (isFloat)
						{
							EFloat(lhsValue.f % rhsValue.f);
						}
						else
						{
							EInt(lhsValue.i % rhsValue.i);
						}

					case OpMult:
						if (isFloat)
						{
							EFloat(lhsValue.f * rhsValue.f);
						}
						else
						{
							EInt(lhsValue.i * rhsValue.i);
						}

					case OpSub:
						if (isFloat)
						{
							EFloat(lhsValue.f - rhsValue.f);
						}
						else
						{
							EInt(lhsValue.i - rhsValue.i);
						}

					default:
						throw 'Unexpected operator ${op}';
				}

			default:
				throw "not arithmetic";
		}
	}

	/**
	Eval a binary assignation (= += -= /= *= <<= >>= >>>= |= &= ^= %=) operator expression.

	@param op The operator.
	@param lhs The left operand.
	@param rhs The right operand.
	@param context The context to use.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	static function binopAssignation(op:Binop, lhs:TypedExpr, rhs:TypedExpr, context:Context, eval:EvalFn):EVal
	{
		var rhsValue = eval(rhs);

		return switch (op)
		{
			case OpAssign:
				// TODO check var can hold value?
				switch (lhs.expr)
				{
					case TArray(data, key):
						switch ([eval(data), eval(key)])
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

								values[i] = rhsValue;

							default:
								throw 'Unexpected array access on ${data.t} with type ${key.t}';
						}

					case TField(e, fa):
						e.findField(fa, eval).val = rhsValue;

					case TLocal(v):
						context[v.id] = rhsValue;

					default:
						throw "can only assign to var " + lhs.expr;
				}

			case OpAssignOp(subOp):
				switch (lhs.expr)
				{
					case TArray(data, key):
						switch ([eval(data), eval(key)])
						{
							case [EArray(_, values), EInt(i)]:
								if (i < 0)
								{
									throw 'Negative array index: $i';
								}

								if (i >= values.length)
								{
									binopSub(subOp, ENull, rhsValue, eval);
								}

								values[i] = binopSub(subOp, values[i], rhsValue, eval);

							default:
								throw 'Unexpected array access on ${data.t} with type ${key.t}';
						}

					case TField(e, fa):
						var fieldEVal = e.findField(fa, eval);
						fieldEVal.val = binopSub(subOp, fieldEVal.val, rhsValue, eval);

					case TLocal(v):
						context[v.id] = switch (context[v.id])
						{
							case null:
								throw "var isn't in context";

							case value:
								binopSub(subOp, value, rhsValue, eval);
						}

					default:
						throw "can only assign to var " + lhs.expr;
				}

			default:
				throw "not assign";
		}
	}

	/**
	Eval a binary bitwise (<< >> >>> & | ^) operator expression.

	@param op The operator.
	@param lhsValue The left operand's value.
	@param rhsValue The right operand's value.
	**/
	static function binopBitwise(op:Binop, lhsValue:EVal, rhsValue:EVal):EVal
	{
		return switch (op)
		{
			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor:
				switch ([lhsValue, rhsValue])
				{
					case [EInt(i), EInt(j)]:
						switch (op)
						{
							case OpAnd:
								EInt(i & j);

							case OpOr:
								EInt(i | j);

							case OpShl:
								EInt(i << j);

							case OpShr:
								EInt(i >> j);

							case OpUShr:
								EInt(i >>> j);

							case OpXor:
								EInt(i ^ j);

							default:
								throw 'Unexpected operator ${op}';
						}

					default:
						throw 'Bitwise operations are only between EInt, not ${lhsValue} and ${rhsValue}';
				}

			default:
				throw "not bitwise";
		}
	}

	/**
	Eval a binary boolean (&& ||) operator expression.

	@param op The operator.
	@param lhs The left operand.
	@param rhs The right operand.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	static function binopBoolean(op:Binop, lhs:TypedExpr, rhs:TypedExpr, eval:EvalFn):EVal
	{
		function getBool(v:TypedExpr):Bool
		{
			var val = eval(v);

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
				EBool(getBool(lhs) && getBool(rhs));

			case OpBoolOr:
				EBool(getBool(lhs) || getBool(rhs));

			default:
				throw 'Unexpected operator ${op}';
		}
	}

	/**
	Eval a binary comparison (+ - * /) operator expression.

	@param op The operator.
	@param lhsValue The left operand's value.
	@param rhsValue The right operand's value.
	**/
	static function binopComparison(op:Binop, lhsValue:EVal, rhsValue:EVal):EVal
	{
		return switch (op)
		{
			case OpEq, OpNotEq:
				switch ([lhsValue, rhsValue])
				{
					case [EFloat(i), EInt(j)]:
						EBool(op == OpEq ? i == j : i != j);

					case [EInt(i), EFloat(j)]:
						EBool(op == OpEq ? i == j : i != j);

					default:
						if (lhsValue.isSameType(rhsValue))
						{
							var eq = lhsValue.equals(rhsValue);
							EBool(op == OpEq ? eq : !eq);
						}
						else
						{
							throw '${lhsValue} and ${rhsValue} cannot be compared';
						}
				}

			case OpLt, OpLte, OpGt, OpGte:
				var i = intOrFloat(lhsValue);
				var j = intOrFloat(rhsValue);

				switch (op)
				{
					case OpGt:
						EBool((i.isFloat ? i.f : i.i) > (j.isFloat ? j.f : j.i));

					case OpGte:
						EBool((i.isFloat ? i.f : i.i) >= (j.isFloat ? j.f : j.i));

					case OpLt:
						EBool((i.isFloat ? i.f : i.i) < (j.isFloat ? j.f : j.i));

					case OpLte:
						EBool((i.isFloat ? i.f : i.i) <= (j.isFloat ? j.f : j.i));

					default:
						throw 'unexpected operator ${op}';
				}

			default:
				throw "not comparison";
		}
	}

	/**
	Eval a sub binary operator expressio, after an assign.

	@param op The operator.
	@param lhsValue The left operand's value.
	@param rhsValue The right operand's value.
	**/
	static function binopSub(op:Binop, lhsValue:EVal, rhsValue:EVal, eval:EvalFn):EVal
	{
		return switch (op)
		{
			case OpMod, OpMult, OpDiv, OpAdd, OpSub:
				binopArithmetic(op, lhsValue, rhsValue);

			case OpShl, OpShr, OpUShr, OpAnd, OpOr, OpXor:
				binopBitwise(op, lhsValue, rhsValue);

			case OpEq, OpNotEq, OpLt, OpLte, OpGt, OpGte:
				binopComparison(op, lhsValue, rhsValue);

			default:
				throw "not supported";
		}
	}

	/**
	Extract either an EInt or an EFloat, with a marker.

	@param val The value.
	**/
	static function intOrFloat(val:EVal):{ i:Int, f:Float, isFloat:Bool }
	{
		return switch (val)
		{
			case EFloat(f):
				{
					i: 0,
					f: f,
					isFloat: true
				}

			case EInt(i):
				{
					i: i,
					f: i,
					isFloat: false
				}

			default:
				throw 'expected EInt or EFloat, got ${val}';
		}
	}

	/**
	Eval an unary operator expression.

	@param op The operator.
	@param postFix If the operator is postfix.
	@param expr The operand.
	@param context The context to use.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function unop(op:Unop, postFix:Bool, expr:TypedExpr, context:Context, eval:EvalFn):EVal
	{
		return switch (op)
		{
			case OpDecrement, OpIncrement:
				function update(before:EVal):EVal
				{
					return switch (before)
					{
						case EInt(i):
							op.match(OpDecrement) ? EVal.EInt(i - 1) : EVal.EInt(i + 1);

						default:
							throw "unexpected type, want EInt, got " + before;
					}
				}

				switch (expr.expr)
				{
					case TConst(_):
						throw "requires a variable";

					case TField(expr, fieldAccess):
						var fieldEVal = expr.findField(fieldAccess, eval);
						var before = fieldEVal.val;
						var after = update(fieldEVal.val);
						fieldEVal.val = after;
						postFix ? before : after;

					case TLocal(v):
						var before = context[v.id];
						var after = update(before);
						context[v.id] = after;
						postFix ? before : after;

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

				switch (expr.expr)
				{
					case TConst(TInt(i)):
						EInt(-i);

					case TLocal(v):
						update(context[v.id]);

					case TField(expr, fieldAccess):
						update(expr.findField(fieldAccess, eval).val);

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

				switch (expr.expr)
				{
					case TConst(TInt(i)):
						EInt(~i);

					case TField(expr, fieldAccess):
						update(expr.findField(fieldAccess, eval).val);

					case TLocal(v):
						update(context[v.id]);

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

				switch (expr.expr)
				{
					case TConst(TBool(b)):
						EBool(!b);

					case TField(expr, fieldAccess):
						update(expr.findField(fieldAccess, eval).val);

					case TLocal(v):
						update(context[v.id]);

					default:
						throw "not implemented";
				}
		}
	}
}
