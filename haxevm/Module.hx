package haxevm;

import haxe.macro.Type.ModuleType;

typedef Module =
{
	file:String,
	name:String,
	types:Array<ModuleType>,
	linesData:Array<Int>
}
