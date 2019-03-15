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
Special case of ModuleTypeTyper for classes and abstracts, which have fields.
**/
class WithFieldTyper<DefinitionFlag, DataType> extends ModuleTypeTyper<DefinitionFlag, Array<Field>, DataType>
{
	/**
	The typed fields.
	**/
	var fields:Array<ClassField>;

	/**
	The typed fields' expression.
	**/
	var fieldsExpr:Array<TypedExpr>;

	/**
	The class storing the fields: either the actual class or the abstract's impl class.
	**/
	var classData:Null<ClassType>;

	/**
	Construct a module type typer.

	@param compiler The compiler doing the compilation.
	@param module The module this module type is part of.
	@param definition The definition of the module type.
	@param position The module type's position.
	**/
	function new(compiler:Compiler, module:Module, definition:Definition<DefinitionFlag, Array<Field>>, position:Position)
	{
		super(compiler, module, definition, position);

		this.fields = [];
		this.fieldsExpr = [];
	}

	/**
	Parse the class/abstract's fields.
	**/
	function constructFields():Void
	{
		var memberFields = classData.fields.get();
		var overrideFields = classData.overrides;
		var staticFields = classData.statics.get();

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
	}

	/**
	Type the fields' expression.
	**/
	public override function secondPass():Void
	{
		if (classData == null)
		{
			throw "need to assign a classtype before doing second pass";
		}

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

							fieldsExpr[i] = new ExprTyper(compiler, module, classData, fn.expr).type();
						});

					case FProp(_, _, _, expr):
						fieldsExpr[i] = new ExprTyper(compiler, module, classData, expr).type();

					case FVar(_, expr):
						fieldsExpr[i] = new ExprTyper(compiler, module, classData, expr).type();
				}

				switch (fields[i].type.follow())
				{
					case TMono(ref):
						(cast ref : Ref<Type>).set(fieldsExpr[i].t);

					default:
						// pass
				}
			}
		});
	}
}
