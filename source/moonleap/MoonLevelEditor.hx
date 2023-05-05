package moonleap;

import flixel.FlxG;
import flixel.FlxSprite;
import moonleap.data.*;
import moonleap.data.LevelData;
import moonleap.gameObjects.*;
import data.MusicBeat.MusicBeatState;

class MoonLevelEditor extends MusicBeatState
{
	public var luano:Luano;
	public var background:FlxSprite;
	public var blocks:FlxTypedGroup<Block>;
	
	public static var LEVEL:Level;
	
	override function create()
	{
		super.create();
		
		if(LEVEL == null)
			LEVEL = Level.loadJson('test');
	}
}