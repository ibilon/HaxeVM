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

package tests;

import haxe.PosInfos;
import haxevm.impl.MetaAccess;
import haxevm.impl.Position;
import haxevm.impl.Ref;
import utest.Assert;

/**
Test miscellaneous features.
**/
class MiscTest extends Test
{
	public function testConditionalCompilationSample(?pos:PosInfos):Void
	{
		compareFile("tests/samples/ConditionalCompilation.hx", pos);
		compareFile("tests/samples/ConditionalCompilation.hx", ["test" => "1"], pos);
		compareFile("tests/samples/ConditionalCompilation.hx", ["other" => "1"], pos);
	}

	public function testMetaAcess():Void
	{
		var m = MetaAccess.make(null);

		var copy = m.get();
		Assert.equals(0, copy.length);

		m.add("hello", [], Position.makeEmpty());
		Assert.equals(0, copy.length);
		Assert.isTrue(m.has("hello"));
		Assert.equals(1, m.get().length);

		m.add("hello", [], Position.makeEmpty());
		Assert.equals(0, copy.length);
		Assert.isTrue(m.has("hello"));
		Assert.equals(2, m.get().length);

		m.add("nothello", [], Position.makeEmpty());
		Assert.equals(1, m.extract("nothello").length);
		Assert.equals(2, m.extract("hello").length);

		m.remove("hello");
		Assert.equals(1, m.extract("nothello").length);
		Assert.equals(0, m.extract("hello").length);
		Assert.equals(0, copy.length);
	}

	public function testRef():Void
	{
		var r = Ref.make(null);
		Assert.equals(r.get(), null);
		Assert.equals(r.toString(), "null");

		(cast r : Ref<String>).set("hello");
		Assert.equals(r.get(), "hello");
		Assert.equals(r.toString(), "hello");

		try
		{
			(cast r : Ref<String>).set("hello2");
			Assert.fail();
		}
		catch (e:String)
		{
			Assert.equals(e, "not monomorph or already bound");
		}

		Assert.equals(r.get(), "hello");
		Assert.equals(r.toString(), "hello");
	}
}
