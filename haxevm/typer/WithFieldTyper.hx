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
import haxe.macro.Expr.Position as BasePosition;
import haxe.macro.Type;
import haxeparser.Data;
import haxevm.impl.MetaAccess;
import haxevm.impl.Position;
import haxevm.impl.Ref;
import haxevm.typer.BaseType;
import haxevm.typer.Error;
import haxevm.typer.expr.ConstExpr;

using haxevm.utils.ComplexTypeUtils;

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
	function new(compiler:Compiler, module:Module, definition:Definition<DefinitionFlag, Array<Field>>, position:BasePosition)
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

		var propertyAccessorRequired = [];

		for (i in 0...definition.data.length)
		{
			var data = definition.data[i];

			var field:ClassField = {
				doc: data.doc,
				isExtern: classData.isExtern,
				isFinal: false,
				isPublic: classData.isInterface,
				kind: null,
				meta: MetaAccess.make(data.meta),
				name: data.name,
				overloads: Ref.make([]),
				params: [],
				pos: data.pos,
				type: null,
				expr: () -> fieldsExpr[i]
			};

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

			function eagerType(field:ClassField, expr:Null<Expr>) // Eagerly type constant.
			{
				switch (expr != null ? expr.expr : null)
				{
					case EConst(constant):
						Unification.unify(field.type, ConstExpr.type(constant, expr.pos, module, classData, compiler.symbolTable, null).t);

					default:
				}
			}

			switch (data.kind)
			{
				case FFun(fn):
					field.kind = FMethod(MethNormal);
					field.type = TFun(fn.args.map(arg -> { name: arg.name, opt: arg.opt, t: arg.type.toType() }), fn.ret.toType());

				case FProp(getAccessor, setAccessor, t, expr):
					function resolveAccess(get:Bool):VarAccess
					{
						return switch (get ? getAccessor : setAccessor)
						{
							case "get" if (get):
								propertyAccessorRequired.push({ name: 'get_${data.name}', isStatic: isStatic, pos: data.pos });
								AccCall;

							case "set" if (!get):
								propertyAccessorRequired.push({ name: 'set_${data.name}', isStatic: isStatic, pos: data.pos });
								AccCall;

							case "dynamic":
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
								var delta = get ? 1 : getAccessor.length + 2;
								var length = get ? getAccessor.length : setAccessor.length;
								var pos = Position.make(data.pos.file, data.pos.min + delta, data.pos.min + delta + length);
								//trace(delta, data.pos, pos);
								// TODO figure out accessor position
								throw new Error(CustomPropertyAccessor(get), module, pos);
						}
					}

					field.kind = FVar(resolveAccess(true), resolveAccess(false));
					field.type = t.toType();
					eagerType(field, expr);

				case FVar(t, expr):
					field.kind = FVar(AccNormal, AccNormal);
					field.type = t.toType();
					eagerType(field, expr);
			}

			if (field.name == "new")
			{
				if (isStatic)
				{
					throw "A constructor must not be static";
				}
				switch (field.type)
				{
					case TFun(_, t):
						if (BaseType.isVoid(t))
						{
							throw "A class constructor can't have a return value";
						}
					default:
						throw "Unexpected new";
				}
				classData.constructor = Ref.make(field);
			}
			else
			{
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
			}
			fields.push(field);
		}

		// Check that all get_var and set_var exist.
		for (accessor in propertyAccessorRequired)
		{
			var found = false;

			if (accessor.isStatic)
			{
				for (field in staticFields)
				{
					if (field.name == accessor.name)
					{
						found = true;
						break;
					}
				}
			}
			else
			{
				for (field in fields)
				{
					if (field.name == accessor.name)
					{
						found = true;
						break;
					}
				}
			}

			if (!found)
			{
				throw new Error(MissingPropertyAccessor(accessor.name), module, accessor.pos);
			}
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
				compiler.symbolTable.addField(field, classData);
			}

			// Second pass: type class symbols' expr
			for (i in 0...definition.data.length)
			{
				var data = definition.data[i];
				switch (data.kind)
				{
					case FFun(fn):
						if (fn.expr == null && fields[i].isExtern == false)
						{
							throw new Error(FunctionBodyRequired, module, data.pos);
						}

						if (data.name == "new" || data.access == null || data.access.indexOf(AStatic) == -1)
						{
							compiler.symbolTable.stack(() ->
							{
								var argsId = fn.args.map(arg -> compiler.symbolTable.addVar(arg.name, arg.type.toType()));
								argsId.unshift(1);
								compiler.symbolTable.addStaticFunctionArgumentSymbols(fields[i], argsId);

								fieldsExpr[i] = new ExprTyper(compiler, module, classData, fn.expr).type();
							});
						}
						else
						{
							compiler.symbolTable.stack(() ->
							{
								var argsId = fn.args.map(arg -> compiler.symbolTable.addVar(arg.name, arg.type.toType()));
								compiler.symbolTable.addStaticFunctionArgumentSymbols(fields[i], argsId);

								fieldsExpr[i] = new ExprTyper(compiler, module, classData, fn.expr).type();
							});
						}

					case FProp(_, _, _, expr):
						fieldsExpr[i] = new ExprTyper(compiler, module, classData, expr).type();

					case FVar(_, expr):
						fieldsExpr[i] = new ExprTyper(compiler, module, classData, expr).type();
				}

				Unification.unify(fields[i].type, fieldsExpr[i].t);
			}
		});
	}
}
