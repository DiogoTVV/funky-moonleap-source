package meta.data.dependency;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.Transition;
import flixel.addons.transition.TransitionData;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import meta.MusicBeat.MusicBeatSubState;

/**
 *
 * Transition overrides
 * @author Shadow_Mario_
 *
**/
class FNFTransition extends MusicBeatSubState
{
	public static var finishCallback:Void->Void;

	private var leTween:FlxTween = null;

	public static var nextCamera:FlxCamera;
	var rhombus:FlxSprite;
	var isTransIn:Bool = false;

	public function new(duration:Float, isTransIn:Bool)
	{
		super();

		this.isTransIn = isTransIn;
		var width:Int = Std.int(FlxG.width);
		var height:Int = Std.int(FlxG.height);
		
		rhombus = new FlxSprite();
		rhombus.frames = Paths.getSparrowAtlas('UI/default/transition');
		//rhombus.animation.addByPrefix('fadeIn', 'fade', Std.int(20 / duration), false);
		//rhombus.animation.addByPrefix('fadeOut', 'fade', Std.int(20 / duration), false);
		rhombus.animation.addByIndices('fadeIn', 'fade', [29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0], "", Std.int(20 / duration), false);
		rhombus.animation.addByIndices('fadeOut','fade', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", Std.int(20 / duration), false);
		//rhombus.animation.play('fade' + (), false, isTransIn);
		rhombus.animation.play('fade' + (isTransIn ? 'In' : 'Out'));
		rhombus.color = flixel.util.FlxColor.fromRGB(0,0,85);
		rhombus.scrollFactor.set();
		add(rhombus);

		/*
		// too lazy to do an actual timer
		if (isTransIn)
		{
			FlxTween.tween(rhombus, {alpha: 1}, duration * 1.4, {
				onComplete: function(twn:FlxTween)
				{
					close();
				},
				ease: FlxEase.linear
			});
		}
		else
		{
			leTween = FlxTween.tween(rhombus, {alpha: 1}, duration * 1.4, {
				onComplete: function(twn:FlxTween)
				{
					if (finishCallback != null)
					{
						finishCallback();
					}
				},
				ease: FlxEase.linear
			});
		}
		*/
		
		//trace('trans in is ${isTransIn}');
	}

	var camStarted:Bool = false;
	var stopNow:Bool = false;
	override function update(elapsed:Float)
	{
		var camList = FlxG.cameras.list;
		camera = camList[camList.length - 1];
		rhombus.cameras = [camera];

		super.update(elapsed);
		
		if(rhombus.animation.curAnim.finished && !stopNow)
		{
			stopNow = true;
		
			if(isTransIn)
				close();
			else if (finishCallback != null)
				finishCallback();
		}
	}

	override function destroy()
	{
		/*if (rhombus != null)
		{
			finishCallback();
			remove(rhombus);
		}*/
		super.destroy();
	}
}