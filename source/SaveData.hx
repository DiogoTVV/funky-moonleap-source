package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.util.FlxSave;
import meta.data.ColorBlindFilterManager;
import meta.Overlay;

using StringTools;

/** 
	Enumerator for SettingTypes
	
	Checkmark:		Bool setting
	Selector:  		Int and Array<String> setting
	ProgressData:	Dynamic, but resets to default by "reset save data" on the options menu, so be careful!!

	*empty*:		Dynamic, but can't be set into options menu normally
**/
enum SettingTypes
{
	Checkmark;
	Selector;
	ProgressData;
}
class SaveData
{
	/*
		Here's, what each value does because i keep forgetting it and you probably will too
		
		0 - default value when you open the game for the first time
		1 - setting type (see above)
		2 - description (for the options menu)
		3 - bounds [min, max] or [option1, option2, option3] (if setting type is selector)
	*/
	public static var loaded:Bool = false;
	public static var trueSettings:Map<String, Dynamic> = [];
	public static var gameSettings:Map<String, Dynamic> = [
		'Finished' => [
			false,
			ProgressData,
		],
		'Locked Songs' => [
			['sun-hop', 'devlog', 'leap-(d-side-mix)', 'midnight-secrets'],
			ProgressData,
		],


		'Fullscreen' => [
			false,
			Checkmark,
			'Makes the game fullscreen.'
		],
		'Particles' => [
			true,
			Checkmark,
			'Whether to have little particles on the menu.'
		],

		'Baby Mode' => [
			false,
			Checkmark,
			'Whether to disable Modcharts\n(scroll speed changes also disables).'
		],
		'Reduced Movements' => [
			false,
			Checkmark,
			"Whether to reduce movements, like icons bouncing or beat zooms in gameplay."
		],

		'Show Clock' => [
			true,
			Checkmark,
			"Whether the clock that shows how much time is left should be visible or not.",
		],
		'Flashing Lights' => [
			true,
			Checkmark,
			"Disable this if you're sensible to quick flashing lights.",
		],
		'Downscroll' => [
			false,
			Checkmark,
			'Whether to have the strumline vertically flipped in gameplay.',
		],
		'Controller Mode' => [
			false,
			Checkmark,
			'Whether to use a controller instead of the keyboard to play. (Disables keyboard controls menu, be careful!!)',
		],
		'Auto Pause' => [
			true,
			Checkmark,
			'Whether to pause the game automatically if the window is unfocused.',
		],
		'FPS Counter' => [true, Checkmark, 'Whether to display the FPS counter.'],
		'Memory Counter' => [
			true,
			Checkmark,
			'Whether to display approximately how much memory is being used.',
		],
		'Debug Info' => [
			false,
			Checkmark,
			'Whether to display information like your game state.',
		],
		'Stage Opacity' => [
			100,
			Selector,
			'Darkens non-ui elements, useful if you find the characters and backgrounds distracting.',
			[0, 100],
		],
		'Ratings Counter' => [
			'none',
			Selector,
			'Choose whether you want to display your judgements on the HUD, and where you want it.',
			['none', 'left', 'right'],
		],
		'Ratings Near Notes' => [
			true,
			Checkmark,
			'If you want the ratings to appear near each note instead of near the player.',
		],
		'Display Accuracy' => [true, Checkmark, 'Whether to display your accuracy on screen.'],
		'Antialiasing' => [
			true,
			Checkmark,
			'Whether to enable Anti-aliasing. Disabling it might improve performance in FPS.',
		],
		'Camera Note Movement' => [
			true,
			Checkmark,
			'When enabled, notes move the camera when hit.',
		],
		'Note Splashes' => [
			true,
			Checkmark,
			'Whether to enable note splashes when you hit sick in gameplay.',
		],
		'Colorblind Filter' => [
			'none',
			Selector,
			'Choose a filter for colorblindness.',
			['none', 'protanopia', 'protanomaly', 'deuteranopia', 'deuteranomaly', 'tritanopia', 'tritanomaly', 'achromatopsia', 'achromatomaly']
		],
		"Clip Style" => [
			'stepmania',
			Selector,
			"Chooses a style for hold note clippings\nStepMania: Holds under strumline\nFNF: Holds over strumline",
			['stepmania', 'fnf']
		],
		"UI Skin" => [
			'default',
			Selector,
			'Choose a UI Skin for judgements, combo, etc.',
			''
		],
		"Note Skin" => ['default', Selector, 'Choose a note skin.', ['']],
		"Framerate Cap" => [120, Selector, 'Define your maximum FPS.', [30, 360]],
		"Opaque Arrows" => [
			false,
			Checkmark,
			"Makes the arrows at the top of the screen opaque again."
		],
		"Opaque Holds" => [false, Checkmark, "Same thing as above, but for hold/long notes"],
		'Ghost Tapping' => [
			true,
			Checkmark,
			"Enables Ghost Tapping, allowing you to press inputs without missing.",
		],
		'Middlescroll' => [false, Checkmark, "Center the notes, disables the enemy's notes."],
		'Skip Text' => [
			'freeplay only',
			Selector,
			'Decides whether to skip cutscenes and dialogue in gameplay. May be always, only in freeplay, or never.',
			['never', 'freeplay only', 'always']
		],
		'Fixed Judgements' => [
			false,
			Checkmark,
			"Fixes the judgements to the camera instead of to the world itself, making them easier to read.",
		],
		'Simply Judgements' => [
			false,
			Checkmark,
			"Simplifies the judgement animations, displaying only one judgement / rating sprite at a time.",
		],
		'Offset' => [0],
	];
	
