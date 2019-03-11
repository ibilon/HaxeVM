/**
Copyright (c) 2019 Valentin Lemière, Guillaume Desquesnes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/

package haxevm;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;

@:noCompletion
class InitMacro
{
	/**
	Macro called by extraParams.hxml, adds the class path of the libs.
	**/
	macro static function addClassPath():Expr
	{
		switch (Context.getType("haxevm.InitMacro"))
		{
			case TInst(_.get() => t, _):
				var pdir = Path.directory(Context.getPosInfos(t.pos).file);

				Compiler.addClassPath(Path.join([pdir, "../libs/hxparse/src"]));
				Compiler.addClassPath(Path.join([pdir, "../libs/haxeparser/src"]));
				Compiler.addClassPath(Path.join([pdir, "../libs/utest/src"]));
				Compiler.addClassPath(Path.join([pdir, "../libs/mcover/src"]));

			default:
				throw "can't find the haxevm.InitMacro type";
		}

		return macro null;
	}
}
