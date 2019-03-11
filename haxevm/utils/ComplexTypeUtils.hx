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

import haxe.macro.Type;
import haxe.macro.Expr;
import haxevm.typer.BaseType;
import haxevm.typer.Monomorph;

/**
Utilities for `ComplexType`.

To be used with `using ComplexTypeUtils;`.
**/
class ComplexTypeUtils
{
	/**
	Convert a complex type to a type.

	@param type The complex type to convert.
	**/
	public static function toType(type:Null<ComplexType>):Type
	{
		if (type == null)
		{
			return Monomorph.make();
		}

		return switch (type)
		{
			case TPath(path): // TODO convert TPath to Type
				switch (path.name)
				{
					case "Bool":
						BaseType.tBool;

					case "Float":
						BaseType.tFloat;

					case "Int":
						BaseType.tInt;

					case "String":
						BaseType.tString;

					case "Void":
						BaseType.tVoid;

					default:
						throw "unknown type";
				}

			default: // TODO TAnonymous | TExtend | TFunction | TIntersection | TNamed | TOptional | TParent
				throw "not implemented";
		}
	}
}
