package moonleap.data;

import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef LevelData =
{
	var name:String;
	var luanoPos:Array<Float>;
	var blockData:Array<Array<Dynamic>>;
}
class Level
{
	public var data:LevelData;
	
	public function new() {}
	
	public static function loadJson(levelName:String = 'test'):Level
	{
		var daLevel = new Level();
		daLevel.data = cast Json.parse(File.getContent(Paths.getPath('levels/$levelName.json', TEXT)).trim());
		return daLevel;
	}
}