import haxe.macro.Expr;
import haxe.macro.Type;
import typer.BaseType;
import typer.RefImpl;

class Typer
{
	public function new()
	{
		insertTrace();
	}

	public function typeExpr(expr:Expr) : TypedExpr
	{
		switch (expr.expr)
		{
			case EConst(c):
				switch (c)
				{
					case CInt(v):
						return makeTyped(expr, TConst(TInt(Std.parseInt(v))), BaseType.Int);

					case CFloat(f):
						return makeTyped(expr, TConst(TFloat(f)), BaseType.Float);

					//TODO boolean
					//case CIdent("true"):
					//case CIdent("false"):

					case CIdent(s):
						var sid = getSymbol(s);
						var type = typeTable[sid];
						return makeTyped(expr, makeTypedVar(s, sid, type), type);

					case CRegexp(r, opt):
						//return makeTyped(expr, TConst(TCRegexp(r, opt)), TRegexp);
						throw "no regex support";

					case CString(s):
						return makeTyped(expr, TConst(TString(s)), BaseType.String);
				}

			case EArray(e1, e2):
				var t1 = typeExpr(e1);
				var t2 = typeExpr(e2);

				var of = switch (t1.t)
				{
					case TInst(_.get() => t, params) if (t.name == "Array"): params[0];
					default: throw "Array access only allowed on arrays";
				}

				switch (t2.t)
				{
					case TAbstract(_.get() => t, _) if (t.name == "Int"):
					default: throw "Array index must be int";
				}

				return makeTyped(expr, TArray(t1, t2), of);

			case EBinop(op, e1, e2):
				var t1 = typeExpr(e1);
				var t2 = typeExpr(e2);

				//TODO that's not true of all binops, eg +=
				var t = switch([t1.t, t2.t])
				{
					case [TAbstract(_.get() => t1, _), TAbstract(_.get() => t2, _)] if (t1.name == "Int" && t2.name == "Int"): BaseType.Int;
					case [TAbstract(_.get() => t1, _), TAbstract(_.get() => t2, _)] if ((t1.name == "Int" || t1.name == "Float") && (t2.name == "Int" || t2.name == "Float")): BaseType.Float;
					default: throw "TODO binop return type " + t1.t + " " + t2.t; //TODO
				}

				return makeTyped(expr, TBinop(op, t1, t2), t);

			case EField(e, field):
				var t = typeExpr(e);

				//TODO class
				var sub = null;

				switch (t.t)
				{
					case TAnonymous(_.get() => a):
						for (f in a.fields)
						{
							if (f.name == field)
							{
								sub = f;
								break;
							}
						}

					default: throw "field access on non object " + t.t;
				}

				if (sub == null)
				{
					throw "object has no field " + field;
				}

				return makeTyped(expr, TField(t, FAnon(new RefImpl(sub))), sub.type);

			case EParenthesis(e):
				enter();
					var t = typeExpr(e);
				leave();

				return makeTyped(expr, TParenthesis(t), t.t);

			case EObjectDecl(fields):
				var ofields = [];
				var tfields = [];

				for (f in fields)
				{
					var texpr = typeExpr(f.expr);

					ofields.push({
						name: f.field,
						expr: texpr
					});

					tfields.push({
						doc: null,
						isExtern: false,
						isFinal: false,
						isPublic: true,
						kind: FVar(AccNormal, AccNormal),
						meta: null,
						name: f.field,
						overloads: cast new RefImpl([]),
						params: [],
						pos: cast {
							file: "",
							max: 0,
							min: 0
						},
						type: texpr.t,
						expr: () -> texpr
					});
				}

				return makeTyped(expr, TObjectDecl(ofields), TAnonymous(new RefImpl({
					fields: tfields,
					status: AConst
				})));

			case EArrayDecl(values):
				var t = null;
				var elems = [];

				for (e in values)
				{
					var st = typeExpr(e);
					elems.push(st);

					if (t == null)
					{
						t = st.t;
					}
					else
					{
						if (t != st.t) //TODO monomorph/unify
						{
							throw "array must be of single type";
						}
					}
				}

				return makeTyped(expr, TArrayDecl(elems), BaseType.Array(t));

			case ECall(e, params):
				var t = typeExpr(e);
				var elems = [];

				var r = switch (t.t)
				{
					case TFun(_, ret): ret;
					default: throw "Can only call functions";
				}

				for (e in params)
				{
					elems.push(typeExpr(e));
				}

				return makeTyped(expr, TCall(t, elems), r); //TODO check function sign and param

			case ENew(t, params):
				/*
				var elems = [];

				for (e in params)
				{
					elems.push(typeExpr(e));
				}

				return makeTyped(expr, TNew(t, elems), makeMonomorph()); //TODO type of the TypePath
				*/
				throw "no class support";

			case EUnop(op, postFix, e):
				var t = typeExpr(e);

				return makeTyped(expr, TUnop(op, postFix, t), t.t); //TODO

			case EFunction(name, f):
				var at = [];
				var args = [];

				var fid = addSymbol(name);

				enter();
					for (a in f.args)
					{
						var sid = addSymbol(a.name);
						typeTable[sid] = switch (a.type)
						{
							case TPath(p):
								switch (p.name)
								{
									case "Int":
										BaseType.Int;

									default: makeMonomorph(); //TODO
								}

							default: makeMonomorph(); //TODO
						}
						at.push({ name: a.name, opt: a.opt, t: typeTable[sid] });
						args.push({ value: null, v: { capture: false, extra: null, id: sid, meta: null, name: a.name, t: null } });
					}

					var t = typeExpr(f.expr);
				leave();

				var ft = TFun(at, t.t);
				var sid = getSymbol(name);
				typeTable[sid] = ft;

				var te = makeTyped(expr, TFunction({ args: args, expr: t, t: t.t }), ft);
				return makeTyped(expr, TVar({ t: null, name: name, meta: null, id: sid, extra: null, capture: false }, te), ft);

			case EVars(vars):
				var v = vars[0]; //TODO how to make multiple nodes from this?
				var sid = addSymbol(v.name);
				var t = typeExpr(v.expr);
				typeTable[sid] = t.t;

				return makeTyped(expr, TVar({ capture: false, extra: null, id: sid, meta: null, name: v.name, t: null }, t), t.t);

			case EBlock(exprs):
				var elems = [];

				enter();
					for (e in exprs)
					{
						elems.push(typeExpr(e));
					}
				leave();

				var t = elems.length > 0 ? elems[elems.length - 1].t : typer.BaseType.Void;

				return makeTyped(expr, TBlock(elems), t);

			case EFor(it, expr):
				enter();
					typeExpr(it); //TODO get var and e1
					enter();
						var t = typeExpr(expr);
					leave();
				leave();

				return makeTyped(expr, TFor(null, null, t), typer.BaseType.Void); //TODO check

			case EIf(econd, eif, eelse):
				enter();
					var c = typeExpr(econd);
					switch (c.t)
					{
						default: //TODO needs to be bool
					}

					enter();
						var i = typeExpr(eif);
					leave();
					enter();
						var e = typeExpr(eelse);
					leave();
				leave();

				return makeTyped(expr, TIf(c, i, e), typer.BaseType.Void); //TODO check

			case EWhile(econd, e, normalWhile):
				enter();
					var c = typeExpr(econd); //TODO needs to be bool
					enter();
						var t = typeExpr(e);
					leave();
				leave();

				return makeTyped(expr, TWhile(c, t, normalWhile), typer.BaseType.Void); //TODO check

			case ESwitch(e, cases, edef):
				//TODO cases exprs must be from the switch expr
				enter();
					var t = typeExpr(e);
					var elems = [];

					for (c in cases)
					{
						var vals = [];

						enter();
							for (v in c.values)
							{
								vals.push(typeExpr(v));
							}
							enter();
								typeExpr(c.guard);
							leave();
							enter();
								var et = typeExpr(c.expr);
							leave();
						leave();

						elems.push({ values: vals, expr: et });
					}
					enter();
						var d = typeExpr(edef);
					leave();
				leave();

				return makeTyped(expr, TSwitch(t, elems, d), typer.BaseType.Void); //TODO check

			case ETry(e, catches):
				enter();
					var t = typeExpr(e);
					var elems = [];

					for (c in catches)
					{
						enter();
							var t = typeExpr(c.expr);
							elems.push({ v: { capture: false, extra: null, id: -1, meta: null, name: c.name, t: null }, expr: t });
						leave();
					}
				leave();

				return makeTyped(expr, TTry(t, elems), typer.BaseType.Void); //TODO check

			case EReturn(e):
				var t = typeExpr(e);

				return makeTyped(expr, TReturn(t), t.t);

			case EBreak:
				return makeTyped(expr, TBreak, typer.BaseType.Void);

			case EContinue:
				return makeTyped(expr, TContinue, typer.BaseType.Void);

			case EThrow(e):
				var t = typeExpr(e);

				return makeTyped(expr, TThrow(t), typer.BaseType.Void);

			case ECast(e, t):
				var t = typeExpr(e);

				return makeTyped(expr, TCast(t, null), makeMonomorph()); //TODO type of the TypePath

			case EMeta(s, e):
				var t = typeExpr(e);

				return makeTyped(expr, TMeta(s, t), t.t);

			case ECheckType(e, t):
				var t = typeExpr(e);

				return makeTyped(expr, TParenthesis(t), makeMonomorph()); //TODO

			case ETernary(econd, eif, eelse):
				enter();
					var c = typeExpr(econd); //TODO needs to be bool
					enter();
						var i = typeExpr(eif);
					leave();
					enter();
						var e = typeExpr(eelse); //TODO needs to unify with t
					leave();
				leave();

				return makeTyped(expr, TIf(c, i, e), i.t); //TODO type

			case EUntyped(e):
				throw "Untyped is not supported";

			case EDisplay(_, _), EDisplayNew(_):
				throw "cannot get display info";
		}
	}

