package events;

import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef ScrollChangeData =
{
	var data:Array<Array<Float>>;
}
class ScrollSpeedEvent
{
	// data[curStep] = newSpeed;
	public static var data:Map<Int, Float> = [];
	
	public static function mapSteps(curSong:String = 'leap'):Void
	{
		data = [];
		
		var jsonPath:String = Paths.getPath('speed-changes/$curSong.json', TEXT);
		
		if(FileSystem.exists(jsonPath))
		{
			var fuck:ScrollChangeData = cast Json.parse(File.getContent(jsonPath).trim());
			
			for(i in fuck.data)
			{
				data.set(Math.floor(i[0]), i[1]);
			}
			
			trace('mapped $curSong scroll speed changes');
		}
		else
			trace('$curSong doesnt have any scroll speed changes, what a loser');
	}
}