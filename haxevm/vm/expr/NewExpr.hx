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

import haxe.macro.Type;
import haxevm.vm.EVal;

using haxevm.utils.EValUtils;

/**
Evaluate a new.
**/
class NewExpr
{
	/**
	Evaluate a new.

	@param classType The class to construct.
	@param arguments The constructor call's arguments.
	@param symbolTable The symbol table from the compilation.
	@param moduleTypeCache The cache of module types.
	@param context The context to use.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function eval(classType:ClassType, arguments:Array<TypedExpr>, symbolTable:SymbolTable, moduleTypeCache:Map<String, EVal>, context:Context, eval:EvalFn):EVal
	{
		var eclass = ModuleTypeExpr.loadClass(classType, symbolTable, moduleTypeCache, context, eval).asClass();
		var fields = new Map<String, EField>();

		for (name => memberFunction in eclass.memberFunctions)
		{
			fields[name] = { name: name, value: memberFunction };
		}

		for (name => memberVariable in eclass.memberVariables)
		{
			fields[name] = { name: name, value: eval(memberVariable) };
		}

		var object = EInstance(fields, eclass);

		if (eclass.constructor != null)
		{
			CallExpr.evalWithThis(eclass.constructor, arguments, object, eval);
		}

		return object;
	}
}
