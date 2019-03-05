package haxevm;

import haxe.macro.Type;
import haxevm.Compiler.CompilationOutput;
import haxevm.vm.Context;
import haxevm.vm.EVal;
import haxevm.vm.EValTools;
import haxevm.vm.FlowControl;
import haxevm.vm.Operator;

class VM
{
	var compilationOutput:CompilationOutput;
	var mainClass:String;

	public function new(compilationOutput:CompilationOutput, mainClass:String)
	{
		this.compilationOutput = compilationOutput;
		this.mainClass = mainClass;
		// TODO populate context with top level symbol table
	}

	public function run():Void
	{
		for (module in compilationOutput.modules)
		{
			if (module.name == mainClass)
			{
				for (type in module.types)
				{
					switch (type)
					{
						case TClassDecl(_.get() => c) if (c.name == mainClass):
							for (f in c.statics.get())
							{
								if (f.name == "main")
								{
									evalExpr(f.expr());
									return;
								}
							}

							throw "no main function";

						default:
							// pass
					}
				}

				throw 'module "$mainClass" doesn\'t define a main type';
			}
		}
	}

	static function evalExpr(texpr:TypedExpr):EVal
	{
		var context = new Context();

		// insert builtin trace
		context[0] = EFn(function(a) {
			var buf = [];

			for (e in a)
			{
				buf.push(EVal2str(e, context));
			}

			Sys.println(buf.join(" "));
			return EVoid;
		});

		return eval(texpr, context);
	}

