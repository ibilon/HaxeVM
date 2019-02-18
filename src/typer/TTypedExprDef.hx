package typer;

import haxe.macro.Expr;
import haxe.macro.Type.ModuleType;
import haxe.macro.Type.TVar;
import typer.TConstant;

//TODO use haxe.macro.Type.TypedExprDef
enum TTypedExprDef
{
	TConst(c:TConstant);
	TArray(e1:TExpr, e2:TExpr);
	TBinop(op:Binop, e1:TExpr, e2:TExpr);
	TField(e:TExpr, f:String);
	TParenthesis(e:TExpr);
	TObjectDecl(fields:Array<{name:String, expr:TExpr}>);
	TArrayDecl(el:Array<TExpr>);
	TCall(e:TExpr, el:Array<TExpr>);
	TNew(t:TypePath, el:Array<TExpr>);
	TUnop(op:Unop, postFix:Bool, e:TExpr);
	TFunction(args:Array<TVar>, expr:TExpr, ret:TType);
	TVar(v:TVar, expr:TExpr);
	TBlock(el:Array<TExpr>);
	TFor(v:TVar, e1:TExpr, e2:TExpr);
	TIf(econd:TExpr, eif:TExpr, eelse:TExpr);
	TWhile(econd:TExpr, e:TExpr, normalWhile:Bool);
	TSwitch(e:TExpr, cases:Array<{values:Array<TExpr>, expr:TExpr}>, edef:TExpr);
	TTry(e:TExpr, catches:Array<{v:TVar, expr:TExpr}>);
	TReturn(e:TExpr);
	TBreak;
	TContinue;
	TThrow(e:TExpr);
	TCast(e:TExpr, m:ModuleType);
	TMeta(m:MetadataEntry, e1:TExpr);
}
