package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxevm.SymbolTable.Symbol;
import haxevm.typer.BaseType;
import haxevm.typer.Operator;
import haxevm.typer.RefImpl;

class ExprTyper
{
	var symbolTable:SymbolTable;
	var module:Module;
	var cls:ClassType;
	var expr:Expr;

	public function new(symbolTable:SymbolTable, module:Module, cls:ClassType, expr:Expr)
	{
		this.symbolTable = symbolTable;
		this.module = module;
		this.cls = cls;
		this.expr = expr;
	}

	public function type():TypedExpr
	{
		return typeExpr(expr);
	}

	function typeExpr(expr:Expr):TypedExpr
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

					case CIdent("true"):
						return makeTyped(expr, TConst(TBool(true)), BaseType.Bool);

					case CIdent("false"):
						return makeTyped(expr, TConst(TBool(false)), BaseType.Bool);

					case CIdent("null"):
						return makeTyped(expr, TConst(TNull), makeMonomorph());

					case CIdent("this"):
						return makeTyped(expr, TConst(TThis), makeMonomorph());

					case CIdent("super"):
						return makeTyped(expr, TConst(TSuper), makeMonomorph());

					case CIdent(s):
						var sid = symbolTable.getSymbol(s);
						var type = symbolTable.getVar(sid); // TODO ident could be a package or module or type or field

						return makeTyped(expr, makeTypedVar(s, sid, type), type);

					case CRegexp(r, opt):
						// return makeTyped(expr, TConst(TCRegexp(r, opt)), TRegexp);
						throw "no regex support";

