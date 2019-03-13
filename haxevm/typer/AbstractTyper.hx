/**
Copyright (c) 2019 Valentin Lemière, Guillaume Desquesnes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/

package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxeparser.Data;
import haxevm.impl.MetaAccess;
import haxevm.impl.Ref;
import haxevm.typer.Error;

using haxevm.utils.ComplexTypeUtils;
using haxevm.utils.TypeUtils;

/**
Do abstract typing.
**/
class AbstractTyper implements ModuleTypeTyper
{
	/**
	Link to the compiler doing the compilation.
	**/
	var compiler:Compiler;

	/**
	The definition of the abstract.
	**/
	var definition:Definition<AbstractFlag, Array<Field>>;

	/**
	The typed abstract' fields.
	**/
	var fields:Array<ClassField>;

	/**
	The typed abstract fields' expression.
	**/
	var fieldsExpr:Array<TypedExpr>;

	/**
	The module this abstract is part of.
	**/
	var module:Module;

	/**
	The abstract' position.
	**/
	var position:Position;

	/**
	The typed abstract.
	**/
	var typedAbstract:Null<AbstractType>;

	/**
	Construct a abstract typer.

	@param compiler The compiler doing the compilation.
	@param module The module this abstract is part of.
	@param definition The definition of the abstract.
	@param position The abstract' position.
	**/
	public function new(compiler:Compiler, module:Module, definition:Definition<AbstractFlag, Array<Field>>, position:Position)
	{
		this.compiler = compiler;
		this.definition = definition;
		this.fields = [];
		this.fieldsExpr = [];
		this.module = module;
		this.position = position;
		this.typedAbstract = null;
	}

	/**
	Construct the abstract' typed data, but don't type its fields' expression.
	**/
	public function firstPass():ModuleType
	{
		var memberFields = [];
		var staticFields = [];
		var overrideFields = [];

		typedAbstract = {
			array: [], // TODO
			binops: [], // TODO
			doc: definition.doc,
			from: [], // TODO
			impl: null, // TODO
			isExtern: false,
			isPrivate: false,
			meta: MetaAccess.make(definition.meta),
			module: module.name,
			name: definition.name,
			pack: [],
			params: [], // def.params,
			pos: position,
			resolve: null, // TODO
			resolveWrite: null, // TODO
			to: [], // TODO
			type: Monomorph.make(),
			unops:[], // TODO
			exclude: () -> {}
		};

		for (flag in definition.flags)
		{
			switch (flag)
			{
				case AExtern:
					typedAbstract.isExtern = true;

				case AFromType(ct):
					typedAbstract.from.push({t:ct.toType(), field:null});

				case AIsType(ct):
					typedAbstract.type = ct.toType();

				case APrivAbstract:
					typedAbstract.isPrivate = true;

				case AToType(ct):
					typedAbstract.to.push({t:ct.toType(), field:null});
			}
		}

		// First pass: add abstract symbols
		for (i in 0...definition.data.length)
		{
			var data = definition.data[i];

			var field:ClassField = {
				doc: data.doc,
				isExtern: false,
				isFinal: false,
				isPublic: false,
				kind: null,
				meta: MetaAccess.make(data.meta),
				name: data.name,
				overloads: Ref.make([]),
				params: [],
				pos: data.pos,
				type: null,
				expr: () -> fieldsExpr[i]
			};

			switch (data.kind)
			{
				case FFun(fn):
					field.kind = FMethod(MethNormal);
					field.type = TFun(fn.args.map(arg -> { name: arg.name, opt: arg.opt, t: arg.type.toType() }), fn.ret.toType());

				case FProp(get, set, t, _):
					function resolveAccess(a:String, get:Bool):VarAccess
					{
						return switch (a)
						{
							case "get", "set", "dynamic":
								AccCall;

							case "inline":
								AccInline;

							case "never":
								AccNever;

							case "null":
								AccNo;

							case "default":
								AccNormal;

							default:
								throw new Error(CustomPropertyAccessor(get), module, data.pos);
						}
					}

					field.kind = FVar(resolveAccess(get, true), resolveAccess(set, false));
					field.type = t.toType();

				case FVar(t, _):
					field.kind = FVar(AccNormal, AccNormal);
					field.type = t.toType();
			}

			var isStatic = false;
			var isOverride = false;

			for (access in (data.access != null ? data.access : []))
			{
				switch (access)
				{
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

					case APrivate:
						// pass

					case APublic:
						field.isPublic = true;

					case AStatic:
						isStatic = true;
				}
			}

			if (isStatic)
			{
				staticFields.push(field);
			}
			else
			{
				memberFields.push(field);
			}

			if (isOverride)
			{
				overrideFields.push(Ref.make(field));
			}

			fields.push(field);
		}

		return ModuleType.TAbstract(Ref.make(typedAbstract));
	}

	/**
	Type the abstract' fields' expression.
	**/
	public function secondPass():Void
	{
	}
}
