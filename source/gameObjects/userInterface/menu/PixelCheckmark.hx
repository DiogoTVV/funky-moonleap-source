package gameObjects.userInterface.menu;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class PixelCheckmark extends FlxSprite
{
	public var value:Bool = true;
	
	public function new(value:Bool = true)
	{
		super();
		this.value = value;
		
		loadGraphic(Paths.image('menus/moonleap/checkmark'), true, 16, 16);
		animation.add('false', [0], 0, false);
		animation.add('true',  [1], 0, false);
		animation.play(Std.string(value));
		
		scale.set(2.4,2.4);
		updateHitbox();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		scale.x = FlxMath.lerp(scale.x, 2.4, elapsed * 8);
		scale.y = FlxMath.lerp(scale.y, 2.4, elapsed * 8);
	}
	
	// does a little jump animation and changes the animation
	public function updateValue(value:Bool = true)
	{
		this.value = value;
		animation.play(Std.string(value));
		scale.set(3.1,3.1);
	}
}