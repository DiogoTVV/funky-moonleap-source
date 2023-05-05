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

class MidnightState extends MusicBeatState
{
	public var texts:FlxTypedGroup<FlxText>;
	public var clock:RealClock;
	
	var curLine:Int = -1;
	var dialogue:Array<String> = [
		"There is still something left",
		"for you to play",
		"ill tell you at midnight",
	];
	
	override function create()
	{
		super.create();
		var bg = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(0,0,85));
		bg.screenCenter();
		add(bg);
		
		texts = new FlxTypedGroup<FlxText>();
		add(texts);
		
		clock = new RealClock();
		clock.screenCenter();
		clock.alpha = 0;
		add(clock);
		
		readLine();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(FlxG.keys.justPressed.ANY)
		{
			if(curLine >= dialogue.length - 1)
			{
				//Sys.exit(0);
				GlobalMenuState.spawnMenu = 'title';
				Main.switchState(new GlobalMenuState());
			}
			else
				for(i in curLine...dialogue.length)
					readLine();
		}
	}
	
	public function readLine()
	{
		curLine++;
		var text = new FlxText(0, 150, 0, dialogue[curLine]);
		text.setFormat(Main.gFont, 36, FlxColor.fromRGB(181,165,240), CENTER);
		texts.add(text);
		
		text.screenCenter(X);
		if(texts.length > 1)
			text.y = texts.members[texts.length - 2].y + 100;
		
		text.y -= 10;
		FlxTween.tween(text, {y: text.y + 10}, 0.8, {
			ease: FlxEase.cubeOut,
			onComplete: function(twn:FlxTween)
			{
				new FlxTimer().start(0.3, function(timer:FlxTimer)
				{
					if(curLine < dialogue.length - 1)
						readLine();
				},1);
			}
		});
		
		switch(curLine)
		{
			case 2:
				clock.y = text.y + text.height + 30 - 10;
				FlxTween.tween(clock, {y: clock.y + 10, alpha: 1}, 0.8, {
					ease: FlxEase.cubeOut,
					startDelay: 0.8 + 0.3
				});
		}
	}
}