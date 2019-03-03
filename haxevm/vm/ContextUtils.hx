package haxevm.vm;

import haxe.macro.Type.FieldAccess;
import haxe.macro.Type.TypedExpr;

typedef Context = Map<Int, EVal>;

class ContextUtils
{
	public static function findEVal(context:Context, te:TypedExpr):EVal
	{
		switch (te.expr)
		{
			case TLocal(v):
				return context[v.id];

			case TParenthesis(e):
				return findEVal(context, e);

			case TField(e, fa):
				var parent = findEVal(context, e);

				switch (parent)
				{
					case EObject(fields):
						var name = nameOf(fa);

						for (f in fields)
						{
							if (f.name == name)
							{
								return f.val;
							}
						}

						throw 'Field ${name} not found';

					default:
						throw 'Field access on non object "${e.t}"';
				}

			default:
				throw '${te} is not stored in the context';
		}
	}

	public static function findFieldEVal(context:Context, parent:TypedExpr, fa:FieldAccess):{ name:String, val:EVal }
	{
		switch (findEVal(context, parent))
		{
			case EObject(fields):
				var name = nameOf(fa);

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

	static function nameOf (fa:FieldAccess) : String
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
