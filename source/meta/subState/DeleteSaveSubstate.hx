package meta.subState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Highscore;
import meta.state.menus.GlobalMenuState;

using StringTools;

class DeleteSaveSubstate extends MusicBeatSubState
{
	var warningText:FlxText;
	public var grpItems:FlxTypedGroup<FlxSprite>;
	
	public function new()
	{
		super();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(0,0,85));
		bg.scrollFactor.set();
		bg.alpha = 0;
		add(bg);
		
		var daText:String = "WARNING!";
		daText += '\nthis will reset your whole save data\npress CONFIRM 3 times to do it';
		
		warningText = new FlxText(0, 64, 1180, daText);
		warningText.setFormat(Main.gFont, 26, FlxColor.fromRGB(173,253,255), CENTER);
		warningText.screenCenter(X);
		add(warningText);
		
		grpItems = new FlxTypedGroup<FlxSprite>();
		add(grpItems);
		
		var options:Array<String> = ["CONFIRM", "nevermind"];
		for(i in 0...options.length)
		{
			var newItem = new FlxText(0,0,0,options[i]);
			newItem.setFormat(Main.gFont, 32, FlxColor.WHITE, CENTER);
			grpItems.add(newItem);
			
			newItem.x = (FlxG.width / 2) - (newItem.width / 2);
			newItem.y = FlxG.height - newItem.height - (140);
			if(i == 0)
				newItem.y -= newItem.height + 4;
			
			newItem.ID = i;
		}
		
		changeSelection(false);
		
		FlxTween.tween(bg, {alpha: 0.75}, 0.05, {
			onComplete: function(twn:FlxTween)
			{
				canChoose = true;
			}
		});
	}
	
	var canChoose:Bool = false;
	var clicked:Int = 3;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(controls.BACK)
			close();
		
		if(!canChoose) return;
		
		if(controls.ACCEPT)
		{
			if(curSelected == 0)
			{
				warningText.text = warningText.text.replace('' + clicked, '' + (clicked - 1));
				clicked--;
				if(clicked <= 0)
				{
					trace('deleted lol');
					// only resets save data info and not your settings
					for (setting in SaveData.gameSettings.keys())
						if(SaveData.gameSettings.get(setting)[1] == SaveData.SettingTypes.SaveData)
							SaveData.trueSettings.set(setting, SaveData.gameSettings.get(setting)[0]);
					// bye highscores
					Highscore.highscoreMap = [];
					Highscore.save();
					
					FlxG.sound.music.stop();
					GlobalMenuState.spawnMenu = 'title';
					Main.switchState(new GlobalMenuState());
				}
			}
			else
				close();
			
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		if(controls.UI_DOWN_P || controls.UI_UP_P)
			changeSelection();
	}
	
	static var curSelected:Int = 1;
	
	public function changeSelection(change:Bool = true)
	{
		if(change)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected++;
			curSelected = FlxMath.wrap(curSelected, 0, 1);
		}
		
		for(item in grpItems.members)
		{
			item.color = FlxColor.fromRGB(171,169,255);
			if (item.ID == curSelected)
				item.color = FlxColor.fromRGB(173,253,255);
		}
	}
}