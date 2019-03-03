package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxeparser.Data;

class ClassTyper
{
	public function new()
	{
	}

	public function typeClass(module:String, d:Definition<ClassFlag, Array<Field>>) : ClassType
	{
		var statics : Array<ClassField> = [];

		for (d in d.data)
		{
			switch (d.kind)
			{
				case FFun(f):
					if (d.name == "main" && f.args.length == 0)
					{
						var typed = new haxevm.typer.ExprTyper().typeExpr(f.expr);

						statics.push({
							doc: null,
							isExtern: false,
							isFinal: false,
							isPublic: true,
							kind: FMethod(MethNormal),
							meta: null,
							name: d.name,
							overloads: cast new RefImpl([]),
							params: [],
							pos: null,
							type: typed.t,
							expr: () -> typed
						});
					}

				default:
					throw "not supported";
			}
		}

		return {
			constructor: null,
			doc: null,
			fields: new RefImpl([]),
			init: null,
			interfaces: [],
			isExtern: false,
			isFinal: false,
			isInterface: false,
			isPrivate: false,
			kind: KNormal,
			meta: null,
			module: module,
			name: d.name,
			overrides: [],
			pack: [],
			params: [],
			pos: null,
			statics: new RefImpl(statics),
			superClass: null,
			exclude: () -> {}
		};
	}
}
