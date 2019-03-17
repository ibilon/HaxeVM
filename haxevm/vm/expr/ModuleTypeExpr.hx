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
import haxevm.utils.EValUtils;
import haxevm.vm.EVal;

using haxevm.utils.ModuleTypeUtils;
using haxevm.utils.TypeUtils;

/**
Evaluate a module type.
**/
class ModuleTypeExpr
{
	/**
	Load a module type if not already in cache.

	@param moduleType The module type to load.
	@param symbolTable The symbol table from the compilation.
	@param moduleTypeCache The cache of module types.
	@param context The context to use.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function load(moduleType:ModuleType, symbolTable:SymbolTable, moduleTypeCache:Map<String, EVal>, context:Context, eval:EvalFn):EVal
	{
		var hash = moduleType.hashModuleType();

		if (moduleTypeCache.exists(hash))
		{
			return moduleTypeCache[hash];
		}

		return switch (moduleType)
		{
			case TClassDecl(_.get() => classType):
				loadClass(classType, symbolTable, moduleTypeCache, context, eval);

			default:
				throw "not supported";
		}
	}

	/**
	Load a class type if not already in cache.

	@param classType The class type to load.
	@param symbolTable The symbol table from the compilation.
	@param moduleTypeCache The cache of module types.
	@param context The context to use.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function loadClass(classType:ClassType, symbolTable:SymbolTable, moduleTypeCache:Map<String, EVal>, context:Context, eval:EvalFn):EVal
	{
		var hash = classType.hashClassType();

		if (moduleTypeCache.exists(hash))
		{
			return moduleTypeCache[hash];
		}

		var constructorField = null;
		var memberFields = new Map<String, TypedExpr>();
		var staticFields = new Map<String, EField>();

		if (classType.constructor != null)
		{
			var constructor = classType.constructor.get();
			constructorField = EValUtils.makeEFunction(symbolTable.getFunctionArgumentSymbols(constructor), constructor.expr(), context, eval);
		}

		for (memberField in classType.fields.get())
		{
			memberFields[memberField.name] = memberField.expr();
		}

		for (staticField in classType.statics.get())
		{
			switch (staticField.kind)
			{
				case FMethod(_):
					switch (staticField.type)
					{
						case TFun(_, _):
							staticFields[staticField.name] = { name: staticField.name, value: EValUtils.makeEFunction(symbolTable.getFunctionArgumentSymbols(staticField), staticField.expr(), context, eval) };

						default:
							throw "invalid method type";
					}

				case FVar(_, _):
					var expr = staticField.expr();
					var value = expr != null ? eval(expr) : staticField.type.defaultEVal();

					staticFields[staticField.name] = { name: staticField.name, value: value };
			}
		}

		var value = EClass(classType, { constructor: constructorField, memberFields: memberFields, staticFields: staticFields });
		moduleTypeCache[hash] = value;
		return value;
	}
}
