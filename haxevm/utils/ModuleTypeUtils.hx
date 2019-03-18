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

import haxe.macro.Expr;
import haxe.macro.Type;

using haxevm.utils.ModuleTypeUtils;

/**
Utilities for `ModuleType`.

To be used with `using ModuleTypeUtils;`.
**/
class ModuleTypeUtils
{
	/**
	Find a class in a module.

	@param module The module to search in.
	@param typePath The class to search.
	**/
	public static function findClass(module:Module, typePath:TypePath):Ref<ClassType>
	{
		// TODO do proper type search with imports
		var ref = null;

		for (type in module.types)
		{
			switch (type)
			{
				case TClassDecl(classTypeRef):
					if (classTypeRef.get().name == typePath.name)
					{
						ref = classTypeRef;
						break;
					}

				default:
					continue;
			}
		}

		if (ref == null)
		{
			throw 'Type not found : ${typePath.sub == null ? typePath.name : typePath.sub}';
		}

		return ref;
	}

	/**
	Calculate the class type's hash.

	@param classType The class type to hash.
	**/
	public static inline function hashClassType(classType:ClassType):String
	{
		return '${classType.pack.join(".")}#${classType.module}#${classType.name}';
	}

	/**
	Calculate the module type's hash.

	@param moduleType The module type to hash.
	**/
	public static function hashModuleType(moduleType:ModuleType):String
	{
		return switch (moduleType)
		{
			case TClassDecl(_.get() => classType):
				classType.hashClassType();

			default:
				throw "not supported";
		}
	}
}
