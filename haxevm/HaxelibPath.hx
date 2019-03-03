package haxevm;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;

@:noCompletion
class HaxelibPath
{
	macro static function init():Expr
	{
		switch (Context.getType("haxevm.HaxelibPath"))
		{
			case TInst(_.get() => t, _):
				var pdir = Path.directory(Context.getPosInfos(t.pos).file);

				Compiler.addClassPath(Path.join([pdir, "../libs/hxparse/src"]));
				Compiler.addClassPath(Path.join([pdir, "../libs/haxeparser/src"]));

			default:
		}

		return macro null;
	}
}
