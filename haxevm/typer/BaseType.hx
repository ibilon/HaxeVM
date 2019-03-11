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

import haxe.macro.Type;
import haxevm.impl.Position;
import haxevm.impl.Ref;

/**
Basic types supported.
Temporary until there is support for std parsing.
**/
class BaseType
{
	/**
	Check if the type is an Array.

	@param type The type to check.
	**/
	public static function isArray(type:Type):Bool
	{
		return switch (type)
		{
			case TInst(_.get() => t, _):
				t.pack.length == 0 && t.module == "Array" && t.name == "Array";

			default:
				false;
		}
	}

	/**
	Check if the type is a Bool.

	@param type The type to check.
	**/
	public static function isBool(type:Type):Bool
	{
		return switch (type)
		{
			case TAbstract(_.get() => t, _):
				t.pack.length == 0 && t.module == "StdTypes" && t.name == "Bool";

			default:
				false;
		}
	}

	/**
	Check if the type is a Float.

	@param type The type to check.
	**/
	public static function isFloat(type:Type):Bool
	{
		return switch (type)
		{
			case TAbstract(_.get() => t, _):
				t.pack.length == 0 && t.module == "StdTypes" && t.name == "Float";

			default:
				false;
		}
	}

	/**
	Check if the type is an Int.

	@param type The type to check.
	**/
	public static function isInt(type:Type):Bool
	{
		return switch (type)
		{
			case TAbstract(_.get() => t, _):
				t.pack.length == 0 && t.module == "StdTypes" && t.name == "Int";

			default:
				false;
		}
	}

	/**
	Check if the type is numeric, ie. either an Int or a Float.

	@param type The type to check.
	**/
	public static function isNumeric(t:Type):Bool
	{
		return isInt(t) || isFloat(t);
	}

	/**
	Check if the type is a String.

	@param type The type to check.
	**/
	public static function isString(type:Type):Bool
	{
		return switch (type)
		{
			case TInst(_.get() => t, _):
				t.pack.length == 0 && t.module == "String" && t.name == "String";

			default:
				false;
		}
	}

	/**
	Check if the type is a Void.

	@param type The type to check.
	**/
	public static function isVoid(type:Type):Bool
	{
		return switch (type)
		{
			case TAbstract(_.get() => t, _):
				t.pack.length == 0 && t.module == "StdTypes" && t.name == "Void";

			default:
				false;
		}
	}

	/**
	Construct an Array<of> type.

	@param of The type of the array.
	**/
	public static function tArray(of:Type):Type
	{
		return TInst(Ref.make({
			constructor: null,
			doc: "",
			fields: Ref.make([]),
			init: null,
			interfaces: [],
			isExtern: true,
			isFinal: false,
			isInterface: false,
			isPrivate: false,
			kind: KNormal,
			meta: null,
			module: "Array",
			name: "Array",
			overrides: [],
			pack: [],
			params: [{
				name: "T",
				t: TInst(Ref.make({
					constructor: null,
					doc: null,
					fields: Ref.make([]),
					init: null,
					interfaces: [],
					isExtern: false,
					isFinal: false,
					isInterface: false,
					isPrivate: false,
					kind: KTypeParameter([]),
					meta: null,
					module: "Array",
					name: "T",
					overrides: [],
					pack: ["Array"],
					params: [],
					pos: Position.makeEmpty(),
					statics: Ref.make([]),
					superClass: null,
					exclude: () -> {}
				}), [])
			}],
			pos: Position.makeEmpty(),
			statics: Ref.make([]),
			superClass: null,
			exclude: () -> {}
		}), [of]);
	}

	/**
	The bool Type.
	**/
	public static final tBool:Type = TAbstract(Ref.make({
		array: [],
		binops: [],
		doc: "",
		from: [],
		impl: null,
		isExtern: false,
		isPrivate: false,
		meta: null,
		module: "StdTypes",
		name: "Bool",
		pack: [],
		params: [],
		pos: Position.makeEmpty(),
		resolve: null,
		resolveWrite: null,
		to: [],
		type: null, // The TAbstract(this, []);
		unops: [],
		exclude: () -> {}
	}), []);

	/**
	The Float type.
	**/
	public static final tFloat:Type = TAbstract(Ref.make({
		array: [],
		binops: [],
		doc: "",
		from: [],
		impl: null,
		isExtern: false,
		isPrivate: false,
		meta: null,
		module: "StdTypes",
		name: "Float",
		pack: [],
		params: [],
		pos: Position.makeEmpty(),
		resolve: null,
		resolveWrite: null,
		to: [],
		type: null, // The TAbstract(this, []);
		unops: [],
		exclude: () -> {}
	}), []);

	/**
	The Int type.
	**/
	public static final tInt:Type = TAbstract(Ref.make({
		array: [],
		binops: [],
		doc: "",
		from: [],
		impl: null,
		isExtern: false,
		isPrivate: false,
		meta: null,
		module: "StdTypes",
		name: "Int",
		pack: [],
		params: [],
		pos: Position.makeEmpty(),
		resolve: null,
		resolveWrite: null,
		to: [],
		type: null, // The TAbstract(this, []);
		unops: [],
		exclude: () -> {}
	}), []);

	/**
	The String type.
	**/
	public static final tString:Type = TInst(Ref.make({
		constructor: null,
		doc: "",
		fields: Ref.make([]),
		init: null,
		interfaces: [],
		isExtern: true,
		isFinal: false,
		isInterface: false,
		isPrivate: false,
		kind: KNormal,
		meta: null,
		module: "String",
		name: "String",
		overrides: [],
		pack: [],
		params: [],
		pos: Position.makeEmpty(),
		statics: Ref.make([]),
		superClass: null,
		exclude: () -> {}
	}), []);

	/**
	The Void type.
	**/
	public static final tVoid:Type = TAbstract(Ref.make({
		array: [],
		binops: [],
		doc: "",
		from: [],
		impl: null,
		isExtern: false,
		isPrivate: false,
		meta: null,
		module: "StdTypes",
		name: "Void",
		pack: [],
		params: [],
		pos: Position.makeEmpty(),
		resolve: null,
		resolveWrite: null,
		to: [],
		type: null, // The TAbstract(this, []);
		unops: [],
		exclude: () -> {}
	}), []);
}
