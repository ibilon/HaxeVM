package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxevm.SymbolTable.Symbol;
import haxevm.typer.BaseType;
import haxevm.typer.Operator;
import haxevm.typer.RefImpl;

class ExprTyper
{
	var compiler:Compiler;
	var module:Module;
	var cls:ClassType;
	var expr:Null<Expr>;

	public function new(compiler:Compiler, module:Module, cls:ClassType, expr:Null<Expr>)
	{
		this.compiler = compiler;
		this.module = module;
		this.cls = cls;
		this.expr = expr;
	}

	public function type():TypedExpr
	{
		var expr = expr;

		if (expr != null)
		{
			return typeExpr(expr);
		}
		else
		{
			return emptyTypedExpr();
		}
	}

	function emptyExpr():Expr
	{
		return {
			expr: EBlock([]),
			pos: PositionImpl.makeEmpty()
		}
	}

	function emptyTypedExpr():TypedExpr
	{
		return {
			expr: TBlock([]),
			pos: PositionImpl.makeEmpty(),
			t: BaseType.tVoid
		};
	}

	function typePrettyPrint(t:Type):String
	{
		function name(name:String, p:Array<Type>):String
		{
			return if (p.length == 0)
			{
				name;
			}
			else
			{
				'${name}<${p.map(typePrettyPrint).join(",")}>';
			}
		}

		return switch (t)
		{
			case TInst(_.get() => t, p):
				name(t.name, p);

			case TAbstract(_.get() => t, p):
				name(t.name, p);

			case TAnonymous(_.get() => a):
				var fields = [];

				for (f in a.fields)
				{
					fields.push('${f.name} : ${typePrettyPrint(f.type)}');
				}

				var buf = new StringBuf();
				buf.add('{ ');
				buf.add(fields.join(", "));
				buf.add(' }');
				buf.toString();

			case TFun(args, ret):
				var pargs = [];

				for (a in args)
				{
					if (a.name != "")
					{
						pargs.push('(${a.name} : ${typePrettyPrint(a.t)})');
					}
					else
					{
						pargs.push(typePrettyPrint(a.t));
					}
				}

				if (args.length == 0)
				{
					pargs.push("Void");
				}

				var buf = new StringBuf();
				buf.add(pargs.join(" -> "));
				buf.add(" -> ");
				buf.add(typePrettyPrint(ret));
				buf.toString();

			case TMono(t):
				return 'Unknown<0>';

			default:
				throw "not supported";
		}
	}

