package meta.data;

import flixel.FlxG;

using StringTools;

typedef HighscoreData = 
{
	var score:Int;
	var accuracy:Float;
	var misses:Int;
}
class Highscore
{
	public static var highscoreMap:Map<String, HighscoreData> = [];
	
	public static function setHighscore(song:String, newScore:HighscoreData):Void
	{
		if(highscoreMap.get(song) == null)
			highscoreMap.set(song, newScore);
		
		var curScore:HighscoreData = highscoreMap.get(song);
		curScore.score 		= getBigger(newScore.score,    curScore.score);
		curScore.accuracy 	= getBigger(newScore.accuracy, curScore.accuracy);
		// updates misses whenever the accuracy is updated so it can decrese/increase misses
		if(curScore.accuracy == newScore.accuracy) curScore.misses = newScore.misses;
		
		highscoreMap.set(song, curScore);
		save();
	}
	
	public static function getHighscore(song:String):HighscoreData
	{
		if(!highscoreMap.exists(song))
			setHighscore(song, {score: 0, accuracy: 0, misses: 0});
		
		return highscoreMap.get(song);
	}
	
	public static function save()
	{
		FlxG.save.data.highscoreMap = highscoreMap;
		FlxG.save.flush();
	}
	
	public static function load():Void
	{
		if (FlxG.save.data.highscoreMap != null)
			highscoreMap = FlxG.save.data.highscoreMap;
		
		if(FlxG.save.data.songScores != null)
		{
			var saveShit = FlxG.save.data;
			var loopScore:Map<String, Int> = saveShit.songScores;
			for(i in loopScore.keys())
			{
				i = i.replace('-easy', '');
				if(i == '???') continue;
				
				setHighscore(i, {score: saveShit.songScores.get(i), accuracy: saveShit.songAccs.get(i), misses: -1});
				trace('imported $i');
			}
			// fuck you no more old data
			FlxG.save.data.songScores = null;
			FlxG.save.data.songAccs = null;
		}
		
		save();
	}
	
	// just so i dont have to type this every time
	static function getBigger(val1:Float, val2:Float):Dynamic
		return (val1 > val2) ? val1 : val2;
}