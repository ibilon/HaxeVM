package haxevm.typer;

import haxe.macro.Type.ModuleType;

interface ModuleTypeTyper
{
	function preType():ModuleType;
	function fullType():Void;
}
