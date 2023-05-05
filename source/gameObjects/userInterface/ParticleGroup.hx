package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

class ParticleGroup extends FlxSpriteGroup
{
	public var isDay:Bool = true;
	
	public function new(maxParticles:Int = 20)
	{
		super();
		for(i in 0...maxParticles)
		{
			var part = new FlxSprite(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height));
			part.makeGraphic(1, 1, FlxColor.WHITE);
			part.antialiasing = false;
			part.velocity.x = FlxG.random.float(-30, 30);
			part.velocity.y = FlxG.random.float(-30, 30);
			renewParticle(part);
			add(part);
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		for(part in members)
		{
			if(part.y > FlxG.height || part.y < -part.height || part.x > FlxG.width || part.x < -part.width)
				renewParticle(part);
		
			// making it not go offscreen
			if(part.y > FlxG.height)
				part.y = -part.height;
			if(part.y < -part.height)
				part.y = FlxG.height;
			// same for X
			if(part.x > FlxG.width)
				part.x = -part.width;
			if(part.x < -part.width)
				part.x = FlxG.width;
		}
		
		color = isDay ? FlxColor.fromRGB(173,253,255) : FlxColor.fromRGB(236,157,0);
		visible = SaveData.trueSettings.get('Particles');
	}
	
	public function renewParticle(part:FlxSprite)
	{
		var newSize:Int = FlxG.random.int(4, 12);
		part.setGraphicSize(newSize, newSize);
		part.updateHitbox();
	}
}