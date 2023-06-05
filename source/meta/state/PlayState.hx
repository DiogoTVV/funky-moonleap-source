package meta.state;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
import events.*;
import gameObjects.*;
import gameObjects.userInterface.*;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Strumline.StrumNote;
import meta.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Highscore.HighscoreData;
import meta.data.Song.SwagSong;
import meta.state.editors.*;
import meta.state.menus.*;
import meta.subState.*;
import openfl.display.GraphicsShader;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import openfl.media.Sound;
import openfl.utils.Assets;
import sys.io.File;

using StringTools;

#if desktop
import meta.data.dependency.Discord;
#end

class PlayState extends MusicBeatState
{
	public static var startTimer:FlxTimer;
	
	// curStage is inside stageBuild now
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 2;
	
	public static var songMusic:FlxSound = new FlxSound();
	public static var vocals:FlxSound = new FlxSound();
	
	public static var campaignScore:Int = 0;
	
	public static var dadOpponent:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;
	
	public var pump:Character;
	
	public static var assetModifier:String = 'base';
	public static var changeableSkin:String = 'default';
	
	private var unspawnNotes:Array<Note> = [];
	private var ratingArray:Array<String> = [];
	private var allSicks:Bool = true;
	
	// if you ever wanna add more keys
	private var numberOfKeys:Int = 4;
	
	// get it cus release
	// I'm funny just trust me
	public static var curSection:Int = 0;
	private var camFollow:FlxObject;
	private var camFollowPos:FlxObject;
	
	// Discord RPC variables
	public static var songDetails:String = "";
	public static var detailsSub:String = "";
	public static var detailsPausedText:String = "";
	
	private static var prevCamFollow:FlxObject;
	
	private var curSong:String = "";
	private var gfSpeed:Int = 1;
	
	public static var health:Float = 1; // mario
	public static var combo:Int = 0;
	
	public static var misses:Int = 0;
	
	public static var deaths:Int = 0;
	
	public var generatedMusic:Bool = false;
	
	private var startingSong:Bool = false;
	public static var paused:Bool = false;
	var startedCountdown:Bool = false;
	var inCutscene:Bool = false;
	
	public static var canPause:Bool = true;
	
	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;
	
	public var blackBars:BlackBars;
	
	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;
	public static var dialogueHUD:FlxCamera;
	
	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0; // might not use depending on result
	
	public static var cameraSpeed:Float = 1;
	public static var forceCamFollow:Bool = false;
	public static var defaultCamZoom:Float = 1.05;
	
	public static var forceZoom:Array<Float>;
	
	public static var songScore:Int = 0;
	
	var storyDifficultyText:String = "";
	
	public static var iconRPC:String = "";
	
	public static var songLength:Float = 0;
	public static var songPercent:Float = 0;
	public static var pauseSongLength:String = '';
	
	private var stageBuild:Stage;
	
	public static var uiHUD:ClassHUD;
	
	public static var daPixelZoom:Float = 6;
	public static var determinedChartType:String = "FNF";
	
	public var songSpeed:Float = 1.0;
	public var songSpeedTween:FlxTween;
	
	// strumlines
	public static var autoplay:Bool = false;
	public static var practice:Bool = false;
	public static var dadStrums:Strumline;
	public static var boyfriendStrums:Strumline;
	
	public static var strumLines:FlxTypedGroup<Strumline>;
	public static var strumHUD:Array<FlxCamera> = [];
	
	private var allUIs:Array<FlxCamera> = [];
	
	// stores the last combo objects in an array
	public static var lastCombo:Array<FlxSprite>;
	
	public var sunHopEffect:FlxSprite;
	public var midnightParticles:ParticleGroup;
	
	function resetStatics()
	{
		// reset any values and variables that are static
		songScore = 0;
		combo = 0;
		health = 1;
		misses = 0;
		// sets up the combo object array
		lastCombo = [];
		
		cameraSpeed = 1;
		forceCamFollow = false;
		defaultCamZoom = 1.05;
		forceZoom = [0, 0, 0, 0];

		assetModifier = 'base';
		changeableSkin = 'default';
		
		paused = false;
		canPause = true;
		FlxG.mouse.visible = false; // nuh uh
		SONG.validScore = true;
		curSection = 0;
	}
	
	// at the beginning of the playstate
	override public function create()
	{
		super.create();

		resetStatics();

		Timings.callAccuracy();

		// stop any existing music tracks playing
		resetMusic();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// create the game camera
		camGame = new FlxCamera();

		// create the hud camera (separate so the hud stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		allUIs.push(camHUD);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		
		var darknessHUD:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		darknessHUD.alpha = (100 - SaveData.trueSettings.get('Stage Opacity')) / 100;
		darknessHUD.scrollFactor.set();
		darknessHUD.cameras = [camHUD];
		darknessHUD.screenCenter();
		add(darknessHUD);
		
		// default song
		if (SONG == null)
			SONG = Song.loadFromJson('leap', 'leap');
		
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		
		songSpeed = SONG.speed;
		ScrollSpeedEvent.mapSteps(SONG.song.toLowerCase());
		
		/// here we determine the chart type!
		// determine the chart type here
		determinedChartType = "FNF";

		// set up a class for the stage type in here afterwards
		//curStage = "";
		// call the song's stage if it exists
		//if (SONG.stage != null)
		//	curStage = SONG.stage;
		//
		
		// kinda dumb but to get curStage you gotta do stageBuild.curStage now
		stageBuild = new Stage();
		add(stageBuild);
		
		stageBuild.loadStageBySong(CoolUtil.spaceToDash(SONG.song.toLowerCase()));
		
		// set up characters here too
		gf = new Character();
		//gf.adjustPos = false;
		//gf.setCharacter(300, 100, stageBuild.returnGFtype(stageBuild.curStage));
		gf.setCharacter(300, 720, stageBuild.returnGFtype(stageBuild.curStage));
		gf.scrollFactor.set(0.95, 0.95);
		
		dadOpponent = new Character();
		dadOpponent.setCharacter(50, 850, SONG.player2);
		// boyfriend
		boyfriend = new Boyfriend();
		boyfriend.setCharacter(750, 850, SONG.player1);
		// if you want to change characters later use setCharacter() instead of new or it will break
		
		stageBuild.repositionPlayers(boyfriend, dadOpponent, gf);
		stageBuild.dadPosition(boyfriend, dadOpponent, gf);
		
		/*if (SONG.assetModifier != null && SONG.assetModifier.length > 1)
			assetModifier = SONG.assetModifier;
		
		changeableSkin = Init.trueSettings.get("UI Skin");
		if ((stageBuild.curStage.startsWith("school")) && ((determinedChartType == "FNF")))
			assetModifier = 'pixel';*/
		
		// add characters
		var spawnOrder:Array<FlxSprite> = [gf, dadOpponent, boyfriend];
		
		switch(SONG.song.toLowerCase())
		{
			case 'midnight-secrets':
				pump = new Character();
				pump.setCharacter(0, 0, 'pump-pixel');
				pump.setPosition(dadOpponent.x - (16 * 8 * 1.35), dadOpponent.y);
				spawnOrder.push(pump);
				
			default:
				if(boyfriend.curCharacter == 'skid')
				{
					pump = new Character();
					pump.setCharacter(boyfriend.x + boyfriend.width + 25, boyfriend.y + boyfriend.frameHeight + 40, 'pump-bg');
					spawnOrder.push(pump);
				}
		}
		
		// adds them all in order
		for(char in spawnOrder)
			add(char);
		
		add(stageBuild.foreground);

		// force them to dance
		dadOpponent.dance();
		gf.dance();
		boyfriend.dance();
		
		// set song position before beginning
		Conductor.songPosition = -(Conductor.crochet * 4);
		
		// strum setup
		strumLines = new FlxTypedGroup<Strumline>();
		
		// generate the song
		generateSong(SONG.song);

		// create the game camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		followCamera(dadOpponent, true);
		// check if the camera was following someone previously
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		add(camFollowPos);

		// actually set the camera up
		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		
		// initialize ui elements
		startingSong = true;
		startedCountdown = true;

		//
		var placement = (FlxG.width / 2);
		dadStrums = new Strumline(placement - (FlxG.width / 4), dadOpponent, false, true, false, 4, SaveData.trueSettings.get('Downscroll'));
		dadStrums.visible = !SaveData.trueSettings.get('Middlescroll');
		boyfriendStrums = new Strumline(placement + (!SaveData.trueSettings.get('Middlescroll') ? (FlxG.width / 4) : 0), boyfriend, true, false, true,
			4, SaveData.trueSettings.get('Downscroll'));

		strumLines.add(dadStrums);
		strumLines.add(boyfriendStrums);

		// strumline camera setup
		strumHUD = [];
		for (i in 0...strumLines.length)
		{
			// generate a new strum camera
			strumHUD[i] = new FlxCamera();
			strumHUD[i].bgColor.alpha = 0;

			strumHUD[i].cameras = [camHUD];
			allUIs.push(strumHUD[i]);
			FlxG.cameras.add(strumHUD[i], false);
			// set this strumline's camera to the designated camera
			strumLines.members[i].cameras = [strumHUD[i]];
		}
		add(strumLines);
		
		// cache shit
		displayRating('sick', dadStrums.receptors.members[0], true);
		popUpCombo(true);
		
		blackBars = new BlackBars();
		blackBars.cameras = [camHUD];
		add(blackBars);
		
		uiHUD = new ClassHUD();
		add(uiHUD);
		uiHUD.cameras = [camHUD];
		//

		// create a hud over the hud camera for dialogue
		dialogueHUD = new FlxCamera();
		dialogueHUD.bgColor.alpha = 0;
		FlxG.cameras.add(dialogueHUD, false);
		
		#if android
		addMobileControls();
		mobileControls.visible = true;
		#end

		//
		keysArray = [
			copyKey(SaveData.gameControls.get('LEFT')[0]),
			copyKey(SaveData.gameControls.get('DOWN')[0]),
			copyKey(SaveData.gameControls.get('UP')[0]),
			copyKey(SaveData.gameControls.get('RIGHT')[0])
		];

		if (!SaveData.trueSettings.get('Controller Mode'))
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Paths.clearUnusedMemory();
		
		preloadCharacters();

		// call the funny intro cutscene depending on the song
		if (!skipCutscenes())
			songIntroCutscene();
		else
			startCountdown();
		
		/**
		 * SHADERS
		 *
		 * This is a highly experimental code by gedehari to support runtime shader parsing.
		 * Usually, to add a shader, you would make it a class, but now, I modified it so
		 * you can parse it from a file.
		 *
		 * This feature is planned to be used for modcharts
		 * (at this time of writing, it's not available yet).
		 *
		 * This example below shows that you can apply shaders as a FlxCamera filter.
		 * the GraphicsShader class accepts two arguments, one is for vertex shader, and
		 * the second is for fragment shader.
		 * Pass in an empty string to use the default vertex/fragment shader.
		 *
		 * Next, the Shader is passed to a new instance of ShaderFilter, neccesary to make
		 * the filter work. And that's it!
		 *
		 * To access shader uniforms, just reference the `data` property of the GraphicsShader
		 * instance.
		 *
		 * Thank you for reading! -gedehari
		 */

		// Uncomment the code below to apply the effect

		/*
			var shader:GraphicsShader = new GraphicsShader("", File.getContent("./assets/shaders/vhs.frag"));
			FlxG.camera.setFilters([new ShaderFilter(shader)]);
		 */
		curSong = SONG.song.toLowerCase();
		switch(curSong)
		{
			case 'midnight-secrets':
				midnightParticles = new ParticleGroup(20);
				midnightParticles.cameras = [strumHUD[strumHUD.length - 1]];
				add(midnightParticles);
			
			case 'sun-hop'|'devlog':
				var effectColor = FlxColor.fromRGB(236,157,0);
				if(curSong == 'devlog')
					effectColor = FlxColor.WHITE;
				
				sunHopEffect =
				FlxGradient.createGradientFlxSprite(Std.int(FlxG.width * 1.2), Std.int(FlxG.height * 1.2), [0x0, effectColor], 1, -90);
				sunHopEffect.cameras = [strumHUD[strumHUD.length - 1]];
				sunHopEffect.screenCenter();
				sunHopEffect.blend = ADD;
				sunHopEffect.alpha = 0;
				add(sunHopEffect);
				
				/*if(curSong == 'devlog')
					sunHopEffect.color = FlxColor.fromRGB(28,203,110);*/
				
				if(!SaveData.trueSettings.get('Flashing Lights')) sunHopEffect.visible = false;
		}
		
		var creditSong:String = curSong;
		switch(creditSong)
		{
			case 'midnight-secrets':
				if(storyDifficulty != 0) // midnight secrets stuff
					creditSong += (storyDifficulty == 1) ? " (day only)" : " (night only)";
		}
		
		var creditDisc = new CreditDisc(creditSong);
		creditDisc.cameras = [strumHUD[strumHUD.length - 1]];
		add(creditDisc);
	}
	
