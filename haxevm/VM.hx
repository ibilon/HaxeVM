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

import haxe.io.Output;
import haxe.macro.Type;
import haxevm.Compiler.CompilationOutput;
import haxevm.vm.Context;
import haxevm.vm.EVal;
import haxevm.vm.FlowControl;
import haxevm.vm.expr.*;

using haxevm.utils.ArrayUtils;
using haxevm.utils.EValUtils;
using haxevm.utils.FieldUtils;

/**
Virtual machine evaluating the typed AST.
**/
class VM
{
	/**
	The context for this run.
	**/
	var context:Context;

	/**
	The result of the compilation.
	**/
	var compilationOutput:CompilationOutput;

	/**
	The output to send the error prints to.
	**/
	var err:Output;

	/**
	The main class' path, to find the main function.
	**/
	var mainClass:String;

	/**
	Cache holding the result of a Type loading to keep the value of the static variables.
	**/
	var moduleTypeCache:Map<String, EVal>;

	/**
	The output to send the normal prints to.
	**/
	var out:Output;

	/**
	Construct a new VM.

	@param compilationOutput The result of the compilation.
	@param mainClass The main class' path, to find the main function.
	@param out The output to send the normal prints to.
	@param err The output to send the error prints to.
	**/
	public function new(compilationOutput:CompilationOutput, mainClass:String, out:Output, err:Output)
	{
		this.context = new Context();
		this.compilationOutput = compilationOutput;
		this.err = err;
		this.mainClass = mainClass;
		this.moduleTypeCache = new Map<String, EVal>();
		this.out = out;

		// insert builtin trace
		context[compilationOutput.symbolTable.traceID] = EFunction(function(args:Array<EVal>) {
			var buf = [];

			for (arg in args)
			{
				buf.push(arg.toString(context, eval));
			}

			this.out.writeString(buf.join(" "));
			this.out.writeString("\n");
			return EVoid;
		});
	}

	/**
	Run the main function.
	**/
	public function run():Void
	{
		for (module in compilationOutput.modules)
		{
			if (module.name == mainClass)
			{
				for (type in module.types)
				{
					switch (type)
					{
						case TClassDecl(_.get() => classType) if (classType.name == mainClass):
							for (staticField in classType.statics.get())
							{
								if (staticField.name == "main")
								{
									switch (staticField.expr())
									{
										case null:
											throw "main function doesn't have expr";

										case value:
											eval(value);
									}
									return;
								}
							}

							err.writeString('Invalid -main : $mainClass does not have static function main\n');
							return;

						default:
							// pass
					}
				}

				err.writeString('Module $mainClass does not define type $mainClass\n');
				return;
			}
		}
	}

	/**
	Evaluate an expression.

	@param expr The expression to evaluate.
	**/
	function eval(expr:TypedExpr):EVal
	{
		return switch (expr.expr)
		{
			case TArray(array, key):
				ArrayExpr.eval(array, key, eval);

			case TArrayDecl(values):
				EArray(expr.t, values.map(eval));

			case TBinop(op, lhs, rhs):
				OperatorExpr.binop(op, lhs, rhs, context, eval);

			case TBlock(exprs):
				exprs.map(eval).last();

			case TBreak:
				throw FCBreak;

			case TCall(expr, arguments):
				CallExpr.eval(expr, arguments, eval);

			case TCast(_, _):
				throw "TCast unimplemented";

			case TConst(constant):
				ConstExpr.eval(constant, compilationOutput.symbolTable, context);

			case TContinue:
				throw FCContinue;

			case TEnumIndex(_): // generated by the pattern matcher
				throw "unexpected TEnumIndex";

			case TEnumParameter(_, _, _): // generated by the pattern matcher
				throw "unexpected TEnumParameter";

			case TField(expr, fieldAccess):
				expr.findField(fieldAccess, eval).value;

			case TFor(_, _, _):
				throw "TFor unimplemented";

			case TFunction(fn):
				EValUtils.makeEFunction(fn.args.map(arg -> arg.v.id), fn.expr, context, eval);

			case TIdent(_):
				throw "shouldn't happen";

			case TIf(conditionExpr, ifExpr, elseExpr):
				IfExpr.eval(conditionExpr, ifExpr, elseExpr, eval);

			case TLocal(v):
				context.exists(v.id) ? context[v.id] : throw 'using unbound variable ${v.id}';

			case TMeta(_, expr): // TODO is there actually something to do at runtime?
				eval(expr);

			case TNew(_.get() => classType, _, arguments):
				NewExpr.eval(classType, arguments, compilationOutput.symbolTable, moduleTypeCache, context, eval);

			case TObjectDecl(fields):
				EObject([for (field in fields) field.name => { name: field.name, value: eval(field.expr) }]);

			case TParenthesis(expr):
				eval(expr);

			case TReturn(expr):
				throw FCReturn(expr != null ? eval(expr) : EVoid);

			case TSwitch(_, _, _):
				throw "not implemented";

			case TThrow(expr):
				throw FCThrow(eval(expr));

			case TTry(expr, catches):
				TryExpr.eval(expr, catches, context, eval);

			case TUnop(op, postFix, expr):
				OperatorExpr.unop(op, postFix, expr, context, eval);

			case TVar(v, expr):
				context[v.id] = expr != null ? eval(expr) : EVoid;

			case TWhile(conditionExpr, expr, normalWhile):
				LoopExpr.whileLoop(conditionExpr, expr, normalWhile, eval);

			case TTypeExpr(module):
				ModuleTypeExpr.load(module, compilationOutput.symbolTable, moduleTypeCache, context, eval);
		}
	}
}
