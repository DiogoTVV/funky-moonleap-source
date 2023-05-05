package;

import lime.utils.Assets;
import meta.state.PlayState;

using StringTools;

#if sys
import sys.FileSystem;
#end

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];
	//public static var difficultyArray:Array<String> = ["HARD", "HARD", "HARD"];
	
	public static var difficultyLength = difficultyArray.length;

	public static function difficultyFromNumber(number:Int):String
	{
		return difficultyArray[number];
	}

	public static function dashToSpace(string:String):String
	{
		return string.replace("-", " ");
	}

	public static function spaceToDash(string:String):String
	{
		return string.replace(" ", "-");
	}

	public static function swapSpaceDash(string:String):String
	{
		return StringTools.contains(string, '-') ? dashToSpace(string) : spaceToDash(string);
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function getOffsetsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);

		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
			swagOffsets.push(i.split(' '));

		return swagOffsets;
	}

	public static function returnAssetsLibrary(library:String, ?subDir:String = 'assets/images'):Array<String>
	{
		var libraryArray:Array<String> = [];

		#if sys
		var unfilteredLibrary = FileSystem.readDirectory('$subDir/$library');

		for (folder in unfilteredLibrary)
		{
			if (!folder.contains('.'))
				libraryArray.push(folder);
		}
		trace(libraryArray);
		#end

		return libraryArray;
	}

	public static function getAnimsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);

		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagOffsets.push(i.split('--'));
		}

		return swagOffsets;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	
	public static function getIconColor(char:String = 'bf'):flixel.util.FlxColor
	{
		// green
		var cc:Array<Int> = [0,255,0];
		
		switch(char.toLowerCase())
		{
			case 'skid' | 'pump': cc = [238,143,28]; //[204,204,204];
			case 'luano': cc = [255,192,63];
			case 'luano-night': cc = [181,165,204];
			case 'solano': cc = [255,195,46];
			case 'guselect': cc = [28,203,110];
			case 'luano-pixel': cc = [255,170,85];
			case 'luano-pixel-night': cc = [170,170,255];
			case 'skid-pixel': cc = [170,255,255];
			case 'pump-pixel': cc = [255,170,0];
			case 'skid-d-side': cc = [204,204,204];
			case 'estrelano': cc = [203,236,255];
			case 'estrelano-night': cc = [236,0,116];
			// default stuff
			case 'bf': cc = [49,176,209];
			case 'face': cc = [161,161,161];
		}
		
		return flixel.util.FlxColor.fromRGB(cc[0],cc[1],cc[2]);
	}
}
