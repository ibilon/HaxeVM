import haxe.macro.Type;

class Display
{
	public static function displayTExpr(expr:TypedExpr)
	{
		//print(expr.t); //TODO proper/less verbose print of type

		switch (expr.expr)
		{
			case TConst(c):
				print("TConst", c);

			case TArray(e1, e2):
				print("TArray");
				indent++;
				displayTExpr(e1);
				displayTExpr(e2);
				indent--;

			case TBinop(op, e1, e2):
				print("TBinop", op);
				indent++;
				displayTExpr(e1);
				displayTExpr(e2);
				indent--;

			case TField(e, field):
				print("TField"); //, field); //TODO displayFieldAccess(field)
				indent++;
				displayTExpr(e);
				indent--;

			case TParenthesis(e):
				print("TParenthesis");
				indent++;
				displayTExpr(e);
				indent--;

			case TObjectDecl(fields):
				print("TObjectDecl");
				indent++;
				for (f in fields)
				{
					print("field", f.name);
					displayTExpr(f.expr);
				}
				indent--;

			case TArrayDecl(values):
				print("TArrayDecl");
				indent++;
				for (e in values)
				{
					displayTExpr(e);
				}
				indent--;

			case TCall(e, el):
				print("TCall");
				indent++;
				displayTExpr(e);
				indent++;
				for (e in el)
				{
					displayTExpr(e);
				}
				indent--;
				indent--;

			case TNew(_.get() => c, params, el):
				print("TNew", c.name);
				indent++;
				for (e in el)
				{
					displayTExpr(e);
				}
				indent--;

			case TUnop(op, postFix, e):
				print("TUnop " + (postFix ? "post" : "pre"), op);
				indent++;
				displayTExpr(e);
				indent--;

			case TFunction(tfunc):
				print("TFunction");
				indent++;
				for (a in tfunc.args)
				{
					print(a.v.name, a.v.t);
				}
				indent++;
				displayTExpr(tfunc.expr);
				indent--;
				indent--;

			case TVar(v, expr):
				print("TVar", v.name);
				indent++;
				displayTExpr(expr);
				indent--;

			case TBlock(exprs):
				print("TBlock");
				indent++;
				for (e in exprs)
				{
					displayTExpr(e);
				}
				indent--;

			case TFor(v, e1, e2):
				print("TFor"); //TODO
				indent++;
				displayTExpr(e2);
				indent--;

			case TIf(econd, eif, eelse):
				print("TIf");
				indent++;
				displayTExpr(econd);
				indent++;
				displayTExpr(eif);
				if (eelse != null)
				{
					displayTExpr(eelse);
				}
				indent--;
				indent--;

			case TWhile(econd, e, normalWhile):
				print("TWhile", normalWhile);
				indent++;
				displayTExpr(econd);
				indent++;
				displayTExpr(e);
				indent--;
				indent--;

			case TSwitch(e, cases, edef):
				print("TSwitch");
				indent++;
				displayTExpr(e);
				indent++;
				for (c in cases)
				{
					for (v in c.values)
					{
						displayTExpr(v);
					}
					displayTExpr(c.expr);
				}
				indent--;
				indent--;

			case TTry(e, catches):
				print("TTry");
				indent++;
				displayTExpr(e);
				indent++;
				for (c in catches)
				{
					displayTExpr(c.expr);
				}
				indent--;
				indent--;

			case TReturn(e):
				print("TReturn");
				indent++;
				displayTExpr(e);
				indent--;

			case TBreak:
				print("TBreak");

			case TContinue:
				print("TContinue");

			case TThrow(e):
				print("TThrow");
				indent++;
				displayTExpr(e);
				indent--;

			case TCast(e, m):
				print("TCast", m);
				indent++;
				displayTExpr(e);
				indent--;

			case TMeta(s, e):
				print("TMeta", s.name);
				indent++;
				displayTExpr(e);
				indent--;

			case TEnumIndex(e1):
				print("TEnumIndex");
				indent++;
				displayTExpr(e1);
				indent--;

			case TEnumParameter(e1, ef, index):
				print("TEnumParameter " + ef.name + "@" + index, ef.type);
				indent++;
				displayTExpr(e1);
				indent--;

			case TIdent(s):
				print("TIdent", s);

			case TLocal(v):
				print("TLocal " + v.name + "@" + v.id);

			case TTypeExpr(m):
				print("TTypeExpr", m);
		}
	}

	static var indent = 0;

	static function print(value:Dynamic, ?value2:Dynamic)
	{
		for (_ in 0...indent)
		{
			Sys.print("\t");
		}
		Sys.print(value);

		if (value2 != null)
		{
			Sys.print(" ");
			Sys.println(value2);
		}
		else
		{
			Sys.println("");
		}
	}
}
