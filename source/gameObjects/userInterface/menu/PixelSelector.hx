package gameObjects.userInterface.menu;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PixelSelector extends FlxText
{
	public var value:Dynamic = 0;
	public var options:Array<Dynamic> = ["crash", "prevention"];
	
	public function new(value:Dynamic, options:Array<Dynamic>)
	{
		this.value = value;
		this.options = options;
		
		super(0, 0, 0, '< $value >');
		setFormat(Main.gFont, 24, FlxColor.WHITE, CENTER);
		updateHitbox();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		scale.x = FlxMath.lerp(scale.x, 1, elapsed * 8);
		scale.y = FlxMath.lerp(scale.y, 1, elapsed * 8);
		updateHitbox();
	}
	
	// changes the selector value according to the current value inside the array (if it exists)
	public function changeSelection(direction:Int = 0)
	{
		if(Std.isOfType(options[0], String)) // text types (colorblind filter, ratings counter)
		{
			var curSelected:Int = options.indexOf(value) + direction;
			curSelected = FlxMath.wrap(curSelected, 0, options.length - 1);
			
			value = options[curSelected];
		}
		else // number types (fps counter, stage opacity)
		{
			value += direction;
			value = FlxMath.wrap(value, options[0], options[1]);
		}
		
		text = '< $value >';
		if(direction < 0)
			scale.set(1.2,0.8);
		else
			scale.set(0.7,1.3);
		updateHitbox();
	}
	
	// makes the sprite origin right-middle
	public var followY:Float = -400;
	override function updateHitbox()
	{
		super.updateHitbox();
		x = (840 + 46) - width;
		y = followY - (height / 2);
	}
}