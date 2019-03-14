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
Do enum typing.
**/
class EnumTyper extends ModuleTypeTyper<EnumFlag, Array<EnumConstructor>, EnumType>
{
	/**
	Construct an enum typer.

	@param compiler The compiler doing the compilation.
	@param module The module this enum is part of.
	@param definition The definition of the enum.
	@param position The enum's position.
	**/
	public function new(compiler:Compiler, module:Module, definition:Definition<EnumFlag, Array<EnumConstructor>>, position:Position)
	{
		super(compiler, module, definition, position);
	}

	/**
	Construct the enum's typed data.
	**/
	public override function firstPass():ModuleType
	{
		typedData = {
			constructs: [],
			doc: definition.doc,
			isExtern: false,
			isPrivate: false,
			meta: MetaAccess.make(definition.meta),
			module: module.name,
			name: definition.name,
			names: [],
			pack: [],
			params: [], // def.params,
			pos: position,
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

		for (i in 0...definition.data.length)
		{
			var field = definition.data[i];
			typedData.names.push(field.name);

			var enumField = {
				doc: field.doc,
				index: i,
				meta: MetaAccess.make(field.meta),
				name: field.name,
				params: [], // fields.params,
				pos: field.pos,
				type: field.type.toType()
			};

			typedData.constructs.set(field.name, enumField);
		}

		return ModuleType.TEnumDecl(Ref.make(typedData));
	}
}
