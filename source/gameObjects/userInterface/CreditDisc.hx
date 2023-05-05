package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.data.Conductor;
import meta.state.PlayState;

using StringTools;

class CreditDisc extends FlxSpriteGroup
{
	private var location:String = 'UI/default/base/songCredits/';
	
	var disc:FlxSprite;
	var bg:FlxSprite;
	var text:FlxText;
	
	public function new(song:String = 'leap')
	{
		super();
		var composer:String = 'beastlychip';
		switch(song)
		{
			case 'crescent' | 'devlog':
				composer = 'anakimplay';
			case 'moonlight':
				composer = 'julianobeta';
		}
		
		disc = new FlxSprite().loadGraphic(Paths.image(location + 'disc'));
		disc.x = -(disc.width / 3);
		disc.y = FlxG.height - (disc.height / 1.5);
		
		text = new FlxText(disc.x + disc.width + 10, 0, 0, '', 24);
		text.scrollFactor.set();
		text.setFormat(Main.gFont, 28, FlxColor.fromRGB(0,170,255), LEFT);
		text.text =  CoolUtil.dashToSpace(song);
		text.text += '\nby: $composer';
		text.y = FlxG.height - text.height - 5;
		
		bg = new FlxSprite().loadGraphic(Paths.image(location + 'bar'));
		bg.x = text.x + text.width + 95/*80*/ - bg.width;
		bg.y = text.y - 5;
		
		add(bg);
		add(text);
		add(disc);
		
		x = -text.width - 300;
		FlxTween.tween(this, {x: 0}, Conductor.crochet / 1000 * 4, {
			ease: FlxEase.cubeInOut,
			startDelay: Conductor.crochet / 1000 * 5,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(this, {x: -text.width - 300}, Conductor.crochet / 1000 * 8, {
					ease: FlxEase.backIn,
					startDelay: Conductor.crochet / 1000 * 16,
					onComplete: function(twn:FlxTween)
					{
						destroy();
					}
				});
			}
		});
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		disc.angle += Conductor.crochet * elapsed;
	}
}
