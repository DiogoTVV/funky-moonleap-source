package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

class BlackBars extends FlxSpriteGroup
{
	public var enabled:Bool = false;
	
	public function new()
	{
		super();
		for(i in 0...2)
		{
			var bar = new FlxSprite().makeGraphic(FlxG.width + 20, FlxG.width, 0xFF000000);
			bar.ID = i;
			bar.screenCenter(X);
			bar.y = getItemY(bar);
			add(bar);
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		for(item in members)
		{
			item.y = FlxMath.lerp(item.y, getItemY(item), elapsed * 8);
		}
	}
	
	function getItemY(item:FlxSprite):Float
	{
		var daY = (item.ID == 0) ? -item.height - 20 : FlxG.height + 20;
		
		if(enabled)
			daY += (20 + 170) * (item.ID == 0 ? 1 : -1);
		
		return daY;
	}
}