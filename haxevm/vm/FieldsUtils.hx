package haxevm.vm;

import haxe.macro.Type.FieldAccess;
import haxe.macro.Type.TypedExpr;

private typedef EvalFn = TypedExpr->Context->EVal;

class FieldsUtils
{
	public static function findField(parent:TypedExpr, fa:FieldAccess, eval:EvalFn, context:Context):{ name:String, val:EVal }
	{
		var parent = eval(parent, context);
		var name = FieldAccessUtils.nameOf(fa);

		function findField(fields:Array<{ name:String, val:EVal }>):{ name:String, val:EVal }
		{
			for (f in fields)
			{
				if (f.name == name)
				{
					return f;
				}
			}

			throw 'Field ${name} not found';
		}

		return switch (parent)
		{
			case EObject(fields):
				findField(fields);

			case EType(_, staticFields):
				findField(staticFields);

			default:
				throw 'Field access unsuported "$parent"';
		}
	}
}
