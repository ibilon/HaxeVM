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

package haxevm.utils;

import haxe.macro.Type;
import haxevm.vm.Context;
import haxevm.vm.EVal;
import haxevm.vm.FlowControl;

using haxevm.utils.EValUtils;

/**
Utilities for `EVal`.

To be used with `using EValUtils;`.
**/
class EValUtils
{
	/**
	Check if two EVal values are of the same type.

	@param a The first value.
	@param b The second value.
	**/
	public static function isSameType(a:EVal, b:EVal):Bool
	{
		return switch ([a, b])
		{
			case [EArray(of1, _), EArray(of2, _)]:
				of1 == of2;

			case [EBool(_), EBool(_)]:
				true;

			case [EFloat(_), EFloat(_)]:
				true;

			case [EFunction(fn1), EFunction(fn2)]:
				fn1 == fn2;

			case [EInt(_), EInt(_)]:
				true;

			case [ENull, ENull]:
				true;

			case [EObject(_), EObject(_)]:
				false; // TODO compare fields

			case [EString(_), EString(_)]:
				true;

			case [EVoid, EVoid]:
				true;

			default:
				false;
		}
	}

	/**
	Construct an EFun representing a function.

	@param argumentsId The array of symbol id for the function's arguments.
	@param expression The function's expression.
	@param context The context to use.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function makeEFunction(argumentsId:Array<Int>, expression:TypedExpr, context:Context, eval:EvalFn):EVal
	{
		return EFunction(function(a:Array<EVal>)
		{
			var ret;

			context.stack(() ->
			{
				for (i in 0...argumentsId.length)
				{
					context[argumentsId[i]] = a[i];
				}

				ret = try
				{
					eval(expression);
				}
				catch (fc:FlowControl)
				{
					switch (fc)
					{
						case FCReturn(v):
							v;

						default:
							throw fc;
					}
				}
			});

			return ret;
		});
	}

	/**
	Returns the string representation of an EVal.

	@param value The value.
	@param context The context to use.
	**/
	public static function toString(value:EVal, context:Context):String
	{
		return switch (value)
		{
			case EArray(_, a):
				"[" + a.map(f -> f.toString(context)).join(",") + "]";

			case EBool(b):
				b ? "true" : "false";

			case EFloat(f):
				'$f';

			case EFunction(_):
				'#fun';

			case EInt(i):
				'$i';

			case ENull:
				"null";

			case EObject(fields):
				var buf = new StringBuf();
				buf.add("{");
				var fs = [];

				for (f in fields)
				{
					fs.push('${f.name}: ${f.val.toString(context)}');
				}

				buf.add(fs.join(", "));
				buf.add("}");
				buf.toString();

			case EString(s):
				s;

			case EType(m, _):
				switch (m)
				{
					case TAbstract(_.get() => a):
						a.name;

					case TClassDecl(_.get() => c):
						c.name;

					case TEnumDecl(_.get() => e):
						e.name;

					case TTypeDecl(_.get() => t):
						t.name;
				}

			case EVoid:
				"Void";
		}
	}
}
