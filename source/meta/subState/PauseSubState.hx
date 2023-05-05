package meta.subState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.font.Alphabet;
import meta.state.*;
import meta.state.menus.*;

class PauseSubState extends MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = [
		'resume',
		'restart',
		//'options', // i give up
		'autoplay',
		'practice',
		'exit to menu'
	];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	
	var levelInfo:FlxText;

	public function new(x:Float, y:Float)
	{
		super();
		#if debug
		// trace('pause call');
		#end

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		#if debug
		// trace('pause background');
		#end

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(0,0,85));
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Main.gFont, 32, FlxColor.fromRGB(173,253,255), CENTER);
		levelInfo.updateHitbox();
		levelInfo.alpha = 0;
		add(levelInfo);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.3});
		
		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var menuText:FlxText = new FlxText(0, 0, 0, menuItems[i], 36);
			menuText.scrollFactor.set();
			menuText.setFormat(Main.gFont, 36, FlxColor.WHITE, CENTER);
			menuText.ID = i;
			grpMenuShit.add(menuText);
			
			// spawns everyone in the middle
			menuText.x = (FlxG.width / 2) - (menuText.width / 2);
			menuText.y = (FlxG.height / 2) - (menuText.height / 2);
			// sorting
			var spaceY:Float = menuText.size + 12;
			menuText.y -= spaceY * (menuItems.length / 3);
			menuText.y += spaceY * i;
			// OoOooOoO ghost
			menuText.alpha = 0;
			FlxTween.tween(menuText, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
		}

		#if debug
		// trace('change selection');
		#end

		changeSelection(false);

		#if debug
		// trace('cameras');
		#end

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if debug
		// trace('cameras done');
		#end
	}

	override function update(elapsed:Float)
	{
		#if debug
		// trace('call event');
		#end

		super.update(elapsed);

		#if debug
		// trace('updated event');
		#end

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);
		
		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "resume":
					close();
					
				case "restart":
					Main.switchState(new PlayState());
					
				case "options":
					close();
					
				case "autoplay":
					PlayState.autoplay = !PlayState.autoplay;
				case "practice":
					PlayState.practice = !PlayState.practice;
					
				case "exit to menu":
					PlayState.resetMusic();
					PlayState.deaths = 0;
					
					GlobalMenuState.spawnMenu = 'freeplay';
					Main.switchState(new GlobalMenuState());
			}
		}
		
		levelInfo.text = "";
		levelInfo.text += CoolUtil.dashToSpace(PlayState.SONG.song.toLowerCase());
		levelInfo.text += " - " + PlayState.pauseSongLength;
		if(PlayState.autoplay)
			levelInfo.text += "\nautoplay";
		if(PlayState.practice)
			levelInfo.text += "\npractice mode";
			
		levelInfo.x = (FlxG.width / 2) - (levelInfo.width / 2);

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}

		#if debug
		// trace('music volume increased');
		#end

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.02 * elapsed;
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(?change:Int = 0, ?playSound:Bool = true):Void
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 1);
	
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		#if debug
		// trace('mid selection');
		#end

		for (item in grpMenuShit.members)
		{
			item.color = FlxColor.fromRGB(171,169,255);

			if (item.ID == curSelected)
			{
				item.color = FlxColor.fromRGB(173,253,255);
			}
		}

		#if debug
		// trace('finished selection');
		#end
		//
	}
}
