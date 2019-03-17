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

import haxe.macro.Type.FieldAccess;
import haxe.macro.Type.TypedExpr;
import haxevm.vm.EVal;

/**
Utilities for `FieldAccess` on `TypedExpr`.

To be used with `using FieldUtils;`.
**/
class FieldUtils
{
	/**
	Extract the name of the field from the field access.

	@param fieldAccess The field access.
	**/
	static function fieldName(fieldAccess:FieldAccess):String
	{
		return switch (fieldAccess)
		{
			case FAnon(_.get() => field), FClosure(_, _.get() => field), FInstance(_, _, _.get() => field), FStatic(_, _.get() => field):
				field.name;

			case FDynamic(fieldName):
				fieldName;

			case FEnum(_, field):
				field.name;
		}
	}

	/**
	Find the field value.

	@param parent The value containing the field.
	@param fieldAccess The field access.
	@param eval The expression evaluation function, should be `VM.eval`.
	**/
	public static function findField(parent:TypedExpr, fieldAccess:FieldAccess, eval:EvalFn):EField
	{
		var parent = eval(parent);
		var name = fieldName(fieldAccess);

		function findFieldImpl(fields:Array<EField>):EField
		{
			for (field in fields)
			{
				if (field.name == name)
				{
					return field;
				}
			}

			throw 'Field ${name} not found';
		}

		return switch (parent)
		{
			case EObject(fields):
				findFieldImpl(fields);

			case EType(_, _, memberFields, staticFields):
				try
				{
					findFieldImpl(staticFields);
				}
				catch (_:Any)
				{
					findFieldImpl(memberFields);
				}

			default:
				throw 'Field access unsuported "$parent"';
		}
	}
}
