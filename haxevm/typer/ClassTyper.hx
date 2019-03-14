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

/**
Do class typing.
**/
class ClassTyper extends WithFieldTyper<ClassFlag, ClassType>
{
	/**
	Construct a class typer.

	@param compiler The compiler doing the compilation.
	@param module The module this class is part of.
	@param definition The definition of the class.
	@param position The class' position.
	**/
	public function new(compiler:Compiler, module:Module, definition:Definition<ClassFlag, Array<Field>>, position:Position)
	{
		super(compiler, module, definition, position);
	}

	/**
	Construct the class' typed data, but don't type its fields' expression.
	**/
	public override function firstPass():ModuleType
	{
		typedData = {
			constructor: null,
			doc: definition.doc,
			fields: Ref.make([]),
			init: null,
			interfaces: [],
			isExtern: false,
			isFinal: false,
			isInterface: false,
			isPrivate: false,
			kind: KNormal,
			meta: MetaAccess.make(definition.meta),
			module: module.name,
			name: definition.name,
			overrides: [],
			pack: [],
			params: [], // def.params,
			pos: position,
			statics: Ref.make([]),
			superClass: null,
			exclude: () -> {}
		};

		for (flag in definition.flags)
		{
			switch (flag)
			{
				case HExtends(_):
					throw "not implemented";
					// cls.superClass = { t: new Ref(null), params: t.params };

				case HExtern:
					typedData.isExtern = true;

				case HImplements(_):
					throw "not implemented";
					// cls.interfaces.push({ t: new Ref(null), params: t.params });

				case HInterface:
					typedData.isInterface = true;

				case HPrivate:
					typedData.isPrivate = true;
			}
		}

		// Set the fields' owning class as this.
		classData = typedData;

		// First pass: add class symbols.
		constructFields();

		return ModuleType.TClassDecl(Ref.make(typedData));
	}
}
