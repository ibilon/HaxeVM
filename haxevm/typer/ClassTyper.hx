package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxeparser.Data;

class ClassTyper implements ModuleTypeTyper
{
	var compiler:Compiler;
	var module:Module;
	var def:Definition<ClassFlag, Array<Field>>;
	var cls:Null<ClassType>;
	var data:Array<ClassField>;
	var typed:Array<TypedExpr>;

	public function new(compiler:Compiler, module:Module, def:Definition<ClassFlag, Array<Field>>)
	{
		this.compiler = compiler;
		this.module = module;
		this.def = def;

		cls = null;
		data = [];
		typed = [];
	}

	public function preType():ModuleType
	{
		var fields:Array<ClassField> = [];
		var statics:Array<ClassField> = [];
		var overrides:Array<Ref<ClassField>> = [];

		cls = {
			constructor: null,
			doc: def.doc,
			fields: RefImpl.make(fields),
			init: null,
			interfaces: [],
			isExtern: false,
			isFinal: false,
			isInterface: false,
			isPrivate: false,
			kind: KNormal,
			meta: MetaAccessImpl.make(def.meta),
			module: module.name,
			name: def.name,
			overrides: overrides,
			pack: [],
			params: [], // def.params,
			pos: null,
			statics: RefImpl.make(statics),
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
		for (i in 0...def.data.length)
		{
			var d = def.data[i];

			var field:ClassField = {
				doc: d.doc,
				isExtern: false,
				isFinal: false,
				isPublic: false,
				kind: null,
				meta: MetaAccessImpl.make(d.meta),
				name: d.name,
				overloads: RefImpl.make([]),
				params: [],
				pos: d.pos,
				type: null,
				expr: () -> typed[i]
			};

			switch (d.kind)
			{
				case FFun(f):
					field.kind = FMethod(MethNormal);
					field.type = TFun(f.args.map(a -> { name: a.name, opt: a.opt, t: ComplexTypeUtils.convertComplexType(a.type) }), ComplexTypeUtils.convertComplexType(f.ret));

				case FProp(get, set, t, _):
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

					field.kind = FVar(resolveAccess(get), resolveAccess(set));
					field.type = ComplexTypeUtils.convertComplexType(t);

				case FVar(t, _):
					field.kind = FVar(AccNormal, AccNormal);
					field.type = ComplexTypeUtils.convertComplexType(t);
			}

			var isStatic = false;
			var isOverride = false;

			var daccess = d.access;
			for (a in (daccess != null ? daccess : []))
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
				overrides.push(RefImpl.make(field));
			}
			if (isStatic)
			{
				statics.push(field);
			}
			else
			{
				fields.push(field);
			}

			data.push(field);
		}

		return ModuleType.TClassDecl(RefImpl.make(cls));
	}

	public function fullType()
	{
		compiler.symbolTable.enter();

		for (d in data)
		{
			compiler.symbolTable.addField(d.name, d);
		}

		// Second pass: type class symbols' expr
		for (i in 0...def.data.length)
		{
			var d = def.data[i];

			switch (d.kind)
			{
				case FFun(f):
					compiler.symbolTable.enter();

					var argsid = [];

					for (a in f.args)
					{
						var sid = compiler.symbolTable.addVar(a.name, ComplexTypeUtils.convertComplexType(a.type));
						argsid.push(sid);
					}

					compiler.symbolTable.addFunctionArgSymbols(data[i], argsid);

					typed[i] = new ExprTyper(compiler, module, cls, f.expr).type();

					compiler.symbolTable.leave();

				case FProp(get, set, t, e):
					typed[i] = new ExprTyper(compiler, module, cls, e).type();

				case FVar(t, e):
					typed[i] = new haxevm.typer.ExprTyper(compiler, module, cls, e).type();

					switch (data[i].type)
					{
						case TMono(_):
							data[i].type = typed[i].t;

						default:
							// pass
					}
			}
		}

		compiler.symbolTable.leave();
	}
}
