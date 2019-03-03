package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxeparser.Data;

class ClassTyper
{
	public function new()
	{
	}

	public function typeClass(module:String, def:Definition<ClassFlag, Array<Field>>) : ClassType
	{
		var fields : Array<ClassField> = [];
		var statics : Array<ClassField> = [];
		var overrides : Array<ClassField> = [];

		var cls = {
			constructor: null,
			doc: def.doc,
			fields: cast new RefImpl(fields),
			init: null,
			interfaces: [],
			isExtern: false,
			isFinal: false,
			isInterface: false,
			isPrivate: false,
			kind: KNormal,
			meta: cast new MetaAccessImpl(def.meta),
			module: module,
			name: def.name,
			overrides: cast new RefImpl(overrides),
			pack: [],
			params: [], //def.params,
			pos: null,
			statics: cast new RefImpl(statics),
			superClass: null,
			exclude: () -> {}
		};

		for (f in def.flags)
		{
			switch (f)
			{
				case HInterface:
					cls.isInterface = true;

				case HExtern:
					cls.isExtern = true;

				case HPrivate:
					cls.isPrivate = true;

				case HExtends(t):
					throw "not implemented";
					//cls.superClass = { t: new RefImpl(null), params: t.params };

				case HImplements(t):
					throw "not implemented";
					//cls.interfaces.push({ t: new RefImpl(null), params: t.params });
			}
		}

		for (d in def.data)
		{
			var field = {
				doc: d.doc,
				isExtern: false,
				isFinal: false,
				isPublic: false,
				kind: null,
				meta: cast new MetaAccessImpl(d.meta),
				name: d.name,
				overloads: cast new RefImpl([]),
				params: [],
				pos: null,
				type: null,
				expr: null
			};

			switch (d.kind)
			{
				case FFun(f):
					var typed = new haxevm.typer.ExprTyper().typeExpr(f.expr);

					field.type = typed.t;
					field.expr = () -> typed;

				case FProp(get, set, t, e):
					var typed = new haxevm.typer.ExprTyper().typeExpr(e);

					function resolveAccess(a)
					{
						return switch (a)
						{
							case "default": AccNormal;
							case "null": AccNo;
							case "never": AccNever;
							case "get", "set", "dynamic": AccCall;
							case "inline": AccInline;
							default: throw "invalid access";
						}
					}

					field.type = typed.t; //TODO unify typed.t and t
					field.kind = FVar(resolveAccess(get), resolveAccess(set));

				case FVar(t, e):
					var typed = new haxevm.typer.ExprTyper().typeExpr(e);

					field.type = typed.t; //TODO unify typed.t and t
					field.kind = FVar(AccNormal, AccNormal);
			}

			var isStatic = false;
			var isOverride = false;

			for (a in d.access)
			{
				switch (a)
				{
					case APublic:
						field.isPublic = true;

					case APrivate:
						// pass

					case ADynamic:
						field.kind = FMethod(MethDynamic);

					case AExtern:
						field.isExtern = true;

					case AFinal:
						field.isFinal = true;

					case AInline:
						field.kind = FMethod(MethInline);

					case AMacro:
						field.kind = FMethod(MethMacro);

					case AOverride:
						isOverride = true;

					case AStatic:
						isStatic = true;
				}
			}

			if (isOverride)
			{
				overrides.push(field);
			}
			if (isStatic)
			{
				statics.push(field);
			}
			else
			{
				fields.push(field);
			}
		}

		return cls;
	}
}
