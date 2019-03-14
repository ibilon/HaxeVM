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
import haxe.macro.Expr.Position as BasePosition;
import haxe.macro.Type;
import haxeparser.Data;
import haxevm.impl.MetaAccess;
import haxevm.impl.Position;
import haxevm.impl.Ref;

using haxevm.utils.ComplexTypeUtils;

/**
Do abstract typing.
**/
class AbstractTyper extends WithFieldTyper<AbstractFlag, AbstractType>
{
	/**
	Construct an abstract typer.

	@param compiler The compiler doing the compilation.
	@param module The module this abstract is part of.
	@param definition The definition of the abstract.
	@param position The abstract's position.
	**/
	public function new(compiler:Compiler, module:Module, definition:Definition<AbstractFlag, Array<Field>>, position:BasePosition)
	{
		super(compiler, module, definition, position);
	}

	/**
	Construct the abstract' typed data, but don't type its fields' expression.
	**/
	public override function firstPass():ModuleType
	{
		typedData = {
			array: [], // TODO
			binops: [], // TODO
			doc: definition.doc,
			from: [], // TODO
			impl: null, // TODO
			isExtern: false,
			isPrivate: false,
			meta: MetaAccess.make(definition.meta),
			module: module.name,
			name: definition.name,
			pack: [],
			params: [], // def.params,
			pos: position,
			resolve: null, // TODO
			resolveWrite: null, // TODO
			to: [], // TODO
			type: Monomorph.make(),
			unops:[], // TODO
			exclude: () -> {}
		};

		for (flag in definition.flags)
		{
			switch (flag)
			{
				case AExtern:
					typedData.isExtern = true;

				case AFromType(ct):
					typedData.from.push({ t: ct.toType(), field: null });

				case AIsType(ct):
					typedData.type = ct.toType();

				case APrivAbstract:
					typedData.isPrivate = true;

				case AToType(ct):
					typedData.to.push({ t: ct.toType(), field: null });
			}
		}

		// Set the fields' owning class as the impl class.
		var ref = Ref.make(typedData);

		classData = {
			constructor: null,
			doc: null,
			fields: Ref.make([]),
			init: null,
			interfaces: [],
			isExtern: false,
			isFinal: false,
			isInterface: false,
			isPrivate: false,
			kind: KAbstractImpl(ref),
			meta: MetaAccess.make(null),
			module: module.name,
			name: definition.name + "_Impl",
			overrides: [],
			pack: [],
			params: [], // def.params,
			pos: Position.makeEmpty(),
			statics: Ref.make([]),
			superClass: null,
			exclude: () -> {}
		};

		// First pass: add abstract symbols.
		constructFields();

		return ModuleType.TAbstract(ref);
	}
}
