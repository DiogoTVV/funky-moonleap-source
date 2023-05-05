package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import meta.data.Conductor;
import meta.data.font.Alphabet;
import meta.MusicBeat.MusicBeatState;
import gameObjects.userInterface.notes.*;

class AdjustOffsetState extends MusicBeatState
{
	public var daSong:FlxSound;
	
	public var daOffset:Float = 0;
	
	public var luano:FlxSprite;
	
	public var strumline:Strumline;
	public var offsetTxt:FlxText;
	
	public var offsetBarBG:FlxSprite;
	public var offsetBar:FlxBar;
	
	override function create():Void
	{
		super.create();
		daOffset = SaveData.trueSettings.get('Offset');
		// setting up the conductor (also controls the notes strumtime later on)
		Conductor.songPosition = 0;
		Conductor.changeBPM(140);
		
		var bg = new FlxSprite().loadGraphic(Paths.image('backgrounds/leap/backNight'));
		bg.screenCenter();
		bg.scale.set(0.4,0.4);
		add(bg);
		
		/*luano = new FlxSprite().loadGraphic(Paths.image('moonleap/char/luano'), true, 16, 18);
		luano.animation.add('idle-day', [0,1,2,3], 8, true);
		luano.animation.add('idle-night', [12,13,14,15], 8, true);
		luano.animation.add('jump-day', [9], 8, true);
		luano.animation.add('jump-night', [21], 8, true);
		luano.animation.play('idle-day');
		luano.scale.set(4,4);
		luano.updateHitbox();
		luano.flipX = true;
		add(luano);
		
		luano.screenCenter();
		luano.x += FlxG.width / 4;*/
		
		// creating the strumline
		strumline = new Strumline(FlxG.width / 2, null, false, true, false, 4, SaveData.trueSettings.get('Downscroll'));
		add(strumline);
		
		// pushing the 4 notes into the strumline
		for(i in 0...4)
		{
			var daNote:Note = ForeverAssets.generateArrow('base', (Conductor.crochet * i), i, 'none', 0);
			strumline.push(daNote);
		}
		
		var explainTxt = new FlxText(0, 0, 0, '', 18);
		explainTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.fromRGB(170,255,255), RIGHT);
		//explainTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		add(explainTxt);
		explainTxt.text +='\nEnter to save';
		explainTxt.text += '\nLeft and Right to change offset';
		explainTxt.x = FlxG.width - explainTxt.width - 10;
		explainTxt.y = FlxG.height - explainTxt.height - 10;
		
		offsetBarBG = new FlxSprite().loadGraphic(Paths.image('UI/default/base/healthBar'));
		offsetBarBG.y = (!strumline.downscroll ? (FlxG.height - offsetBarBG.height - 15) : 15);
		add(offsetBarBG);
		offsetBarBG.color = FlxColor.BLACK;
		offsetBarBG.scale.x = 0.6;
		offsetBarBG.updateHitbox();
		offsetBarBG.x = (FlxG.width / 2) - (offsetBarBG.width / 2);
		
		// offset bar stuff
		offsetBar = new FlxBar(offsetBarBG.x + 4, offsetBarBG.y + 4, LEFT_TO_RIGHT, Std.int(offsetBarBG.width - 8), Std.int(offsetBarBG.height - 8));
		offsetBar.createFilledBar(0xFF000000, FlxColor.fromRGB(170,255,255));
		offsetBar.numDivisions = 800; // 800
		add(offsetBar);
		
