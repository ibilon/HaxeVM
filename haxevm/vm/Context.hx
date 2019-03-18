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

package haxevm.vm;

using haxevm.utils.ArrayUtils;

/**
The VM context holding the value of all variables.
**/
abstract Context(ContextData)
{
	/**
	Construct a new context.
	**/
	public function new()
	{
		this = new ContextData();
	}

	/**
	Checks if the symbol exist.

	@param key The symbol to check.
	**/
	public inline function exists(key:Int):Bool
	{
		return this.current.exists(key);
	}

	/**
	Array get operator.

	@param key The symbol to get.
	**/
	@:arrayAccess
	inline function get(key:Int):EVal
	{
		return switch (this.current[key])
		{
			case null:
				throw 'symbol $key doesn\'t exist in context';

			case value:
				value;
		}
	}

	/**
	Array set operator.

	@param key The symbol to set.
	@param value The value to set to.
	**/
	@:arrayAccess
	inline function set(key:Int, value:EVal):EVal
	{
		return this.current[key] = value;
	}

	/**
	Stack a function call, reverting the context afterward.
	**/
	public function stack(block:Void->Void):Void
	{
		this.current = this.current.copy();
		this.stacks.push(this.current);

		block();

		this.stacks.pop();
		this.current = this.stacks.last();
	}
}

/**
Data class for the Context.
**/
private class ContextData
{
	/**
	The current stack, linking a symbol to its value.
	**/
	public var current : Map<Int, EVal>;

	/**
	The successive stacks of context.
	**/
	public var stacks : Array<Map<Int, EVal>>;

	/**
	Construct the data.
	**/
	public function new()
	{
		current = new Map<Int, EVal>();
		stacks = [current];
	}
}
