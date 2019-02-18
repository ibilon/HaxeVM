package typer;

enum TConstant
{
	TCInt(v:String);
	TCFloat(f:String);
	TCString(s:String);
	TCIdent(sid:Int);
	TCRegexp(r:String, opt:String);
}
