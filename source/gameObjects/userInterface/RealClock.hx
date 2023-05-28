package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import meta.data.Conductor;
import meta.state.PlayState;

using StringTools;

class RealClock extends FlxSpriteGroup
{
	private var location:String = 'UI/default/pixel/clock/menu/';
	
	public var clockColor:FlxSprite;
	public var clockHandle:FlxSprite;
	public var clockFront:FlxSprite;
	
	public function new()
	{
		super();
		clockColor = new FlxSprite().loadGraphic(Paths.image(location + 'clock back'));
		add(clockColor);
		
		clockHandle = new FlxSprite().loadGraphic(Paths.image(location + 'clock hand'));
		clockHandle.flipX = true;
		add(clockHandle);
		
		clockFront = new FlxSprite().loadGraphic(Paths.image(location + 'clock'));
		add(clockFront);
		
		// pixel clock
		for(obj in this.members)
		{
			obj.antialiasing = false;
			obj.setGraphicSize(Std.int(obj.width * 4));
			obj.updateHitbox();
		}

		setByRealTime();
		updateColors(true);
	}
	
	// (curTime is in minutes) 720 = 12 hours
	public var curTime:Float = 0;

	public var moving:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(!moving)
		{
			// simulates an actual clock when not adjusting it
			curTime += elapsed / 60;
		}
		//setByRealTime();
		curTime = CoolUtil.wrapFloat(curTime, 0, 720 * 2);
		updateColors();

		// updating the handle
		var angularTime:Float = FlxMath.remapToRange(curTime, 0, 720, 0, 360);
		
		clockHandle.angle = angularTime;
		clockColor.angle = angularTime;
	}
	
	public function setByRealTime()
	{
		var moonDate = Date.now();
		// gets the current minute
		curTime = moonDate.getMinutes();
		for(i in 0...moonDate.getHours()) // and it adds 60 minutes for each hour
			curTime += 60;
	}

	public function updateColors(?instant:Bool = false)
	{
		var hour:Float = FlxMath.remapToRange(curTime, 0, 720, 0, 12);
		//trace("hour: " + hour);
		var daColor:FlxColor;

		if((hour >= 18 && hour <= 24) || (hour >= 0 && hour < 6))
			daColor = FlxColor.fromRGB(85,0,170);
		else
			daColor = FlxColor.fromRGB(0,170,255);

		if(instant)
			clockColor.color = daColor;
		else
			flixel.tweens.FlxTween.color(clockColor, 0.25, clockColor.color, daColor);
	}
}