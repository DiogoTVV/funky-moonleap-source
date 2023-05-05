package moonleap.gameObjects;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class Background extends FlxTypedGroup<FlxBasic>
{
	public function new()
		super();
	
	var curStage:String;
	
	public function updateBackground(curStage:String = 'test', isDay:Bool = true)
	{
		while (members.length > 0)
			remove(members[0], true);
		
		this.curStage = curStage;
		switch(curStage)
		{
			default:
				var bg = new FlxSprite().makeGraphic(1280, 720, 0xFF888888);
				bg.screenCenter();
				add(bg);
		}
	}
}