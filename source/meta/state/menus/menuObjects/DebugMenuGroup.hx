package meta.state.menus.menuObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import meta.subState.WebsiteSubState;
import meta.state.*;
import meta.data.*;

class DebugMenuGroup extends MusicBeatGroup
{
	var optionShit:Array<String> = ["chart editor", "character editor", "final cutscene"];
	static var curSelected:Int = 0;
	
	var menuItems:FlxTypedGroup<FlxText>;
	
	public function new()
	{
		super();
		groupName = GlobalMenuState.spawnMenu = 'debug-menu';
		
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
			if(controls.BACK)
			{
				selectedSomething = true;
				GlobalMenuState.nextMenu = new MainMenuGroup();
				alive = false;
			}
			
			if(controls.UI_UP_P)
				changeSelection(-1);
			if(controls.UI_DOWN_P)
				changeSelection(1);
			
			if(controls.ACCEPT)
			{
				selectedSomething = true;
				GlobalMenuState.nextMenu = new DebugMenuGroup();
				
				switch(optionShit[curSelected].toLowerCase())
				{
					case 'chart editor':
						FlxG.sound.music.stop();
						
						PlayState.storyPlaylist = ['leap'];
						PlayState.isStoryMode = true;
						
						PlayState.storyDifficulty = 0;
						
						PlayState.SONG = Song.loadFromJson('leap', 'leap');
						PlayState.storyWeek = 0;
						PlayState.campaignScore = 0;
						
						Main.switchState(new meta.state.editors.ChartingState());
						
					case 'character editor':
						trace('not yet');
						
					case 'final cutscene':
						FlxG.sound.music.stop();
						Main.switchState(new MidnightState());
				}
				
				alive = false;
			}
		}
	}
	
	public function changeSelection(direction:Int = 0)
	{
		curSelected += direction;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);
		
		for(item in menuItems)
		{
			item.color = FlxColor.fromRGB(171,169,255);
			if (item.ID == curSelected)
				item.color = FlxColor.fromRGB(173,253,255);
		}
	}
}