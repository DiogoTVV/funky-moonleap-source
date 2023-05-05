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

enum WarningType {
	FLASHING;
	ENDING;
}
class WarningState extends MusicBeatState
{
	public static var curWarning:WarningType = FLASHING;
	
	override function create()
	{
		super.create();
		var bg = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(0,0,85));
		bg.screenCenter();
		add(bg);
		
		var mizera:String = '';
		switch(curWarning)
		{
			case FLASHING:
				mizera += "WARNING!!";
				mizera += "\n\nThis mod contains FLASHING LIGHTS";
				mizera += "\nIf you are sensible to those,\nmake sure to disable them at the acessibility options!";
				
			case ENDING:
				mizera += 'thanks for playing';
				mizera += '\n\nyou have completed all the songs\nin funky moonleap';
				mizera += '\n\nnow try pressing 7 or 8 on\nmidnight secrets for a surprise!';
				SaveData.trueSettings.set('Finished', true);
				SaveData.saveSettings();
				
			default:
				mizera = "this is a blank warning lol";
		}
		
		var text = new FlxText(0, 150, 0, mizera);
		text.setFormat(Main.gFont, 32, FlxColor.fromRGB(181,165,240), CENTER);
		text.screenCenter();
		add(text);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		switch(curWarning)
		{
			default:
				if(controls.ACCEPT)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					GlobalMenuState.spawnMenu = 'title';
					Main.switchState(new GlobalMenuState());
				}
		}
	}
}