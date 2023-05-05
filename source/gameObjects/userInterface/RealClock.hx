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
		updateColors(0);
		
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
	}
	
	public var curTime:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var moonDate = Date.now();
		updateColors(moonDate.getHours());
		// gets the current minute
		curTime = moonDate.getMinutes();
		for(i in 0...moonDate.getHours()) // and it adds 60 minutes for each hour
			curTime += 60;
		
		// updating the handle
		var angularTime:Float = FlxMath.remapToRange(curTime, 0, 720, 0, 360);
		
		clockHandle.angle = angularTime;
		
		// updating the colors angles
		clockColor.angle = angularTime;
	}
	
	public function updateColors(hour:Int)
	{
		if((hour >= 18 && hour < 24) || (hour >= 0 && hour < 6))
			clockColor.color = FlxColor.fromRGB(85,0,170);
		else
			clockColor.color = FlxColor.fromRGB(0,170,255);
	}
}