package meta.state.menus.menuObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import meta.subState.WebsiteSubState;
import meta.data.dependency.Discord;
import meta.data.*;

class GamepadGroup extends MusicBeatGroup
{
	public function new()
	{
		super();
		groupName = 'gamepad';
		
		#if !html5
		Discord.changePresence('CONTROLS', 'Main Menu');
		#end
		
		var label:FlxText = new FlxText(0, 60, 0, "controls");
		label.setFormat(Main.gFont, 28, FlxColor.fromRGB(170,170,255), CENTER);
		label.antialiasing = false;
		label.screenCenter(X);
		add(label);
		
		var guide = new FlxSprite(0, label.y).loadGraphic(Paths.image("menus/moonleap/gamepad-guide"));
		guide.scale.set(4,4);
		guide.updateHitbox();
		guide.screenCenter(X);
		add(guide);
	}
	
	var selectedSomething:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(!selectedSomething)
		{
			if(controls.BACK)
			{
				selectedSomething = true;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				GlobalMenuState.nextMenu = new OptionsGroup();
				alive = false;
			}
		}
	}
}