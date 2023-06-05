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
		
		// its easier than creating two separate classes that do basically the same thing
		var mizera:String = '';
		switch(curWarning)
		{
			case FLASHING:
				mizera += "WARNING!!";
				mizera += "\n\nThis mod contains FLASHING LIGHTS";
				mizera += "\nIf you are sensible to those,\nmake sure to disable them at the acessibility options!";
				
			case ENDING:
				mizera += 'Congrats, you have completed all the songs in Funky Moonleap';
				mizera += '\n\nConsider checking out Moonleap\navailable for Windows, Android, IOS and Nintendo Switch';

				if(!SaveData.trueSettings.get('Controller Mode'))
					mizera += '\n\n(Press 7 or 8 while playing "Midnight Secrets"';
				else
					mizera += '\n\n(Press one of the joysticks\nwhile playing "Midnight Secrets"';

				mizera += '\nto see each version of the song)';
				mizera += '\n\nThanks for Playing!!';
				
				SaveData.trueSettings.set('Finished', true);
				SaveData.saveSettings();
				
			default:
				mizera = "looks like someone\ndidn't properly set the warning";
		}
		
		var text = new FlxText(0, 150, 0, mizera);
		text.setFormat(Main.gFont, 32, FlxColor.fromRGB(181,165,240), CENTER);
		text.screenCenter();
		add(text);
		
		#if mobile
		addVirtualPad(NONE, A_B);
		#end
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		switch(curWarning)
		{
			default:
				if(controls.ACCEPT || controls.BACK)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					GlobalMenuState.spawnMenu = 'title';
					Main.switchState(new GlobalMenuState());
				}
		}
	}
}