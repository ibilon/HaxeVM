package vm;

import haxe.macro.Type;

enum EVal
{
	EBool(b:Bool);
	EInt(i:Int);
	EFloat(f:Float);
	EString(s:String);
	ERegexp(r:EReg);
	EArray(of:Type, a:Array<EVal>);
	EObject(fields:Array<{ name:String, val:EVal }>);
	EVoid;
	EFn(fn:Array<EVal>->EVal);
	EIdent(id:Int);
	ENull;
}
