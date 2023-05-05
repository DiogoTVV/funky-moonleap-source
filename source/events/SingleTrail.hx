package events;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class SingleTrail extends FlxSprite
{
	var target:FlxSprite;
	
	public function new(target:FlxSprite, startAlpha:Float = 1, fadeTime:Float = 1)
	{
		super(target.x, target.y);
		this.target = target;
		
		loadGraphicFromSprite(target);
		scale.set(target.scale.x, target.scale.y);
		updateHitbox();
		offset.set(target.offset.x, target.offset.y);
		antialiasing = target.antialiasing;
		flipX = target.flipX;
		angle = target.angle;
		color = target.color;
		
		alpha = startAlpha;
		
		FlxTween.tween(this, {alpha: 0}, fadeTime, {
			onComplete: function(twn:FlxTween)
			{
				destroy();
			}
		});
	}
}