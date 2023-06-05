package meta.subState;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Character;
import gameObjects.Boyfriend;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Conductor;
import meta.state.*;
import meta.state.menus.*;

class GameOverSubstate extends MusicBeatSubState
{
	//
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var camHUD:FlxCamera;
	
	public static var stageSuffix:String = "";
	
	public function new(x:Float, y:Float)
	{
		var daBoyfriendType = PlayState.boyfriend.curCharacter;
		var daBf:String = '';
		switch (daBoyfriendType)
		{
			default:
				if(PlayState.boyfriend.animation.getByName('firstDeath') != null)
					daBf = daBoyfriendType;
				else
					daBf = 'skid-dead';
		}
		
		super();
		
		#if mobile
    addVirtualPad(NONE, A_B);
    addVirtualPadCamera();
    #end
		
		Conductor.songPosition = 0;
		
		var bg = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.fromRGB(34,12,43));
		bg.screenCenter();
		add(bg);
		
		bf = new Boyfriend();
		bf.setCharacter(x, y + PlayState.boyfriend.height, daBf);
		bf.angle = PlayState.boyfriend.angle;
		add(bf);
		
		switch(daBf)
		{
			case 'skid-dead':
				bf.x -= 7;
				bf.y += 26;
			
			case 'pump' | 'pump-alt':
				bf.x -= 25;
				bf.y += 160;
				
			case 'luano-devlog':
				var dad = new Character();
				dad.setCharacter(0, 0, PlayState.dadOpponent.curCharacter);
				dad.setPosition(PlayState.dadOpponent.getScreenPosition().x, PlayState.dadOpponent.getScreenPosition().y);
				dad.playAnim('firstDeath');
				remove(bf);
				add(dad);
				add(bf);
				
				var barraFoda = new FlxSprite(dad.x).makeGraphic(Math.floor(dad.width + bf.width), 300, FlxColor.fromRGB(34,12,43));
				add(barraFoda);
				barraFoda.y = dad.y + dad.height - 200;
		}
		
		/*var ghosts = new Boyfriend();
		ghosts.setCharacter(x, y + PlayState.boyfriend.height, daBoyfriendType);
		ghosts.setPosition(x, y);
		ghosts.alpha = 0.4;
		add(ghosts);*/
		
		//PlayState.boyfriend.destroy();
		FlxTween.tween(FlxG.camera, {zoom: 0.9}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut});
		
		camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20, bf.getGraphicMidpoint().y - 40, 1, 1);
		add(camFollow);
		
		Conductor.changeBPM(130);
		
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		
		bf.playAnim('firstDeath');
		
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK)
		{
			camHUD.fade(FlxColor.fromRGB(0,0,85), 0.2, false, function()
			{
				FlxG.sound.music.stop();
				PlayState.deaths = 0;
				
				/*if (PlayState.isStoryMode)
					Main.switchState(new StoryMenuState());
				else
					Main.switchState(new FreeplayState());*/
				GlobalMenuState.spawnMenu = 'freeplay';
				Main.switchState(new GlobalMenuState());
			});
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver'));
			var creditDisc = new gameObjects.userInterface.CreditDisc('moonlight');
			creditDisc.cameras = [camHUD];
			add(creditDisc);
		}
		
		// if (FlxG.sound.music.playing)
		//	Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd'));
			new FlxTimer().start(2.2, function(tmr:FlxTimer)
			{
				camHUD.fade(FlxColor.fromRGB(0,0,85), 1.25, false, function()
				{
					Main.switchState(new PlayState());
				});
			});
			//
		}
	}
}
