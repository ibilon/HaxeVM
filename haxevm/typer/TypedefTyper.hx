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
import haxeparser.Data;
import haxevm.impl.MetaAccess;
import haxevm.impl.Ref;

using haxevm.utils.ComplexTypeUtils;

/**
Do typedef typing.
**/
class TypedefTyper implements ModuleTypeTyper
{
	/**
	Link to the compiler doing the compilation.
	**/
	var compiler:Compiler;

	/**
	The definition of the typedef.
	**/
	var definition:Definition<EnumFlag, ComplexType>;

	/**
	The module this typedef is part of.
	**/
	var module:Module;

	/**
	The typedef' position.
	**/
	var position:Position;

	/**
	The typed typedef.
	**/
	var typedTypedef:Null<DefType>;

	/**
	Construct a class typer.

	@param compiler The compiler doing the compilation.
	@param module The module this class is part of.
	@param definition The definition of the typedef.
	@param position The typedef' position.
	**/
	public function new(compiler:Compiler, module:Module, definition:Definition<EnumFlag, ComplexType>, position:Position)
	{
		this.compiler = compiler;
		this.definition = definition;
		this.module = module;
		this.position = position;
		this.typedTypedef = null;
	}

	/**
	Construct the typedef's typed data.
	**/
	public function firstPass():ModuleType
	{
		typedTypedef = {
			doc: definition.doc,
			isExtern: false,
			isPrivate: false,
			meta: MetaAccess.make(definition.meta),
			module: module.name,
			name: definition.name,
			pack: [],
			params: [], // def.params,
			pos: position,
			type: definition.data.toType(),
			exclude: () -> {}
		};

		for (flag in definition.flags)
		{
			switch (flag)
			{
				case EExtern:
					typedTypedef.isExtern = true;

				case EPrivate:
					typedTypedef.isPrivate = true;
			}
		}

		return ModuleType.TTypeDecl(Ref.make(typedTypedef));
	}

	/**
	Nothing to do in the second pass for a typedef.
	**/
	public function secondPass():Void
	{
	}
}
