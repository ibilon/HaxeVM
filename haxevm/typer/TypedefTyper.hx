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
class TypedefTyper extends ModuleTypeTyper<EnumFlag, ComplexType, DefType>
{
	/**
	Construct a typedef typer.

	@param compiler The compiler doing the compilation.
	@param module The module this typedef is part of.
	@param definition The definition of the typedef.
	@param position The typedef' position.
	**/
	public function new(compiler:Compiler, module:Module, definition:Definition<EnumFlag, ComplexType>, position:Position)
	{
		super(compiler, module, definition, position);
	}

	/**
	Construct the typedef's typed data.
	**/
	public override function firstPass():ModuleType
	{
		typedData = {
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
					typedData.isExtern = true;

				case EPrivate:
					typedData.isPrivate = true;
			}
		}

		return ModuleType.TTypeDecl(Ref.make(typedData));
	}
}
