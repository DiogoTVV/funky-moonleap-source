package meta.state.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import gameObjects.*;
import gameObjects.userInterface.*;
import gameObjects.userInterface.notes.*;
import haxe.Json;
import lime.utils.Assets;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Section.SwagSection;
import meta.data.Song.SwagSong;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

/**
	In case you dont like the forever engine chart editor, here's the base game one instead.
**/
class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;
	
	// note type stuff
	static var curNoteType:String = 'none';
	var allNoteTypes:Array<String> = [
		"none", // dont change this one
		"No Animation",
		"Night Note",
	];
	
	public static var lastSection:Int = 0;
	
	var bpmTxt:FlxText;
	
	var strumLine:FlxSprite;
	//var curSong:String = 'test';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;
	
	var highlight:FlxSprite;
	
	final snaps:Array<Int> = [0, 4, 8, 12, 16, 20, 24, 32, 48, 64, 96, 192];
	public static var curSnap:Int = 1;
	public static var GRID_SNAP:Int = 4;
	public static var GRID_SIZE:Int = 40;
	
	var dummyArrow:FlxSprite;
	
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedTypes:FlxTypedGroup<FlxText>;

	var gridBG:FlxSprite;

	var _song:SwagSong;
	public static var lastSong:String = 'test';

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	
	override function create()
	{
		super.create();
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.set();
		bg.screenCenter();
		bg.alpha = 0.4;
		add(bg);
		
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);
		
		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + 1 + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);
		
		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedTypes = new FlxTypedGroup<FlxText>();
		
		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			/*
				_song = {
					song: 'Test',
					notes: [],
					bpm: 150,
					needsVoices: true,
					player1: 'bf',
					player2: 'dad',
					speed: 1,
					validScore: false
			};*/
		}
		
		FlxG.mouse.visible = true;
		//FlxG.save.bind('funkin', 'ninjamuffin99');
		
		tempBpm = _song.bpm;
		
		addSection();
		
		// sections = _song.notes;
		
		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);
		
		//	curSection = lastSection;
		
		bpmTxt = new FlxText(1000, 50, 1280, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);
		
		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);
		
		// timing lines
		for(i in 0...4)
		{
			var bpmLine = new FlxSprite(gridBG.x, gridBG.y + (GRID_SIZE * i * 4));
			bpmLine.makeGraphic(GRID_SIZE * 8, 2, FlxColor.fromRGB(222, 0, 0));
			add(bpmLine);
		}
		
		//strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		strumLine = new FlxSprite(gridBG.x, 50).makeGraphic(GRID_SIZE * 10, 4);
		strumLine.x -= GRID_SIZE;
		add(strumLine);
		
		var tabs = [
			{name: "Song", 	  label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note",	  label: 'Note'},
		];
		
		UI_box = new FlxUITabMenu(null, tabs, true);
		
		UI_box.resize(300, 300);
		UI_box.x = FlxG.width - UI_box.width - 180 + 20;
		UI_box.y = 20;
		add(UI_box);
		
		addSongUI();
		addSectionUI();
		addNoteUI();
		
		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedTypes);
		
		updateGrid();
		createIcons(false);
		
		// actually going into the right section
		if(_song.song == lastSong)
			changeSection(lastSection);
	}
	
	function createIcons(shouldRemove:Bool = true)
	{
		if(shouldRemove) // removing old icons
		{
			remove(leftIcon);
			remove(rightIcon);
		}
		
		leftIcon  = new HealthIcon((check_mustHitSection.checked) ? _song.player1 : _song.player2);
		rightIcon = new HealthIcon((!check_mustHitSection.checked) ? _song.player1 : _song.player2);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);
		
		var size:Int = 50; // 45
		leftIcon.setGraphicSize(0, size);
		rightIcon.setGraphicSize(0, size);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);
	}
	
	var playTicksBf:FlxUICheckBox = null;
	var playTicksDad:FlxUICheckBox = null;
	
	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			songMusic.volume = vol;
		};
		
		var check_mute_vocals = new FlxUICheckBox(10 + 120, 200, null, null, "Mute Vocals (in editor)", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_vocals.checked)
				vol = 0;

			vocals.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);
		
		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

		var player1DropDown = new FlxUIDropDownMenu(140, 115, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
			createIcons();
		});
		player1DropDown.selectedLabel = _song.player1;

		var player2DropDown = new FlxUIDropDownMenu(10, 115, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
			createIcons();
		});
		player2DropDown.selectedLabel = _song.player2;
		
		playTicksBf = new FlxUICheckBox(check_mute_inst.x, check_mute_inst.y + 25, null, null, 'Play BF Hitsounds', 100);
		playTicksBf.checked = false;

		playTicksDad = new FlxUICheckBox(check_mute_inst.x + 120, playTicksBf.y, null, null, 'Play Dad Hitsounds', 100);
		playTicksDad.checked = false;

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_vocals);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(new FlxText(stepperBPM.x + stepperBPM.width, stepperBPM.y, 0, ' :BPM'));
		tab_group_song.add(new FlxText(stepperSpeed.x + stepperSpeed.width, stepperSpeed.y, 0, ' :Song Speed'));
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(playTicksBf);
		tab_group_song.add(playTicksDad);
		
		// playeys
		tab_group_song.add(new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, 'Boyfriend:'));
		tab_group_song.add(new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, 'Opponent:'));
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();
		
		
		FlxG.camera.follow(strumLine);
		//var camFollow:FlxObject = new FlxObject(gridBG.x, gridBG.y - (GRID_SIZE * 4), 1, 1);
		//FlxG.camera.follow(camFollow);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	//var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';
		
		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 90, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear Section", clearSection);
		var clearSongButton:FlxButton = new FlxButton(10, 170, "Clear Song", clearSong);
		clearSongButton.color = FlxColor.RED;
		clearSongButton.label.color = FlxColor.WHITE;

		var swapSection:FlxButton = new FlxButton(10, 190, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
			}
			updateGrid();
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = _song.notes[curSection].mustHitSection;
		// _song.needsVoices = check_mustHit.checked;

		//check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		//check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 70, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		//tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(clearSongButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var convertSide:String = 'ALL';
	
	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 20, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		
		var noteTypeDropDown = new FlxUIDropDownMenu(10, 60, FlxUIDropDownMenu.makeStrIdLabelArray(allNoteTypes, true), function(daType:String)
		{
			curNoteType = allNoteTypes[Std.parseInt(daType)];
			updateGrid();
		});
		noteTypeDropDown.selectedLabel = curNoteType;
		
		var convertOptions:Array<String> = ['ALL', 'DAD NOTES', 'BF NOTES'];
		var convertDropDown = new FlxUIDropDownMenu(noteTypeDropDown.x, 100,
		FlxUIDropDownMenu.makeStrIdLabelArray(convertOptions, true), function(value:String)
		{
			convertSide = convertOptions[Std.parseInt(value)];
		});
		convertDropDown.selectedLabel = convertSide;
		
		var convertButton:FlxButton = new FlxButton(10 + noteTypeDropDown.width + 10, convertDropDown.y, "Convert Notes", function()
		{
			convertSectionType();
		});
		
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(new FlxText(stepperSusLength.x, stepperSusLength.y - 15, 0, 'Note Length:'));
		tab_group_note.add(convertButton);
		tab_group_note.add(convertDropDown);
		tab_group_note.add(new FlxText(convertDropDown.x, convertDropDown.y - 15, 0, 'Convert Note Types:'));
		tab_group_note.add(noteTypeDropDown);
		tab_group_note.add(new FlxText(noteTypeDropDown.x, noteTypeDropDown.y - 15, 0, 'Note Type:'));
		
		UI_box.addGroup(tab_group_note);
		// I'm genuinely tempted to go around and remove every instance of the word "sus" it is genuinely killing me inside
		// im not tho
	}

	var songMusic:FlxSound;

	function loadSong(daSong:String):Void
	{
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();

		songMusic = new FlxSound().loadEmbedded(Paths.inst(daSong), false, true);
		if (_song.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong), false, true);
		else
			vocals = new FlxSound();
		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		songMusic.play();
		vocals.play();

		pauseMusic();

		songMusic.onComplete = function()
		{
			ForeverTools.killMusic([songMusic, vocals]);
			loadSong(daSong);
		};
		//
	}

	function pauseMusic()
	{
		songMusic.time = Math.max(songMusic.time, 0);
		songMusic.time = Math.min(songMusic.time, songMusic.length);

		songMusic.pause();
		vocals.pause();
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;
					createIcons();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				//case "Alt Animation":
				//	_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			// ew what was this before? made it switch cases instead of else if
			switch (wname)
			{
				case 'section_length':
					_song.notes[curSection].lengthInSteps = Std.int(nums.value); // change length
					updateGrid(); // vrrrrmmm
				case 'song_speed':
					_song.speed = nums.value; // change the song speed
				case 'song_bpm':
					tempBpm = Std.int(nums.value);
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(Std.int(nums.value));
				case 'note_susLength': // STOP POSTING ABOUT AMONG US
					curSelectedNote[2] = nums.value; // change the currently selected note's length
					updateGrid(); // oh btw I know sus stands for sustain it just bothers me
				case 'section_bpm':
					_song.notes[curSection].bpm = Std.int(nums.value); // redefine the section's bpm
					updateGrid(); // update the note grid
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}
	
	var lastSongPos:Null<Float> = null;
	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();
		
		Conductor.songPosition = songMusic.time;
		_song.song = typingShit.text;
		
		// real thanks for the help with this ShadowMario, you are the best -Ghost
		var playedSound:Array<Bool> = [false, false, false, false];
		curRenderedNotes.forEachAlive(function(note:Note)
        {
			if(note.strumTime <= Conductor.songPosition)
			{
				if(note.strumTime > lastSongPos && songMusic.playing && note.noteData > -1)
				{
					var data:Int = note.noteData % 4;
					if(!playedSound[data])
					{
						if ((playTicksBf.checked) && (note.mustPress) || (playTicksDad.checked) && (!note.mustPress))
						{
							//FlxG.sound.play(Paths.sound('soundNoteTick'));
							FlxG.sound.play(Paths.sound('hitsound'));
							playedSound[data] = true;
						}
						
						data = note.noteData;
						if(note.mustPress != _song.notes[curSection].mustHitSection)
							data += 4;
					}
				}
			}
        });
		lastSongPos = Conductor.songPosition;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}
		
		if(FlxG.keys.justPressed.Z)
			curSnap--;
		if(FlxG.keys.justPressed.X)
			curSnap++;
		// yeah
		/*if(curSnap < 0)
			curSnap = snaps.length - 1;
		if(curSnap >= snaps.length)
			curSnap = 0;*/
		curSnap = FlxMath.wrap(curSnap, 0, snaps.length - 1);
		
		GRID_SNAP = snaps[curSnap];
		
		var formatSnap:Int = Math.floor(GRID_SNAP / 4);
		
		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.alpha = 1;
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT || GRID_SNAP == 0)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / formatSnap)) * (GRID_SIZE / formatSnap);
		}
		else
			dummyArrow.alpha = 0.0001;
		
		if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.mouse.visible = false;
			
			lastSection = curSection;
			lastSong = _song.song;

			PlayState.SONG = _song;
			songMusic.stop();
			vocals.stop();
			Main.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (songMusic.playing)
				{
					songMusic.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					songMusic.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				songMusic.pause();
				vocals.pause();

				songMusic.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = songMusic.time;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					songMusic.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						songMusic.time -= daTime;
					}
					else
						songMusic.time += daTime;

					vocals.time = songMusic.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					songMusic.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						songMusic.time -= daTime;
					}
					else
						songMusic.time += daTime;

					vocals.time = songMusic.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		var shiftThing:Int = (!FlxG.keys.pressed.SHIFT) ? 1 : 4;
		
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(songMusic.length / 1000, 2))
			+ "\n\nSection: "
			+ curSection
			+ "\nBeat: "
			+ curBeat
			+ "\nStep: "
			+ curStep
			+ '\n\nSnap: ' + getSnap();
		//bpmTxt.setPosition(20, FlxG.height - bpmTxt.height - 20);
		bpmTxt.setPosition(UI_box.x, FlxG.height - bpmTxt.height - 20);
		
		super.update(elapsed);
	}
	
	private function getSnap():String
	{
		var daSnap = "NONE";
		if(GRID_SNAP > 0)
			daSnap = '${GRID_SNAP}th';
		return daSnap;
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (songMusic.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((songMusic.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		songMusic.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		songMusic.time = sectionStartTime() - 10;

		if (songBeginning)
		{
			songMusic.time = 0;
			curSection = 0;
		}

		vocals.time = songMusic.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section ' + sec);
		
		if(curSection + sec < 0)
			return resetSection(true);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				songMusic.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				songMusic.time = sectionStartTime();
				vocals.time = songMusic.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}
	
	// converting note types
	function convertSectionType():Void
	{
		for (note in _song.notes[curSection].sectionNotes)
			note[3] = convertCheck(note);
		
		updateGrid();
	}
	
	// checking bf notes
	private function convertCheck(note:Array<Dynamic>):Dynamic
	{
		var newType = curNoteType;
		// i hate THISSS
		var mustPress:Bool = false;
		if((note[1] < 4 && check_mustHitSection.checked)
		|| (note[1]>= 4 && !check_mustHitSection.checked))
			mustPress = true;
		
		// cheking if the note type should be the same or not
		if((mustPress && convertSide.startsWith("DAD"))
		|| (!mustPress && convertSide.startsWith("BF")))
		{
			trace("ignored lol");
			newType = note[3];
		}
		
		return newType;
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		//check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		createIcons();
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}
		
		while (curRenderedTypes.members.length > 0)
		{
			curRenderedTypes.remove(curRenderedTypes.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		*/

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var daNoteType = "";

			if (i.length > 2)
				daNoteType = i[3];

			var note:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, daNoteInfo % 4, daNoteType, 0);
			note.sustainLength = daSus;
			note.noteType = daNoteType;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			note.mustPress = _song.notes[curSection].mustHitSection;
			if(daNoteInfo > 3) note.mustPress = !note.mustPress;

			curRenderedNotes.add(note);
			
			// type number
			for(type in allNoteTypes)
				if(type == daNoteType && type != "none")
				{
					var typeTxt = new FlxText(0, 0, 0, Std.string(allNoteTypes.indexOf(type)), 16);
					typeTxt.setFormat("vcr.ttf", Math.floor(GRID_SIZE / 1.3), FlxColor.WHITE, CENTER);
					typeTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
					typeTxt.setPosition(note.x + (note.width / 2) - (typeTxt.width / 2), note.y + (note.height / 2) - (typeTxt.height / 2));
					
					curRenderedTypes.add(typeTxt);
				}

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2) - 4,
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)), FlxColor.LIME);
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		//FlxTween.tween(note, {alpha: 0}, 0.2, {type: FlxTweenType.BACKWARD});
		
		var checkData:Int = note.noteData;
		if(note.mustPress != _song.notes[curSection].mustHitSection) checkData += 4;
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i != curSelectedNote && i.length > 2 && i[0] == note.strumTime && i[1] == checkData)
			{
				curSelectedNote = i;
				break;
			}
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		var checkData:Int = note.noteData;
		if(note.mustPress != _song.notes[curSection].mustHitSection) checkData += 4;
	
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == checkData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}
	
	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteType = curNoteType; // define notes as the current type
		var noteSus = 0; // ninja you will NOT get away with this

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteType]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteType]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		//if(!SaveData.debugMode) return;
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		Main.switchState(new ChartingState());
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		Main.switchState(new ChartingState());
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		removeFileEvents();
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		removeFileEvents();
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		removeFileEvents();
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
	
	function removeFileEvents()
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
	}
}