	static function eval(texpr:TypedExpr, context:Context):EVal
	{
		switch (texpr.expr)
		{
			case TConst(c):
				return switch (c)
				{
					case TInt(v):
						EInt(v);

					case TFloat(f):
						EFloat(Std.parseFloat(f));

					case TString(s):
						EString(s);

					case TBool(b):
						EBool(b);

					case TNull:
						ENull;

					case TSuper:
						throw "no super";

					case TThis:
						throw "no this";
				}

			case TArray(e1, e2):
				var val = eval(e1, context);

				return switch (val)
				{
					case EArray(of, a):
						var idx = eval(e2, context);

						switch (idx)
						{
							case EInt(i):
								if (i < 0)
								{
									throw 'Negative array index: $i';
								}

								if (i < a.length)
								{
									a[i];
								}
								else
								{
									ENull;
								}

							default:
								throw "unexpected value, expected EInt, got " + idx;
						}

					default:
						throw "unexpected value, expected EArray, got " + val;
				}

			case TBinop(op, e1, e2):
				return Operator.binop(op, e1, e2, context, eval);

			case TField(e, fa):
				var parent = eval(e, context);

				switch (parent)
				{
					case EObject(fields):
						var name = nameOf(fa);

						for (f in fields)
						{
							if (f.name == name)
							{
								return f.val;
							}
						}

						throw 'Field ${name} not found';

					default:
						throw 'Field access on non object "${e.t}"';
				}

			case TParenthesis(e):
				return eval(e, context);

			case TObjectDecl(fields):
				return EObject(fields.map(f -> {
					name: f.name,
					val: eval(f.expr, context)
				}));

			case TArrayDecl(values):
				var value:Array<EVal> = [];

				for (v in values)
				{
					value.push(eval(v, context));
				}

				return EArray(texpr.t, value);

			case TCall(e, el):
				var v = eval(e, context);

				return switch (v)
				{
					case EIdent(id):
						return EVoid;

					case EFn(fn):
						var eargs = [];

						for (a in el)
						{
							eargs.push(eval(a, context));
						}

						fn(eargs);

					default:
						throw "unexpected value, expected EFunction, got " + v;
				}

			case TNew(c, params, el):
				throw "TNew unimplemented";

			case TUnop(op, postFix, e):
				return Operator.unop(op, postFix, e, context, eval);

			case TFunction(tfunc):
				return EFn(function(a:Array<EVal>)
				{
					context.stack();

					for (i in 0...tfunc.args.length)
					{
						context[tfunc.args[i].v.id] = a[i];
					}

					var ret = try
					{
						eval(tfunc.expr, context);
					}
					catch (fc:FlowControl)
					{
						switch (fc)
						{
							case FCReturn(v):
								v;

							default:
								throw fc;
						}
					}

					context.unstack();

					return ret;
				});

			case TVar(v, expr):
				if (expr != null)
				{
					return context[v.id] = eval(expr, context);
				}

				return context[v.id] = EVoid;

			case TBlock(exprs):
				var v = EVoid;

				for (e in exprs)
				{
					v = eval(e, context);
				}

				return v;

			case TFor(v, e1, e2):
				throw "TFor unimplemented";

			case TIf(econd, eif, eelse):
				return switch (eval(econd, context))
				{
					case EBool(b):
						if (b)
						{
							eval(eif, context);
						}
						else if (eelse != null)
						{
							eval(eelse, context);
						}
						else
						{
							EVoid;
						}

					default:
						throw "if condition is not bool";
				}

			case TWhile(econd, e, normalWhile):
				var stop = false;

				while (!stop && eval(econd, context).match(EBool(true)))
				{
					try
					{
						eval(e, context);
					}
					catch (fc:FlowControl)
					{
						switch (fc)
						{
							case FCBreak:
								stop = true;

							case FCContinue:
								// nothing to do

							default:
								throw fc;
						}
					}
				}

				return EVoid;

			case TSwitch(e, cases, edef):
				var val = eval(e, context);

				for (c in cases)
				{
					var match = false;

					for (v in c.values)
					{
						if (val.equals(eval(v, context)))
						{
							match = true;
							break;
						}
					}

					if (match)
					{
						return eval(c.expr, context);
					}
				}

				if (edef != null)
				{
					return eval(edef, context);
				}

				return EVoid;

			case TTry(e, catches):
				try
				{
					eval(e, context);
				}
				catch (fc:FlowControl)
				{
					switch (fc)
					{
						case FCThrow(v):
							for (c in catches)
							{
								if (EValTools.isSameType(v, EValTools.extractType(c.v.t)))
								{
									context[c.v.id] = v;
									eval(c.expr, context);
									return EVoid;
								}
							}

							throw fc;

						default:
							throw fc;
					}
				}

				return EVoid;

			case TReturn(e):
				throw FCReturn(eval(e, context));

			case TBreak:
				throw FCBreak;

			case TContinue:
				throw FCContinue;

			case TThrow(e):
				throw FCThrow(eval(e, context));

			case TCast(e, m):
				throw "TCast unimplemented";

			case TMeta(s, e):
				// TODO is there actually something to do at runtime?
				return eval(e, context);

			case TEnumIndex(e1): // generated by the pattern matcher
				throw "unexpected TEnumIndex";

			case TEnumParameter(e1, ef, index): // generated by the pattern matcher
				throw "unexpected TEnumParameter";

			case TTypeExpr(m):
				throw "TTypeExpr unimplemented";

			case TIdent(s): // TODO "unknown identifier" is that possible?
				throw "TIdent unimplemented";

			case TLocal(v):
				if (!context.exists(v.id))
				{
					throw 'using unbound variable ${v.id}';
				}

				return context[v.id];
		}
	}

	static function EVal2str(e:EVal, context:Context):String
	{
		return switch (e)
		{
			case EBool(b):
				b ? "true" : "false";

			case ENull:
				"null";

			case EArray(_, a):
				"[" + a.map(f -> EVal2str(f, context)).join(",") + "]";

			case EFloat(f):
				'$f';

			case EFn(_):
				'function';

			case EInt(i):
				'$i';

			case EObject(fields):
				var buf = new StringBuf();
				buf.add("{");
				var fs = [];

				for (f in fields)
				{
					fs.push('${f.name}: ${EVal2str(f.val, context)}');
				}

				buf.add(fs.join(", "));
				buf.add("}");
				buf.toString();

			case ERegexp(r):
				throw "todo print ereg";

			case EString(s):
				s;

			case EVoid:
				"Void";

			case EIdent(id):
				if (!context.exists(id))
				{
					throw 'using unbound variable $id';
				}

				EVal2str(context[id], context);
		}
	}

	public static function nameOf(fa:FieldAccess):String
	{
		return switch (fa)
		{
			case FInstance(_, _, _.get() => cf), FStatic(_, _.get() => cf), FAnon(_.get() => cf), FClosure(_, _.get() => cf):
				cf.name;

			case FDynamic(s):
				s;

			case FEnum(_, ef):
				ef.name;
		}
	}
}
