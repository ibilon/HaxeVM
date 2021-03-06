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
Evaluate a call.
**/
class CallExpr
{
	/**
	Evaluate a call.

	@param expr The caller's expression.
	@param arguments The call arguments' expressions.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function eval(expr:TypedExpr, arguments:Array<TypedExpr>, eval:EvalFn):EVal
	{
		return eval(expr).asFunction()(arguments.map(arg -> eval(arg)));
	}

	/**
	Evaluate an instance call.

	@param fn The member function to call.
	@param arguments The call arguments' expressions.
	@param object The reference to `this` used in the call.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function evalWithThis(fn:EVal, arguments:Array<TypedExpr>, object:EVal, eval:EvalFn):EVal
	{
		return fn.asFunction()([object].concat(arguments.map(arg -> eval(arg))));
	}
}
