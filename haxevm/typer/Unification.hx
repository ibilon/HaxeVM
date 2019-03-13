package haxevm.typer;

import haxe.macro.Type;
import haxevm.typer.BaseType;

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

		if (a == b)
		{
			result.type = a;
		}
		else if ((BaseType.isInt(a) && BaseType.isFloat(b)) || (BaseType.isFloat(a) && BaseType.isInt(b)))
		{
			result.type = BaseType.tFloat;
		}
		else if (a.match(TMono(_))) // TODO fix mono update
		{
			result.type = a = b;
		}
		else if (b.match(TMono(_)))
		{
			result.type = b = a;
		}
		else if (BaseType.isVoid(a) || BaseType.isVoid(b))
		{
			result.success = false;
		}
		else
		{
			throw 'not implemented for ${a.prettyName()} and ${b.prettyName()}';
		}

		if (fail && !result.success)
		{
			throw '${b.prettyName()} should be ${a.prettyName()}';
		}

		return result;
	}
}