	var symbolTable = new Map<String, Array<Int>>();
	var currentScope : Array<Array<String>> = [[]];
	var id = 0;
	var typeTable = new Map<Int, Type>();

	function insertTrace()
	{
		var sid = addSymbol("trace");
		typeTable[sid] = TFun([{ t: makeMonomorph(), opt:false, name: "value" }], typer.BaseType.Void);
	}

	function makeTyped(expr:Expr, texpr:TypedExprDef, type:Type) : TypedExpr
	{
		return { expr: texpr, pos: expr.pos, t: type };
	}

	function makeTypedVar(name:String, sid:Int, type:Type) : TypedExprDef
	{
		return TLocal({ capture: false, extra: null, id: sid, meta: null, name: name, t: type });
	}

	function makeMonomorph() : Type
	{
		//TODO allow this to be changed after unification
		return TMono(new RefImpl(null));
	}

	function enter()
	{
		currentScope.push([]);
	}

	function leave()
	{
		var s = currentScope.pop();

		for (i in s)
		{
			symbolTable[i].pop();
		}
	}

	function addSymbol(name:String) : Int
	{
		var sid = id++;
		currentScope[currentScope.length - 1].push(name);

		if (!symbolTable.exists(name))
		{
			symbolTable.set(name, [sid]);
		}
		else
		{
			symbolTable[name].push(sid);
		}

		typeTable[sid] = makeMonomorph();

		return sid;
	}

	function getSymbol(name:String) : Int
	{
		if (!symbolTable.exists(name) || symbolTable[name].length == 0)
		{
			return -1;
		}

		var sids = symbolTable[name];
		return sids[sids.length - 1];
	}
}
