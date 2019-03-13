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

using haxevm.utils.ComplexTypeUtils;

/**
Do class typing.
**/
class ClassTyper implements ModuleTypeTyper
{
	/**
	Link to the compiler doing the compilation.
	**/
	var compiler:Compiler;

	/**
	The definition of the class.
	**/
	var definition:Definition<ClassFlag, Array<Field>>;

	/**
	The typed class' fields.
	**/
	var fields:Array<ClassField>;

	/**
	The typed class fields' expression.
	**/
	var fieldsExpr:Array<TypedExpr>;

	/**
	The module this class is part of.
	**/
	var module:Module;

	/**
	The class' position.
	**/
	var position:Position;

	/**
	The typed class.
	**/
	var typedClass:Null<ClassType>;

	/**
	Construct a class typer.

	@param compiler The compiler doing the compilation.
	@param module The module this class is part of.
	@param definition The definition of the class.
	@param position The class' position.
	**/
	public function new(compiler:Compiler, module:Module, definition:Definition<ClassFlag, Array<Field>>, position:Position)
	{
		this.compiler = compiler;
		this.definition = definition;
		this.fields = [];
		this.fieldsExpr = [];
		this.module = module;
		this.position = position;
		this.typedClass = null;
	}

	/**
	Construct the class' typed data, but don't type its fields' expression.
	**/
	public function firstPass():ModuleType
	{
		var memberFields = [];
		var staticFields = [];
		var overrideFields = [];

		typedClass = {
			constructor: null,
			doc: definition.doc,
			fields: Ref.make(memberFields),
			init: null,
			interfaces: [],
			isExtern: false,
			isFinal: false,
			isInterface: false,
			isPrivate: false,
			kind: KNormal,
			meta: MetaAccess.make(definition.meta),
			module: module.name,
			name: definition.name,
			overrides: overrideFields,
			pack: [],
			params: [], // def.params,
			pos: position,
			statics: Ref.make(staticFields),
			superClass: null,
			exclude: () -> {}
		};

		for (flag in definition.flags)
		{
			switch (flag)
			{
				case HExtends(t):
					throw "not implemented";
					// cls.superClass = { t: new Ref(null), params: t.params };

				case HExtern:
					typedClass.isExtern = true;

				case HImplements(t):
					throw "not implemented";
					// cls.interfaces.push({ t: new Ref(null), params: t.params });

				case HInterface:
					typedClass.isInterface = true;

				case HPrivate:
					typedClass.isPrivate = true;
			}
		}

		// First pass: add class symbols
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
					function resolveAccess(a)
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
								throw "invalid access";
						}
					}

					field.kind = FVar(resolveAccess(get), resolveAccess(set));
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

		return ModuleType.TClassDecl(Ref.make(typedClass));
	}

	/**
	Type the class' fields' expression.
	**/
	public function secondPass():Void
	{
		compiler.symbolTable.stack(() ->
		{
			for (field in fields)
			{
				compiler.symbolTable.addField(field);
			}

			// Second pass: type class symbols' expr
			for (i in 0...definition.data.length)
			{
				var data = definition.data[i];

				switch (data.kind)
				{
					case FFun(fn):
						compiler.symbolTable.stack(() ->
						{
							var argsId = fn.args.map(arg -> compiler.symbolTable.addVar(arg.name, arg.type.toType()));
							compiler.symbolTable.addStaticFunctionArgumentSymbols(fields[i], argsId);

							fieldsExpr[i] = new ExprTyper(compiler, module, typedClass, fn.expr).type();
						});

					case FProp(_, _, _, expr):
						fieldsExpr[i] = new ExprTyper(compiler, module, typedClass, expr).type();

					case FVar(_, expr):
						fieldsExpr[i] = new ExprTyper(compiler, module, typedClass, expr).type();

						switch (fields[i].type)
						{
							case TMono(ref):
								(cast ref : Ref<Type>).set(fieldsExpr[i].t);

							default:
								// pass
						}
				}
			}
		});
	}
}
