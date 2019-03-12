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
		var array = eval(array).asArray();
		var key = eval(key).asInt();

		if (key < 0)
		{
			throw 'Negative array index: $key';
		}

		return key < array.length ? array[key] : ENull;
	}
}
