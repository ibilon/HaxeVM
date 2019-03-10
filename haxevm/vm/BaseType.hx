package haxevm.vm;

import haxe.macro.Type.Type;
import haxevm.typer.BaseType as TyperBaseType;

class BaseType
{
	public static function defaultValue(type:Type):EVal
	{
		return if (TyperBaseType.isInt(type))
		{
			EInt(0);
		}
		else if (TyperBaseType.isFloat(type))
		{
			EFloat(0);
		}
		else if (TyperBaseType.isString(type))
		{
			EString("");
		}
		else
		{
			throw "type not supported";
		}
	}
}