	// also preloads icons
	public function preloadCharacters()
	{
		var preloadList:Array<String> = [];
		
		switch(SONG.song.toLowerCase())
		{
			case 'leap' | 'crescent' | 'odyssey':
				preloadList = ['luano-day', 'luano-night'];
			case 'lunar-odyssey':
				preloadList = ['estrelano-day', 'estrelano-night'];
			case 'sun-hop':
				preloadList = ['solano', 'solano-alt'];
		}
		
		dadOpponent.adjustPos = false;
		for(i in preloadList)
			changeCharacter(dadOpponent, i);
		
		dadOpponent.adjustPos = true;
		changeCharacter(dadOpponent, SONG.player2);
		
		// also reposition players
		//stageBuild.repositionPlayers(null, dadOpponent, null);
	}
	
	public function changeCharacter(character:Character, newChar:String = 'luano', updateIcon:Bool = true)
	{
		character.setCharacter((!character.isPlayer ? 50 : 750), 850, newChar);
		
		if(updateIcon)
			uiHUD.changeIcon(newChar, character.isPlayer);
		
		if(!character.adjustPos) return;
		
		if(character == dadOpponent) stageBuild.repositionPlayers(null, dadOpponent, null);
		if(character == boyfriend) stageBuild.repositionPlayers(boyfriend, null, null);
		if(character == gf) stageBuild.repositionPlayers(null, null, gf);
	}
	
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}

	var keysArray:Array<Dynamic>;

	public function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if ((key >= 0)
			&& !boyfriendStrums.autoplay
			&& (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || SaveData.trueSettings.get('Controller Mode'))
			&& (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)))
		{
			if (generatedMusic)
			{
				var previousTime:Float = Conductor.songPosition;
				Conductor.songPosition = songMusic.time;
				// improved this a little bit, maybe its a lil
				var possibleNoteList:Array<Note> = [];
				var pressedNotes:Array<Note> = [];

				boyfriendStrums.allNotes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.noteData == key) && daNote.canBeHit && !daNote.isSustainNote && !daNote.tooLate && !daNote.wasGoodHit)
						possibleNoteList.push(daNote);
				});
				possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				// if there is a list of notes that exists for that control
				if (possibleNoteList.length > 0)
				{
					var eligable = true;
					var firstNote = true;
					// loop through the possible notes
					for (coolNote in possibleNoteList)
					{
						for (noteDouble in pressedNotes)
						{
							if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
								firstNote = false;
							else
								eligable = false;
						}

						if (eligable)
						{
							goodNoteHit(coolNote, boyfriend, boyfriendStrums, firstNote); // then hit the note
							pressedNotes.push(coolNote);
						}
						// end of this little check
					}
					//
				}
				else // else just call bad notes
					if (!SaveData.trueSettings.get('Ghost Tapping'))
						missNoteCheck(key, boyfriend, true);
				Conductor.songPosition = previousTime;
			}

			if (boyfriendStrums.receptors.members[key] != null
				&& boyfriendStrums.receptors.members[key].animation.curAnim.name != 'confirm')
				boyfriendStrums.receptors.members[key].playAnim('pressed');
		}
	}

	public function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate))
		{
			// receptor reset
			if (key >= 0 && boyfriendStrums.receptors.members[key] != null)
				boyfriendStrums.receptors.members[key].playAnim('static');
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
						return i;
				}
			}
		}
		return -1;
	}

	override public function destroy()
	{
		if (!SaveData.trueSettings.get('Controller Mode'))
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		super.destroy();
	}

	var staticDisplace:Int = 0;

	var lastSection:Int = 0;

	override public function update(elapsed:Float)
	{
		stageBuild.stageUpdateConstant(elapsed, boyfriend, gf, dadOpponent);
		
		if(dadOpponent.curCharacter == 'guselect-devlog')
			LuanoDevlogData.update(dadOpponent, boyfriend);
		
		super.update(elapsed);
		
		if(controls.ACTION && !startingSong)
		{
			switch(SONG.song.toLowerCase())
			{
				case "midnight-secrets":
					var isJumping:Bool = boyfriend.animation.curAnim.name == 'jump';
					var finishedJump:Bool = (isJumping && boyfriend.animation.curAnim.curFrame >= 6);
					
					if((!isJumping || finishedJump) && storyDifficulty == 0 && canPause && !autoplay)
						midnightJump();
					
				default:
					var chars:Array<Character> = [boyfriend];
					if(pump != null) chars.push(pump);
					
					for(char in chars)
						if(char.animation.getByName('hey') != null
						&& !["sunglass"].contains(char.animation.curAnim.name))
						{
							char.specialAnim = true;
							char.specialAnimTimer = getBeatSec() * 2;
							char.playAnim('hey', true);
						}
			}
		}
		switch(SONG.song.toLowerCase())
		{
			case "leap-(d-side-mix)":
				elapsedtime += elapsed * Conductor.crochet / 32;
				leapdside_noteside = Math.sin(elapsedtime);// * 1.1;
		}
		
		//if (health > 2) health = 2;
		health = FlxMath.bound(health, 0, 2);
		
		// dialogue checks
		if (dialogueBox != null && dialogueBox.alive)
		{
			// wheee the shift closes the dialogue
			if (FlxG.keys.justPressed.SHIFT)
				dialogueBox.closeDialog();
			
			// the change I made was just so that it would only take accept inputs
			if (FlxG.keys.justPressed.SHIFT #if android FlxG.android.justReleased.BACK #end)
				dialogueBox.closeDialog();
			
			// the change I made was just so that it would only take accept inputs
			var justTouched:Bool = false;

			for (touch in FlxG.touches.list)
			{
				justTouched = false;
				
				if (touch.justReleased)
					justTouched = true;
			}
			if (justTouched && dialogueBox.textStarted)
			#else
			if (controls.ACCEPT && dialogueBox.textStarted)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				dialogueBox.curPage += 1;
				
				if (dialogueBox.curPage == dialogueBox.dialogueData.dialogue.length)
					dialogueBox.closeDialog()
				else
					dialogueBox.updateDialog();
			}
		}
		
		if (!inCutscene)
		{
			// pause the game if the game is allowed to pause and enter is pressed
			if(controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
				pauseGame();
			
			var pressDebug:Array<Bool> = [FlxG.keys.justPressed.SEVEN,FlxG.keys.justPressed.EIGHT];
			if(SaveData.trueSettings.get('Controller Mode') && FlxG.gamepads.firstActive != null)
				pressDebug = [FlxG.gamepads.firstActive.justPressed.LEFT_STICK_CLICK,
								FlxG.gamepads.firstActive.justPressed.RIGHT_STICK_CLICK];

			switch(SONG.song.toLowerCase())
			{
				case 'midnight-secrets':
					if(Highscore.getHighscore('midnight-secrets').score > 0)
					{
						if(pressDebug.contains(true))
						{
							if(pressDebug[0] && storyDifficulty != 1)
							{
								SONG = Song.loadFromJson('midnight-secrets-day', 'midnight-secrets');
								storyDifficulty = 1;
								Main.switchState(new PlayState());
								return;
							}
							if(pressDebug[1] && storyDifficulty != 2)
							{
								SONG = Song.loadFromJson('midnight-secrets-night', 'midnight-secrets');
								storyDifficulty = 2;
								Main.switchState(new PlayState());
								return;
							}
							SONG = Song.loadFromJson('midnight-secrets', 'midnight-secrets');
							storyDifficulty = 0;
							Main.switchState(new PlayState());
						}
					}
					
				default:
					// char editor or whatever
					if(pressDebug[1])
					{
						resetMusic();
						
						OffsetEditorState.charName = (FlxG.keys.pressed.SHIFT ? boyfriend.curCharacter : dadOpponent.curCharacter);
						Main.switchState(new OffsetEditorState());
					}
					
					// charting state
					if(pressDebug[0])
					{
						resetMusic();
						if (FlxG.keys.pressed.SHIFT)
						{
							ChartingState.lastSong = SONG.song;
							ChartingState.lastSection = Math.floor(curStep / 16);
						}
						Main.switchState(new ChartingState());
					}
			}

			///*
			if (startingSong)
			{
				if (startedCountdown)
				{
					Conductor.songPosition += elapsed * 1000;
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
			else
			{
				// Conductor.songPosition = FlxG.sound.music.time;
				Conductor.songPosition += elapsed * 1000;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
						// Conductor.songPosition += FlxG.elapsed * 1000;
						// trace('MISSED FRAME');
					}
				}

				// Conductor.lastSongPos = FlxG.sound.music.time;
				// song shit for testing lols
			}
			
			// song ending shit
			checkEndSong();
			
			// boyfriend.playAnim('singLEFT', true);
			// */

			if(generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				curSection = Std.int(curStep / 16);
				if (curSection != lastSection)
				{
					// section reset stuff
					var lastMustHit:Bool = PlayState.SONG.notes[lastSection].mustHitSection;
					if (PlayState.SONG.notes[curSection].mustHitSection != lastMustHit)
					{
						camDisplaceX = 0;
						camDisplaceY = 0;
					}
					lastSection = Std.int(curStep / 16);
				}
				
				switch(SONG.song.toLowerCase())
				{
					case 'midnight-secrets':
						followCamera(dadOpponent, true);
					
					default:
						if(!forceCamFollow)
							defaultFollowCamera();
				}
			}
			
			var lerpVal = (elapsed * 2.4) * cameraSpeed;
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

			var easeLerp = 1 - Main.framerateAdjust(0.05);
			// camera stuffs
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, easeLerp);
			for (hud in allUIs)
				hud.zoom = FlxMath.lerp(1 + forceZoom[1], hud.zoom, easeLerp);

			// not even forcezoom anymore but still
			FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
			for (hud in allUIs)
				hud.angle = FlxMath.lerp(0 + forceZoom[3], hud.angle, easeLerp);

			// Controls

			// RESET = Quick Game Over Screen
			if ((health <= 0 || controls.RESET) && startedCountdown && !autoplay && !practice && !isDead)
			{
				forceDeath();
			}

			// spawn in the notes from the array
			if((unspawnNotes[0] != null) && ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500))
			{
				var dunceNote:Note = unspawnNotes[0];
				// push note to its correct strumline
				strumLines.members[Math.floor((dunceNote.noteData + (dunceNote.mustPress ? 4 : 0)) / numberOfKeys)].push(dunceNote);
				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}

			noteCalls();
			boyfriendStrums.autoplay = autoplay;
			if(autoplay || practice)
				SONG.validScore = false;

			if (SaveData.trueSettings.get('Controller Mode'))
				controllerInput();
		}
		
		var curTime:Float = Conductor.songPosition;
		if(curTime < 0) curTime = 0;
		songPercent = (curTime / songLength) * 100; // 0 to 100
		
		var curSeconds:Int = Math.floor(Math.abs(curTime / 1000));
		var secondsTotal:Int = Math.floor(Math.abs(songLength / 1000));
		
		pauseSongLength = FlxStringUtil.formatTime(curSeconds, false) + ' / ' + FlxStringUtil.formatTime(secondsTotal, false);
	}
	
	// making it easier to control the camera
	function followCamera(?char:Character, ?customX:Float = 0, ?customY:Float = 0, ?instant:Bool = false)
	{
		if(char == null) {
			camFollow.setPosition(customX, customY);
			return;
		}
		
		// if you want to mess with boyfriend's camera just check for char.isPlayer
		var getCenterX = char.getMidpoint().x + (char.isPlayer ? -100 : 100);
		var getCenterY = char.getMidpoint().y - 100;
		
		camFollow.setPosition(
			getCenterX + camDisplaceX + (char.charData.camOffsets[0] * (char.isPlayer ? -1 : 1)),
			getCenterY + camDisplaceY +  char.charData.camOffsets[1]
		);

		if(instant) camFollowPos.setPosition(camFollow.x, camFollow.y);
		
		// makes zooming for characters easier
		forceZoom[0] = char.charData.charZoom;
	}

	function defaultFollowCamera(?instant:Bool = false)
	{
		if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			followCamera(dadStrums.character, instant);
		else
			followCamera(boyfriendStrums.character, instant);

	}
	
	public var isDead:Bool = false;
	function forceDeath()
	{
		health = 0;
		isDead = true;
		deaths += 1;
		#if DISCORD_RPC
			Discord.changePresence("Game Over - " + songDetails, detailsSub, iconRPC);
		#end
		
		switch(SONG.song.toLowerCase())
		{
			case 'midnight-secrets':
				canPause = false;
				paused = true;
				resetMusic();
				//Conductor.songPosition = 0;
				boyfriend.playAnim('death');
				FlxG.sound.play(Paths.sound('death/luano'));
				
				new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					Main.switchState(new PlayState());
				});
				
			default:
				canPause = false;
				paused = true;
				// startTimer.active = false;
				persistentUpdate = false;
				persistentDraw = false;
				
				resetMusic();

				// dumb fix but it works ig
				for(i in  ["", "End"])
				{
					var preloadDeathMusic = new FlxSound().loadEmbedded(Paths.music('gameOver$i'), false, false);
					preloadDeathMusic.play();
					preloadDeathMusic.pause();
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				//FlxG.sound.play(Paths.sound('fnf_loss_sfx' + GameOverSubstate.stageSuffix));
				var deathSound:String = 'skid';
				for(char in ['pump', 'luano', 'skid-d-side'])
					if(boyfriend.curCharacter.startsWith(char))
						deathSound = char;
				
				FlxG.sound.play(Paths.sound('death/$deathSound'));
		}
	}
	
	// maybe theres a better place to put this, idk -saw
	function controllerInput()
	{
		var justPressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		var justReleaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		
		if (justPressArray.contains(true))
		{
			for (i in 0...justPressArray.length)
			{
				if (justPressArray[i])
					onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
			}
		}
		
		if (justReleaseArray.contains(true))
		{
			for (i in 0...justReleaseArray.length)
			{
				if (justReleaseArray[i])
					onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
			}
		}
	}
	
	var elapsedtime:Float = 0;
	var leapdside_noteside:Float = 0;

	function noteCalls()
	{
		// reset strums
		for (strumline in strumLines)
		{
			// handle strumline stuffs
			for (strum in strumline.receptors)
			{
				if (strumline.autoplay)
					strumCallsAuto(strum);
			}
			
			if (strumline.splashNotes != null)
				for (i in 0...strumline.splashNotes.length)
				{
					strumline.splashNotes.members[i].x = strumline.receptors.members[i].x - 48;
					strumline.splashNotes.members[i].y = strumline.receptors.members[i].y + (Note.swagWidth / 6) - 56;
				}
		}

		// if the song is generated
		if (generatedMusic && startedCountdown)
		{
			for (strumline in strumLines)
			{
				// set the notes x and y
				var downscrollMultiplier = (strumline.downscroll ? -1 : 1);
				
				strumline.allNotes.forEachAlive(function(daNote:Note)
				{
					var thisReceptor = strumline.receptors.members[Math.floor(daNote.noteData)];
					var roundedSpeed = FlxMath.roundDecimal(songSpeed, 2);
					var receptorPosY:Float = thisReceptor.y + Note.swagWidth / 6;
					var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * roundedSpeed)));
					var psuedoX = 25 + daNote.noteVisualOffset;
					
					var canModchart:Bool = !SaveData.trueSettings.get("Baby Mode");

					// funny curly notes
					if(SONG.song.toLowerCase() == "leap-(d-side-mix)" && canModchart)
					{
						if(blackBars.enabled && curStep < 2560)
							psuedoX += Math.sin((Conductor.songPosition - daNote.strumTime) / 150) * (daNote.mustPress ? 50 : -50) * leapdside_noteside;
					}
					
					daNote.y = receptorPosY
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX);
					// painful math equation
					daNote.x = thisReceptor.x
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY);
					
					// also set note rotation
					//daNote.angle = -daNote.noteDirection;
					if(SONG.song.toLowerCase() == "midnight-secrets")
					{
						daNote.canHitUpdate();
						// checks if the note matches with the background
						var dCheck:Array<Bool> = [stageBuild.curStage.endsWith('day'), daNote.noteType == "Night Note"];
						if((dCheck[0] && dCheck[1]) || (!dCheck[0] && !dCheck[1]))
							daNote.canBeHit = false;
					}
					
					// funny size change so it keeps up with the songSpeed
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end'))
					{
						if(daNote.noteSpeed != songSpeed)
						{
							// cleaner way to do hold note stuff
							daNote.setGraphicSize(
								Math.floor(daNote.width),
								Math.floor(0.46 * (daNote.noteCrochet * songSpeed))
							);
							
							daNote.updateHitbox();
							
							daNote.noteSpeed = songSpeed;
						}
					}
					
					// hur hur hur hur modchart hur hur
					if(!daNote.isSustainNote && thisReceptor != null)
					{
						daNote.scale.set(thisReceptor.scale.x, thisReceptor.scale.y);
						daNote.angle = thisReceptor.angle;
					}
					
					// shitty note hack I hate it so much
					var center:Float = receptorPosY + Note.swagWidth / 2;
					if (daNote.isSustainNote)
					{
						daNote.y -= ((daNote.height / 2) * downscrollMultiplier);
						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null))
						{
							daNote.y -= ((daNote.prevNote.height / 2) * downscrollMultiplier);
							if(strumline.downscroll)
							{
								daNote.y += (daNote.height * 2);
								
								if(!daNote.prevNote.wasGoodHit)
									daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height));
								
								if(daNote.endHoldOffset != Math.NEGATIVE_INFINITY)
									daNote.y += daNote.endHoldOffset;
							}
							else // this system is funny like that
								daNote.y += ((daNote.height / 2) * downscrollMultiplier);
						}
						
						if(strumline.downscroll)
						{
							daNote.flipY = true;
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
						else
						{
							daNote.flipY = false;
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}
					}
					// hell breaks loose here, we're using nested scripts!
					mainControls(daNote, strumline.character, strumline, strumline.autoplay);

					// check where the note is and make sure it is either active or inactive
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}

					if (!daNote.tooLate && daNote.strumTime < Conductor.songPosition - (Timings.msThreshold) && !daNote.wasGoodHit)
					{
						if ((!daNote.tooLate) && (daNote.mustPress))
						{
							if (!daNote.isSustainNote)
							{
								daNote.tooLate = true;
								for (note in daNote.childrenNotes)
									note.tooLate = true;

								vocals.volume = 0;
								missNoteCheck(daNote.noteData, boyfriend, true);
							}
							else if (daNote.isSustainNote)
							{
								if (daNote.parentNote != null)
								{
									var parentNote = daNote.parentNote;
									if (!parentNote.tooLate)
									{
										var breakFromLate:Bool = false;
										for (note in parentNote.childrenNotes)
										{
											trace('hold amount ${parentNote.childrenNotes.length}, note is late?' + note.tooLate + ', ' + breakFromLate);
											if (note.tooLate && !note.wasGoodHit)
												breakFromLate = true;
										}
										if (!breakFromLate)
										{
											missNoteCheck(daNote.noteData, boyfriend, true);
											for (note in parentNote.childrenNotes)
												note.tooLate = true;
										}
										//
									}
								}
							}
						}
					}

					// if the note is off screen (above)
					if ((((!strumline.downscroll) && (daNote.y < -daNote.height))
						|| ((strumline.downscroll) && (daNote.y > (FlxG.height + daNote.height))))
						&& (daNote.tooLate || daNote.wasGoodHit))
						destroyNote(strumline, daNote);
				});

				// unoptimised asf camera control based on strums
				strumCameraRoll(strumline.receptors, (strumline == boyfriendStrums));
			}
		}

		// reset bf's animation
		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		if ((boyfriend != null && boyfriend.animation != null)
			&& (boyfriend.holdTimer > Conductor.stepCrochet * (4 / 1000) && (!holdControls.contains(true) || boyfriendStrums.autoplay)))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}
	}

	function destroyNote(strumline:Strumline, daNote:Note)
	{
		daNote.active = false;
		daNote.exists = false;

		var chosenGroup = (daNote.isSustainNote ? strumline.holdsGroup : strumline.notesGroup);
		// note damage here I guess
		daNote.kill();
		if (strumline.allNotes.members.contains(daNote))
			strumline.allNotes.remove(daNote, true);
		if (chosenGroup.members.contains(daNote))
			chosenGroup.remove(daNote, true);
		daNote.destroy();
	}

	function goodNoteHit(coolNote:Note, character:Character, characterStrums:Strumline, ?canDisplayJudgement:Bool = true)
	{
		if (!coolNote.wasGoodHit)
		{
			coolNote.wasGoodHit = true;
			vocals.volume = 1;

			characterPlayAnimation(coolNote, character, characterStrums);
			if (characterStrums.receptors.members[coolNote.noteData] != null)
				characterStrums.receptors.members[coolNote.noteData].playAnim('confirm', true);

			// special thanks to sam, they gave me the original system which kinda inspired my idea for this new one
			if(canDisplayJudgement)
			{
				// get the note ms timing
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);
				// get the timing
				if(coolNote.strumTime < Conductor.songPosition)
					ratingTiming = "late";
				else
					ratingTiming = "early";

				// loop through all avaliable judgements
				var foundRating:String = 'miss';
				var lowestThreshold:Float = Math.POSITIVE_INFINITY;
				for (myRating in Timings.judgementsMap.keys())
				{
					var myThreshold:Float = Timings.judgementsMap.get(myRating)[1];
					if (noteDiff <= myThreshold && (myThreshold < lowestThreshold))
					{
						foundRating = myRating;
						lowestThreshold = myThreshold;
					}
				}
				
				if (!coolNote.isSustainNote)
				{
					increaseCombo(foundRating, coolNote.noteData, character);
					popUpScore(foundRating, characterStrums, coolNote);
					//if (coolNote.childrenNotes.length > 0)
					//	Timings.notesHit++;
					healthCall(Timings.judgementsMap.get(foundRating)[3]);
				}
				else if (coolNote.isSustainNote)
				{
					// call updated accuracy stuffs
					if (coolNote.parentNote != null)
					{
						// Timings.updateAccuracy(100, true, coolNote.parentNote.childrenNotes.length);
						Timings.updateAccuracy(100);
						healthCall(100 / coolNote.parentNote.childrenNotes.length);
					}
				}
			}

			if (!coolNote.isSustainNote)
				destroyNote(characterStrums, coolNote);
			//
		}
	}

	function missNoteCheck(direction:Int = 0, character:Character, popMiss:Bool = false, lockMiss:Bool = false)
	{
		var stringDirection:String = StrumNote.getArrowFromNumber(direction);
		
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		character.playAnim('sing' + stringDirection.toUpperCase() + 'miss', lockMiss);
		decreaseCombo(popMiss, direction);
		Timings.updateAccuracy(-175);
		allSicks = false;
	}
	
	function characterPlayAnimation(coolNote:Note, character:Character, characterStrums:Strumline)
	{
		// alright so we determine which animation needs to play
		var stringArrow = returnSingAnim(coolNote.noteData);
		
		switch(coolNote.noteType)
		{
			case "Night Note":
				if(!character.isPlayer)
					if(pump != null)
						character = pump;
		}
		
		// cool little effect that happens with double/really close to each other notes
		if(!coolNote.isSustainNote)
		{
			for(strum in characterStrums.receptors.members)
				if(strum.animation.curAnim.name == 'confirm' && strum.animation.curAnim.curFrame <= 0)
				{
					var hehe = new SingleTrail(character, 0.5, Conductor.crochet / 1000);
					stageBuild.add(hehe);
					break;
				}
		}
		
		switch(SONG.song.toLowerCase())
		{
			case 'midnight-secrets':
				if(!character.isPlayer && uiHUD.iconP2.curIcon != character.curCharacter)
					uiHUD.changeIcon(character.curCharacter, false);
				
				if(character.isPlayer && autoplay)
				{
					var dCheck:Array<Bool> = [coolNote.noteType == "Night Note", boyfriend.curCharacter.endsWith('day')];
					if((dCheck[0] && dCheck[1]) || (!dCheck[0] && !dCheck[1]))
						midnightJump();
				}
		}
		
		for(anim in ['jump', 'sunglass'])
			if(character.animation.curAnim.name.endsWith(anim)) return;
		
		character.playAnim(stringArrow, true);
		character.holdTimer = 0;
		
		// stuff
		if(dadOpponent.curCharacter == 'guselect-devlog')
			LuanoDevlogData.update(dadOpponent, boyfriend);
	}
	
	function returnSingAnim(direction:Int = 0):String
		return 'sing' + StrumNote.getArrowFromNumber(direction).toUpperCase();
	
	private function strumCallsAuto(cStrum:StrumNote, ?callType:Int = 1, ?daNote:Note):Void
	{
		switch (callType)
		{
			case 1:
				// end the animation if the calltype is 1 and it is done
				if ((cStrum.animation.finished) && (cStrum.canFinishAnimation))
					cStrum.playAnim('static');
			default:
				// check if it is the correct strum
				if (daNote.noteData == cStrum.ID)
				{
					// if (cStrum.animation.curAnim.name != 'confirm')
					cStrum.playAnim('confirm'); // play the correct strum's confirmation animation (haha rhymes)
					
					// stuff for sustain notes
					if ((daNote.isSustainNote) && (!daNote.animation.curAnim.name.endsWith('holdend')))
						cStrum.canFinishAnimation = false; // basically, make it so the animation can't be finished if there's a sustain note below
					else
						cStrum.canFinishAnimation = true;
				}
		}
	}

	private function mainControls(daNote:Note, char:Character, strumline:Strumline, autoplay:Bool):Void
	{
		var notesPressedAutoplay = [];

		// here I'll set up the autoplay functions
		if (autoplay)
		{
			// check if the note was a good hit
			if (daNote.strumTime <= Conductor.songPosition)
			{
				// use a switch thing cus it feels right idk lol
				// make sure the strum is played for the autoplay stuffs
				/*
					charStrum.forEach(function(cStrum:StrumNote)
					{
						strumCallsAuto(cStrum, 0, daNote);
					});
				 */

				// kill the note, then remove it from the array
				var canDisplayJudgement = false;
				if (strumline.displayJudgements)
				{
					canDisplayJudgement = true;
					for (noteDouble in notesPressedAutoplay)
					{
						if (noteDouble.noteData == daNote.noteData)
						{
							// if (Math.abs(noteDouble.strumTime - daNote.strumTime) < 10)
							canDisplayJudgement = false;
							// removing the fucking check apparently fixes it
							// god damn it that stupid glitch with the double judgements is annoying
						}
						//
					}
					notesPressedAutoplay.push(daNote);
				}
				goodNoteHit(daNote, char, strumline, canDisplayJudgement);
			}
			//
		}

		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		if (!autoplay)
		{
			// check if anything is held
			if (holdControls.contains(true))
			{
				// check notes that are alive
				strumline.allNotes.forEachAlive(function(coolNote:Note)
				{
					if ((coolNote.parentNote != null && coolNote.parentNote.wasGoodHit)
						&& coolNote.canBeHit
						&& coolNote.mustPress
						&& !coolNote.tooLate
						&& coolNote.isSustainNote
						&& holdControls[coolNote.noteData])
						goodNoteHit(coolNote, char, strumline);
				});
			}
		}
	}

	private function strumCameraRoll(cStrum:FlxTypedGroup<StrumNote>, strumHit:Bool)
	{
		if(!SaveData.trueSettings.get('Camera Note Movement')) return;
		
		var camNoteMove:Float = 25 / camGame.zoom;
		//var camNoteMove:Float = 40; // 15
		if(SONG.song.toLowerCase() == 'midnight-secrets')
			camNoteMove = 0;
		
		if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			var mustHit:Bool = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
			
			if((mustHit && strumHit) || (!mustHit && !strumHit))
			{
				camDisplaceX = 0;
				if (cStrum.members[0].animation.curAnim.name == 'confirm')
					camDisplaceX -= camNoteMove;
				if (cStrum.members[3].animation.curAnim.name == 'confirm')
					camDisplaceX += camNoteMove;
				
				camDisplaceY = 0;
				if (cStrum.members[1].animation.curAnim.name == 'confirm')
					camDisplaceY += camNoteMove;
				if (cStrum.members[2].animation.curAnim.name == 'confirm')
					camDisplaceY -= camNoteMove;
			}
		}
	}

	public function pauseGame()
	{
		// pause discord rpc
		updateRPC(true);

		// pause game
		paused = true;

		// update drawing stuffs
		persistentUpdate = false;
		persistentDraw = true;

		// stop all tweens and timers
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
		{
			if (!tmr.finished)
				tmr.active = false;
		});

		FlxTween.globalManager.forEach(function(twn:FlxTween)
		{
			if (!twn.finished)
				twn.active = false;
		});

		// open pause substate
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	override public function onFocus():Void
	{
		if (!paused)
			updateRPC(false);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (canPause && !paused && !SaveData.trueSettings.get('Auto Pause'))
			pauseGame();
		super.onFocusLost();
	}

	public static function updateRPC(pausedRPC:Bool)
	{
		#if DISCORD_RPC
		var displayRPC:String = (pausedRPC) ? detailsPausedText : songDetails;

		if (health > 0)
		{
			if (Conductor.songPosition > 0 && !pausedRPC)
				Discord.changePresence(displayRPC, detailsSub, iconRPC, true, songLength - Conductor.songPosition);
			else
				Discord.changePresence(displayRPC, detailsSub, iconRPC);
		}
		#end
	}

	var animationsPlay:Array<Note> = [];

	private var ratingTiming:String = "";

	function popUpScore(baseRating:String, strumline:Strumline, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// notesplashes
		if (baseRating == "sick")
			// create the note splash if you hit a sick
			createSplash(coolNote, strumline);
		else
			// if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
				allSicks = false;

		displayRating(baseRating, strumline.receptors.members[coolNote.noteData]);
		Timings.updateAccuracy(Timings.judgementsMap.get(baseRating)[3]);
		score = Std.int(Timings.judgementsMap.get(baseRating)[2]);
		
		songScore += score;
		
		popUpCombo();
	}

	public function createSplash(coolNote:Note, strumline:Strumline)
	{
		// play animation in existing notesplashes
		/*var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		if (strumline.splashNotes != null)
			strumline.splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom, true);*/
		strumline.splashNotes.members[coolNote.noteData].playAnim('anim1', true);
	}
	
	private var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popUpCombo(?cache:Bool = false)
	{
		if(true) return;
		
		var comboString:String = Std.string(combo);
		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;
		var stringArray:Array<String> = comboString.split("");
		// deletes all combo sprites prior to initalizing new ones
		if (lastCombo != null)
		{
			while (lastCombo.length > 0)
			{
				lastCombo[0].kill();
				lastCombo.remove(lastCombo[0]);
			}
		}
		
		for (scoreInt in 0...stringArray.length)
		{
			// numScore.loadGraphic(Paths.image('UI/' + pixelModifier + 'num' + stringArray[scoreInt]));
			var numScore = ForeverAssets.generateCombo('combo', stringArray[scoreInt], (!negative ? allSicks : false), assetModifier, changeableSkin, 'UI',
				negative, createdColor, scoreInt);
			add(numScore);
			// hardcoded lmao
			if (!SaveData.trueSettings.get('Simply Judgements'))
			{
				add(numScore);
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
			else
			{
				add(numScore);
				// centers combo
				numScore.y += 10;
				numScore.x -= 95;
				numScore.x -= ((comboString.length - 1) * 22);
				lastCombo.push(numScore);
				FlxTween.tween(numScore, {y: numScore.y + 20}, 0.1, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			}
			// hardcoded lmao
			if (SaveData.trueSettings.get('Fixed Judgements'))
			{
				if (!cache)
					numScore.cameras = [camHUD];
				numScore.y += 50;
			}
			numScore.x += 100;
		}
	}

	function decreaseCombo(?popMiss:Bool = false, direction:Int = 0)
	{
		// painful if statement
		if (((combo > 5) || (combo < 0)) && (gf.animOffsets.exists('sad')))
			gf.playAnim('sad');

		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		songScore -= 10;
		misses++;

		// display negative combo
		if (popMiss)
		{
			// doesnt matter miss ratings dont have timings
			displayRating("miss", boyfriendStrums.receptors.members[direction]);
			healthCall(Timings.judgementsMap.get("miss")[3]);
		}
		popUpCombo();

		// gotta do it manually here lol
		Timings.updateFCDisplay();
	}

	function increaseCombo(?baseRating:String, ?direction = 0, ?character:Character)
	{
		// trolled this can actually decrease your combo if you get a bad/shit/miss
		if (baseRating != null)
		{
			if (Timings.judgementsMap.get(baseRating)[3] > 0)
			{
				if (combo < 0)
					combo = 0;
				combo += 1;
			}
			else
				missNoteCheck(direction, character, false, true);
		}
	}

	public function displayRating(daRating:String, ratingStrum:StrumNote, ?cache:Bool = false)
	{
		/* so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss judgements can pop, and they dont mess with your sick combo
		 */
		var rating = ForeverAssets.generateRating('$daRating', (daRating == 'sick' ? allSicks : false), assetModifier);
		add(rating);
		
		if(cache)
		{
			rating.kill();
			return;
		}
		
		// */
		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				rating.kill();
			},
			startDelay: Conductor.crochet * 0.00125
		});
		
		// no ratings near notes :(
		if(!SaveData.trueSettings.get('Ratings Near Notes'))
		{
			if(assetModifier != 'pixel')
			{
				rating.scale.x *= 1.78;
				rating.scale.y *= 1.78;
			}
			else
			{
				rating.scale.set(8,8);
			}
			rating.updateHitbox();
			
			rating.velocity.x = FlxG.random.int(-30, 30);
			
			rating.x = boyfriend.x - (rating.width / 2) - boyfriend.animOffsets[boyfriend.returnIdle()][0];
			rating.y = boyfriend.y - rating.height;
		}
		else // yess ratings near notes >:]
		{
			rating.cameras = [camHUD];
			rating.x = 25 + ratingStrum.x + (Note.swagWidth / 2) - (rating.width / 2);
			
			rating.y = ratingStrum.y;
			if(ratingStrum.y + Note.swagWidth / 2 >= (FlxG.height / 2)) // checks if its under or above mid-screen height
				rating.y -= rating.height - 35;
			else
				rating.y += Note.swagWidth + 35;
		}
		
		// return the actual rating to the array of judgements
		Timings.gottenJudgements.set(daRating, Timings.gottenJudgements.get(daRating) + 1);
		
		// set new smallest rating
		if (Timings.smallestRating != daRating)
		{
			if (Timings.judgementsMap.get(Timings.smallestRating)[0] < Timings.judgementsMap.get(daRating)[0])
				Timings.smallestRating = daRating;
		}
	}

	function healthCall(?ratingMultiplier:Float = 0)
	{
		// health += 0.012;
		var healthBase:Float = 0.06;
		health += (healthBase * (ratingMultiplier / 100));
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			songMusic.play();
			vocals.play();
			
			resyncVocals();
			
			#if desktop
			// Song duration in a float, useful for the time left feature
			songLength = songMusic.length;
			
			// Updating Discord Rich Presence (with Time Left)
			updateRPC(false);
			#end
		}
		
		switch(SONG.song.toLowerCase())
		{
			case 'midnight-secrets':
				if(storyDifficulty == 2)
					midnightJump();
		}
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		//var songData = SONG;
		curSong = SONG.song.toLowerCase();
		Conductor.changeBPM(SONG.bpm);
		
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		/*var musicaFake:Array<String> = [
			'Lunar-Colapse',
			'Blood-Moon',
			'Hellgate',
			'A A Folou Rematch',
			'Fleap',
			'Hurricane',
			'Collision',
			'Receita-Federal-Song',
			'Killer-Tibba',
			'Comical',
			'ModMod',
		];
		songDetails = musicaFake[FlxG.random.int(0, musicaFake.length - 1)];*/
		songDetails = CoolUtil.dashToSpace(SONG.song).toUpperCase();// + ' - ' + CoolUtil.difficultyFromNumber(storyDifficulty);
		
		// String for when the game is paused
		detailsPausedText = "Paused - " + songDetails;

		// set details for song stuffs
		detailsSub = "";
		
		// Updating Discord Rich Presence.
		updateRPC(false);
		
		songMusic = new FlxSound();
		vocals = new FlxSound();
		
		switch(SONG.song.toLowerCase())
		{
			case "midnight-secrets": // preloading
				var preloadSong:Array<String> = ["Inst", "Voices"];
				for(i in 0...2)
				{
					songMusic.loadEmbedded(Paths.voices(SONG.song, preloadSong[i] + "-Night"), false, true);
					songMusic.play();
					songMusic.stop();
				}
		}
		
		songMusic.loadEmbedded(Paths.inst(SONG.song), false, true);
		if(SONG.needsVoices)
			vocals.loadEmbedded(Paths.voices(SONG.song), false, true);
		
		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);
		
		// generate the chart
		unspawnNotes = ChartLoader.generateChartType(SONG, determinedChartType);
		
		// mirroring notes lol
		//for(note in unspawnNotes)
		//	note.noteData = [0,1,2,3][3 - note.noteData];
		
		// sort through them
		unspawnNotes.sort(sortByShit);
		// give the game the heads up to be able to start
		generatedMusic = true;
	}
	
	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	
	function resyncVocals():Void
	{
		checkEndSong();
		
		trace('resyncing vocal time ${vocals.time}');
		songMusic.pause();
		vocals.pause();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		songMusic.play();
		vocals.play();
		trace('new vocal time ${Conductor.songPosition}');
	}

	override function stepHit()
	{
		super.stepHit();
		///*
		if(songMusic.time >= Conductor.songPosition + 20 || songMusic.time <= Conductor.songPosition - 20)
			resyncVocals();
		//*/
		
		// changing the scroll speed with the data inside ScrollSpeedEvent
		if(ScrollSpeedEvent.data.exists(curStep))
			changeScrollSpeed(ScrollSpeedEvent.data[curStep]);
		
		stepSongEvents(SONG.song.toLowerCase());
	}
	
	function changeScrollSpeed(newSpeed:Float = 2.8, time:Null<Float> = null)
	{
		if(SaveData.trueSettings.get("Baby Mode")) return;

		if(time == null) time = getBeatSec() * 2;
		
		if(songSpeedTween != null) songSpeedTween.cancel();
		songSpeedTween = FlxTween.tween(this, {songSpeed: newSpeed}, time);
	}
	
	// add your animations here or whatever
	var danceAnims:Array<String> = ["idle", "dance", "hey", "cheer", "sad", "angry", "scared"];
	private function charactersDance(curBeat:Int)
	{
		var charList:Array<Character> = [gf, boyfriend, dadOpponent];
		
		if(pump != null) charList.push(pump);
		
		for(char in charList)
		{
			for(anim in danceAnims)
			{
				var beatCheck:Bool = (curBeat % 2 == 0 || char.charData.quickDancer);
				// checks gfSpeed for gf
				if(char.curCharacter == gf.curCharacter)
					beatCheck = (curBeat % gfSpeed == 0);
				
				if(char.animation.curAnim.name.startsWith(anim) && beatCheck)
					char.dance();
			}
		}
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		if(curBeat % 4 == 0)
			camZoom();
		
		if(curStep % 16 == 0)
		{
			for(event in Conductor.bpmChangeMap)
				if(curStep >= event.stepTime)
					Conductor.changeBPM(event.bpm);
		}
		
		uiHUD.beatHit();
		
		//
		charactersDance(curBeat);

		// stage stuffs
		stageBuild.stageUpdate(curBeat, boyfriend, gf, dadOpponent);
	}
	
	//
	//
	/// substate stuffs
	//
	//
	
	public static function resetMusic()
	{
		Conductor.songPosition = 0;
		// simply stated, resets the playstate's music for other states and substates
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			// trace('null song');
			if (songMusic != null)
			{
				//	trace('nulled song');
				songMusic.pause();
				vocals.pause();
				//	trace('nulled song finished');
			}
		}
		
		// trace('open substate');
		super.openSubState(SubState);
		// trace('open substate end ');
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (songMusic != null && !startingSong)
				resyncVocals();

			// resume all tweens and timers
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
			{
				if (!tmr.finished)
					tmr.active = true;
			});

			FlxTween.globalManager.forEach(function(twn:FlxTween)
			{
				if (!twn.finished)
					twn.active = true;
			});

			paused = false;

			///*
			updateRPC(false);
			// */
		}

		Paths.clearUnusedMemory();

		super.closeSubState();
	}

	/*
		Extra functions and stuffs
	*/
	/// song end function at the end of the playstate lmao ironic I guess
	function checkEndSong()
	{
		if(generatedMusic)
		{
			var endCheck:FlxSound = songMusic;
			if(songMusic.length > vocals.length)
				endCheck = vocals;
			
			if(Conductor.songPosition >= endCheck.length
			||(endCheck.time == 0 && Conductor.songPosition >= 1000 && canPause))
				endSong();
		}
	}
	
	function endSong():Void
	{
		canPause = false;
		songMusic.volume = 0;
		vocals.volume = 0;
		deaths = 0;
		if(SONG.validScore && storyDifficulty == 0)
		{
			var newHighscore:HighscoreData = {
				score: songScore,
				accuracy: Math.floor(Timings.getAccuracy() * 100) / 100,
				misses: PlayState.misses,
			};
			
			Highscore.setHighscore(SONG.song, newHighscore);
			
			switch(SONG.song.toLowerCase())
			{
				case 'leap' | 'crescent' | 'lunar-odyssey':
					SaveData.unlockSong('sun-hop');
					
				case 'sun-hop':
					SaveData.unlockSong('devlog');
				
				case 'leap-(d-side-mix)':
					// only does it if you didnt unlock midnight secrets yet
					if(SaveData.trueSettings.get('Locked Songs').contains('midnight-secrets'))
					{
						Main.switchState(new MidnightState());
						return;
					}
					
				case 'midnight-secrets':
					if(!SaveData.trueSettings.get('Finished'))
					{
						WarningState.curWarning = ENDING;
						Main.switchState(new WarningState());
						return;
					}
			}
		}

		if (!isStoryMode)
		{
			GlobalMenuState.spawnMenu = 'freeplay';
			Main.switchState(new GlobalMenuState());
		}
		else
		{
			// set the campaign's score higher
			campaignScore += songScore;

			// remove a song from the story playlist
			storyPlaylist.remove(storyPlaylist[0]);

			// check if there aren't any songs left
			if (storyPlaylist.length <= 0)
			{
				// play menu music
				ForeverTools.resetMenuMusic();

				// set up transitions
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// change to the menu state
				Main.switchState(new GlobalMenuState());

				// save the week's score if the score is valid
				/*if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				// flush the save
				FlxG.save.flush();*/
			}
			else
				songEndSpecificActions();
		}
		//
	}

	private function songEndSpecificActions()
	{
		switch (SONG.song.toLowerCase())
		{
			case 'eggnog':
				// make the lights go out
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;

				// oooo spooky
				FlxG.sound.play(Paths.sound('Lights_Shut_off'));

				// call the song end
				var eggnogEndTimer:FlxTimer = new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer)
				{
					callDefaultSongEnd();
				}, 1);

			default:
				callDefaultSongEnd();
		}
	}

	private function callDefaultSongEnd()
	{
		var difficulty:String = '-' + CoolUtil.difficultyFromNumber(storyDifficulty).toLowerCase();
		difficulty = difficulty.replace('-normal', '');
		
		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
		ForeverTools.killMusic([songMusic, vocals]);

		// deliberately did not use the main.switchstate as to not unload the assets
		//FlxG.switchState(new PlayState());
		Main.switchState(new PlayState());
	}

	var dialogueBox:DialogueBox;

	public function songIntroCutscene()
	{
		switch (curSong)
		{
			case "winter-horrorland":
				inCutscene = true;
				var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					remove(blackScreen);
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					camFollow.y = -2050;
					camFollow.x += 200;
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				});
			case 'roses':
				// the same just play angery noise LOL
				FlxG.sound.play(Paths.sound('confirmDevlog'));
				callTextbox();
			case 'thorns':
				inCutscene = true;
				for (hud in allUIs)
					hud.visible = false;

				var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
				red.scrollFactor.set();

				var senpaiEvil:FlxSprite = new FlxSprite();
				senpaiEvil.frames = Paths.getSparrowAtlas('cutscene/senpai/senpaiCrazy');
				senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
				senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
				senpaiEvil.scrollFactor.set();
				senpaiEvil.updateHitbox();
				senpaiEvil.screenCenter();

				add(red);
				add(senpaiEvil);
				senpaiEvil.alpha = 0;
				new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
				{
					senpaiEvil.alpha += 0.15;
					if (senpaiEvil.alpha < 1)
						swagTimer.reset();
					else
					{
						senpaiEvil.animation.play('idle');
						FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
						{
							remove(senpaiEvil);
							remove(red);
							FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
							{
								for (hud in allUIs)
									hud.visible = true;
								callTextbox();
							}, true);
						});
						new FlxTimer().start(3.2, function(deadTime:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
						});
					}
				});
			default:
				callTextbox();
		}
		//
	}

	function callTextbox()
	{
		var dialogPath = Paths.json(SONG.song.toLowerCase() + '/dialogue');
		if (Assets.exists(dialogPath))
		{
			startedCountdown = false;

			dialogueBox = DialogueBox.createDialogue(sys.io.File.getContent(dialogPath));
			dialogueBox.cameras = [dialogueHUD];
			dialogueBox.whenDaFinish = startCountdown;

			add(dialogueBox);
		}
		else
			startCountdown();
	}

	public static function skipCutscenes():Bool
	{
		// pretty messy but an if statement is messier
		if(SaveData.trueSettings.get('Skip Text') != null && Std.isOfType(SaveData.trueSettings.get('Skip Text'), String))
		{
			switch (cast(SaveData.trueSettings.get('Skip Text'), String))
			{
				case 'never':
					return false;
				case 'freeplay only':
					if (!isStoryMode)
						return true;
					else
						return false;
				default:
					return true;
			}
		}
		return false;
	}

	public static var swagCounter:Int = 0;

	private function startCountdown():Void
	{
		inCutscene = false;
		Conductor.songPosition = -(Conductor.crochet * 5);
		swagCounter = 0;

		camHUD.visible = true;
		
		var soundFolder:String = 'countdown/default/';
		
		switch(SONG.song.toLowerCase())
		{
			
		}
		
		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			startedCountdown = true;

			charactersDance(curBeat);
			
			Conductor.songPosition = -(Conductor.crochet * (4 - swagCounter));
			
			// stops at "go"
			if(swagCounter >= 4) return;
			
			var soundMap:Map<Int, String> = [
				0 => '3',
				1 => '2',
				2 => '1',
				3 => 'Go',
			];
			FlxG.sound.play(Paths.sound(soundFolder + 'intro${soundMap[swagCounter]}')); // 0.6
			
			if(swagCounter != 0)
			{
				var spriteMap:Map<Int, String> = [
					0 => '',
					1 => 'ready',
					2 => 'set',
					3 => 'go',
				];
				
				var countSprite:FlxSprite = new FlxSprite();
				countSprite.loadGraphic(Paths.image('UI/default/base/countdown/' + spriteMap[swagCounter]));
				countSprite.scale.set(0.8,0.8);
				countSprite.updateHitbox();
				countSprite.scrollFactor.set();
				countSprite.cameras = [camHUD];
				add(countSprite);
				
				countSprite.screenCenter();
				countSprite.y -= (FlxG.height / 8);
				
				FlxTween.tween(countSprite, {y: countSprite.y += 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween) {
						countSprite.destroy();
					}
				});
			}
			
			swagCounter += 1;
		}, 5);
	}
	
	var curDevlogColor:Int = 0;
	var devlogColors:Array<Array<Int>> = [
		[28,203,110],  // green
		[175,102,206], // ourple
		[243,255,110], // yellow
		[175,102,206], // ourple
	];
	
	function stepSongEvents(daSong:String):Void
	{
		if(daSong == 'leap')
		{
			switch(curStep) // true day // false night
			{
				case 904 | 2584:
					swapDayNight('leap', false);
					
				case 1928:
					swapDayNight('leap', true);
				// zooms
				case 2192:
					changeCharZoom(0.55);
					spawnBlackScreen(2224);
					
				case 2224:
					changeCharZoom();
					blackBars.enabled = true;
					flashCamera(camGame, 1);
					
				case 2592:
					blackBars.enabled = false;
					flashCamera(camGame, 1);
				case 2848:
					changeCharZoom();
			}
			
			if(curStep % 32 == 0 && curStep >= 2592 && curStep < 2848)
			{
				camZoom(0.15);
				changeCharZoom(boyfriend.charData.charZoom + 0.1);
			}
			
			switch(curStep)
			{
				case 384|1168|1552:
					boyfriend.skidDance = true;
				case 896|1296|2576:
					boyfriend.skidDance = false;
			}
			/*if (songSpeed >= 2.7)
				boyfriend.altAnim['idle'] = '-dance';
			else
				boyfriend.altAnim['idle'] = '';*/
		}
		
		if(daSong == 'crescent')
		{
			var zoomSteps:Array<Int> = [1,10,12,14,16,32,42,44,46,48,64,74,76,78,80,96,106,108,110];
			var bigZoomSteps:Array<Int> = [128,640,1168,1232,1296,1552,1616,1680,1744,1808];
			if(zoomSteps.contains(curStep))
				camZoom(0.05, 0.05);
			if(bigZoomSteps.contains(curStep))
				camZoom(0.1, 0.1);
			
			switch(curStep)
			{
				case 896 | 1024:
					changeCharZoom(0.6);
					boyfriend.charData.camOffsets[0] -= 250;
					spawnBlackScreen(curStep + (904 - 896), true);
				case 904 | 1032:
					changeCharZoom(); // 0.7
					boyfriend.charData.camOffsets[0] += 250;
				
				case 256 | 1424:
					changeCharZoom(0.15);
					blackBars.enabled = true;
				case 384 | 1552:
					changeCharZoom();
					blackBars.enabled = false;
			}
			
			switch(curStep)
			{
				case 384:
					swapDayNight('crescent', false);
				case 1168:
					swapDayNight('crescent', true);
			}
		}
		
		if(daSong == 'lunar-odyssey')
		{
			switch(curStep)
			{
				case 1408 | 2461 | 2972:
					swapDayNight('odyssey', false);
				case 2168 | 2716 | 3228:
					swapDayNight('odyssey', true);
			}
			switch(curStep)
			{
				case 112|116|120|122|123|124|126|2448|2452|2456|2460|2462:
					camZoom(0.1, 0.05);
				case 128:
					camZoom(0.4, 0.1);
					flashCamera(camGame, getBeatSec() * 4);
				case 640|1920|2176|2720|2848|2976|3232:
					camZoom(0.1, 0.05);
					flashCamera(camGame, getBeatSec() * 3);
					blackBars.enabled = false;
				case 1152:
					flashCamera(camGame, getBeatSec() * 3);
					blackBars.enabled = true;
				case 1392:
					changeCharZoom(0.4);
				case 1408:
					flashCamera(camGame, getBeatSec() * 4);
					blackBars.enabled = false;
					changeCharZoom();
				case 2432:
					changeCharZoom(0.5);
					spawnBlackScreen(2464);
				case 2464:
					changeCharZoom();
					blackBars.enabled = true;
				case 3616:
					defaultCamZoom = 0.7;
					flashCamera(camGame, getBeatSec() * 12);
			}
			switch(curStep)
			{
				case 1976|2032|2104|3032|3088|3160|3216:
					changeCharZoom(0.4);
					blackBars.enabled = true;
				case 1984|2048|2112|3040|3104|3168|3232:
					changeCharZoom();
					blackBars.enabled = false;
			}
			if(curStep >= 3488 && curStep < 3616)
			{
				defaultCamZoom += (1.2 - 0.7) / (3616 - 3488);
			}
		}
		
		if(daSong == 'sun-hop')
		{
			switch(curStep)
			{
				case 528 | 1168:
					swapDayNight('sun-hop', false);
				
				case 912 | 1680:
					swapDayNight('sun-hop', true);
			}
			switch(curStep)
			{
				case 288|291|294|352|355|358:
					camZoom(0.05,0.05);
				
				case 1424:
					changeCharZoom(0.3);
					
				case 656|848|1440:
					changeCharZoom(0.3);
					blackBars.enabled = true;
				
				case 784|912|1552:
					changeCharZoom();
					blackBars.enabled = false;
				case 1762: 
					forceCamFollow = false;
					followCamera(gf);
			}
			switch(curStep)
			{
				case 656|912|1440:
					flashCamera(camGame, getBeatSec() * 4);
			}
		}
		
		if(daSong == 'devlog')
		{
			switch(curStep)
			{
				case 272:
					flashCamera(camGame, getBeatSec() * 2);
					defaultCamZoom = 0.25;
				case 368:
					changeCharZoom(0.1);
				case 528:
					changeCharZoom();
					boyfriend.charData.charZoom = 0.1;
				case 2064:
					changeCharZoom(0.1);
					FlxTween.tween(sunHopEffect, {alpha: 0.6}, getBeatSec());
				case 2192:
					blackBars.enabled = true;
				case 2320:
					changeCharZoom();
					blackBars.enabled = false;
					boyfriend.charData.charZoom = 0.1;
					FlxTween.tween(sunHopEffect, {alpha: 0}, getBeatSec() * 4);
				case 2448:
					changeCharZoom();
					defaultCamZoom = 0.8;
					flashCamera(camGame, getBeatSec() * 8);
			}
			
			if(curStep >= 2064 + 4 && curStep < 2320)
			{
				if(curStep % 8 == 0)
				{
					//trace('era pra mudar');
					curDevlogColor = FlxMath.wrap(curDevlogColor + 1, 0, devlogColors.length - 1);
					FlxTween.color(sunHopEffect, (getStepSec() * 8) * 0.95, sunHopEffect.color, CoolUtil.arrayToColor(devlogColors[curDevlogColor]));
				}
			}
		}
		
		if(daSong == 'leap-(d-side-mix)')
		{
			switch(curStep)
			{
				case 1012 | 2804: // 1008
					swapDayNight(false);

				case 2040: // 2036
					swapDayNight(true);
			}
			switch(curStep)
			{
				case 256|512|768|1152|1408|1536|2048|2304|2560|2624|2688|2752|3072:
					flashCamera(camGame, getBeatSec() * 2);
			}
			switch(curStep)
			{
				case 256:
					camZoom(0.15,0.05);
				case 768|2304:
					blackBars.enabled = true;
				case 1024|2560:
					blackBars.enabled = false;
				case 2608|2736:
					blackBars.enabled = true;
					changeCharZoom(0.6);
				case 2624|2752:
					blackBars.enabled = false;
					changeCharZoom();
			}
		}
		
		if(daSong == 'midnight-secrets' && storyDifficulty == 0)
		{
			switch(curStep)
			{
				case 144:
					var pressMidnight = new gameObjects.background.MidnightButton();
					pressMidnight.cameras = [camHUD];
					add(pressMidnight);
			}
		}
	}
	
	function swapDayNight(?stageName:String = 'leap', isDay:Bool = true)
	{
		switch(stageBuild.curStage)
		{
			case 'leap-(d-side-mix)':
				if(!isDay)
				{
					forceCamFollow = true;
					followCamera(dadOpponent);
					defaultCamZoom += 0.5;
					dadOpponent.playAnim('pre-jump');
					
					new FlxTimer().start((1 / 24) * 16, function(timer:FlxTimer)
					{
						defaultCamZoom -= 0.5;
						dadOpponent.playAnim('jump');
						
						new FlxTimer().start((1 / 24) * 5, function(timer:FlxTimer)
						{
							stageBuild.spike.x = 1220;
							stageBuild.spike.flipX = false;
							flashCamera(camGame, Conductor.crochet / 1000);
						},1);
						
						new FlxTimer().start((1 / 24) * 12, function(timer:FlxTimer)
						{
							forceCamFollow = false;
							changeCharacter(dadOpponent, 'estrelano-night');
						},1);
					},1);
				}
				else
				{
					forceCamFollow = true;
					followCamera(dadOpponent);
					
					dadOpponent.playAnim('jump');
					new FlxTimer().start((1 / 24) * 11, function(timer:FlxTimer)
					{
						stageBuild.spike.x = -905;
						stageBuild.spike.flipX = true;
					},1);
					
					new FlxTimer().start((1 / 24) * 15, function(timer:FlxTimer)
					{
						forceCamFollow = false;
						changeCharacter(dadOpponent, 'estrelano-day');
					},1);
				}
				
			case 'sun-hop':
				flashCamera(camGame, getBeatSec() * 3);
				FlxTween.tween(sunHopEffect, {alpha: isDay ? 0 : 0.75}, getBeatSec() * 4, {startDelay: getBeatSec() * 6});
				changeCharacter(dadOpponent, isDay ? 'solano' : 'solano-alt');
				dadOpponent.playAnim('jump');
				
				new FlxTimer().start(Conductor.crochet / 1000 * (isDay ? 2 : 6), function(timer:FlxTimer)
				{
					changeCharacter(boyfriend, isDay ? 'pump' : 'pump-alt');
					boyfriend.playAnim('sunglass');
				},1);
				
				stageBuild.sunHopBG.animation.curAnim.curFrame = isDay ? 0 : 1;
				
				for(spike in [stageBuild.spikeSunA, stageBuild.spikeSunB])
				{
					if(!isDay)
						spike.x = 50 - spike.width;
					else
						spike.x = 1340;
					
					spike.flipX = !isDay;
				}
				
				stageBuild.bixinhoA.isActive = isDay;
				stageBuild.bixinhoB.isActive = !isDay;
				
			default:
				var dPrefix:String = (isDay ? 'day' : 'night');
			
				stageBuild.reloadStage('$stageName-$dPrefix');
				
				changeCharacter(dadOpponent, 'luano-$dPrefix');
				dadOpponent.playAnim('jump');
				
				//stageBuild.repositionPlayers(null, dadOpponent, null);
				
				var newColor:FlxColor = (isDay ? 0xFFFFFFFF : 0xFF534078);
				boyfriend.color = newColor;
				if(pump != null) pump.color = newColor;
				
				camZoom(0.05, 0);
		}
	}
	
	function midnightJump()
	{
		var wasDay:Bool = stageBuild.curStage.endsWith('day');
		var endPrefix:String = (wasDay ? 'night' : 'day');
		
		stageBuild.reloadStage('midnight-' + endPrefix);
		
		changeCharacter(boyfriend, 'luano-pixel-' + endPrefix, true);
		//stageBuild.repositionPlayers(boyfriend, null, null);
		boyfriend.playAnim('jump', true);
		
		// changing vocals
		vocals.loadEmbedded(Paths.voices(SONG.song, (wasDay ? 'Voices-Night' : 'Voices')), false, true);
		songMusic.loadEmbedded(Paths.voices(SONG.song, (wasDay ? 'Inst-Night' : 'Inst')), false, true);
		
		midnightParticles.isDay = !wasDay;
		
		vocals.play();
		songMusic.play();
		vocals.time = songMusic.time = Conductor.songPosition;
	}
	
	function spawnBlackScreen(finalStep:Int, backwards:Bool = false)
	{
		var blackScreen = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF000000);
		blackScreen.screenCenter();
		add(blackScreen);
		
		if(!backwards) blackScreen.alpha = 0;
		
		FlxTween.tween(blackScreen, {alpha: 0.4}, getBeatSec() * 1.5);
		
		new FlxTimer().start((finalStep - curStep) * Conductor.stepCrochet / 1000, function(tmr:FlxTimer)
		{
			FlxTween.tween(blackScreen, {alpha: 0}, getBeatSec() * 0.5, {
				ease: FlxEase.cubeIn,
				onComplete: function(twn:FlxTween)
				{
					blackScreen.destroy();
				}
			});
		});
	}
	
	function changeCharZoom(newZoom:Float = 0)
		boyfriend.charData.charZoom = dadOpponent.charData.charZoom = newZoom;
	
	private function camZoom(gameZoom:Float = 0.015, ?hudZoom:Float = 0.05)
	{
		if(SaveData.trueSettings.get('Reduced Movements')) return;

		camGame.zoom += gameZoom;
		camHUD.zoom += hudZoom;
		for(hud in strumHUD)
			hud.zoom += hudZoom;
	}
	
	function flashCamera(daCamera:FlxCamera, daTime:Float = 1, daColor:FlxColor = FlxColor.WHITE)
	{
		if(!SaveData.trueSettings.get('Flashing Lights')) return;
		
		daCamera.flash(daColor, daTime, null, true);
	}
	
	// idk ill probably use this
	function getStepSec():Float
		return (Conductor.stepCrochet / 1000);
	function getBeatSec():Float
		return (Conductor.crochet / 1000);
}