	function typeExpr(expr:Expr):TypedExpr
	{
		switch (expr.expr)
		{
			case EConst(c):
				switch (c)
				{
					case CInt(v):
						var value = switch (Std.parseInt(v))
						{
							case null:
								throw "invalid integer";

							case value:
								value;
						}

						return makeTyped(expr, TConst(TInt(value)), BaseType.tInt);

					case CFloat(f):
						return makeTyped(expr, TConst(TFloat(f)), BaseType.tFloat);

					case CIdent("true"):
						return makeTyped(expr, TConst(TBool(true)), BaseType.tBool);

					case CIdent("false"):
						return makeTyped(expr, TConst(TBool(false)), BaseType.tBool);

					case CIdent("null"):
						return makeTyped(expr, TConst(TNull), makeMonomorph());

					case CIdent("this"):
						return makeTyped(expr, TConst(TThis), makeMonomorph());

					case CIdent("super"):
						return makeTyped(expr, TConst(TSuper), makeMonomorph());

					case CIdent(s):
						var sid = compiler.symbolTable.getSymbol(s);
						var symbol = compiler.symbolTable[sid];

						return switch (symbol)
						{
							case SModule(_):
								throw "not implemented";

							case SType(m):
								if (module.name == s)
								{
									// Main type of module
									makeTyped(expr, TTypeExpr(m), moduleTypeType(symbol));
								}
								else
								{
									typeExpr({ expr: EField({ expr: EConst(CIdent(module.name)), pos: PositionImpl.makeEmpty() }, s), pos: PositionImpl.makeEmpty() });
								}

							case SField(_):
								typeExpr({ expr: EField({ expr: EConst(CIdent(cls.name)), pos: PositionImpl.makeEmpty() }, s), pos: PositionImpl.makeEmpty() });

							case SVar(t):
								makeTyped(expr, makeTypedVar(s, sid, t), t);
						}

					case CRegexp(r, opt):
						// return makeTyped(expr, TConst(TCRegexp(r, opt)), TRegexp);
						throw "no regex support";

					case CString(s):
						return makeTyped(expr, TConst(TString(s)), BaseType.tString);
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
				switch (t.t)
				{
					case TAnonymous(_.get() => a):
						for (f in a.fields)
						{
							if (f.name == field)
							{
								return makeTyped(expr, TField(t, FAnon(RefImpl.make(f))), f.type);
							}
						}

						throw "object has no field " + field;

					case TInst(c, params):
						for (s in c.get().statics.get())
						{
							if (s.name == field)
							{
								return makeTyped(expr, TField(t, FStatic(c, RefImpl.make(s))), s.type);
							}
						}

						throw "class has no field " + field;

					default:
						throw "field access not implemented " + t.t;
				}

			case EParenthesis(e):
				compiler.symbolTable.enter();
				var t = typeExpr(e);
				compiler.symbolTable.leave();

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
						overloads: RefImpl.make([]),
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

				return makeTyped(expr, TObjectDecl(ofields), TAnonymous(RefImpl.make({
					fields: tfields,
					status: AConst
				})));

			case EArrayDecl(values):
				var t:Null<Type> = null;
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

				return makeTyped(expr, TArrayDecl(elems), BaseType.tArray(t != null ? t : makeMonomorph()));

			case ECall(_ => { expr: EConst(CIdent("$type")) }, params) if (params.length == 1):
				var t = typeExpr(params[0]);
				compiler.warnings.push('${positionString(params[0].pos, true)} Warning : ${typePrettyPrint(t.t)}');
				return t;

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
						throw "Can only call functions " + t.t;
				}

				for (e in params)
				{
					elems.push(typeExpr(e));
				}

				if (isTrace(e))
				{
					elems.unshift(makeTyped(e, TConst(TString(positionString(e.pos))), BaseType.tString));
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
				var at:Array<{ name:String, opt:Bool, t:Type }> = [];
				var args = [];

				var fid = name != null ? compiler.symbolTable.addVar(name, TLazy(() -> throw "not typed yet")) : -1;

				compiler.symbolTable.enter();
				for (a in f.args)
				{
					var sid = compiler.symbolTable.addVar(a.name, ComplexTypeUtils.convertComplexType(a.type));
					var t:Type = switch (compiler.symbolTable.getVar(sid))
					{
						case null:
							throw "symbol doesn't exist";

						case value:
							value;
					}
					var opt = a.opt;

					at.push({
						name: a.name,
						opt: opt != null ? opt : false,
						t: t
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
					compiler.symbolTable[fid] = SVar(TFun(at, ComplexTypeUtils.convertComplexType(f.ret)));
				}

				var fe = f.expr;
				var t = fe != null ? typeExpr(fe) : emptyTypedExpr();
				compiler.symbolTable.leave();

				var ft = TFun(at, t.t); // TODO doing double work? see previous if
				var te = makeTyped(expr, TFunction({
					args: args,
					expr: t,
					t: t.t
				}), ft);

				if (name != null)
				{
					compiler.symbolTable[fid] = SVar(ft);
					var v:TVar = {
						t: ft,
						name: name != null ? name : "", // null safety is weird here
						meta: MetaAccessImpl.make(null),
						id: fid,
						extra: null,
						capture: false
					};

					return makeTyped(expr, TVar(v, te), ft);
				}
				else
				{
					return te;
				}

			case EVars(vars):
				var v = vars[0]; // TODO how to make multiple nodes from this?
				var sid = compiler.symbolTable.addVar(v.name, ComplexTypeUtils.convertComplexType(v.type));
				var e = v.expr;
				var t = e != null ? typeExpr(e) : null;
				var tt = t != null ? t.t : makeMonomorph();
				compiler.symbolTable[sid] = SVar(tt);

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

				compiler.symbolTable.enter();
				for (e in exprs)
				{
					elems.push(typeExpr(e));
				}
				compiler.symbolTable.leave();

				var t = elems.length > 0 ? elems[elems.length - 1].t : BaseType.tVoid;

				return makeTyped(expr, TBlock(elems), t);

			case EFor(it, expr):
				var s;
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
										min = switch (Std.parseInt(i))
										{
											case null:
												throw "invalid integer";

											case value:
												value;
										}

									default:
										throw "unsuported for syntax";
								}

								switch (e2.expr)
								{
									case EConst(CInt(i)):
										max = switch (Std.parseInt(i))
										{
											case null:
												throw "invalid integer";

											case value:
												value;
										}

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
					compiler.symbolTable.enter();
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
					compiler.symbolTable.leave();
				}

				return makeTyped(expr, TBlock(block), BaseType.tVoid); // TODO check

			case EIf(econd, eif, eelse):
				compiler.symbolTable.enter();
				var c = typeExpr(econd);

				if (!BaseType.isBool(c.t))
				{
					throw "if condition must be bool is " + c.t;
				}

				compiler.symbolTable.enter();
				var i = typeExpr(eif);
				compiler.symbolTable.leave();
				compiler.symbolTable.enter();
				var e = eelse != null ? typeExpr(eelse) : null;
				compiler.symbolTable.leave();
				compiler.symbolTable.leave();

				return makeTyped(expr, TIf(c, i, e), BaseType.tVoid); // TODO check

			case EWhile(econd, e, normalWhile):
				compiler.symbolTable.enter();
				var c = typeExpr(econd);

				if (!BaseType.isBool(c.t))
				{
					throw "while condition must be bool is " + c.t;
				}

				compiler.symbolTable.enter();
				var t = typeExpr(e);
				compiler.symbolTable.leave();
				compiler.symbolTable.leave();

				return makeTyped(expr, TWhile(c, t, normalWhile), BaseType.tVoid); // TODO check

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

					var g = c.guard;
					if (g != null)
					{
						cond = {
							expr: EBinop(OpBoolAnd, {
								expr: EParenthesis(cond),
								pos: null
							}, g),
							pos: null
						};
					}

					var ce = c.expr;
					eif = {
						expr: EIf(cond, ce != null ? ce : emptyExpr(), eif),
						pos: null
					};
				}

				return typeExpr(eif);

			case ETry(e, catches):
				compiler.symbolTable.enter();
				var t = typeExpr(e);
				var elems:Array<{ v:TVar, expr:TypedExpr }> = [];

				for (c in catches)
				{
					compiler.symbolTable.enter();
					var sid = compiler.symbolTable.addVar(c.name, ComplexTypeUtils.convertComplexType(c.type));
					var t = typeExpr(c.expr);
					var vt:Type = switch (compiler.symbolTable.getVar(sid))
					{
						case null:
							throw 'unknown symbol $sid';

						case value:
							value;
					}

					elems.push({
						v: {
							capture: false,
							extra: null,
							id: sid,
							meta: MetaAccessImpl.make(null),
							name: c.name,
							t: vt
						},
						expr: t
					});
					compiler.symbolTable.leave();
				}
				compiler.symbolTable.leave();

				return makeTyped(expr, TTry(t, elems), BaseType.tVoid); // TODO check

			case EReturn(e):
				var t = e != null ? typeExpr(e) : null;

				return makeTyped(expr, TReturn(t), t != null ? t.t : BaseType.tVoid);

			case EBreak:
				return makeTyped(expr, TBreak, BaseType.tVoid);

			case EContinue:
				return makeTyped(expr, TContinue, BaseType.tVoid);

			case EThrow(e):
				var t = typeExpr(e);

				return makeTyped(expr, TThrow(t), BaseType.tVoid);

			case ECast(e, t):
				var t = typeExpr(e);

				return makeTyped(expr, TCast(t, null), makeMonomorph()); // TODO type of the TypePath

			case EMeta(s, e):
				var t = typeExpr(e);

				return makeTyped(expr, TMeta(s, t), t.t);

			case ECheckType(e, t):
				var te = typeExpr(e);

				return makeTyped(expr, TParenthesis(te), ComplexTypeUtils.convertComplexType(t));

			case ETernary(econd, eif, eelse):
				compiler.symbolTable.enter();
				var c = typeExpr(econd);

				if (!BaseType.isBool(c.t))
				{
					throw "ternary condition must be bool is " + c.t;
				}

				compiler.symbolTable.enter();
				var i = typeExpr(eif);
				compiler.symbolTable.leave();
				compiler.symbolTable.enter();
				var e = typeExpr(eelse); // TODO needs to unify with t
				compiler.symbolTable.leave();
				compiler.symbolTable.leave();

				return makeTyped(expr, TIf(c, i, e), i.t); // TODO type

			case EUntyped(e):
				throw "Untyped is not supported";

			case EDisplay(_, _), EDisplayNew(_):
				throw "cannot get display info";
		}
	}

	function moduleTypeType(symbol:Symbol):Type
	{
		switch (symbol)
		{
			case SType(m):
				return switch (m)
				{
					case TClassDecl(c):
						TInst(c, []);

					default:
						throw "not implemented";
				}

			default:
				throw "not module";
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
		return TMono(RefImpl.make(null));
	}

	function positionString(pos:Position, characters:Bool = false):String
	{
		var min = 0;
		var max = module.linesData.length - 1;

		while (max - min > 1)
		{
			var i = Math.ceil((min + max) / 2);
			var end = module.linesData[i];

			if (pos.min <= end)
			{
				max = i;
			}

			if (pos.min >= end)
			{
				min = i;
			}
		}

		var line = max + 1;
		var spos = '${module.file}:$line:';

		if (!characters)
		{
			return spos;
		}

		var endmax = max;

		while (pos.max > module.linesData[endmax])
		{
			++endmax;
		}

		if (endmax == max)
		{
			var cstart = pos.min - module.linesData[max - 1] + 1;
			var cend = cstart + pos.max - pos.min;
			return '${spos} characters ${cstart}-${cend} :';
		}
		else
		{
			return '${spos} lines ${line}-${endmax + 1} :';
		}
	}
}