		offsetTxt = new FlxText(0, 0, 0, 'oof', 32);
		offsetTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.fromRGB(170,255,255), CENTER);
		//offsetTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		add(offsetTxt);
		
		updateOffset();
		
		// load da song
		daSong = new FlxSound().loadEmbedded(Paths.music('daylight'), true, false,
			function() {
				trace('reseted notes lol');
				for(daNote in strumline.allNotes.members)
					daNote.strumTime = (Conductor.crochet * daNote.noteData);
			}
		);
		daSong.play();
		FlxG.sound.list.add(daSong);
		
		var creditDisc = new gameObjects.userInterface.CreditDisc('daylight');
		add(creditDisc);
	}
	
	var holdCount:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, elapsed * 6);
		
		if(controls.BACK)
		{
			daSong.stop();
			//Main.switchState(new OptionsMenuState());
			GlobalMenuState.spawnMenu = 'options';
			Main.switchState(new GlobalMenuState());
		}
		
		if(controls.UI_LEFT_R || controls.UI_RIGHT_R)
			holdCount = 0;
		
		var directionCheck:Int = (controls.UI_LEFT ? -1 : 1);
		if(controls.UI_LEFT_P || controls.UI_RIGHT_P)
			updateOffset(1 * directionCheck);
		
		if(controls.UI_LEFT || controls.UI_RIGHT)
		{
			holdCount += elapsed;
			
			if(holdCount >= 0.5)
				updateOffset(1 * directionCheck);
		}
		
		if(controls.ACCEPT)
		{
			trace('saved $daOffset');
			SaveData.trueSettings.set('Offset', daOffset);
			SaveData.saveSettings();
			
			//var shitass = new Alphabet(0, 0, "SAVED!!", true, false);
			//shitass.color = FlxColor.LIME;
			var shitass:FlxText = new FlxText(0, 0, 0, "SAVED!!");
			shitass.setFormat(Main.gFont, 42, FlxColor.fromRGB(236,157,0), CENTER);
			shitass.x = (FlxG.width / 2) - (shitass.width / 2);
			shitass.y = (FlxG.height / 2) - (shitass.height / 2);
			shitass.moves = true;
			add(shitass);
			
			shitass.acceleration.y = FlxG.random.int(200, 300) * 2;
			shitass.velocity.y = -FlxG.random.int(140, 160) * 2;
			shitass.velocity.x = FlxG.random.float(-30, 30);
			
			FlxTween.tween(shitass, {alpha: 0}, (Conductor.crochet / 1000) * FlxG.random.float(2,4), {
				onComplete: function(twn:FlxTween) {
					shitass.destroy();
				}
			});
		}
		
		// does the cool flipping side when the offset is negative
		offsetBar.flipX = (daOffset < 0);
		
		// song control
		if(daSong.playing)
			Conductor.songPosition = (daSong.time - 1 - daOffset);
		
		// making the notes go up (or down)
		for(daNote in strumline.allNotes.members)
		{
			var thisReceptor = strumline.receptors.members[Math.floor(daNote.noteData)];
			var receptorPosY:Float = thisReceptor.y + Note.swagWidth / 6;
			
			daNote.x = thisReceptor.x + 25;
			daNote.y = receptorPosY + ((strumline.downscroll ? -1 : 1) * -((Conductor.songPosition - daNote.strumTime) * (0.45 * 2.5)));
			
			if(daNote.strumTime <= Conductor.songPosition)
			{
				// instead of removing the note it actually just teleports it to the next section
				daNote.strumTime += Conductor.crochet * 4;
				thisReceptor.playAnim('confirm');
			}
		}
		// dumbass doesnt know how to stop by itself
		for(strum in strumline.receptors.members)
		{
			if(strum.animation.curAnim.name == 'confirm'
			&& strum.animation.curAnim.finished)
				strum.playAnim('static');
		}
	}
	
	private function updateOffset(addValue:Int = 0)
	{
		daOffset += addValue;
		daOffset = FlxMath.bound(Math.floor(daOffset), -500, 500);
		
		offsetTxt.text = '${daOffset}ms';
		offsetTxt.x = (FlxG.width / 2) - (offsetTxt.width / 2);
		offsetTxt.y = offsetBarBG.y + (strumline.downscroll ? offsetBarBG.height + 5 : -offsetTxt.height - 5);
		
		offsetBar.percent = (Math.abs(daOffset) / 5);
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		if(curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.05; // 0.1
			//trace('fourth beat hit');
		}
		
		// i was going to put this inside the note hit code but this is more organized
		var beatText:FlxText = new FlxText(0, 0, 0, "BEAT HIT");
		beatText.setFormat(Main.gFont, 36, FlxColor.WHITE, CENTER);
		beatText.moves = true;
		add(beatText);
		
		beatText.color = FlxColor.fromRGB(170,255,255);
		if(curBeat % 4 != 0)
		{
			var mult:Float = 0.4 + ((curBeat % 4) / 9); // / 10
			beatText.scale.set(mult, mult);
			beatText.updateHitbox();
			
			beatText.text = beatText.text.toLowerCase();
			beatText.color = FlxColor.fromRGB(170,170,255);
		}
		
		beatText.x = (FlxG.width / 2) - (FlxG.width / 3.5) - (beatText.width / 2);
		beatText.y = (FlxG.height / 2) - (beatText.height / 2);
		
		beatText.acceleration.y = FlxG.random.int(200, 300) * 2;
		beatText.velocity.y = -FlxG.random.int(140, 160) * 2;
		beatText.velocity.x = FlxG.random.float(-30, 30);
		
		FlxTween.tween(beatText, {alpha: 0}, (Conductor.crochet / 1000) * 2, {
			onComplete: function(twn:FlxTween) {
				beatText.destroy();
			}
		});
	}
}