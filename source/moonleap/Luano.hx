package moonleap;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import moonleap.data.*;

class Luano extends FlxSpriteGroup
{
	public var isDay:Bool = false;

	public var luano:FlxSprite;  // used for anims
	public var collBox:FlxSprite;// self explanatory

	public function new()
	{
		super();
		luano = new FlxSprite();
		luano.loadGraphic(Paths.image('moonleap/luano'), true, 16, 18);

		for(i in 0...2)
		{
			var s:Int = (i == 1) ? Math.floor(luano.graphic.width / 16) : 0;
			var dPrefix:String = (i == 1) ? 'night' : 'day';

			function nb(min:Int, max:Int)
				return CoolUtil.numberArray(max + s + 1, min + s);

			luano.animation.add('idle-$dPrefix', nb(0, 3),  6, true);
			luano.animation.add('walk-$dPrefix', nb(4, 11), 12,true);
			luano.animation.add('jump-$dPrefix', nb(12,14), 12, false);
			luano.animation.add('death-$dPrefix',nb(15,16), 8, false);
		}
		playAnim('idle');

		luano.scale.set(4,4);
		luano.updateHitbox();
		add(luano);

		collBox = new FlxSprite().makeGraphic(12 * 4, 17 * 4, FlxColor.PURPLE);
		collBox.setPosition(luano.x + (luano.width / 2) - (collBox.width / 2), luano.y + luano.height - collBox.height);
		collBox.visible = false;
		//collBox.alpha = 0.7;
		add(collBox);
	}

	// movement variables
	public var move:Int = 0;
	public var hspeed:Float = 0;
	public var vspeed:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(move != 0) luano.flipX = (move < 0);
	}

	// instead of handling offsets (like fnf does) it handles day/night skins
	public function playAnim(animName:String = 'idle', forced:Bool = false)
	{
		var formatAnim:String = animName + (isDay ? '-day' : '-night');

		if(luano.animation.getByName(formatAnim) != null)
			luano.animation.play(formatAnim, forced, false, 0);
	}

	override function destroy()
	{
		// dump cache stuffs
		if (graphic != null)
			graphic.dump();

		super.destroy();
	}
} 