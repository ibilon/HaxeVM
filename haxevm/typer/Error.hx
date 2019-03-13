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
				'${type.prettyName()} has no field $fieldName';

			case MixedTypeArray:
				"Arrays of mixed types are only allowed if the type is forced to Array<Dynamic>";

			case ModuleWithoutMainType(module):
				'Module ${module.name} doesn\'t define a main type';

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
