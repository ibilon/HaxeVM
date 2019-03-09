package haxevm.typer;

import haxe.macro.Type.Type;
import haxe.macro.Expr.ComplexType;

class ComplexTypeUtils
{
	public static function convertComplexType(t:Null<ComplexType>):Type
	{
		if (t == null)
		{
			return TMono(RefImpl.make(null));
		}

		return switch (t)
		{
			case TPath(p): // TODO convert TPath to Type
				switch (p.name)
				{
					case "Int":
						BaseType.tInt;

					case "Bool":
						BaseType.tBool;

					case "Float":
						BaseType.tFloat;

					case "String":
						BaseType.tString;

					default: throw "unknown type";
				}

			default: // TODO TAnonymous | TExtend | TFunction | TIntersection | TNamed | TOptional | TParent
				TMono(RefImpl.make(null));
		}
	}
}
