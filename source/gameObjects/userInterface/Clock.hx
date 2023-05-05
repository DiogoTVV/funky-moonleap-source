package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import meta.data.Conductor;
import meta.state.PlayState;

using StringTools;

class Clock extends FlxSpriteGroup
{
	private var location:String = 'UI/default/peppino/clock/';
	
	public var clockColors:Array<FlxSprite> = [];
	public var clockHandle:FlxSprite;
	public var clockFront:FlxSprite;
	
	var startAngle:Float = 90;
	var isDownscroll:Bool = (SaveData.trueSettings.get('Downscroll'));
	
	public var icons:Array<HealthIcon> = [];
	
	public function new(icons:Array<HealthIcon>, modifier:String = 'base')
	{
		super();
		this.icons = icons;
		location = location.replace('peppino', modifier);
		
		for(i in 0...2)
		{
			var color:FlxSprite = new FlxSprite().loadGraphic(Paths.image(location + 'clock player' + Std.string(i + 1)));
			// flipin'
			color.flipY = isDownscroll;
			color.angle = startAngle;
			color.ID = i;
			
			add(color);
			clockColors.push(color);
		}
		updateColors();
		
		clockHandle = new FlxSprite().loadGraphic(Paths.image(location + 'clock hand'));
		clockHandle.flipX = isDownscroll;
		clockHandle.angle = startAngle;
		add(clockHandle);
		
		clockFront = new FlxSprite().loadGraphic(Paths.image(location + 'clock'));
		clockFront.flipY = isDownscroll;
		clockFront.angle = startAngle;
		add(clockFront);
		
		// pixel clock
		if(modifier == 'pixel')
		{
			for(obj in this.members)
			{
				obj.antialiasing = false;
				obj.setGraphicSize(Std.int(obj.width * 6));
				obj.updateHitbox();
			}
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		x = FlxG.width - width;
		if(!isDownscroll)
			y = FlxG.height - (height / 2);
		else
			y = 0 - (height / 2);
		
		// updating the handle
		if(Conductor.songPosition > 0)
		{
			// spins the other way around if downscroll is turned on
			var angularPercent:Float = (PlayState.songPercent * (!isDownscroll ? 1.8 : -1.8));
			
			clockHandle.angle = startAngle - angularPercent;
		}
		
		// updating the colors
		for(color in clockColors)
		{
			color.angle = clockHandle.angle - startAngle;
		}
	}
	
	public function updateColors()
	{
		// fucking stupid shit
		for(color in clockColors)
			color.color = (color.ID == 0) ? icons[0].iconColor : icons[1].iconColor;
	}
}