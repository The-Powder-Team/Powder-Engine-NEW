import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;

using StringTools;

class Helper
{
	/**
	 * Similar to `FlxMath.roundDecimal()`.
	 * 
	 * @param number Number to truncate.
	 * @param precision How many decimal places should this have when truncated?
	 * @return Truncated float with the precision provided.
	 */
	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	/**
	 * Gives off a "complete" percent.
	 * Replaces missing precision places with zeros.
	 * 
	 * e.g. `98` becomes `98.00`
	 * @param number Number to truncate
	 * @param precision How many decimal places should this have when truncated?
	 * @return Truncated float with no missing precision places.
	 */
	public static function completePercent(number:Float, precision:Int):String
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);

		var string = num + "";

		if (!string.contains("."))
			string += ".";

		var split = string.split(".");
		while (split[1].length < precision)
			split[1] += "0";

		string = split.join(".");

		return string;
	}

	/**
	 * Convert a string to a bool.
	 * Returns false when it can't be converted.
	 * 
	 * @param bool Bool as a string.
	 * @return String as a bool.
	 */
	public static function toBool(bool:String):Bool
	{
		switch (bool.toLowerCase())
		{
			case 'true':
				return true;
			case 'false':
				return false;
		}

		return false;
	}

	public static function getERegMatches(ereg:EReg, input:String, unique:Bool = false, index:Int = 0):Array<String>
	{
		var matches = [];
		while (ereg.match(input))
		{
			if (unique)
			{
				if (!matches.contains(ereg.matched(index)))
					matches.push(ereg.matched(index));
			}
			else
				matches.push(ereg.matched(index));

			input = ereg.matchedRight();
		}
		return matches;
	}

	/**
	 * Hi Psych!
	 * Similar to `FlxMath.bound()`.
	 * 
	 * @param value Any number.
	 * @param min Any number.
	 * @param max Any number.
	 * @return A number.
	 */
	public static function boundTo(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));

	/**
	 * You know, I wish overlap() used screen position. Shit fucks.
	 * 
	 * @param obj Object to check if it overlaps with the mouse cursor
	 * @return Bool Do it overlap?
	 */
	public static function screenOverlap(obj:FlxObject, ?camera:FlxCamera):Bool
	{
		var mouse = FlxG.mouse.getScreenPosition(camera);
		var bruh = obj.getScreenPosition(camera);

		return (mouse.x >= bruh.x && mouse.x <= bruh.x + obj.width) && (mouse.y >= bruh.y && mouse.y <= bruh.y + obj.height);
	}

	#if windows
	/**
	 * Heh. Window transparency.
	 *
	 * @param color Color to key. Format is `0x00bbggrr`!
	 */
	public static function setTransparency(color:Int)
	{
		Transparency.setTransparency("Friday Night Funkin': Powder Engine", color);
	}
	#end
}
