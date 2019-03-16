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

package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type;

using haxevm.utils.PositionUtils;
using haxevm.utils.TypeUtils;

/**
A typing error message.
**/
enum ErrorMessage
{
	/**
	Trying to use array access on a type without it.
	**/
	ArrayAccessNotAllowed(type:Type);

	/**
	A backward range (eg. 7...1).
	**/
	BackwardIterating;

	/**
	No comparation operation available.
	**/
	CantCompare(lhs:Type, rhs:Type);

	/**
	Can't use a custom property operator anymore, must use get/set.
	**/
	CustomPropertyAccessor(get:Bool);

	/**
	Type doesn't have the requested field.
	**/
	FieldNotFound(type:Type, fieldName:String);

	/**
	A non extern function doesn't have a body.
	**/
	FunctionBodyRequired;

	/**
	A property accessor is missing.
	**/
	MissingPropertyAccessor(name:String);

	/**
	Array of mixed type.
	**/
	MixedTypeArray;

	/**
	A module Name without type Name.
	**/
	ModuleWithoutMainType(module:Module);

	/**
	The function call is missing arguments.
	**/
	// InsufficientArguments(remainingArgs:Array<TFunctionArg>);

	/**
	The function call has too many arguments.
	**/
	// TooManyArguments;

	/**
	There was a parsing error from haxeparser.
	**/
	ParsingError(message:String);

	/**
	Calling a type which is not callable.
	**/
	TypeIsNotCallable(type:Type);

	/**
	Can't find the type.
	**/
	// TypeNotFound(module:Array<String>, name:String);

	/**
	Unification error.
	**/
	UnificationError(expected:Type, got:Type);

	/**
	Unresolved identifier.
	**/
	UnresolvedIdentifier(ident:String);
}

/**
A typing error.
**/
class Error
{
	/**
	The error's message.
	**/
	public final message:ErrorMessage;

	/**
	The module the error was thrown in, used to display the position.
	**/
	public final module:Module;

	/**
	The error's position.
	**/
	public final position:Position;

	/**
	Construct a new typing error.

	@param message The error's message.
	@param module The module the error was thrown in, used to display the position.
	@param position The error's position.
	**/
	public function new (message:ErrorMessage, module:Module, position:Position)
	{
		this.message = message;
		this.module = module;
		this.position = position;
	}

	/**
	Calculate the string representation of the error ready to be displayed.
	**/
	public function toString():String
	{
		var messageString = switch (message)
		{
			case ArrayAccessNotAllowed(type):
				'Array access is not allowed on ${type.prettyName()}';

			case BackwardIterating:
				"Cannot iterate backwards";

			case CantCompare(lhs, rhs):
				'Cannot compare ${lhs.prettyName()} and ${rhs.prettyName()}';

			case CustomPropertyAccessor(get):
				'Custom property accessor is no longer supported, please use `${get ? "get" : "set"}`';

			case FieldNotFound(type, fieldName):
				'${type.prettyName(true)} has no field $fieldName';

			case FunctionBodyRequired:
				"Function body required";

			case MissingPropertyAccessor(name):
				'Method $name required by property ${name.substr(4)} is missing';

			case MixedTypeArray:
				"Arrays of mixed types are only allowed if the type is forced to Array<Dynamic>";

			case ModuleWithoutMainType(module):
				'Module ${module.name} does not define type ${module.name}';

			case ParsingError(message):
				message;

			case TypeIsNotCallable(type):
				'${type.prettyName()} cannot be called';

			case UnificationError(expected, got):
				'${got.prettyName()} should be ${expected.prettyName()}';

			case UnresolvedIdentifier(ident):
				'Unknown identifier : $ident';
		}

		return '${position.toString(module, true)} $messageString';
	}
}
