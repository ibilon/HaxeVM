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

import haxe.macro.Type;

/**
A class.
**/
typedef EClassData =
{
	/**
	The constructor of the class, if it exists.
	**/
	var constructor:Null<EVal>;

	/**
	The member fields of the class.
	**/
	var memberFields:Map<String, TypedExpr>;

	/**
	The static fields of the class.
	**/
	var staticFields:Map<String, EField>;
}

/**
A field.
**/
typedef EField =
{
	/**
	The name of the field.
	**/
	var name:String;

	/**
	The value of the field.
	**/
	var value:EVal;
}

/**
The type of a function.
**/
typedef EFunctionFn = (arguments:Array<EVal>)->EVal;

/**
The type of an expression evaluation function.
**/
typedef EvalFn = (expr:TypedExpr)->EVal;

enum EVal
{
	/**
	An array of type `of`, containing `data`.
	**/
	EArray(of:Type, data:Array<EVal>);

	/**
	A Bool.
	**/
	EBool(b:Bool);

	/**
	A class.
	**/
	EClass(classType:ClassType, classData:EClassData);

	/**
	A Float.
	**/
	EFloat(f:Float);

	/**
	A function.
	**/
	EFunction(fn:EFunctionFn);

	/**
	A class object instance.
	**/
	EInstance(fields:Map<String, EField>, classData:EClassData);

	/**
	An Int.
	**/
	EInt(i:Int);

	/**
	The null value.
	**/
	ENull;

	/**
	An anon object.
	**/
	EObject(fields:Map<String, EField>);

	/**
	A String.
	**/
	EString(s:String);

	/**
	No value.
	**/
	EVoid;
}
