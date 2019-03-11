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

import haxe.macro.Type.ModuleType;
import haxevm.Compiler.CompilationOutput;
import haxevm.utils.EValUtils;
import haxevm.vm.EVal;

using haxevm.utils.ModuleTypeUtils;
using haxevm.utils.TypeUtils;

/**
Evaluate a module.
**/
class ModuleExpr
{
	/**
	Load a module if not already in cache.

	@param modume The module to load.
	@param compilationOutput The result of the compilation.
	@param moduleTypeCache The cache of modules.
	@param context The context to use.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function load(module:ModuleType, compilationOutput:CompilationOutput, moduleTypeCache:Map<String, EVal>, context:Context, eval:EvalFn):EVal
	{
		var hash = module.hash();

		if (moduleTypeCache.exists(hash))
		{
			return moduleTypeCache[hash];
		}

		var staticFields = [];

		switch (module)
		{
			case TClassDecl(_.get() => classType):
				for (staticField in classType.statics.get())
				{
					switch (staticField.kind)
					{
						case FMethod(_):
							switch (staticField.type)
							{
								case TFun(_, _):
									var value = EValUtils.makeEFunction(compilationOutput.symbolTable.getStaticFunctionArgumentSymbols(staticField), staticField.expr(), context, eval);
									staticFields.push({ name: staticField.name, val: value });

								default:
									throw "invalid method type";
							}

						case FVar(_, _):
							var expr = staticField.expr();
							var value = expr != null ? eval(expr) : staticField.type.defaultEVal();

							staticFields.push({ name: staticField.name, val: value });
					}
				}

			default:
				throw "not supported";
		}

		var value = EType(module, staticFields);
		moduleTypeCache[hash] = value;
		return value;
	}
}
