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

import haxe.macro.Type.Ref in BaseRef;

/**
Implementation for `haxe.macro.Type.Ref`.
**/
class Ref<T>
{
	/**
	Create a new `Ref` around a value.

	@param value The value to wrap.
	**/
	public static function make<T>(value:T):BaseRef<T>
	{
		return new Ref(value);
	}

	/**
	The wrapped value.
	**/
	var value:T;

	/**
	Construct a `Ref`.

	@param value The value to wrap.
	**/
	function new(value:T)
	{
		this.value = value;
	}

	/**
	Get the wrapped value.
	**/
	public function get():T
	{
		return value;
	}

	/**
	Set the wrapped value.
	**/
	public function set(newValue:T):Void
	{
		if (value != null)
		{
			throw "not monomorph or already bound";
		}

		value = newValue;
	}

	/**
	String representation of the value.
	**/
	public function toString():String
	{
		return Std.string(value);
	}
}
