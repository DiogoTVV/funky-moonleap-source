package meta.state.menus.menuObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.subState.WebsiteSubState;
import meta.data.dependency.Discord;
import meta.state.menus.*;
import meta.state.PlayState;
import meta.data.*;
import meta.data.Highscore.HighscoreData;

using StringTools;

class FreeplayGroup extends MusicBeatGroup
{
	// buttons
	var menuItems:FlxTypedGroup<FlxSprite>;
	var songs:Array<Array<String>> =
	[
		['leap', 'crescent', 'lunar-odyssey'],
		['sun-hop', 'devlog', 'leap-(d-side-mix)', 'midnight-secrets'],
	];
	static var curSelected:Int = 0;
	static var curRow:Int = 0;
	// score stuff
	/*var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var lerpAccuracy:Float = 0;
	var intendedAccuracy:Float = 0;*/
	var curScore:Array<Int> = [0,0];
	var curAccuracy:Array<Float> = [0,0];
	var curMisses:Array<Int> = [0,0];
	// objects
	var selectSquare:FlxSprite;
	var infoTxt:FlxText;

	public function new()
	{
		super();
		GlobalMenuState.spawnMenu = groupName = 'freeplay';
		
		// foda
		#if !html5
		Discord.changePresence('FREEPLAY MENU', 'Main Menu');
		#end
		
		var moonDate = Date.now();
		
		// you cant play unless you unlocked it
		for(i in songs[1])
			if(SaveData.trueSettings.get('Locked Songs').contains(i))
			{
				if(i == 'midnight-secrets'
				&& moonDate.getHours() == 0 && moonDate.getMinutes() <= 5
				&& Highscore.getHighscore('leap-(d-side-mix)').score > 0)
				{
					continue;
				}
				
				songs[1].insert(songs[1].indexOf(i), '???');
				songs[1].remove(i);
			}
		
		// add the menu items
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		// looping
		var songNum:Int = 0;
		for(row in 0...songs.length)
		{
			for(line in 0...songs[row].length)
			{
				songNum++;
				var zero:String = '0';
				if(songNum >= 10) zero = '';
				
				var menuItem:FlxText = new FlxText(0, 0, 0, zero + Std.string(songNum), 24);
				menuItem.scrollFactor.set();
				menuItem.setFormat(Main.gFont, 48, FlxColor.WHITE, CENTER);
				menuItem.ID = songNum;
				menuItems.add(menuItem);
				
				// if you beat the song it gets light-blue
				if(Highscore.getHighscore(songs[row][line]).score > 0)
					menuItem.color = FlxColor.fromRGB(170,255,255);
				else
					menuItem.color = FlxColor.fromRGB(170,170,255);
				// ???
				if(songs[row][line] == '???')
					menuItem.color = FlxColor.fromRGB(0,85,170); // dark
				
				var divideNum:Float = 3;
				if(songs[row].length >= 4)
					divideNum = 2.75;
				//var divideNum:Float = (3.75 - (0.25 * songs[row].length));
				
				// spawns everyone in the middle
				menuItem.x = (FlxG.width / 2) - (65 / 2);
				menuItem.y = (FlxG.height / 2) - (50 / 2);
				// sorting X
				var spaceX:Float = 100;
				menuItem.x -= spaceX * (songs[row].length / divideNum);
				menuItem.x += spaceX * line;
				// sorting Y
				var spaceY:Float = 100;
				menuItem.y -= spaceY * (songs.length / 3);
				menuItem.y += (spaceY * row) + 120;
				
				// i hate one
				if(menuItem.text.startsWith('1') || menuItem.text.endsWith('1')) menuItem.x += 3;
				
				// does that little effect on the buttons that og moonleap does
				FlxTween.tween(menuItem, {y: ((FlxG.height / 2) - (menuItem.height / 2)) + 120}, 1.5,
				{
					ease: FlxEase.expoOut, // expoOut
					type: FlxTweenType.BACKWARD,
				});
			}
		}
		
		infoTxt = new FlxText(0, 0, 0, '', 24);
		infoTxt.scrollFactor.set();
		infoTxt.setFormat(Main.gFont, 20, FlxColor.fromRGB(170,170,255), CENTER);
		add(infoTxt);
		
		selectSquare = new FlxSprite(menuItems.members[curSelected].x, (FlxG.height / 2) + 80).loadGraphic(Paths.image('menus/moonleap/select'));
		selectSquare.antialiasing = false;
		selectSquare.setGraphicSize(Std.int(selectSquare.width * 2));
		add(selectSquare);
		
		changeSelected(false);
		changeRow(false);
	}
	
