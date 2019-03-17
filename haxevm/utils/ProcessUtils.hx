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

package haxevm.utils;

#if sys
import sys.io.Process;
#elseif js
import js.node.ChildProcess;
#end

/**
The output produced by a process.
**/
typedef RunResult =
{
	/**
	The normal output.
	**/
	var out:String;

	/**
	The error output.
	**/
	var err:String;
}

/**
Utilities for `Process` with support for NodeJS.
**/
class ProcessUtils
{
	/**
	Run a command and return it's output (both normal and error).

	@param arguments The command to run.
	**/
	public static inline function run(arguments:Array<String>):RunResult
	{
		#if sys
		var process = new Process(arguments.join(" "));

		var out = process.stdout.readAll().toString();
		var err = process.stderr.readAll().toString();

		process.close();

		return {
			out: out,
			err: err
		}
		#elseif js
		var command = arguments.shift();
		var process = ChildProcess.spawnSync(command, arguments);

		return {
			out: (cast process.stdout).toString(),
			err: (cast process.stderr).toString()
		}
		#end
	}
}
