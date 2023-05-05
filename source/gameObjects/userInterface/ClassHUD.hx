package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import meta.data.Conductor;
import meta.data.Timings;
import meta.state.PlayState;

using StringTools;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	var scoreBar:FlxText;
	var scoreLast:Float = -1;
	
	// fnf mods
	var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';
	
	public var autoplayTxt:FlxText; // autoplay indicator at the center
	public var autoplaySine:Float = 0;
	
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	
	private var SONG = PlayState.SONG;
	
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	
	public var clock:Clock;
	
	private var stupidHealth:Float = 0;
	
	private var timingsMap:Map<String, FlxText> = [];
	
	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (SaveData.trueSettings.get('Downscroll'))
			barY = 64;
		
		healthBarBG = new FlxSprite(0,
			barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		
		clock = new Clock([iconP1, iconP2], PlayState.assetModifier);
		clock.visible = SaveData.trueSettings.get('Show Clock');
		add(clock);
		
		// just updates the bar colors dw
		changeIcon();
		
		scoreBar = new FlxText(FlxG.width / 2, Math.floor(healthBarBG.y + 40), 0, scoreDisplay);
		scoreBar.setFormat(Main.gFont, 18, FlxColor.fromRGB(170,255,255));
		scoreBar.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		updateScoreText();
		// scoreBar.scrollFactor.set();
		//scoreBar.antialiasing = true;
		add(scoreBar);

		// counter
		if (SaveData.trueSettings.get('Ratings Counter') != 'none')
		{
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length)
			{
				var textAsset:FlxText = new FlxText(5
					+ (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0, '', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(Main.gFont, counterTextSize, FlxColor.fromRGB(170,255,255), RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}
		updateScoreText();
		
		autoplayTxt = new FlxText(0, 0, 0, "autoplay");
		autoplayTxt.setFormat(Main.gFont, 28, FlxColor.fromRGB(170,255,255));//FlxColor.WHITE);
		autoplayTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(autoplayTxt);
		autoplayTxt.x = FlxG.width / 2 - autoplayTxt.width / 2;
		autoplayTxt.y = (SaveData.trueSettings.get('Downscroll')) ? FlxG.height - autoplayTxt.height - 100 : 100;
	}

	var counterTextSize:Int = 18;
	
	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);
	
	var left = (SaveData.trueSettings.get('Ratings Counter') == 'left');
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		// pain, this is like the 7th attempt
		healthBar.percent = (PlayState.health * 50);
		
		var iconLerp = Main.framerateAdjust(0.15);
		
		for(icon in [iconP1, iconP2])
		{
			icon.scale.set(FlxMath.lerp(icon.scale.x, 1, iconLerp), FlxMath.lerp(icon.scale.y, 1, iconLerp));
			
			icon.offset.x = FlxMath.lerp(icon.offset.x, 0, iconLerp);
			icon.offset.y = FlxMath.lerp(icon.offset.y, 0, iconLerp);
		}
		
		var iconOffset:Int = 26;
		var iconX:Float = healthBar.x + (healthBar.width * ((100 - healthBar.percent) * 0.01));
		
		iconP1.x = iconX - iconOffset;
		iconP2.x = iconX - (iconP2.width - iconOffset);
		
		iconP1.updateAnim(healthBar.percent);
		iconP2.updateAnim(100 - healthBar.percent);
		
		autoplayTxt.visible = PlayState.autoplay;
		if(PlayState.autoplay)
		{
			autoplaySine += elapsed * 3;
			autoplayTxt.alpha = 0.6 + Math.sin(autoplaySine) * 0.6;
		}
	}

	private final divider:String = " || "; //" • ";

	public function updateScoreText()
	{
		var comboDisplay:String = (Timings.comboDisplay != null && Timings.comboDisplay != '' ? ' [${Timings.comboDisplay}]' : '');
		
		scoreBar.text = 'Score: ${PlayState.songScore}';
		// testing purposes
		var displayAccuracy:Bool = SaveData.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			scoreBar.text += divider + 'Combo: ${PlayState.combo}';
			// misses
			scoreBar.text += divider + 'Misses: ${PlayState.misses}';
			// accuracy
			scoreBar.text += divider + 'Accuracy: ${Timings.formatAccuracy(Timings.getAccuracy())}% $comboDisplay';
			// rank
			scoreBar.text += '[${Timings.returnScoreRating().toUpperCase()}]';
		}
		scoreBar.text += '\n';
		scoreBar.x = Math.floor((FlxG.width / 2) - (scoreBar.width / 2));
		
		// update counter
		if (SaveData.trueSettings.get('Ratings Counter') != 'None')
		{
			for (i in timingsMap.keys())
			{
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}
		
		// update playstate
		PlayState.detailsSub = scoreBar.text;
		PlayState.updateRPC(false);
	}

	private var beated:Bool = false;
	
	public function beatHit()
	{
		beated = !beated;
		
		var I_S:Array<Float> = [1.3, 0.8];
		if(beated) I_S.reverse();
		
		// 1.3
		iconP1.scale.set(I_S[0], I_S[1]);
		iconP2.scale.set(I_S[1], I_S[0]);
		
		var mult:Int = (beated ? 35 : -35);
		iconP1.offset.x = mult;
		iconP2.offset.x = mult;
	}
	
	// also updates the healthBar color without actually changing the icons
	public function changeIcon(char:Null<String> = null, isPlayer:Bool = false):Void
	{
		if(char != null)
			(isPlayer ? iconP1 : iconP2).updateIcon(char, isPlayer);
		
		healthBar.createFilledBar(iconP2.iconColor, iconP1.iconColor);
		healthBar.updateBar();
		clock.updateColors();
	}
}
