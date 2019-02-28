package vm;

import haxe.macro.Type;

class EValTools
{
	public static function isSameType(a:EVal, b:EVal)
	{
		return switch([a, b])
		{
			case [EBool(_), EBool(_)]: true;
			case [EInt(_), EInt(_)]: true;
			case [EFloat(_), EFloat(_)]: true;
			case [EString(_), EString(_)]: true;
			case [ERegexp(_), ERegexp(_)]: true;
			case [EVoid, EVoid]: true;
			case [ENull, ENull]: true;
			case [EArray(of1, _), EArray(of2, _)]: of1 == of2;
			case [EObject(fields1), EObject(fields2)]: false; //TODO compare fields
			case [EFn(fn1), EFn(fn2)]: fn1 == fn2;
			case [EIdent(id1), EIdent(id2)]: id1 == id2;
			default: false;
		}
	}

	public static function extractType(t:Type) : EVal
	{
		return switch (t)
		{
			case TAbstract(_.get() => t, _):
				switch ([t.pack, t.module, t.name])
				{
					case [[], "StdTypes", "Int"]: EInt(0);
					case [[], "StdTypes", "Float"]: EFloat(0);
					case [[], "StdTypes", "Bool"]: EBool(false);
					default: throw "unknown type";
				}

			case TInst(_.get() => t, _):
				switch ([t.pack, t.module, t.name])
				{
					case [[], "String", "String"]: EString("");
					default: throw "unknown type";
				}

			default:
				throw "unknown type";
		}
	}
}
