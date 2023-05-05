package gameObjects.background;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

class DevlogCursor extends FlxSprite
{
	public var collBox:FlxSprite;
	
	public function new()
	{
		super();
		frames = Paths.getSparrowAtlas("backgrounds/devlog/cursor");
		animation.addByPrefix("cursor", "cursor", 24, true);
		animation.play("cursor");
		
		screenCenter(X);
		x -= 150;
		y = FlxG.height - height + 280;
		
		collBox = new FlxSprite().makeGraphic(18,18,0xFFFF0000);
		collBox.antialiasing = false;
		collBox.alpha = 0;
	}
	
	// scale stuff
	public var daScale:Float = 1;
	public var pressed:Bool = false;
	public var justPressed:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		
		if(SaveData.trueSettings.get("Controller Mode") && gamepad != null)
		{
			x += gamepad.analog.value.RIGHT_STICK_X * 2000 * elapsed;
			y += gamepad.analog.value.RIGHT_STICK_Y * 2000 * elapsed;
			pressed 	= gamepad.pressed.A;
			justPressed = gamepad.justPressed.A;
		}
		else
		{
			// i fucking hate pointers now
			var dumbass:FlxPoint = FlxG.mouse.getWorldPosition(cameras[0]);
			x = dumbass.x - (width / 2);
			y = dumbass.y - (height / 2);
			pressed 	= FlxG.mouse.pressed;
			justPressed = FlxG.mouse.justPressed;
		}
		collBox.setPosition(x + 14 * daScale, y + 15 * daScale);
		collBox.cameras = cameras;
		
		// updating scale
		daScale = (pressed ? 0.7 : 1.1);
		daScale /= cameras[0].zoom;
		
		var mult = FlxMath.lerp(scale.x, daScale, elapsed * 16);
		scale.set(mult, mult);
		collBox.scale.set(mult, mult);
	}
}