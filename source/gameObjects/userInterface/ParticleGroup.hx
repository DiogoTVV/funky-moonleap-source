package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import shaders.MosaicShader;

class ParticleGroup extends FlxSpriteGroup
{
	public var isDay:Bool = true;
	
	public function new(maxParticles:Int = 20)
	{
		super();
		for(i in 0...maxParticles)
		{
			var part = new Particle();
			add(part);
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		color = isDay ? FlxColor.fromRGB(173,253,255) : FlxColor.fromRGB(236,157,0);
		visible = SaveData.trueSettings.get('Particles');
	}
}

// single particle
class Particle extends FlxSprite
{
	public function new()
	{
		super(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height));
		makeGraphic(4, 4, FlxColor.WHITE);
		pixelPerfectPosition = true;
		antialiasing = false;
		velocity.x = FlxG.random.float(-1, 1) * 30;
		velocity.y = FlxG.random.float(-1, 1) * 30;
		renewParticle();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(y > FlxG.height || y < -height || x > FlxG.width || x < -width)
			renewParticle();
		
		// making it not go offscreen
		if(y > FlxG.height) y = -height;
		if(y < -height)		y = FlxG.height;
		// same for X
		if(x > FlxG.width) 	x = -width;
		if(x < -width)		x = FlxG.width;
	}
	
	public function renewParticle()
	{
		var newSize:Int = FlxG.random.int(4, 12);
		setGraphicSize(newSize, newSize);
		updateHitbox();
	}
}