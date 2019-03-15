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

import haxe.macro.Expr.Position;

/**
Utilities for `Position`.

To be used with `using PositionUtils;`.
**/
class PositionUtils
{
	/**
	Calculate the position's hash.

	@param position The position to hash.
	**/
	public static function hash(position:Position):String
	{
		return '${position.file}#${position.min}#${position.max}';
	}

	/**
	Preparse a file's content to find the new line positions.

	@param content The file content.
	**/
	public static function preparseLinesData(content:String):Array<Int>
	{
		var positions = [];
		var i = 0;

		while (i < content.length)
		{
			switch (content.charCodeAt(i++))
			{
				case "\r".code:
					if (content.charCodeAt(i + 1) == "\n".code) // Parse \r\n as a single new line
					{
						i++;
					}

					positions.push(i);

				case "\n".code:
					positions.push(i);

				default:
			}
		}

		positions.push(i);
		return positions;
	}

	/**
	Calculate the string representation of the position ready to be displayed.

	@param position The position.
	@param module The module the position is contained in.
	@param displayRange Whether to display the range of the position in characters or lines if multiline.
	**/
	public static function toString(position:Position, module:Module, displayRange:Bool = false):String
	{
		// Find the line for the position.min
		var min = 0;
		var max = module.newLinesPositions.length - 1;

		while (max - min > 1)
		{
			var i = Math.ceil((min + max) / 2);
			var end = module.newLinesPositions[i];

			if (position.min <= end)
			{
				max = i;
			}

			if (position.min >= end)
			{
				min = i;
			}
		}

		var line = max + 1;
		var positionString = '${module.file}:$line:';

		if (!displayRange)
		{
			return positionString;
		}

		// Find the line for the position.max
		var endmax = max;

		while (position.max > module.newLinesPositions[endmax])
		{
			endmax++;
		}

		if (endmax == max)
		{
			var cstart = position.min - module.newLinesPositions[max - 1];
			var cend = cstart + position.max - position.min;
			return '${positionString} characters ${cstart}-${cend} :';
		}
		else
		{
			return '${positionString} lines ${line}-${endmax + 1} :';
		}
	}
}
