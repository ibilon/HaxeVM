package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxeparser.Data;
import haxevm.SymbolTable.Symbol;

class ClassTyper
{
	var symbolTable:SymbolTable;
	var module:Module;
	var def:Definition<ClassFlag, Array<Field>>;

	public function new(symbolTable:SymbolTable, module:Module, def:Definition<ClassFlag, Array<Field>>)
	{
		this.symbolTable = symbolTable;
		this.module = module;
		this.def = def;
	}

	public function type():ClassType
	{
		symbolTable.enter();

		var fields:Array<ClassField> = [];
		var statics:Array<ClassField> = [];
		var overrides:Array<ClassField> = [];

		var cls:ClassType = {
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
			module: module.name,
			name: def.name,
			overrides: cast new RefImpl(overrides),
			pack: [],
			params: [], // def.params,
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
					// cls.superClass = { t: new RefImpl(null), params: t.params };

				case HImplements(t):
					throw "not implemented";
					// cls.interfaces.push({ t: new RefImpl(null), params: t.params });
			}
		}

		// First pass: add class symbols
		var ids = new Map<String, Int>();

		for (field in def.data)
		{
			ids[field.name] = symbolTable.addField(field.name);
		}

		// Second pass: type class symbols
		for (d in def.data)
		{
			var typed = null;

			var field:ClassField = {
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
				expr: () -> typed
			};

			switch (d.kind)
			{
				case FFun(f):
					// TODO f args?
					typed = new ExprTyper(symbolTable, module, cls, f.expr).type();

					field.type = typed.t;

				case FProp(get, set, t, e):
					typed = new ExprTyper(symbolTable, module, cls, e).type();

					function resolveAccess(a)
					{
						return switch (a)
						{
							case "default":
								AccNormal;

							case "null":
								AccNo;

							case "never":
								AccNever;

							case "get", "set", "dynamic":
								AccCall;

							case "inline":
								AccInline;

							default:
								throw "invalid access";
						}
					}

					field.type = typed.t; // TODO unify typed.t and t
					field.kind = FVar(resolveAccess(get), resolveAccess(set));

				case FVar(t, e):
					typed = new haxevm.typer.ExprTyper(symbolTable, module, cls, e).type();

					field.type = typed.t; // TODO unify typed.t and t
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

			symbolTable[ids[field.name]] = SField(field);
		}

		symbolTable.leave();

		return cls;
	}
}