	// this (kinda) sucks but im lazy to redo it and it works just fine so whatever
	public static var gameControls:Map<String, Dynamic> = [
		'LEFT' => 	[[A, FlxKey.LEFT], 				0],
		'DOWN' => 	[[S, FlxKey.DOWN], 				1],
		'UP' =>	  	[[W, FlxKey.UP],				2],
		'RIGHT' => 	[[D, FlxKey.RIGHT], 			3],
		'ACTION' => [[FlxKey.SPACE, FlxKey.NONE], 	4],
		// 5
		'UI_LEFT' =>[[A, FlxKey.LEFT], 		6],
		'UI_DOWN' =>[[S, FlxKey.DOWN], 		7],
		'UI_UP' => 	[[W, FlxKey.UP], 		8],
		'UI_RIGHT'=>[[D, FlxKey.RIGHT], 	9],
		// 10
		'ACCEPT' => [[FlxKey.SPACE, 	FlxKey.ENTER], 						11],
		'BACK' =>	[[X,				FlxKey.BACKSPACE,	FlxKey.ESCAPE], 12],
		'PAUSE' => 	[[P,				FlxKey.ENTER,		FlxKey.ESCAPE], 13],
		'RESET' => 	[[R, 				FlxKey.NONE],	 					14],
	];
	
	public static function loadSettings():Void
	{
		// set the true settings array
		// only the first variable will be saved! the rest are for the menu stuffs
		// IF YOU WANT TO SAVE MORE THAN ONE VALUE MAKE YOUR VALUE AN ARRAY INSTEAD
		for (setting in gameSettings.keys())
			trueSettings.set(setting, gameSettings.get(setting)[0]);
		
		// NEW SYSTEM, INSTEAD OF REPLACING THE WHOLE THING I REPLACE EXISTING KEYS
		// THAT WAY IT DOESNT HAVE TO BE DELETED IF THERE ARE SETTINGS CHANGES
		if (FlxG.save.data.settings != null)
		{
			var settingsMap:Map<String, Dynamic> = FlxG.save.data.settings;
			for (singularSetting in settingsMap.keys())
				if (gameSettings.get(singularSetting) != null)
					trueSettings.set(singularSetting, FlxG.save.data.settings.get(singularSetting));
		}
		
		// lemme fix that for you
		for(i in ["Framerate Cap", "Stage Opacity"])
			if(!Std.isOfType(trueSettings.get(i), Int))
				trueSettings.set(i, gameSettings.get(i)[0]);
		
		saveSettings();
		
		updateAll();
		loaded = true;
		FlxG.fullscreen = SaveData.trueSettings.get("Fullscreen");
	}
	
	public static function loadControls():Void
	{
		// stealing your controls from psych engine lol
		var psychSave = new flixel.util.FlxSave();
		//psychSave.bind("controls_v2", "ShadowMario/PsychEngine/ninjamuffin99");
		psychSave.bind("controls_v2", salvar());
		
		public static function salvar():String {
		@:privateAccess //galakxisne
		return #if (flixel < "5.0.0") 'ShadowMario/PsychEngine/ninjamuffin99' #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}
		
		if(FlxG.save.data.gameControls == null && psychSave.data.customControls != null)
		{
			var importControls:Map<String, Dynamic> = [];
			var psychControls:Map<String, Array<FlxKey>> = psychSave.data.customControls;
			for(label => key in psychControls)
			{
				label = label.replace('note_', '');
				
				for(i in gameControls.keys())
					if(i.toLowerCase() == label)
					{
						importControls.set(i, [key, gameControls.get(i)[1]]);
						trace('imported controls/$i from psych');
					}
			}
			for(label => key in gameControls)
			{
				if(importControls.get(label) == null)
					importControls.set(label, key);
			}
			gameControls = importControls;
			return saveControls();
		}

		if ((FlxG.save.data.gameControls != null) && (Lambda.count(FlxG.save.data.gameControls) == Lambda.count(gameControls)))
			gameControls = FlxG.save.data.gameControls;
		
		saveControls();
	}
	
	public static function saveSettings():Void
	{
		// ez save lol
		FlxG.save.data.settings = trueSettings;
		FlxG.save.flush();

		updateAll();
	}
	
	public static function saveControls():Void
	{
		FlxG.save.data.gameControls = gameControls;
		FlxG.save.flush();
	}
	
	public static function updateAll()
	{
		FlxG.autoPause = trueSettings.get('Auto Pause');
		
		Overlay.updateDisplayInfo(trueSettings.get('FPS Counter'), trueSettings.get('Debug Info'), trueSettings.get('Memory Counter'));
		
		#if !html5
		Main.updateFramerate(trueSettings.get("Framerate Cap"));
		#end
		
		//FlxG.fullscreen = trueSettings.get("Fullscreen");
		
		ColorBlindFilterManager.reload();
		
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
	}
	
	public static function unlockSong(daSong:String = 'leap')
	{
		if(trueSettings.get('Locked Songs').contains(daSong))
			trueSettings.get('Locked Songs').remove(daSong);
		
		saveSettings();
	}
}
