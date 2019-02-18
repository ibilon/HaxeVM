package typer;

import haxe.macro.Expr;

typedef TExpr = {
	var expr : TTypedExprDef;
	var pos : Position;
	var type : TType;
}
