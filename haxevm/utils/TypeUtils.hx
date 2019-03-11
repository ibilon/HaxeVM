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

package haxevm.utils;

import haxe.macro.Type.Type;
import haxevm.typer.BaseType;
import haxevm.vm.EVal;

/**
Utilities for `Type`.

To be used with `using TypeUtils;`.
**/
class TypeUtils
{
	/**
	Get the default value of the type.

	@param type The type.
	**/
	public static function defaultEVal(type:Type):EVal
	{
		return if (BaseType.isInt(type))
		{
			EInt(0);
		}
		else if (BaseType.isFloat(type))
		{
			EFloat(0);
		}
		else if (BaseType.isString(type))
		{
			EString("");
		}
		else if (BaseType.isBool(type))
		{
			EBool(false);
		}
		else
		{
			throw "type not supported " + type;
		}
	}

	/**
	Calculate the string representation of the type ready to be displayed.

	@param type The type.
	**/
	public static function prettyName(type:Type):String
	{
		function name(name:String, typeParameters:Array<Type>):String
		{
			return if (typeParameters.length == 0)
			{
				name;
			}
			else
			{
				'${name}<${typeParameters.map(prettyName).join(",")}>';
			}
		}

		return switch (type)
		{
			case TAbstract(_.get() => abstractType, typeParameters):
				name(abstractType.name, typeParameters);

			case TAnonymous(_.get() => anonType):
				var fields = anonType.fields.map(field -> '${field.name} : ${prettyName(field.type)}');

				var buf = new StringBuf();
				buf.add('{ ');
				buf.add(fields.join(", "));
				buf.add(' }');
				buf.toString();

			case TFun(arguments, returnType):
				var pargs = arguments.map(arg -> arg.name != "" ? '(${arg.name} : ${prettyName(arg.t)})' : prettyName(arg.t));

				if (arguments.length == 0)
				{
					pargs.push("Void");
				}

				var buf = new StringBuf();
				buf.add(pargs.join(" -> "));
				buf.add(" -> ");
				buf.add(prettyName(returnType));
				buf.toString();

			case TInst(_.get() => classType, typeParameters):
				name(classType.name, typeParameters);

			case TMono(_):
				return 'Unknown<0>';

			default:
				throw "not supported";
		}
	}
}
