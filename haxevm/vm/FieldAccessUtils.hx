package haxevm.vm;

import haxe.macro.Type.FieldAccess;

class FieldAccessUtils
{
	public static function nameOf(fa:FieldAccess):String
	{
		return switch (fa)
		{
			case FInstance(_, _, _.get() => cf), FStatic(_, _.get() => cf), FAnon(_.get() => cf), FClosure(_, _.get() => cf):
				cf.name;

			case FDynamic(s):
				s;

			case FEnum(_, ef):
				ef.name;
		}
	}
}
