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
	TObject; //TODO
	TVoid;
	TFn(args:Array<TType>, ret:TType);
}
