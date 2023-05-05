package gameObjects.background;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class Bixinho extends FlxSprite
{
	public var direction:Int = 1;
	public var actualX:Float = 0;
	public var isActive:Bool = false;
	public var limits:Array<Float> = [0, 800];
	
	public function new(x:Float, y:Float, direction:Int, isActive:Bool, skin:String)
	{
		super(x, y);
		this.direction = direction;
		this.isActive = isActive;
		actualX = x;
		
		frames = Paths.getSparrowAtlas('backgrounds/sun-hop/bixoFoda');
		animation.addByPrefix('idle', 'idle ' + skin, 24, false);
		animation.addByPrefix('walk', 'walk ' + skin, 18, false);
		playAnims();
		
		switch(skin)
		{
			case 'green':
				limits = [-1240, x];
			case 'orange':
				limits = [x, 2300];
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		flipX = (direction > 0);
		//scale.x = FlxMath.lerp(scale.x, -direction, 0.1);
		
		walk(elapsed);
		
		// looping correctly
		if(animation.curAnim.finished)
			playAnims();
		
		//if(FlxG.keys.justPressed.SPACE)
		//	trace(limits);
	}
	
	function walk(elapsed:Float)
	{
		if(isActive)
			actualX += direction * elapsed * 200;
		
		// only moves when its pulling its body
		if(animation.curAnim.curFrame >= 4)
			x = FlxMath.lerp(x, actualX, elapsed * 8);
		
		if(actualX < limits[0])
			direction = 1;
		if(actualX > limits[1])
			direction = -1;
	}
	
	function playAnims()
	{
		animation.play(isActive ? 'walk' : 'idle');
	}
}