	var placeX:Float = 0;
	var placeY:Float = 0;
	var selectedSomethin:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		
		updateInfoTxt();
		
		//trace('main class state is ${Main.mainClassState}');
		
		if(!selectedSomethin)
		{
			if(controls.BACK)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				GlobalMenuState.nextMenu = new MainMenuGroup();
				alive = false;
			}
			
			if(controls.ACCEPT && songs[curRow][curSelected] != '???')
			{
				//GlobalMenuState.substateOpen = false;
				selectedSomethin = true;
				Init.playSong(songs[curRow][curSelected].toLowerCase());
			}
			
			if(leftP)
				changeSelected(-1);
			if(rightP)
				changeSelected(1);
			if(upP)
				changeRow(-1);
			if(downP)
				changeRow(1);
		}
		
		// placing
		selectSquare.x = FlxMath.lerp(selectSquare.x, placeX, elapsed * 18);
		selectSquare.y = FlxMath.lerp(selectSquare.y, placeY, elapsed * 18);
		
		placeBox();
	}
	
	function getLerpValue(valueToLerp:Array<Dynamic>):Float
		return FlxMath.lerp(valueToLerp[1], valueToLerp[0], Main.framerateAdjust(0.25));
	
	function isNear(value1:Float, value2:Float, bound:Float):Dynamic
		return (Math.abs(value1 - value2) <= bound) ? value2 : value1;
	
	function updateInfoTxt()
	{
		// setting up the lerp stuff
		curScore[1] 	= Math.floor(getLerpValue(curScore));
		curAccuracy[1] 	= Math.floor(getLerpValue(curAccuracy) * 100) / 100;
		curMisses[1] 	= Math.floor(getLerpValue(curMisses));
		// lerp bullshit
		curScore[1] 	= isNear(curScore[1],	 curScore[0],	 10);
		curAccuracy[1] 	= isNear(curAccuracy[1], curAccuracy[0], 0.12);
		curMisses[1] 	= isNear(curMisses[1],	 curMisses[0],	 10);
		
		infoTxt.text = "";
		var selectedSong:String = songs[curRow][curSelected];
		infoTxt.text += CoolUtil.dashToSpace(selectedSong.toLowerCase());
		
		if(selectedSong == '???')
		{
			//infoTxt.text += "\na secret needs to be found to unlock";
			var hints:Array<String> = [
				"beat one of the first three songs to unlock",
				"beat the fourth song to unlock",
				"find it on a youtube video (not literally)",
				"nothing to see here",
			];
			if(Highscore.getHighscore('leap-(d-side-mix)').score > 0)
				hints[3] = "ill tell you at midnight";
			
			infoTxt.text += '\n' + hints[curSelected];
		}
		else
		{
			infoTxt.text += "\nscore: " + curScore[1];
			infoTxt.text += " - accuracy: " + Timings.formatAccuracy(curAccuracy[1]) + "%";
			infoTxt.text += " - misses: " + ((curMisses[1] < 0) ? "--" : "" + curMisses[1]);
		}
		infoTxt.x = (FlxG.width / 2) - (infoTxt.width / 2);
		infoTxt.y = FlxG.height - infoTxt.height - 10;
	}
	
	function changeSelected(?change:Int = 0, ?playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
	
		curSelected += change;
		if (curSelected < 0)
			curSelected = songs[curRow].length - 1;
		if (curSelected >= songs[curRow].length)
			curSelected = 0;
		
		var daHighscore:HighscoreData = Highscore.getHighscore(songs[curRow][curSelected]);
		curScore[0]    = daHighscore.score;
		curAccuracy[0] = daHighscore.accuracy;
		curMisses[0]   = daHighscore.misses;
		
		//trace(daHighscore);
		
		placeBox();
	}
	
	function changeRow(change:Int = 0, ?playSound:Bool = true)
	{
		curRow += change;
		if (curRow < 0)
			curRow = songs.length - 1;
		if (curRow >= songs.length)
			curRow = 0;
		// changing the box position and getting score
		changeSelected(playSound);
	}
	
	function placeBox()
	{
		// placing the box
		placeX = getMid(menuItems.members[curSelected + (3 * curRow)], "X");
		placeY = getMid(menuItems.members[curSelected + (3 * curRow)], "Y");
	}
	
	function getMid(object:FlxSprite, whichWay:String = "X")
	{
		if(whichWay == "X")
			return object.x + (object.width / 7.5);
		else
			return object.y + (object.height / 8);
	}
}