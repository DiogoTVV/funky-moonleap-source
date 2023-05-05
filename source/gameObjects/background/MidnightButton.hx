package gameObjects.background;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import meta.state.PlayState;
import meta.data.Conductor;

using StringTools;

class MidnightButton extends FlxSprite
{
	public function new()
	{
		super();
		var isGamepad:Bool = (SaveData.trueSettings.get('Controller Mode') && FlxG.gamepads.firstActive != null);
		
		loadGraphic(Paths.image('UI/press' + (isGamepad ? 'Gamepad' : 'Space')), true, 48, (isGamepad ? 30 : 24));
		animation.add('press', [0,1,2,3,4,4,4,4,4,4], 12, true);
		animation.play('press');
		scale.set(8,8);
		updateHitbox();
		
		screenCenter(X);
		y = FlxG.height - height - 160;
		
		alpha = 0;
		setColorSpace();
		FlxTween.tween(this, {alpha: 1},	Conductor.crochet / 1000 * 4, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(this, {alpha: 1}, Conductor.crochet / 1000 * 13, {
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(this, {alpha: 0}, Conductor.crochet / 1000 * 1, {
							ease: FlxEase.cubeIn,
							onComplete: function(twn:FlxTween)
							{
								destroy();
							}
						});
					}
				});
			}
		});
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		setColorSpace();
	}
	
	function setColorSpace()
	{
		color = PlayState.boyfriend.curCharacter.endsWith('-night')
			? FlxColor.fromRGB(255,170,85)
			: FlxColor.fromRGB(170,170,255);
	}
}