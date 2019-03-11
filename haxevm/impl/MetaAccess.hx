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

package haxevm.impl;

import haxe.macro.Expr;
import haxe.macro.Type.MetaAccess as BaseMetaAccess;

using Lambda;

/**
Implementation for `haxe.macro.Type.MetaAccess`.
**/
class MetaAccess
{
	/**
	Create a new `MetaAccess` for a `Metadata`.
	If `meta` is null it is replaced by an empty array.

	@param meta The metadata array to wrap.
	**/
	public static function make(meta:Null<Metadata>):BaseMetaAccess
	{
		return new MetaAccess(meta != null ? meta : []);
	}

	/**
	The wrapped `Metadata` array.
	**/
	var meta:Metadata;

	/**
	Construct a `MetaAccess`.

	@param meta The metadata array to wrap.
	**/
	function new(meta:Metadata)
	{
		this.meta = meta;
	}

	/**
	Adds a metadata.

	Metadata names are not unique during compilation, so this method never overwrites a previous metadata.

	If a `Metadata` array is obtained through a call to `get`, a subsequent call to `add` has no effect on that array.

	@param name The name of the metadata.
	@param params The parameters of the metadata.
	@param pos The position of the metadata.
	**/
	public function add(name:String, params:Array<Expr>, pos:Position):Void
	{
		meta.push({
			name: name,
			params: params,
			pos: pos,
		});
	}

	/**
	Extract metadata entries by given `name`.

	If there's no metadata with such name, empty array `[]` is returned.

	@param name The name to search for.
	**/
	public function extract(name:String):Array<MetadataEntry>
	{
		return meta.filter(f -> f.name == name);
	}

	/**
	Return the wrapped `Metadata` array.

	Modifying this array has no effect.
	The `add` and `remove` methods can be used for that.
	**/
	public function get():Metadata
	{
		return meta.copy();
	}

	/**
	Tells there is a `name` metadata entry.

	@param name The name to search for.
	**/
	public function has(name:String):Bool
	{
		return meta.exists(m -> m.name == name);
	}

	/**
	Removes all `name` metadata entries.

	This method might clear several metadata entries of the same name.

	If a `Metadata` array is obtained through a call to `get`, a subsequent call to `remove` has no effect on that array.

	@param name The name to remove.
	**/
	public function remove(name:String):Void
	{
		meta = meta.filter(f -> f.name != name);
	}
}
