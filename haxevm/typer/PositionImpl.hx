package haxevm.typer;

import haxe.macro.Expr.Position;

class PositionImpl
{
	public static function make(file:String, min:Int, max:Int):Position
	{
		return {
			file: file,
			min: min,
			max: max
		};
	}
}