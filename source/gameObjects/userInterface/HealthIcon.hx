package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import sys.FileSystem;

using StringTools;

class HealthIcon extends FlxSprite
{
	// rewrite using da new icon system as ninjamuffin would say it
	public var sprTracker:FlxSprite;
	public var iconColor:FlxColor = FlxColor.WHITE;
	public var curIcon:String = 'bf';
	
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		updateIcon(char, isPlayer);
	}

	public function updateIcon(char:String = 'bf', isPlayer:Bool = false):HealthIcon
	{
		var trimmedCharacter:String = char;
		if (trimmedCharacter.contains('-'))
			trimmedCharacter = trimmedCharacter.substring(0, trimmedCharacter.lastIndexOf('-'));
		
		if(!FileSystem.exists(Paths.getPath('images/icons/icon-' + char + '.png', IMAGE)))
		{
			if (char != trimmedCharacter)
				return updateIcon(trimmedCharacter, isPlayer);
			else
				return updateIcon('face', isPlayer);
			//trace('$char icon trying $char instead you fuck');
		}
		
		if(char.contains('pixel'))
			antialiasing = false;
		else
			antialiasing = SaveData.trueSettings.get('Antialiasing');
		
		if(FileSystem.exists(Paths.getPath('images/icons/icon-' + char + '.xml', TEXT)))
		{
			frames = Paths.getSparrowAtlas('icons/icon-' + char);
			
			animation.addByPrefix('neutral', 'icon-neutral', 24, true);
			animation.addByPrefix('losing', 'icon-losing', 24, true);
			
			animation.play('neutral');
		}
		else
		{
			var iconGraphic:FlxGraphic = Paths.image('icons/icon-' + char);
			loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);
			
			animation.add('icon', [0, 1], 0, false, isPlayer);
			animation.play('icon');
			scrollFactor.set();
		}
		
		curIcon = char;
		iconColor = CoolUtil.getIconColor(char);
		
		return this;
	}
	
	public dynamic function updateAnim(health:Float = 50)
	{
		if(animation.getByName('icon') == null)
		{
			var animCheck:String = (health < 20) ? 'losing' : 'neutral';
			// making it loop correctly
			if(animCheck != animation.curAnim.name)
				animation.play(animCheck);
		}
		else
		{
			var frameCheck:Int = 0;
			
			if (health < 20)
				frameCheck = 1;
			
			animation.curAnim.curFrame = frameCheck;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
