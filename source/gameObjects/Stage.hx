package gameObjects;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.background.*;
import meta.data.Conductor;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	public var spike:FlxSprite;
	
	public var bixinhoA:Bixinho;
	public var bixinhoB:Bixinho;
	public var spikeSunA:FlxSprite;
	public var spikeSunB:FlxSprite;
	public var sunHopBG:FlxSprite;
	
	public var devlogCursor:DevlogCursor;
	public var devlogBox:FlxSprite;
	
	public var curStage:String;
	public var foreground:FlxTypedGroup<FlxBasic>;
	private var backGroup:FlxTypedGroup<FlxBasic>;
	
	public function new()
	{
		super();
		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();
	}
	
	// dont get fooled by this, it doesnt actually creates a bunch of stages
	// it just preloads them, so you can change them without lag
	public function loadStageBySong(songName:String):Void
	{
		var stageList:Array<String> = ['default'];
		
		switch(songName)
		{
			case 'leap': 				stageList = ["leap-night", "leap-day"];
			case 'crescent':			stageList = ["crescent-night", "crescent-day"];
			case 'lunar-odyssey':		stageList = ["odyssey-night", "odyssey-day"];
			case 'midnight-secrets': 	stageList = ["midnight-night", "midnight-day"];
			case 'leap-(d-side-mix)': 	stageList = ["leap-(d-side-mix)"];
			case 'sun-hop': 			stageList = ["sun-hop"];
			case 'devlog': 				stageList = ["devlog"];
			default: stageList = [songName];
		}
		
		for(i in stageList)
			reloadStage(i);
	}
	
	// makes it easier to reload stages
	public function reloadStage(newStage:String = 'stage'):Void
	{
		while (members.length > 0) remove(members[0], true);
		while (foreground.members.length > 0) foreground.remove(foreground.members[0], true);
		
		curStage = newStage;
		switch (curStage)
		{
			case 'devlog':
				PlayState.defaultCamZoom = 0.8;
				var fakeWall = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(15,15,15));
				fakeWall.scale.x /= 0.25; fakeWall.scale.y /= 0.25;
				fakeWall.updateHitbox();
				fakeWall.screenCenter();
				fakeWall.scrollFactor.set();
				add(fakeWall);
				
				var bg = new FlxSprite().loadGraphic(Paths.image('backgrounds/devlog/back'));
				bg.scrollFactor.set(0.9,0.9);
				bg.screenCenter();
				bg.x -= 150;
				add(bg);
				
				var ytPref:String = 'default';
				if(SaveData.trueSettings.get('Middlescroll'))
					ytPref = 'middle';
				
				var youtubeHUD = new FlxSprite(-1400, -1170).loadGraphic(Paths.image('backgrounds/devlog/front-' + ytPref));
				foreground.add(youtubeHUD);
				
				var devDat:Int = -132;
				if(ytPref == 'middle')
					devDat = 1130;
				
				devlogBox = new FlxSprite(devDat, -1100).makeGraphic(1166, 850, FlxColor.WHITE);
				devlogBox.alpha = 0;
				foreground.add(devlogBox);
				
				devlogCursor = new DevlogCursor();
				foreground.add(devlogCursor);
				
				//FlxG.mouse.visible = true; // yuh huh
				
			case 'leap-day' | 'leap-night':
				var location:String = 'backgrounds/leap/';
				PlayState.defaultCamZoom = 0.55;
				
				var dPrefix:String = (curStage.endsWith('day') ? 'Day' : 'Night');
				//trace('time is $dPrefix');
				
				var daBack:FlxSprite = new FlxSprite(-880, -700).loadGraphic(Paths.image(location + 'back' + dPrefix));
				daBack.scrollFactor.set(0.7,0.7);
				add(daBack);
				
				var daFront:FlxSprite = new FlxSprite(-800, -800).loadGraphic(Paths.image(location + 'frontLeap' + dPrefix));
				add(daFront);
				
			case 'crescent-day' | 'crescent-night':
				var location:String = 'backgrounds/crescent/';
				PlayState.defaultCamZoom = 0.55; // 0.68
				
				var dPrefix:String = (curStage.endsWith('day') ? 'day' : 'night');
				//trace('time is $dPrefix');
				
				var daBack:FlxSprite = new FlxSprite(-770,-240).loadGraphic(Paths.image(location + 'sky-' + dPrefix));
				daBack.scale.set(2,2.4); daBack.updateHitbox();
				daBack.scrollFactor.set(0.7,0.7);
				add(daBack);
				
				var daFront:FlxSprite = new FlxSprite(-1400, -240).loadGraphic(Paths.image(location + 'chao'));
				daFront.scale.set(2.5,2.5); daFront.updateHitbox();
				add(daFront);
				
				var nuvem:FlxSprite = new FlxSprite(-1200, -240).loadGraphic(Paths.image(location + 'nuvens-' + dPrefix));
				nuvem.scale.set(2,2); nuvem.updateHitbox();
				nuvem.scrollFactor.set(0.95,0.95);
				add(nuvem);
				
				if(dPrefix == 'night')
					daFront.color = nuvem.color = 0xFF534078;
				
			case 'odyssey-day' | 'odyssey-night':
				var location:String = 'backgrounds/odyssey/';
				PlayState.defaultCamZoom = 0.7;
				
				var dPrefix:String = (curStage.endsWith('day') ? 'day' : 'night');
				
				var sky = new FlxSprite(-720,-250).loadGraphic(Paths.image(location + 'sky-' + dPrefix));
				sky.scrollFactor.set(0.7,0.7);
				sky.scale.set(2,2);
				sky.updateHitbox();
				add(sky);
				
				var ground = new FlxSprite(-800, -200).loadGraphic(Paths.image(location + 'chao-do-mundo-das-fro'));
				ground.scale.set(2,2);
				ground.updateHitbox();
				add(ground);
				
				var front = new FlxSprite(-600, 180).loadGraphic(Paths.image(location + 'as-mizera-da-folha-da-frente'));
				front.scrollFactor.set(0.05,0.05);
				front.scale.x /= PlayState.defaultCamZoom - 0.05;
				front.scale.y /= PlayState.defaultCamZoom - 0.05;
				front.updateHitbox();
				front.screenCenter();
				add(front);
				
				if(dPrefix == 'night')
					ground.color = front.color = 0xFF534078;
				
			case 'midnight-day' | 'midnight-night':
				PlayState.defaultCamZoom = 1.05; // 1.2
				PlayState.assetModifier = 'pixel';
				
				var bg = new FlxSprite().loadGraphic(Paths.image('backgrounds/midnight/' + (curStage.endsWith('day') ? 'fundo-day' : 'fundo-night')));
				bg.scale.set(8,8);
				bg.updateHitbox();
				add(bg);
			
			case 'sun-hop':
				var location:String = 'backgrounds/sun-hop/';
				PlayState.defaultCamZoom = 0.425;
				
				var graphBG = Paths.image(location + 'trees');
				sunHopBG = new FlxSprite(-1250, -400);
				sunHopBG.loadGraphic(graphBG, true, Math.floor(graphBG.width / 2), Math.floor(graphBG.height));
				sunHopBG.scrollFactor.set(0.7, 0.7);
				sunHopBG.animation.add('uhh', [0,1], 0, false);
				sunHopBG.animation.play('uhh');
				add(sunHopBG);
				
				var cuteSpider = new FlxSprite(800,-500);
				cuteSpider.loadGraphic(Paths.image(location + 'cute-spider'));
				cuteSpider.scrollFactor.set(0.7,0.7);
				add(cuteSpider);
				cuteSpider.angle = -30;
				FlxTween.tween(cuteSpider, {angle: 30}, Conductor.crochet / 1000 * 2, {ease: FlxEase.sineInOut, type: PINGPONG,
					onUpdate: function(twn:FlxTween)
					{
						cuteSpider.color = (sunHopBG.animation.curAnim.curFrame == 0) ? FlxColor.fromRGB(1,78,163) : FlxColor.fromRGB(20,8,44);
						// get stretched
						cuteSpider.scale.x = 1.3 - Math.abs(cuteSpider.angle / 100);
					}
				});
				
				var daFront:FlxSprite = new FlxSprite(-1150,620);
				daFront.loadGraphic(Paths.image(location + 'front'));
				add(daFront);
				
				// spike
				spikeSunA = new FlxSprite(1340, 860).loadGraphic(Paths.image(location + 'spikes-back'));
				spikeSunA.scale.set(1.3,1.3);
				spikeSunA.updateHitbox();
				add(spikeSunA);
				
				// bixinhos e espinhos
				for(i in 0...2)
				{	// making it easier to read
					var isLeft:Bool = (i == 0);
					var bixoX:Float = isLeft ? -370 : 1290;
					var bixoMove:Int = isLeft ? -1 : 1;
					var bixoSkin:String = isLeft ? 'green' : 'orange';
					
					var newBixo = new Bixinho(bixoX, 810, bixoMove, isLeft, bixoSkin);
					add(newBixo);
					
					if(isLeft)  bixinhoA = newBixo;
					else		bixinhoB = newBixo;
				}
				
				// spike
				spikeSunB = new FlxSprite(1340, 860 + 170).loadGraphic(Paths.image(location + 'spikes-front'));
				spikeSunB.scale.set(1.3,1.3);
				spikeSunB.updateHitbox();
				add(spikeSunB);
				
			case 'leap-(d-side-mix)':
				var fLocal:String = 'backgrounds/leap-d-side/';
				PlayState.defaultCamZoom = 0.5;
				
				var bg = new FlxSprite(-1200,-700).loadGraphic(Paths.image(fLocal + 'space'));
				bg.scrollFactor.set(0.25,0.25);
				add(bg);
				
				backGroup = new FlxTypedGroup<FlxBasic>();
				add(backGroup);
				
				spike = new FlxSprite(-905, 380).loadGraphic(Paths.image(fLocal + 'spikes'));
				spike.flipX = true;
				add(spike);
				
				var lua = new FlxSprite(-1650,480).loadGraphic(Paths.image(fLocal + 'floor-space'));
				add(lua);
				
			default:
				PlayState.defaultCamZoom = 0.7;
				
				var bg = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.GRAY);
				bg.scrollFactor.set();
				bg.screenCenter();
				add(bg);
				
			case 'stage':
				PlayState.defaultCamZoom = 0.9;
				var bg:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('backgrounds/' + curStage + '/stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				
				// add to the final array
				add(bg);
				
				var stageFront:FNFSprite = new FNFSprite(-650, 600).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				
				// add to the final array
				add(stageFront);
				
				var stageCurtains:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
				
				// add to the final array
				add(stageCurtains);
		}
	}
	
	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		var gfVersion:String = 'pump-bg';
		
		switch(curStage)
		{
			/*case 'leap-day' | 'leap-night' | 'crescent-day' | 'crescent-night' | 'odyssey-day' | 'odyssey-night':
				gfVersion = 'pump-bg';*/
			
			case 'leap-(d-side-mix)':
				gfVersion = 'pump-d-side';
			
			case 'sun-hop':
				gfVersion = 'guselect-gf';
		}
		
		return gfVersion;
	}
	
	// get the dad's position
	public function dadPosition(boyfriend:Character, dad:Character, gf:Character):Void
	{
		for(char in [dad, boyfriend])
		{
			if(char.curCharacter == gf.curCharacter)
			{
				char.setPosition(gf.x, gf.y);
				char.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);
				gf.visible = false;
			}
		}
	}
	
	public function repositionPlayers(boyfriend:Character, dad:Character, gf:Character):Void
	{
		var dumdum:Character = new Character();
		dumdum.setCharacter(0, 0, PlayState.SONG.player1);
		
		if(boyfriend == null) boyfriend = dumdum;
		if(dad == null) dad = dumdum;
		if(gf == null) gf = dumdum;
		
		switch (curStage)
		{
			case 'leap-day' | 'leap-night':
				dad.y -= 50;
				boyfriend.y -= 60;
				
				dad.x += 320;
				boyfriend.x += 375;
				
				gf.visible = false;
				boyfriend.charData.camOffsets[0] = 150;
				
			case 'midnight-day' | 'midnight-night':
				gf.visible = false;
				
				var pY:Float = (72 * 8);
				var pX:Float = (85 * 8);
				
				dad.y = pY - dad.height;
				boyfriend.y = pY - boyfriend.height;
				dad.x = pX - (16 * 8);
				boyfriend.x = pX + (16 * 8);
			
			case 'odyssey-day' | 'odyssey-night':
				gf.visible = false;
				
				dad.x -= 80;
				boyfriend.x += 80;
				
				boyfriend.charData.camOffsets[0] += 180;
			
			case 'crescent-day' | 'crescent-night':
				gf.visible = false;
				
				// uhhh
				boyfriend.charData.camOffsets[0] += 240;
				for(anim in boyfriend.animation.getNameList())
					boyfriend.animOffsets[anim][0] -= 180;
			
			case 'devlog':
				gf.visible = false;
				
			case 'leap-(d-side-mix)':
				gf.x += 110;
				gf.y += 60;
				boyfriend.x += 90;
			
			case 'sun-hop':
				dad.x += 10;
				boyfriend.x += 60;
				gf.x += 45;
				
				//dad.y -= 40;
				boyfriend.y -= 20;
		}
		
		dumdum.destroy();
	}
	
	// update stuff
	var dogSin:Float = 0;
	
	public function stageUpdate(curBeat:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		// trace('update backgrounds');
		switch(curStage)
		{
			case 'leap-(d-side-mix)':
				if(FlxG.random.bool(10))
				{
					if(FlxG.random.bool(10) && dogSin <= 0)
					{
						var doguineo = new FlxSprite(-1650, spike.y - 200).loadGraphic(Paths.image('backgrounds/leap-d-side/catioro'));
						backGroup.add(doguineo);
						
						FlxTween.tween(doguineo, {x: 2200}, Conductor.crochet / 1000 * 24, {
							onUpdate: function(twn:FlxTween)
							{
								dogSin += FlxG.elapsed * 10;
								doguineo.offset.y = Math.sin(dogSin) * 20;
							},
							onComplete: function(twn:FlxTween) {doguineo.destroy(); dogSin = -1;}
						});
					}
					else
					{
						var theRock = new FlxSprite(FlxG.random.int(-1650, 2200));
						theRock.frames = Paths.getSparrowAtlas('backgrounds/leap-d-side/astolfo');
						theRock.animation.addByPrefix('astolfo', 'Astolfo', 0, false);
						theRock.animation.play('astolfo');
						theRock.animation.curAnim.curFrame = FlxG.random.int(0,4);
						backGroup.add(theRock);
						
						var isUpwards:Bool = FlxG.random.bool(50);
						theRock.y = isUpwards ? FlxG.height : - FlxG.height;
						FlxTween.tween(theRock, {x: FlxG.random.int(-1650, 2200), y: isUpwards ? -FlxG.height : FlxG.height}, Conductor.crochet / 1000 * 24, {
							onUpdate: function(twn:FlxTween)
							{
								theRock.angle += FlxG.elapsed * 42;
							},
							onComplete: function(twn:FlxTween) {theRock.destroy();}
						});
					}
				}
		}
	}
	
	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch(curStage)
		{
			case 'devlog':
				if(devlogCursor.collBox.overlaps(devlogBox) && devlogCursor.justPressed && PlayState.canPause)
				{
					PlayState.autoplay = PlayState.practice = PlayState.canPause = false;
					PlayState.resetMusic();
					FlxG.sound.play(Paths.sound('confirmDevlog'));
					
					for(camera in PlayState.strumHUD)
						FlxTween.tween(camera, {alpha: 0}, Conductor.crochet / 1000);
					
					new FlxTimer().start(Conductor.crochet / 1000 * 4, function(timer:FlxTimer)
					{
						SaveData.unlockSong('leap-(d-side-mix)');
						Init.playSong('leap-(d-side-mix)');
					});
				}
				
				// it should be loopin' inside the hud
				if(SaveData.trueSettings.get("Controller Mode"))
				{
					devlogCursor.x = FlxMath.wrap(Math.floor(devlogCursor.x), -1400, 2365);
					devlogCursor.y = FlxMath.wrap(Math.floor(devlogCursor.y), -1170, 2095);
			
				}
		}
	}
}
