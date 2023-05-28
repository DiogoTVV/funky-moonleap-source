package gameObjects;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import gameObjects.userInterface.HealthIcon;
import meta.*;
import meta.data.*;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef CharacterData =
{
	var offsets:Array<Float>;
	var camOffsets:Array<Float>;
	var quickDancer:Bool;
	var charZoom:Float;
}

class Character extends FNFSprite
{
	public var specialAnim:Bool = false;
	public var specialAnimTimer:Float = Math.NEGATIVE_INFINITY;
	
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	
	public var holdTimer:Float = 0;
	
	public var charData:CharacterData;
	public var adjustPos:Bool = true;
	
	public function new(?isPlayer:Bool = false)
	{
		super(x, y);
		this.isPlayer = isPlayer;
	}
	
	public function setCharacter(x:Float, y:Float, character:String):Character
	{
		curCharacter = character;
		//var tex:FlxAtlasFrames;
		
		// resetting it's values
		scale.set(1,1);
		updateHitbox();
		flipX = false;
		angle = 0;
		if(SaveData.trueSettings.get('Antialiasing'))
			antialiasing = true;
		
		charData = {
			offsets:	[0,0],
			camOffsets: [0,0],
			quickDancer:false,
			charZoom:	0,
		};
		
		switch (curCharacter)
		{
			case 'pump-bg':
				frames = Paths.getSparrowAtlas('characters/pump/pump');
				
				animation.addByIndices('danceLeft', 'idle', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, false);
				animation.addByIndices('danceRight','idle', [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", 24, false);
				animation.addByPrefix('hey', 'hey', 24, false);
				
				playAnim('danceLeft');
				
				charData.quickDancer = true;
				
			case 'pump-d-side':
				frames = Paths.getSparrowAtlas('characters/pump/pump-d-side');
				
				for(i in ['left', 'right', 'left-change', 'right-change'])
				{
					animation.addByIndices('danceLeft-$i', 'idle-$i', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, false);
					animation.addByIndices('danceRight-$i','idle-$i', [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", 24, false);
				}
				playAnim('danceLeft-left');
				
				//charData.quickDancer = true;
				
			case 'skid' | 'skid-d-side':
				frames = Paths.getSparrowAtlas('characters/$curCharacter');
				
				animation.addByPrefix('idle', 'idle0', 24, false);
				if(curCharacter == 'skid')
				{
					// skid exclusive anims
					animation.addByPrefix('spooky-dance', 'idle alt0', 24, true);
				}
				else
				{
					// skid d-side exclusive anims
					animation.addByPrefix('firstDeath', 		'death start', 	24, false);
					animation.addByPrefix('deathLoop',			'death loop',	24, true);
					animation.addByPrefix('deathConfirm',   	'death end',   	24, false);
					animation.addByIndices('deathConfirmPost', 	'death end', 	[34,35,36,37,38,39], "", 24, true);
				}
				animation.addByPrefix('singLEFT', 'left0', 24, false);
				animation.addByPrefix('singRIGHT','right0',24, false);
				animation.addByPrefix('singUP',   'up0',   24, false);
				animation.addByPrefix('singDOWN', 'down0', 24, false);

				animation.addByPrefix('hey', 'hey0',  24, false);
				
				var missP:String = (curCharacter == 'skid') ? 'Miss' : ' miss';
				
				animation.addByPrefix('singLEFTmiss', 'left$missP', 24, false);
				animation.addByPrefix('singRIGHTmiss','right$missP',24, false);
				animation.addByPrefix('singUPmiss',   'up$missP',   24, false);
				animation.addByPrefix('singDOWNmiss', 'down$missP', 24, false);
				
				playAnim('idle');
				
				flipX = true;
			
			case 'skid-dead':
				frames = Paths.getSparrowAtlas('characters/$curCharacter');
				
				animation.addByPrefix('firstDeath', 	'death start', 	24, false);
				animation.addByPrefix('deathLoop',		'death loop',	24, true);
				animation.addByPrefix('deathConfirm',   'death end',   	24, false);
				
				playAnim('firstDeath');
				
				flipX = true;
				
				charData.offsets = [-25, 0];
				
			case 'luano-day' | 'luano-night':
				frames = Paths.getSparrowAtlas('characters/luano');
				
				var dPrefix:String = ((curCharacter.endsWith('day')) ? '' : 'night ');
				
				animation.addByPrefix('idle',	  dPrefix + 'idle0', 24, false);
				animation.addByPrefix('singLEFT', dPrefix + 'left0', 24, false);
				animation.addByPrefix('singRIGHT',dPrefix + 'right0',24, false);
				animation.addByPrefix('singUP',   dPrefix + 'up0',   24, false);
				animation.addByPrefix('singDOWN', dPrefix + 'down0', 24, false);
				animation.addByPrefix('jump',	  dPrefix + 'jump0', 24, false);
				
				playAnim('idle');
				
			case 'estrelano-day' | 'estrelano-night':
				frames = Paths.getSparrowAtlas('characters/estrelano');
				
				var dPrefix:String = ((curCharacter.endsWith('day')) ? '0' : ' night');
				
				animation.addByPrefix('singLEFT', 'left$dPrefix', 24, false);
				animation.addByPrefix('singRIGHT','right$dPrefix',24, false);
				animation.addByPrefix('singUP',     'up$dPrefix', 24, false);
				animation.addByPrefix('singDOWN', 'down$dPrefix', 24, false);
				animation.addByPrefix('jump',	  'jump$dPrefix', 24, false);
				
				if(curCharacter.endsWith('-day'))
				{
					animation.addByPrefix('pre-jump', 'pre jump', 24, false);
					animation.addByIndices('pre-jumpPost','pre jump', [7,8,9,10,11,12,13,14,15], "", 24, false);
					
					animation.addByIndices('danceLeft', 'idle0', [0,1,2,3,4,5,6,7,8,9,10,11,12,13], "", 24, false);
					animation.addByIndices('danceRight','idle0', [14,15,16,17,18,19,20,21,22,23,24,25,26,27], "", 24, false);
				}
				else
					animation.addByPrefix('idle', 'idle night', 24, false);
				
				playAnim('idle');
				
				charData.camOffsets[1] = 100;
				
			// SUN HOP
			case 'pump' | 'pump-alt':
				// DAD ANIMATION LOADING CODE
				frames = Paths.getSparrowAtlas('characters/pump');
				
				var sufixXML:String = (curCharacter == 'pump') ? '0' : '-alt';
				
				animation.addByPrefix('idle', 			'idle' + sufixXML, 24, false);
				animation.addByPrefix('singUP', 		'up'   + sufixXML, 24, false);
				animation.addByPrefix('singRIGHT', 		'right'+ sufixXML, 24, false);
				animation.addByPrefix('singDOWN',		'down' + sufixXML, 24, false);
				animation.addByPrefix('singLEFT', 		'left' + sufixXML, 24, false);
				
				animation.addByPrefix('singUPmiss', 	'upMISS'	+ sufixXML, 24, false);
				animation.addByPrefix('singRIGHTmiss', 	'rightMISS' + sufixXML, 24, false);
				animation.addByPrefix('singDOWNmiss', 	'downMISS'  + sufixXML, 24, false);
				animation.addByPrefix('singLEFTmiss', 	'leftMISS'  + sufixXML, 24, false);
				
				animation.addByPrefix('hey', 'hey' + sufixXML, 24, false);
				animation.addByPrefix('sunglass', 'sunglasses' + sufixXML, 24, false);
				
				animation.addByPrefix('firstDeath',  "death start", 24, false);
				animation.addByPrefix('deathLoop',   "death loop", 24, true);
				animation.addByPrefix('deathConfirm',"death end", 24, false);

				playAnim('idle');
				
				flipX = true;
				
				charData.camOffsets = [0, 100];
				charData.offsets = [90 - 64, -60 + 20]; // -50
				if(curCharacter == 'pump')
				{
					//charData.offsets[0] -= 64;
					//charData.offsets[1] += 20;
				}
			
			case 'solano' | 'solano-alt':
				frames = Paths.getSparrowAtlas('characters/$curCharacter');
				
				//var uhh:String = (curCharacter.endsWith('alt') ? ' alt' : '0');
				
				animation.addByIndices('danceLeft', 'idle', [0,1,2,3,4,5,6,7,8,9,10,11,12,13], "", 24, false);
				animation.addByIndices('danceRight','idle', [14,15,16,17,18,19,20,21,22,23,24,25,26,27], "", 24, false);
				
				animation.addByPrefix('singLEFT', 'left', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				animation.addByPrefix('singUP',   'up', 24, false);
				animation.addByPrefix('singRIGHT','right', 24, false);
				
				animation.addByPrefix('jump',	'jump', 24, false);
				
				playAnim('idle');
				
				//if(curCharacter == 'solano')
				charData.offsets = [-25, -8];
				
				charData.camOffsets = [50, 150];
				
			case 'guselect-gf':
				frames = Paths.getSparrowAtlas('characters/guselect-gf');
				
				animation.addByPrefix('idle', 'Idle', 24, false);
				
				playAnim('idle');
				
				charData.camOffsets[1] += 200;
				
			// DEVLOG !!
			case 'guselect-devlog':
				frames = Paths.getSparrowAtlas('characters/guselect-devlog');
				animation.addByIndices('danceLeft', 'idle', [0,1,2,3,4,5,6,7,8,9,10,11,12,13], "", 24, false);
				animation.addByIndices('danceRight','idle', [14,15,16,17,18,19,20,21,22,23,24,25,26,27], "", 24, false);
				animation.addByPrefix('singLEFT', 'left', 24, false);
				animation.addByPrefix('singRIGHT','right', 24, false);
				animation.addByPrefix('singUP',   'up', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				
				animation.addByPrefix('firstDeath', 'dies', 24, false);
				animation.addByPrefix('deathLoop', 'dead', 24, true);
				
				playAnim('danceLeft');
				
				//charData.quickDancer = true;
				
			case 'luano-devlog':
				frames = Paths.getSparrowAtlas('characters/luano-devlog');
				animation.addByIndices('danceLeft', 'idle', [0,1,2,3], "", 24, false);
				animation.addByIndices('danceRight', 'idle', [4,5,6,7], "", 24, false);
				
				animation.addByPrefix('singLEFT', 'left0', 24, false);
				animation.addByPrefix('singRIGHT', 'right0', 24, false);
				animation.addByPrefix('singUP', 'up0', 24, false);
				animation.addByPrefix('singDOWN', 'down0', 24, false);
				
				animation.addByPrefix('singLEFTmiss', 'leftMiss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'rightMiss', 24, false);
				animation.addByPrefix('singUPmiss', 'upMiss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'downMiss', 24, false);
				
				animation.addByPrefix('firstDeath', 'dies', 24, false);
				animation.addByPrefix('deathLoop', 	'dead', 24, true);
				animation.addByPrefix('hey', 		'hey', 24, true);
				
				playAnim('danceLeft');
				
				flipX = true;
				charData.quickDancer = true;
				charData.camOffsets = [0, -80];
			
			// midnight secrets
			case 'luano-pixel-day' | 'luano-pixel-night':
				frames = Paths.getSparrowAtlas('characters/LuanoPixel');
				
				var endPrefix:String = (curCharacter.endsWith('-day') ? 'day' : 'night');
				
				var direct:Array<String> = ['left', 'down', 'up', 'right'];
				for(i in 0...4)
				{
					animation.addByPrefix('sing' + direct[i].toUpperCase(), 			'${direct[i]} $endPrefix',  24, false);
					animation.addByPrefix('sing' + direct[i].toUpperCase() + 'miss', 	'${direct[i]} miss',		24, false);
				}
				
				animation.addByPrefix('idle', 'idle $endPrefix', 24, false);
				animation.addByPrefix('jump', 'jump $endPrefix', 24, false);
				animation.addByPrefix('death', 'death $endPrefix', 24, false);
				
				flipX = true;
				antialiasing = false;
				scale.set(8,8);
				updateHitbox();
				
				charData.camOffsets[0] = 200;
				
				playAnim('idle');
				
			case 'skid-pixel' | 'pump-pixel':
				frames = Paths.getSparrowAtlas('characters/${curCharacter}Assets');
				
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singLEFT', 'left', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				
				antialiasing = false;
				scale.set(8,8);
				updateHitbox();
				
				playAnim('idle');
				
				charData.camOffsets[0] = -200;
				
			/*case 'gf':
				// GIRLFRIEND CODE
				frames = Paths.getSparrowAtlas('characters/GF_assets');
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				playAnim('danceRight');
			
			case 'gf-pixel':
				frames = Paths.getSparrowAtlas('characters/gfPixel');
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
			
			case 'dad':
				// DAD ANIMATION LOADING CODE
				frames = Paths.getSparrowAtlas('characters/DADDY_DEAREST');
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				playAnim('idle');
			
			case 'bf':
				frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);
				
				playAnim('idle');
				
				flipX = true;
				
				charData.offsets[1] = 70;
			
				case 'bf-og':
					frames = Paths.getSparrowAtlas('characters/og/BOYFRIEND');
					
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('scared', 'BF idle shaking', 24);
					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
					
					playAnim('idle');
					
					flipX = true;
			
				
			case 'bf-dead':
				frames = Paths.getSparrowAtlas('characters/BF_DEATH');
				
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
				
				playAnim('firstDeath');
				
				flipX = true;
				
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);
				
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				
				playAnim('idle');
				
				width -= 100;
				height -= 100;
				
				antialiasing = false;
				
				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');
				
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;
				
				charData.offsets[1] = 180;*/
				
			default:
				return setCharacter(x, y, 'luano-day');
		}
		
		// set up offsets cus why not
		var offsetPath:String = Paths.offsetTxt('offsets/' + curCharacter);// + (isPlayer ? '-player' : ''));
		if(OpenFlAssets.exists(offsetPath))
		{
			var characterOffsets:Array<String> = CoolUtil.coolTextFile(offsetPath);
			for (i in 0...characterOffsets.length)
			{
				var getterArray:Array<Array<String>> = CoolUtil.getOffsetsFromTxt(offsetPath);
				addOffset(getterArray[i][0], Std.parseInt(getterArray[i][1]), Std.parseInt(getterArray[i][2]));
			}
		}
		// sets any null offsets to [0, 0]
		for(anim in animation.getNameList())
		{
			if(animOffsets.get(anim) == null)
				addOffset(anim, 0, 0);
		}
		
		dance();
		
		if (isPlayer) // fuck you ninjamuffin lmao
			flipX = !flipX;
		
		if (adjustPos)
		{
			x += charData.offsets[0];
			trace('character ${curCharacter} scale ${scale.y}');
			y += (charData.offsets[1] - (frameHeight * scale.y));
		}

		this.x = x;
		this.y = y;

		return this;
	}

	function flipLeftRight():Void
	{
		// get the old right sprite
		var oldRight = animation.getByName('singRIGHT').frames;

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		// insert ninjamuffin screaming I think idk I'm lazy as hell

		if (animation.getByName('singRIGHTmiss') != null)
		{
			var oldMiss = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001 && animation.curAnim.name != 'pre-jumpPost')
			{
				dance();
				holdTimer = 0;
			}
		}
		
		if(specialAnimTimer != Math.NEGATIVE_INFINITY)
		{
			specialAnimTimer -= elapsed;
			// if you want a timer to stop the specialAnim
			if(specialAnimTimer <= 0)
			{
				specialAnimTimer = Math.NEGATIVE_INFINITY;
				specialAnim = false;
			}
		}
		
		if(!specialAnim)
		{
			var curCharSimplified:String = simplifyCharacter();
			switch(curCharSimplified)
			{
				case 'luano' | 'solano':
					if(animation.curAnim.name == 'jump' && animation.curAnim.finished)
						defaultDance(true);
				
				case 'pump':
					if(animation.curAnim.name == 'sunglass' && animation.curAnim.finished)
						defaultDance(true);
				
				case 'estrelano':
					var daY:Float = 780;
					if(curCharacter.endsWith('-night') && animation.curAnim.name != 'jump')
						daY = 580 + Math.sin(FlxG.game.ticks / 1000) * 120;
					
					y = FlxMath.lerp(y, daY - height, elapsed * 8);
			}
			
			// Post animation
			// (think Week 4 and how the player and mom's hair continues to sway after their idle animations are done!)
			var postAnim:String = animation.curAnim.name + 'Post';
			if(animation.curAnim.finished && animation.getByName(postAnim) != null)
			{
				// (( WE DON'T USE 'PLAYANIM' BECAUSE WE WANT TO FEED OFF OF THE IDLE OFFSETS! ))
				animation.play(postAnim, true, false, 0);
			}
			
			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
				playAnim('deathLoop');
		}
		
		super.update(elapsed);
	}

	private var danced:Bool = false;
	public var skidDance:Bool = false;
	
	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if(!specialAnim)
		{
			switch(curCharacter)
			{
				case "pump-d-side":
					var nextAnim:String = (PlayState.SONG.notes[PlayState.curSection].mustHitSection ? "right" : "left");
					var curAnim:String = animation.curAnim.name;
					
					if(!curAnim.endsWith('-change'))
					{
						var dCheck:Array<Bool> = [curAnim.endsWith("left"), nextAnim.endsWith("right")];
						if((dCheck[0] && dCheck[1]) || (!dCheck[0] && !dCheck[1]))
							nextAnim += "-change";
					}
					
					if(danced)
						playAnim('danceRight-$nextAnim', forced);
					else
						playAnim('danceLeft-$nextAnim', forced);
					
					danced = !danced;
					return;
					
				case 'pump' | 'pump-alt':
					if(animation.curAnim.name != 'sunglass')
						defaultDance(forced);
					
					return;
					
				case 'skid':
					if(!skidDance)
						defaultDance(forced);
					else
						playAnim('spooky-dance', false);
					
					return;
			}
			
			var curCharSimplified:String = simplifyCharacter();
			switch (curCharSimplified)
			{
				case 'luano':
					if(animation.curAnim.name != 'jump')
					{
						defaultDance(forced);
					}
					
				default:
					defaultDance(forced);
			}
		}
	}
	
	// the funny
	private function defaultDance(?forced:Bool = false)
	{
		// Left/right dancing, think Skid & Pump
		if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null)
		{
			danced = !danced;
			if (danced)
				playAnim('danceRight', forced);
			else
				playAnim('danceLeft', forced);
		}
		else
			playAnim('idle', forced);
	}
	
	public function returnIdle():String
	{
		if(animation.getByName('danceLeft') != null)
			return 'danceLeft';
		else
			return 'idle';
	}
	
	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) != null)
			super.playAnim(AnimName, Force, Reversed, Frame);
	}

	public function simplifyCharacter():String
	{
		var base = curCharacter;

		if (base.contains('-'))
			base = base.substring(0, base.indexOf('-'));
		return base;
	}
}
