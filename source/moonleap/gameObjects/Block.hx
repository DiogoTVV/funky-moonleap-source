package moonleap.gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

class Block extends FlxSpriteGroup
{
	public var blockType:String = 'base';
	
	public var skin:FlxSprite;
	public var collBox:FlxSprite;
	public var isDay:Bool = true;
	
	public function new(x:Float, y:Float)
		super(x, y);
	
	public function reloadBlock(blockType:String = 'base')
	{
		while (members.length > 0)
			remove(members[0], true);
		
		this.blockType = blockType;
		switch(blockType)
		{
			default:
				collBox = new FlxSprite().makeGraphic(64,64,0xFFFF0000);
				add(collBox);
				
				skin = new FlxSprite().makeGraphic(64,64,FlxColor.fromRGB(10,240,10));
				skin.alpha = 0;
				add(skin);
		}
	}
}