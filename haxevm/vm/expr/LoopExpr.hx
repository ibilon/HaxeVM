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

package haxevm.vm.expr;

import haxe.macro.Type.TypedExpr;
import haxevm.vm.EVal;

using haxevm.utils.EValUtils;

/**
Evaluate a loop.
**/
class LoopExpr
{
	/**
	Evaluate a while loop.

	@param conditionExpr The expression of the condition.
	@param expr The body of the loop.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function whileLoop(conditionExpr:TypedExpr, expr:TypedExpr, normalWhile:Bool, eval:EvalFn):EVal
	{
		var stop = false;

		function evalBody()
		{
			try
			{
				eval(expr);
			}
			catch (fc:FlowControl)
			{
				switch (fc)
				{
					case FCBreak:
						stop = true;

					case FCContinue:
						// nothing to do

					default:
						throw fc;
				}
			}
		}

		if (!normalWhile)
		{
			// Do the guaranteed first body run.
			evalBody();
		}

		while (!stop && eval(conditionExpr).asBool())
		{
			evalBody();
		}

		return EVoid;
	}
}
