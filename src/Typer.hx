import haxe.macro.Expr;
import typer.TConstant;
import typer.TExpr;
import typer.TType;
import typer.TTypedExprDef;

class Typer
{
	public function new()
	{
		insertTrace();
	}

	public function typeExpr(expr:Expr) : TExpr
	{
		switch (expr.expr)
		{
			case EConst(c):
				switch (c)
				{
					case CInt(v):
						return makeTyped(expr, TConst(TCInt(v)), TInt);

					case CFloat(f):
						return makeTyped(expr, TConst(TCFloat(f)), TFloat);

					case CIdent(s):
						var sid = getSymbol(s);
						return makeTyped(expr, TConst(TCIdent(sid)), typeTable[sid]);
						//TODO use TLocal

					case CRegexp(r, opt):
						return makeTyped(expr, TConst(TCRegexp(r, opt)), TRegexp);

					case CString(s):
						return makeTyped(expr, TConst(TCString(s)), TString);
				}

			case EArray(e1, e2):
				var t1 = typeExpr(e1);
				var t2 = typeExpr(e2);

				var of = switch (t1.type)
				{
					case TArray(of): of;
					default: throw "Array access only allowed on arrays";
				}

				switch (t2.type)
				{
					case TInt:
					default: throw "Array index must be int";
				}

				return makeTyped(expr, TArray(t1, t2), of);

			case EBinop(op, e1, e2):
				var t1 = typeExpr(e1);
				var t2 = typeExpr(e2);

				var t = switch([t1.type, t2.type])
				{
					case [TInt, TInt]: TInt;
					case [TInt, TFloat], [TFloat, TInt], [TFloat, TFloat]: TFloat;
					default: throw "TODO binop return type"; //TODO
				}

				return makeTyped(expr, TBinop(op, t1, t2), t);

			case EField(e, field):
				var t = typeExpr(e);

				return makeTyped(expr, TField(t, field), TUnknown); //TODO class/object support

			case EParenthesis(e):
				enter();
					var t = typeExpr(e);
				leave();

				return makeTyped(expr, TParenthesis(t), t.type);

			case EObjectDecl(fields):
				var tfields = [];

				for (f in fields)
				{
					tfields.push({ name: f.field, expr: typeExpr(f.expr) });
				}

				return makeTyped(expr, TObjectDecl(tfields), TObject);

			case EArrayDecl(values):
				var t = null;
				var elems = [];

				for (e in values)
				{
					var st = typeExpr(e);
					elems.push(st);

					if (t == null)
					{
						t = st.type;
					}
					else
					{
						if (t != st.type) //TODO monomorph/unify
						{
							throw "array must be of single type";
						}
					}
				}

				return makeTyped(expr, TArrayDecl(elems), TArray(t));

			case ECall(e, params):
				var t = typeExpr(e);
				var elems = [];

				var r = switch (t.type)
				{
					case TFn(args, ret): ret;
					default: throw "Can only call functions";
				}

				for (e in params)
				{
					elems.push(typeExpr(e));
				}

				return makeTyped(expr, TCall(t, elems), r); //TODO check function sign and param

			case ENew(t, params):
				var elems = [];

				for (e in params)
				{
					elems.push(typeExpr(e));
				}

				return makeTyped(expr, TNew(t, elems), TUnknown); //TODO type of the TypePath

			case EUnop(op, postFix, e):
				var t = typeExpr(e);

				return makeTyped(expr, TUnop(op, postFix, t), t.type); //TODO

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
										TInt;

									default: TUnknown; //TODO
								}

							default: TUnknown; //TODO
						}
						at.push(typeTable[sid]);
						args.push({ capture: false, extra: null, id: sid, meta: null, name: a.name, t: null });
					}

					var t = typeExpr(f.expr);
				leave();

				var ft = TFn(at, t.type);
				var sid = getSymbol(name);
				typeTable[sid] = ft;

				var te = makeTyped(expr, TFunction(args, t, t.type), ft);
				return makeTyped(expr, TVar({ t: null, name: name, meta: null, id: sid, extra: null, capture: false }, te), ft);

			case EVars(vars):
				var v = vars[0]; //TODO how to make multiple nodes from this?
				var sid = addSymbol(v.name);
				var t = typeExpr(v.expr);
				typeTable[sid] = t.type;

				return makeTyped(expr, TVar({ capture: false, extra: null, id: sid, meta: null, name: v.name, t: null }, t), t.type);

			case EBlock(exprs):
				var elems = [];

				enter();
					for (e in exprs)
					{
						elems.push(typeExpr(e));
					}
				leave();

				var t = elems.length > 0 ? elems[elems.length - 1].type : TVoid;

				return makeTyped(expr, TBlock(elems), t);

			case EFor(it, expr):
				enter();
					typeExpr(it); //TODO get var and e1
					enter();
						var t = typeExpr(expr);
					leave();
				leave();

				return makeTyped(expr, TFor(null, null, t), TVoid); //TODO check

			case EIf(econd, eif, eelse):
				enter();
					var c = typeExpr(econd);
					switch (c.type)
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

				return makeTyped(expr, TIf(c, i, e), TVoid); //TODO check

			case EWhile(econd, e, normalWhile):
				enter();
					var c = typeExpr(econd); //TODO needs to be bool
					enter();
						var t = typeExpr(e);
					leave();
				leave();

				return makeTyped(expr, TWhile(c, t, normalWhile), TVoid); //TODO check

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

				return makeTyped(expr, TSwitch(t, elems, d), TVoid); //TODO check

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

				return makeTyped(expr, TTry(t, elems), TVoid); //TODO check

			case EReturn(e):
				var t = typeExpr(e);

				return makeTyped(expr, TReturn(t), t.type);

			case EBreak:
				return makeTyped(expr, TBreak, TVoid);

			case EContinue:
				return makeTyped(expr, TContinue, TVoid);

			case EThrow(e):
				var t = typeExpr(e);

				return makeTyped(expr, TThrow(t), TVoid);

			case ECast(e, t):
				var t = typeExpr(e);

				return makeTyped(expr, TCast(t, null), TUnknown); //TODO type of the TypePath

			case EMeta(s, e):
				var t = typeExpr(e);

				return makeTyped(expr, TMeta(s, t), t.type);

			case ECheckType(e, t):
				var t = typeExpr(e);

				return makeTyped(expr, TParenthesis(t), TUnknown); //TODO

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

				return makeTyped(expr, TIf(c, i, e), i.type); //TODO type

			case EUntyped(e):
				throw "Untyped is not supported";

			case EDisplay(_, _), EDisplayNew(_):
				throw "cannot get display info";
		}
	}

	var symbolTable = new Map<String, Array<Int>>();
	var currentScope : Array<Array<String>> = [[]];
	var id = 0;
	var typeTable = new Map<Int, TType>();

	function insertTrace()
	{
		var sid = addSymbol("trace");
		typeTable[sid] = TFn([TUnknown], TVoid);
	}

	function makeTyped(expr:Expr, texpr:TTypedExprDef, type:TType) : TExpr
	{
		return { expr: texpr, pos: expr.pos, type: type };
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

		typeTable[sid] = TMonomorph;

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
