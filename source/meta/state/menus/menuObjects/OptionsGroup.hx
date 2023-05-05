package meta.state.menus.menuObjects;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import gameObjects.userInterface.menu.*;
//import SaveData.SettingTypes;
//import SaveData;

class OptionsGroup extends MusicBeatGroup
{
	// options are the texts, attachs are the attachments (checkmarks/selectors)
	var grpOptions:FlxTypedGroup<FlxText>;
	var grpAttachs:FlxTypedGroup<FlxSprite>;
	var description:FlxText;
	
	var optionShit:Map<String, Dynamic> = [];
	public static var curCategory:String = 'main';
	
	// this stores every category's curSelected instead of it being just one static variable
	static var storedCurSelected:Map<String, Int> = [];
	var curSelected:Int = 0;
	
	public function new()
	{
		super();
		GlobalMenuState.spawnMenu = groupName = 'options';
		
		optionShit = [
			// category picker
			'main' => [
				'preferences',
				'appearence',
				'controls',
				'accessibility',
				'adjust offset',
				'reset save data',
			],
			// actual options
			"preferences" => [
				// pfv alguem me mata
				'Downscroll',
				'Middlescroll',
				'Ghost Tapping',
				'Controller Mode',
				'Display Accuracy',
				'Antialiasing',
				"Framerate Cap",
				'FPS Counter',
				'Memory Counter',
			],
			"appearence" => [
				'Fullscreen',
				'Ratings Near Notes',
				'Ratings Counter',
				'Show Clock',
				'Note Splashes',
				'Opaque Arrows',
				'Opaque Holds',
				'Clip Style',
			],
			"accessibility" => [
				"Flashing Lights",
				'Colorblind Filter',
				'Camera Note Movement',
				"Stage Opacity",
				"Particles",
			],
		];
		
		/*if(Init.debugMode)
		{
			optionShit['preferences'].push('Debug Info');
		}*/
		
		grpOptions = new FlxTypedGroup<FlxText>();
		grpAttachs = new FlxTypedGroup<FlxSprite>();
		add(grpOptions);
		add(grpAttachs);
		
		description = new FlxText(0,0,Math.floor(FlxG.width - 640),"");
		description.setFormat(Main.gFont, 18, FlxColor.fromRGB(173,253,255), CENTER);
		add(description);
		
		// actually reloading it
		changeCategory('main');
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(controls.UI_UP_P)
			changeSelection(-1, true);
		if(controls.UI_DOWN_P)
			changeSelection(1, true);
		
		if(controls.BACK)
		{
			storedCurSelected[curCategory] = curSelected;
			
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if(curCategory == 'main')
			{
				//FlxG.sound.play(Paths.sound('scrollMenu'));
				GlobalMenuState.nextMenu = new MainMenuGroup();
				alive = false;
			}
			else
				changeCategory('main');
		}
		
		if(controls.ACCEPT)
		{
			if(curCategory == 'main')
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				storedCurSelected[curCategory] = curSelected;
				
				var choice:String = optionShit[curCategory][curSelected];
				switch(choice)
				{
					case 'controls':
						if(SaveData.trueSettings.get('Controller Mode'))
							GlobalMenuState.nextMenu = new GamepadGroup();
						else
							GlobalMenuState.nextMenu = new ControlsGroup();
						alive = false;
						
					case 'adjust offset':
						FlxG.sound.music.stop();
						Main.switchState(new AdjustOffsetState());
						
					case 'reset save data':
						FlxG.state.openSubState(new meta.subState.DeleteSaveSubstate());
						
					default: // it will crash it optionShit doesnt have a category for it so beware!!
						changeCategory(choice);
				}
			}
			else
			{
				if(Std.isOfType(grpAttachs.members[curSelected], PixelCheckmark))
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					var checkmark:PixelCheckmark = cast(grpAttachs.members[curSelected], PixelCheckmark);
					
					checkmark.updateValue(!checkmark.value);
					SaveData.trueSettings.set(optionShit[curCategory][curSelected], checkmark.value);
					SaveData.saveSettings();
				}
			}
		}
		
		if(curCategory != 'main')
		{
			if(controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				loopSelector = 0;
				changeCurSelector();
			}
			
			if(controls.UI_LEFT || controls.UI_RIGHT) loopSelector += elapsed;
			if(controls.UI_LEFT_R || controls.UI_RIGHT_R) loopSelector = 0;
			
			if(loopSelector >= 0.6)
			{
				loopSelector = 0.55; // just so every loop delays a bit
				changeCurSelector(true);
			}
		}
	}
	
	var loopSelector:Float = 0;
	function changeCurSelector(isLoop:Bool = false)
	{
		if(Std.isOfType(grpAttachs.members[curSelected], PixelSelector))
		{
			var selector:PixelSelector = cast(grpAttachs.members[curSelected], PixelSelector);
			
			// it can only loop in Int selectors, not String ones
			if(isLoop && Std.isOfType(selector.options[0], String)) return;
			
			FlxG.sound.play(Paths.sound('scrollMenu'));
			selector.changeSelection(controls.UI_LEFT ? -1 : 1);
			SaveData.trueSettings.set(optionShit[curCategory][curSelected], selector.value);
			SaveData.saveSettings();
		}
	}
	
	public function changeCategory(newCategory:String = 'main')
	{
		curCategory = newCategory;
		while(grpOptions.members.length > 0) grpOptions.remove(grpOptions.members[0], true);
		while(grpAttachs.members.length > 0) grpAttachs.remove(grpAttachs.members[0], true);
		
		if(curCategory == 'main')
		{
			for(i in 0...optionShit['main'].length)
			{
				var menuItem:FlxText = new FlxText(0, 0, 0, optionShit['main'][i]);
				menuItem.scrollFactor.set();
				menuItem.setFormat(Main.gFont, 36, FlxColor.WHITE, CENTER);
				menuItem.ID = i;
				grpOptions.add(menuItem);
				
				menuItem.screenCenter(X);
				menuItem.y = 300 + (50 * i); // 300
			}
		}
		else
		{
			var label:FlxText = new FlxText(0,225 - 42,0, curCategory);
			label.setFormat(Main.gFont, 26, FlxColor.WHITE, CENTER);
			label.antialiasing = false;
			label.screenCenter(X);
			label.ID = 69420; // making sure it wont mess up the other options
			grpOptions.add(label);
			
			for(i in 0...optionShit[curCategory].length)
			{
				var daOption:String = optionShit[curCategory][i];
				
				var menuItem:FlxText = new FlxText(0, 0, 0, daOption.toLowerCase());
				menuItem.scrollFactor.set();
				menuItem.setFormat(Main.gFont, 24, FlxColor.WHITE, LEFT);
				menuItem.ID = i;
				grpOptions.add(menuItem);
				
				menuItem.x = 400;
				menuItem.y = label.y + (48/*64*/) + (42 * i); // 240 
				
				var daType:SaveData.SettingTypes = SaveData.gameSettings.get(daOption)[1];
				switch(daType)
				{
					case Selector: // gets the selector value and it's bounds
						var selector = new PixelSelector(SaveData.trueSettings.get(daOption), SaveData.gameSettings.get(daOption)[3]);
						selector.ID = i;
						selector.followY = menuItem.y + (selector.height / 2);
						grpAttachs.add(selector);
						
					case Checkmark: // gets the checkmark value
						var checkmark = new PixelCheckmark(SaveData.trueSettings.get(daOption));
						checkmark.ID = i;
						checkmark.x = 840; // 780
						checkmark.y = menuItem.y;
						grpAttachs.add(checkmark);
						
					default: continue;
				}
			}
		}
		
		if(storedCurSelected[curCategory] == null)
			storedCurSelected[curCategory] = 0;
		
		curSelected = storedCurSelected[curCategory];
		
		changeSelection();
	}
	
	public function changeSelection(direction:Int = 0, ?playSound:Bool = false)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
		
		curSelected += direction;
		curSelected = FlxMath.wrap(curSelected, 0, Math.floor(optionShit[curCategory].length - 1));
		
		function setItemColor(item:FlxSprite)
		{
			item.color = FlxColor.fromRGB(170,170,255);
			if (item.ID == curSelected)
				item.color = FlxColor.fromRGB(170,255,255);
		}
		
		for(item in grpOptions.members)
			setItemColor(item);
		
		description.text = '';
		
		if(curCategory == 'main') return;
		
		for(item in grpAttachs.members)
			setItemColor(item);
		
		description.text = SaveData.gameSettings.get(optionShit[curCategory][curSelected])[2];
		description.screenCenter(X);
		description.y = FlxG.height - description.height - 6;
	}
}