package typer;

import haxe.macro.Type;

class BaseType
{
	public static final Int : Type = TAbstract(new RefImpl({
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

	public static final Float : Type = TAbstract(new RefImpl({
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

	public static final String : Type = TInst(new RefImpl({
		constructor: null,
		doc: "",
		fields: cast new RefImpl(([]:Array<ClassField>)),
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
		statics: cast new RefImpl(([]:Array<ClassField>)),
		superClass: null,
		exclude: () -> {}
	}), []);

	public static final Void : Type = TAbstract(new RefImpl({
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

	public static function Array(t:Type) : Type
	{
		return TInst(new RefImpl({
			constructor: null,
			doc: "",
			fields: cast new RefImpl(([]:Array<ClassField>)),
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
					fields: cast new RefImpl(([]:Array<ClassField>)),
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
					statics: cast new RefImpl(([]:Array<ClassField>)),
					superClass: null,
					exclude: () -> {}
				}), [])
			}],
			pos: cast {
				file: "",
				max: 0,
				min: 0
			},
			statics: cast new RefImpl(([]:Array<ClassField>)),
			superClass: null,
			exclude: () -> {}
		}), [t]);
	}

	public static final Bool : Type = TAbstract(new RefImpl({
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
}
