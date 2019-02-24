package typer;

enum TType
{
	TBool;
	TInt;
	TFloat;
	TString;
	TRegexp;
	TArray(of:TType);
	TMonomorph;
	TUnknown;
	TObject(fields:Array<{ name:String, expr:TExpr }>);
	TVoid;
	TFn(args:Array<TType>, ret:TType);
}
