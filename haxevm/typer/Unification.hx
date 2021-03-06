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

import haxe.macro.Type;
import haxevm.impl.Ref;
import haxevm.typer.BaseType;
import haxevm.typer.Error;

using haxevm.utils.TypeUtils;

/**
A unification result.
**/
typedef UnificationResult =
{
	/**
	Whether the unification was a success. If false the `type` will be void.
	**/
	var success:Bool;

	/**
	The unified type.
	**/
	var type:Type;
}

/**
Do unification.
**/
class Unification
{
	/**
	Unify two types.

	@param a First type to unify, will be considered the expected type when failling to unify.
	@param b Second type to unify.
	@param fail Whether to throw a unification error when failling to unify.
	**/
	public static function unify(a:Type, b:Type, fail:Bool = false):UnificationResult
	{
		var result = {
			success: true,
			type: BaseType.tVoid
		};

		var a = a.follow();
		var b = b.follow();

		if (a == b)
		{
			result.type = a;
		}
		else if ((BaseType.isInt(a) && BaseType.isFloat(b)) || (BaseType.isFloat(a) && BaseType.isInt(b)))
		{
			result.type = BaseType.tFloat;
		}
		else if (a.match(TMono(_)))
		{
			switch (a)
			{
				case TMono(ref):
					(cast ref : Ref<Type>).set(switch (b)
					{
						case TFun(args, ret):
							TFun(args.map(arg -> { name: "", opt: arg.opt, t: arg.t }), ret);

						default:
							b;
					});

				default:
			}

			result.type = b;
		}
		else if (b.match(TMono(_)))
		{
			switch (b)
			{
				case TMono(ref):
					(cast ref : Ref<Type>).set(a);

				default:
			}

			result.type = a;
		}
		else if (a.match(TFun(_, _)) && b.match(TFun(_, _)))
		{
			switch ([a, b])
			{
				case [TFun(argsA, retA), TFun(argsB, retB)]:
					if (argsA.length != argsB.length)
					{
						fail = true;
					}
					else
					{
						for (i in 0...argsA.length)
						{
							if (argsA[i] != argsB[i])
							{
								fail = true;
								break;
							}
						}

						if (retA != retB)
						{
							fail = true;
						}
					}

				default:
			}
		}
		else if (BaseType.isVoid(a) || BaseType.isVoid(b))
		{
			result.success = false;
		}
		else
		{
			//throw 'not implemented for ${a.prettyName()} and ${b.prettyName()}';
			result.success = false;
		}

		if (fail && !result.success)
		{
			throw ErrorMessage.UnificationError(a, b);
		}

		return result;
	}
}