					case CString(s):
						return makeTyped(expr, TConst(TString(s)), BaseType.String);
				}

			case EArray(e1, e2):
				var t1 = typeExpr(e1);
				var t2 = typeExpr(e2);

				var of = switch (t1.t)
				{
					case TInst(_.get() => t, params) if (BaseType.isArray(t1.t)):
						params[0];

					default:
						throw "Array access only allowed on arrays";
				}

				if (!BaseType.isInt(t2.t))
				{
					throw "Array index must be int " + t2.t;
				}

				return makeTyped(expr, TArray(t1, t2), of);

			case EBinop(op, e1, e2):
				var t1 = typeExpr(e1);
				var t2 = typeExpr(e2);

				return makeTyped(expr, TBinop(op, t1, t2), Operator.binop(op, t1.t, t2.t));

			case EField(e, field):
				var t = typeExpr(e);

				// TODO class
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

					default:
						throw "field access on non object " + t.t;
				}

				if (sub == null)
				{
					throw "object has no field " + field;
				}

				return makeTyped(expr, TField(t, FAnon(new RefImpl(sub))), sub.type);

			case EParenthesis(e):
				symbolTable.enter();
				var t = typeExpr(e);
				symbolTable.leave();

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
						if (t != st.t) // TODO monomorph/unify
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
					case TFun(_, ret):
						ret;

					case TMono(_):
						makeMonomorph();

					default:
						throw "Can only call functions";
				}

				for (e in params)
				{
					elems.push(typeExpr(e));
				}

				if (isTrace(e))
				{
					// TODO propagate pos info from compiler
					elems.unshift(tracePosition(e));
				}

				return makeTyped(expr, TCall(t, elems), r); // TODO check function sign and param

			case ENew(t, params):
				/*
				var elems = [];

				for (e in params)
				{
					elems.push(typeExpr(e));
				}

				return makeTyped(expr, TNew(t, elems), makeMonomorph()); // TODO type of the TypePath
				*/
				throw "no class support";

			case EUnop(op, postFix, e):
				var t = typeExpr(e);

				return makeTyped(expr, TUnop(op, postFix, t), Operator.unop(op, t.t));

			case EFunction(name, f):
				var at = [];
				var args = [];

				var fid = name != null ? symbolTable.addVar(name) : -1;

				symbolTable.enter();
				for (a in f.args)
				{
					var sid = symbolTable.addVar(a.name);
					symbolTable[sid] = SVar(convertComplexType(a.type));

					at.push({
						name: a.name,
						opt: a.opt,
						t: symbolTable.getVar(sid)
					});

					args.push({
						value: null,
						v: {
							capture: false,
							extra: null,
							id: sid,
							meta: null,
							name: a.name,
							t: null
						}
					});
				}

				if (fid != -1 && f.ret != null)
				{
					symbolTable[fid] = SVar(TFun(at, convertComplexType(f.ret)));
				}

				var t = typeExpr(f.expr);
				symbolTable.leave();

				var ft = TFun(at, t.t); // TODO doing double work? see previous if
				var te = makeTyped(expr, TFunction({
					args: args,
					expr: t,
					t: t.t
				}), ft);

				if (fid != -1)
				{
					symbolTable[fid] = SVar(ft);

					return makeTyped(expr, TVar({
						t: null,
						name: name,
						meta: null,
						id: fid,
						extra: null,
						capture: false
					}, te), ft);
				}
				else
				{
					return te;
				}

			case EVars(vars):
				var v = vars[0]; // TODO how to make multiple nodes from this?
				var sid = symbolTable.addVar(v.name);
				var t = v.expr != null ? typeExpr(v.expr) : null;
				var tt = t != null ? t.t : makeMonomorph();
				symbolTable[sid] = SVar(tt);

				return makeTyped(expr, TVar({
					capture: false,
					extra: null,
					id: sid,
					meta: null,
					name: v.name,
					t: null
				}, t), tt);

			case EBlock(exprs):
				var elems = [];

				symbolTable.enter();
				for (e in exprs)
				{
					elems.push(typeExpr(e));
				}
				symbolTable.leave();

				var t = elems.length > 0 ? elems[elems.length - 1].t : BaseType.Void;

				return makeTyped(expr, TBlock(elems), t);

			case EFor(it, expr):
				var s = null;
				var min = 0;
				var max = 0;

				switch (it.expr)
				{
					case EBinop(OpIn, e1, e2):
						s = switch (e1.expr)
						{
							case EConst(CIdent(s)):
								s;

							default:
								throw "unsuported for syntax";
						}

						switch (e2.expr)
						{
							case EBinop(OpInterval, e1, e2):
								switch (e1.expr)
								{
									case EConst(CInt(i)):
										min = Std.parseInt(i);

									default:
										throw "unsuported for syntax";
								}

								switch (e2.expr)
								{
									case EConst(CInt(i)):
										max = Std.parseInt(i);

									default:
										throw "unsuported for syntax";
								}

							default:
								throw "unsuported for syntax";
						}

					default:
						throw "unsuported for syntax";
				}

				if (min > max)
				{
					throw "can't iterate backwards";
				}

				var block = [];

				if (min < max)
				{
					symbolTable.enter();
					var min = {
						expr: EConst(CInt('${min - 1}')),
						pos: null
					};

					var v = typeExpr({
						expr: EVars([{
							name: s,
							expr: min,
							type: null
						}]),
						pos: null
					});

					var id = {
						expr: EConst(CIdent(s)),
						pos: null
					};

					var it = {
						expr: EUnop(OpIncrement, false, id),
						pos: null
					};

					var cond = {
						expr: EBinop(OpLte, it, {
							expr: EConst(CInt('$max')),
							pos: null
						}),
						pos: null
					};

					var w = typeExpr({
						expr: EWhile(cond, expr, true),
						pos: null
					});

					block = [v, w];
					symbolTable.leave();
				}

				return makeTyped(expr, TBlock(block), BaseType.Void); // TODO check

			case EIf(econd, eif, eelse):
				symbolTable.enter();
				var c = typeExpr(econd);

				if (!BaseType.isBool(c.t))
				{
					throw "if condition must be bool is " + c.t;
				}

				symbolTable.enter();
				var i = typeExpr(eif);
				symbolTable.leave();
				symbolTable.enter();
				var e = eelse != null ? typeExpr(eelse) : null;
				symbolTable.leave();
				symbolTable.leave();

				return makeTyped(expr, TIf(c, i, e), BaseType.Void); // TODO check

			case EWhile(econd, e, normalWhile):
				symbolTable.enter();
				var c = typeExpr(econd);

				if (!BaseType.isBool(c.t))
				{
					throw "while condition must be bool is " + c.t;
				}

				symbolTable.enter();
				var t = typeExpr(e);
				symbolTable.leave();
				symbolTable.leave();

				return makeTyped(expr, TWhile(c, t, normalWhile), BaseType.Void); // TODO check

			case ESwitch(e, cases, edef):
				// TODO cases exprs must be from the switch expr
				var eif = edef;
				var i = cases.length - 1;

				while (i >= 0)
				{
					var c = cases[i--];
					var cond = {
						expr: EBinop(OpEq, e, c.values[0]),
						pos: null
					}; // TODO OpEq wont work on anon type

					for (j in 1...c.values.length)
					{
						cond = {
							expr: EBinop(OpBoolOr, cond, {
								expr: EBinop(OpEq, e, c.values[j]),
								pos: null
							}),
							pos: null
						};
					}

					if (c.guard != null)
					{
						cond = {
							expr: EBinop(OpBoolAnd, {
								expr: EParenthesis(cond),
								pos: null
							}, c.guard),
							pos: null
						};
					}

					eif = {
						expr: EIf(cond, c.expr, eif),
						pos: null
					};
				}

				return typeExpr(eif);

			case ETry(e, catches):
				symbolTable.enter();
				var t = typeExpr(e);
				var elems = [];

				for (c in catches)
				{
					symbolTable.enter();
					var sid = symbolTable.addVar(c.name);
					symbolTable[sid] = SVar(convertComplexType(c.type));
					var t = typeExpr(c.expr);

					elems.push({
						v: {
							capture: false,
							extra: null,
							id: sid,
							meta: null,
							name: c.name,
							t: symbolTable.getVar(sid)
						},
						expr: t
					});
					symbolTable.leave();
				}
				symbolTable.leave();

				return makeTyped(expr, TTry(t, elems), BaseType.Void); // TODO check

			case EReturn(e):
				var t = typeExpr(e);

				return makeTyped(expr, TReturn(t), t.t);

			case EBreak:
				return makeTyped(expr, TBreak, BaseType.Void);

			case EContinue:
				return makeTyped(expr, TContinue, BaseType.Void);

			case EThrow(e):
				var t = typeExpr(e);

				return makeTyped(expr, TThrow(t), BaseType.Void);

			case ECast(e, t):
				var t = typeExpr(e);

				return makeTyped(expr, TCast(t, null), makeMonomorph()); // TODO type of the TypePath

			case EMeta(s, e):
				var t = typeExpr(e);

				return makeTyped(expr, TMeta(s, t), t.t);

			case ECheckType(e, t):
				var t = typeExpr(e);

				return makeTyped(expr, TParenthesis(t), makeMonomorph()); // TODO

			case ETernary(econd, eif, eelse):
				symbolTable.enter();
				var c = typeExpr(econd);

				if (!BaseType.isBool(c.t))
				{
					throw "ternary condition must be bool is " + c.t;
				}

				symbolTable.enter();
				var i = typeExpr(eif);
				symbolTable.leave();
				symbolTable.enter();
				var e = typeExpr(eelse); // TODO needs to unify with t
				symbolTable.leave();
				symbolTable.leave();

				return makeTyped(expr, TIf(c, i, e), i.t); // TODO type

			case EUntyped(e):
				throw "Untyped is not supported";

			case EDisplay(_, _), EDisplayNew(_):
				throw "cannot get display info";
		}
	}

	inline function isTrace(e:Expr):Bool
	{
		return e.expr.match(EConst(CIdent("trace")));
	}

	function makeTyped(expr:Expr, texpr:TypedExprDef, type:Type):TypedExpr
	{
		return {
			expr: texpr,
			pos: expr.pos,
			t: type
		};
	}

	function makeTypedVar(name:String, sid:Int, type:Type):TypedExprDef
	{
		return TLocal({
			capture: false,
			extra: null,
			id: sid,
			meta: null,
			name: name,
			t: type
		});
	}

	function makeMonomorph():Type
	{
		// TODO allow this to be changed after unification
		return TMono(new RefImpl(null));
	}

	function convertComplexType(t:ComplexType):Type
	{
		return switch (t)
		{
			case TPath(p): // TODO convert TPath to Type
				switch (p.name)
				{
					case "Int":
						BaseType.Int;

					case "Bool":
						BaseType.Bool;

					case "Float":
						BaseType.Float;

					case "String":
						BaseType.String;

					default: throw "unknown type";
				}

			default: // TODO TAnonymous | TExtend | TFunction | TIntersection | TNamed | TOptional | TParent
				makeMonomorph();
		}
	}

	function tracePosition(expr:Expr):TypedExpr
	{
		var bounds = {
			min: 0,
			max: module.linesData.length - 1
		};

		while (bounds.max - bounds.min > 1)
		{
			var i = Std.int((bounds.min + bounds.max) / 2);
			var end = module.linesData[i];

			if (expr.pos.min <= end)
			{
				bounds.max = i;
			}

			if (expr.pos.min >= end)
			{
				bounds.min = i;
			}
		}

		var line = bounds.max + 1;
		return makeTyped(expr, TConst(TString(module.file + ":" + line + ":")), BaseType.String);
	}
}
