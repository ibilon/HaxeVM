import typer.TExpr;
import typer.TType;

enum EVal
{
	EBool(b:Bool);
	EInt(i:Int);
	EFloat(f:Float);
	EString(s:String);
	ERegexp(r:EReg);
	EArray(of:TType, a:Array<EVal>);
	EObject; //TODO
	EVoid;
	EFn(fn:Array<EVal>->EVal);
	EIdent(id:Int);
}

class VM
{
	public static function evalExpr(texpr:TExpr) : EVal
	{
		var context = new Map<Int, EVal>();

		// insert builtin trace
		context[0] = EFn(function (a) {
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

	static function eval(texpr:TExpr, context:Map<Int, EVal>) : EVal
	{
		switch (texpr.expr)
		{
			case TConst(c):
				return switch (c)
				{
					case TCInt(v): EInt(Std.parseInt(v));
					case TCFloat(f): EFloat(Std.parseFloat(f));
					case TCIdent(sid): context.exists(sid) ? context[sid] : {trace(context); throw "using unbound variable " + sid;};
					case TCRegexp(r, opt): ERegexp(new EReg(r, opt));
					case TCString(s): EString(s);
				}

			case TArray(e1, e2):
				var val = eval(e1, context);

				switch (val)
				{
					case EArray(of, a):
						var idx = eval(e2, context);

						switch (idx)
						{
							case EInt(i):
								return a[i];

							default:
								throw "unexpected value, expected EInt, got " + idx;
						}

					default:
						throw "unexpected value, expected EArray, got " + val;
				}

			case TBinop(op, e1, e2):
				var v1 = eval(e1, context);
				var v2 = eval(e2, context);

				return switch (op)
				{
					case OpAdd:
						switch (texpr.type)
						{
							case TInt:
								switch ([v1, v2])
								{
									case [EInt(i1), EInt(i2)]: EInt(i1 + i2);

									default:
										throw 'TBinop $op unimplemented';
								}

							case TFloat:
								EFloat(getFloatOrPromote(v1) + getFloatOrPromote(v2));

							default:
								throw 'TBinop $op unimplemented';
						}

					default:
						throw 'TBinop $op unimplemented';
				}
				return eval(e1, context);

			case TField(e, field):
				throw "TField unimplemented";

			case TParenthesis(e):
				throw "TParenthesis unimplemented";

			case TObjectDecl(fields):
				throw "TObjectDecl unimplemented";

			case TArrayDecl(values):
				var value : Array<EVal> = [];

				for (v in values)
				{
					value.push(eval(v, context));
				}

				return EArray(texpr.type, value);

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

					default: throw "unexpected value, expected EFunction, got " + v;
				}

			case TNew(t, el):
				throw "TNew unimplemented";

			case TUnop(op, postFix, e):
				throw "TUnop unimplemented";

			case TFunction(args, expr, _):
				return EFn(function (a:Array<EVal>) {
					for (i in 0...args.length)
					{
						context[args[i].id] = a[i];
					}

					var ret = eval(expr, context);

					for (i in 0...args.length)
					{
						context.remove(args[i].id);
					}

					return ret;
				});

			case TVar(v, expr):
				var val = eval(expr, context);
				context[v.id] = val;
				return val;

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
				throw "TIf unimplemented";

			case TWhile(econd, e, normalWhile):
				throw "TWhile unimplemented";

			case TSwitch(e, cases, edef):
				throw "TSwitch unimplemented";

			case TTry(e, catches):
				throw "TTry unimplemented";

			case TReturn(e):
				throw "TReturn unimplemented";

			case TBreak:
				throw "TBreak unimplemented";

			case TContinue:
				throw "TContinue unimplemented";

			case TThrow(e):
				throw "TThrow unimplemented";

			case TCast(e, m):
				throw "TCast unimplemented";

			case TMeta(s, e):
				//TODO is there actually something to do at runtime?
				return eval(e, context);
		}
	}

	static function getFloatOrPromote(value:EVal) : Float
	{
		return switch (value)
		{
			case EInt(i): i;
			case EFloat(f): f;
			default: throw "unexpected value, expected number, got " + value;
		}
	}

	static function EVal2str(e:EVal, context:Map<Int, EVal>) : String
	{
		return switch (e)
		{
			case EBool(b): b ? "true" : "false";
			case EArray(_, a): "[" + a.join(", ") + "]";
			case EFloat(f): '$f';
			case EFn(_): 'function';
			case EInt(i): '$i';
			case EObject: throw "todo print object";
			case ERegexp(r): throw "todo print ereg";
			case EString(s): s;
			case EVoid: "Void";
			case EIdent(id):
				if (!context.exists(id))
				{
					throw "using unbound variable";
				}
				EVal2str(context[id], context);
		}
	}
}
