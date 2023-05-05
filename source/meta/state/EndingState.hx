package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.RealClock;
import meta.MusicBeat.MusicBeatState;
import meta.state.menus.GlobalMenuState;

class EndingState extends MusicBeatState
{
	override function create()
	{
		super.create();
		var bg = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(0,0,85));
		bg.screenCenter();
		add(bg);
		
		var mizera:String = 'thanks for playing';
		mizera += '\n\nyou have completed all the songs\nin funky moonleap';
		mizera += '\n\nnow try pressing 7 or 8 on\nmidnight secrets for a surprise!';
		
		var text = new FlxText(0, 150, 0, mizera);
		text.setFormat(Main.gFont, 36, FlxColor.fromRGB(181,165,240), CENTER);
		text.screenCenter();
		add(text);
		
		SaveData.trueSettings.set('Finished', true);
		SaveData.saveSettings();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(controls.ACCEPT)
		{
			GlobalMenuState.spawnMenu = 'title';
			Main.switchState(new GlobalMenuState());
		}
	}
}