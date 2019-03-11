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

/**
Evaluate an array access.
**/
class ArrayExpr
{
	/**
	Evaluate an array access.

	@param array The array expression.
	@param key The key expression.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function eval(array:TypedExpr, key:TypedExpr, eval:EvalFn):EVal
	{
		var arrayValue = eval(array);

		return switch (arrayValue)
		{
			case EArray(_, a):
				var keyValue = eval(key);

				switch (keyValue)
				{
					case EInt(i):
						if (i < 0)
						{
							throw 'Negative array index: $i';
						}

						if (i < a.length)
						{
							a[i];
						}
						else
						{
							ENull;
						}

					default:
						throw "unexpected value, expected EInt, got " + keyValue;
				}

			default:
				throw "unexpected value, expected EArray, got " + arrayValue;
		}
	}
}
