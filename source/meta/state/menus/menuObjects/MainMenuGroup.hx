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

class MainMenuGroup extends MusicBeatGroup
{
	var optionShit:Array<String> = ["play", "credits", "buy moonleap", "options", "exit"];
	static var curSelected:Int = 0;
	
	var menuItems:FlxTypedGroup<FlxText>;
	
	public function new()
	{
		super();
		groupName = GlobalMenuState.spawnMenu = 'main-menu';
		
		#if !html5
		Discord.changePresence('MAIN MENU', 'Main Menu');
		#end
		
		//if(Init.debugMode)
		//	optionShit.insert(optionShit.length - 1, 'debug menu');
		if(GlobalMenuState.realClock != null)
			optionShit.insert(3, "< clock >");
		
		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);
		
		for(i in 0...optionShit.length)
		{
			var menuItem:FlxText = new FlxText(0, 0, 0, optionShit[i]);
			menuItem.scrollFactor.set();
			menuItem.setFormat(Main.gFont, 36, FlxColor.WHITE, CENTER);
			menuItem.ID = i;
			menuItems.add(menuItem);
			
			// arrumando os lugar
			menuItem.x = (FlxG.width / 2) - (menuItem.width / 2);
			menuItem.y = 300 + (50 * i); // 380
			//menuItem.alpha = 0;
			//flixel.tweens.FlxTween.tween(menuItem, {alpha: 1}, 0.5, {ease: flixel.tweens.FlxEase.expoOut});
		}
		changeSelection();
	}
	
	var selectedSomething:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(!selectedSomething)
		{
			if(controls.UI_UP_P)
				changeSelection(-1);
			if(controls.UI_DOWN_P)
				changeSelection(1);
			
			/*if(FlxG.keys.justPressed.SEVEN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				Init.debugMode = !Init.debugMode;
				GlobalMenuState.nextMenu = new MainMenuGroup();
				alive = false;
			}*/
			if(optionShit[curSelected] == "< clock >")
			{
				GlobalMenuState.realClock.moving = (controls.UI_LEFT || controls.UI_RIGHT);
				if(GlobalMenuState.realClock.moving)
				{
					GlobalMenuState.realClock.curTime += (elapsed * 2 * 60) * (controls.UI_LEFT ? -1 : 1);
					//trace("time is: " + GlobalMenuState.realClock.curTime);
				}
			}
			if(SaveData.trueSettings.get('Finished'))
			{
				if(FlxG.keys.justPressed.NUMPADMULTIPLY)
				{
					selectedSomething = true;
					WarningState.curWarning = ENDING;
					Main.switchState(new WarningState());
				}
			}

			if(controls.ACCEPT)
			{
				selectedSomething = true;
				GlobalMenuState.nextMenu = new MainMenuGroup();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				
				switch(optionShit[curSelected])
				{
					case 'story':
						//FlxG.sound.play(Paths.sound('confirmMenu'));
						FlxG.sound.music.stop();
						
						PlayState.storyPlaylist = ['leap', 'crescent', 'odyssey'];
						PlayState.isStoryMode = true;
						
						PlayState.storyDifficulty = 0;
						
						PlayState.SONG = Song.loadFromJson('leap', 'leap');
						PlayState.storyWeek = 0;
						PlayState.campaignScore = 0;
						Main.switchState(new PlayState());
						
					case 'freeplay' | 'play': GlobalMenuState.nextMenu = new FreeplayGroup();
						//Main.switchState(new meta.state.menus.FreeplayState());
					case 'credits': GlobalMenuState.nextMenu = new CreditsGroup();
					case 'options': GlobalMenuState.nextMenu = new OptionsGroup();
					case 'exit': Sys.exit(0);
					
					case 'debug menu': GlobalMenuState.nextMenu = new DebugMenuGroup();
					
					case 'ost' | 'buy moonleap':
						var link:String = (optionShit[curSelected] == 'ost') ? "https://on.soundcloud.com/ha9oz" : "https://store.steampowered.com/app/2166050/Moonleap/";
						
						FlxG.state.openSubState(new WebsiteSubState(link));
						//selectedSomething = false;
						
					//default: selectedSomething = false; // do nothing
				}
				
				alive = false;
			}
		}
	}
	
	public function changeSelection(direction:Int = 0)
	{
		if(direction != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		
		curSelected += direction;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);
		
		for(item in menuItems)
		{
			item.color = FlxColor.fromRGB(170,170,255);
			if (item.ID == curSelected)
				item.color = FlxColor.fromRGB(170,255,255);
		}
	}
}