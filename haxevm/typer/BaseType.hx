package haxevm.typer;

import haxe.macro.Type;

class BaseType
{
	public static final tInt:Type = TAbstract(new RefImpl({
		array: [],
		binops: [],
		doc: "",
		from: [],
		impl: null,
		isExtern: false,
		isPrivate: false,
		meta: null,
		module: "StdTypes",
		name: "Int",
		pack: [],
		params: [],
		pos: cast {
			file: "",
			max: 0,
			min: 0
		},
		resolve: null,
		resolveWrite: null,
		to: [],
		type: null, // The TAbstract(this, []);
		unops: [],
		exclude: () -> {}
	}), []);

	public static function isInt(t:Type):Bool
	{
		return switch (t)
		{
			case TAbstract(_.get() => t, _):
				t.pack.length == 0 && t.module == "StdTypes" && t.name == "Int";

			default:
				false;
		}
	}

	public static final tFloat:Type = TAbstract(new RefImpl({
		array: [],
		binops: [],
		doc: "",
		from: [],
		impl: null,
		isExtern: false,
		isPrivate: false,
		meta: null,
		module: "StdTypes",
		name: "Float",
		pack: [],
		params: [],
		pos: cast {
			file: "",
			max: 0,
			min: 0
		},
		resolve: null,
		resolveWrite: null,
		to: [],
		type: null, // The TAbstract(this, []);
		unops: [],
		exclude: () -> {}
	}), []);

	public static function isFloat(t:Type):Bool
	{
		return switch (t)
		{
			case TAbstract(_.get() => t, _):
				t.pack.length == 0 && t.module == "StdTypes" && t.name == "Float";

			default:
				false;
		}
	}

	public static final tString:Type = TInst(new RefImpl({
		constructor: null,
		doc: "",
		fields: (new RefImpl([]) : Ref<Array<ClassField>>),
		init: null,
		interfaces: [],
		isExtern: true,
		isFinal: false,
		isInterface: false,
		isPrivate: false,
		kind: KNormal,
		meta: null,
		module: "String",
		name: "String",
		overrides: [],
		pack: [],
		params: [],
		pos: cast {
			file: "",
			max: 0,
			min: 0
		},
		statics: (new RefImpl([]) : Ref<Array<ClassField>>),
		superClass: null,
		exclude: () -> {}
	}), []);

	public static function isString(t:Type):Bool
	{
		return switch (t)
		{
			case TInst(_.get() => t, _):
				t.pack.length == 0 && t.module == "String" && t.name == "String";

			default:
				false;
		}
	}

	public static final tVoid:Type = TAbstract(new RefImpl({
		array: [],
		binops: [],
		doc: "",
		from: [],
		impl: null,
		isExtern: false,
		isPrivate: false,
		meta: null,
		module: "StdTypes",
		name: "Void",
		pack: [],
		params: [],
		pos: cast {
			file: "",
			max: 0,
			min: 0
		},
		resolve: null,
		resolveWrite: null,
		to: [],
		type: null, // The TAbstract(this, []);
		unops: [],
		exclude: () -> {}
	}), []);

	public static function isVoid(t:Type):Bool
	{
		return switch (t)
		{
			case TAbstract(_.get() => t, _):
				t.pack.length == 0 && t.module == "StdTypes" && t.name == "Void";

			default:
				false;
		}
	}

	public static function tArray(t:Type):Type
	{
		return TInst(new RefImpl({
			constructor: null,
			doc: "",
			fields: (new RefImpl([]) : Ref<Array<ClassField>>),
			init: null,
			interfaces: [],
			isExtern: true,
			isFinal: false,
			isInterface: false,
			isPrivate: false,
			kind: KNormal,
			meta: null,
			module: "Array",
			name: "Array",
			overrides: [],
			pack: [],
			params: [{
				name: "T",
				t: TInst(new RefImpl({
					constructor: null,
					doc: null,
					fields: (new RefImpl([]) : Ref<Array<ClassField>>),
					init: null,
					interfaces: [],
					isExtern: false,
					isFinal: false,
					isInterface: false,
					isPrivate: false,
					kind: KTypeParameter([]),
					meta: null,
					module: "Array",
					name: "T",
					overrides: [],
					pack: ["Array"],
					params: [],
					pos: cast {
						file: "",
						max: 0,
						min: 0
					},
					statics: (new RefImpl([]) : Ref<Array<ClassField>>),
					superClass: null,
					exclude: () -> {}
				}), [])
			}],
			pos: cast {
				file: "",
				max: 0,
				min: 0
			},
			statics: (new RefImpl([]) : Ref<Array<ClassField>>),
			superClass: null,
			exclude: () -> {}
		}), [t]);
	}

	public static function isArray(t:Type):Bool
	{
		return switch (t)
		{
			case TInst(_.get() => t, _):
				t.pack.length == 0 && t.module == "Array" && t.name == "Array";

			default:
				false;
		}
	}

	public static final tBool:Type = TAbstract(new RefImpl({
		array: [],
		binops: [],
		doc: "",
		from: [],
		impl: null,
		isExtern: false,
		isPrivate: false,
		meta: null,
		module: "StdTypes",
		name: "Bool",
		pack: [],
		params: [],
		pos: cast {
			file: "",
			max: 0,
			min: 0
		},
		resolve: null,
		resolveWrite: null,
		to: [],
		type: null, // The TAbstract(this, []);
		unops: [],
		exclude: () -> {}
	}), []);

	public static function isBool(t:Type):Bool
	{
		return switch (t)
		{
			case TAbstract(_.get() => t, _):
				t.pack.length == 0 && t.module == "StdTypes" && t.name == "Bool";

			default:
				false;
		}
	}

	public static function isNumeric(t:Type):Bool
	{
		return isInt(t) || isFloat(t);
	}
}
