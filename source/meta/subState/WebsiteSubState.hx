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

class WebsiteSubState extends MusicBeatSubState
{
	// "https://on.soundcloud.com/ha9oz" // lunar odyssey's soundcloud link
	
	public var link:String = '';
	
	public var grpItems:FlxTypedGroup<FlxSprite>;
	
	public function new(link:String = 'https://www.youtube.com')
	{
		super();
		this.link = link;
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(0,0,85));
		bg.scrollFactor.set();
		bg.alpha = 0;
		add(bg);
		
		var daText:String = "WARNING!";
		daText += '\nthis is going to open \n${link}\nin your browser, are you sure?';
		
		var warningText = new FlxText(0, 64, 1180, daText);
		warningText.setFormat(Main.gFont, 26, FlxColor.fromRGB(173,253,255), CENTER);
		warningText.screenCenter(X);
		add(warningText);
		
		grpItems = new FlxTypedGroup<FlxSprite>();
		add(grpItems);
		
		var options:Array<String> = ["sure", "not really"];
		for(i in 0...options.length)
		{
			var newItem = new FlxText(0,0,0,options[i]);
			newItem.setFormat(Main.gFont, 32, FlxColor.WHITE, CENTER);
			grpItems.add(newItem);
			
			newItem.x = (FlxG.width / 2) - (newItem.width / 2);
			newItem.x += (FlxG.width / 8) * ((i == 0) ? -1 : 1);
			newItem.y = FlxG.height - newItem.height - 140;
			
			newItem.ID = i;
		}
		
		changeSelection(false);
		
		FlxTween.tween(bg, {alpha: 0.75}, 0.05, {
			//type: BACKWARD,
			onComplete: function(twn:FlxTween)
			{
				canChoose = true;
			}
		});
	}
	
	var canChoose:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(controls.BACK)
			close();
		
		if(!canChoose) return;
		
		if(controls.ACCEPT)
		{
			if(curSelected == 0)
				FlxG.openURL(link);
			else
				FlxG.sound.play(Paths.sound('scrollMenu'));
			
			close();
		}
		
		if(controls.UI_LEFT_P || controls.UI_RIGHT_P)
			changeSelection();
	}
	
	static var curSelected:Int = 0;
	
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