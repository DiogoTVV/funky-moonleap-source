package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import meta.Overlay;
import meta.MusicBeat.MusicBeatState;
import meta.data.Highscore;
import meta.data.dependency.Discord;
import meta.state.*;
import meta.state.menus.*;
import meta.state.charting.*;
import meta.data.Song;

using StringTools;

/**
	This is the initialisation class. if you ever want to set anything before the game starts or call anything then this is probably your best bet.
	A lot of this code is just going to be similar to the flixel templates' colorblind filters because I wanted to add support for those as I'll
	most likely need them for skater, and I think it'd be neat if more mods were more accessible.
**/
class Init extends MusicBeatState
{
	override function create():Void
	{
    #if android
    FlxG.android.preventDefaultKeys = [BACK];
    #end
		// check SaveData.hx to add options!!
		FlxG.save.bind('funkymoonleap-savedata', 'Funky-Moonleap');
		SaveData.loadSettings();
		SaveData.loadControls();
		Highscore.load();
		
		controls.setKeyboardScheme(None, false);
		
		// Some additional changes to default HaxeFlixel settings, both for ease of debugging and usability.
		FlxG.fixedTimestep = false; // This ensures that the game is not tied to the FPS
		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = false; // Hide mouse on start
		FlxGraphic.defaultPersist = true; // make sure we control all of the memory
		
		gotoTitleScreen();
	}
	
	private function gotoTitleScreen()
	{
		var bg = new flixel.FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(0,0,85));
		bg.screenCenter();
		add(bg);
		
		// warns you about the DANGERS OF FLASHING LIGHTS
		if(FlxG.save.data.isFirstTime == null)
		{
			FlxG.save.data.isFirstTime = true;
			FlxG.save.flush();
			WarningState.curWarning = FLASHING;
			Main.switchState(new WarningState());
		}
		else
			Main.switchState(new GlobalMenuState());
	}
	
	// idk why did i put it here but yeah
	public static function playSong(daSong:String)
	{
		daSong = CoolUtil.spaceToDash(daSong);
		
		PlayState.SONG = Song.loadFromJson(daSong, daSong);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;
		
		PlayState.storyWeek = 0;
		trace('PLAYING ' + PlayState.SONG.song.toUpperCase());
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		SaveData.unlockSong(daSong);
		
		Main.switchState(new PlayState());
	}
}
