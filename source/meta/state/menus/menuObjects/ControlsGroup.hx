package meta.state.menus.menuObjects;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameObjects.userInterface.menu.*;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.dependency.Discord;
import meta.state.menus.*;

using StringTools;

/*
**	I HATE CODING THIS AAAAAAAA
*/
class ControlsGroup extends MusicBeatGroup
{
	var submenuOpen:Bool = false;
	static var curSelectedV:Int = 0;
	static var curSelectedH:Int = 0;
	
	var allGuides:FlxTypedGroup<FlxText>;
	var firstButtons:FlxTypedGroup<FlxText>;
	var secondButtons:FlxTypedGroup<FlxText>;
	// submenus texts
	var waitingTxt:WaitingTxt;
	
	public function new()
	{
		super();
		groupName = 'controls';
		
		#if !html5
		Discord.changePresence('CONTROLS', 'Main Menu');
		#end
		
		allGuides = new FlxTypedGroup<FlxText>();
		firstButtons = new FlxTypedGroup<FlxText>();
		secondButtons = new FlxTypedGroup<FlxText>();
		add(allGuides);
		add(firstButtons);
		add(secondButtons);
		
		generateButtons();
		
		waitingTxt = new WaitingTxt();
		waitingTxt.visible = false;
		add(waitingTxt);
		
		changeVertical(false);
	}
	
	private function generateButtons()
	{
		var arrayTemp:Array<String> = [];
		// re-sort everything according to the list numbers
		for (controlString in SaveData.gameControls.keys()) {
			arrayTemp[SaveData.gameControls.get(controlString)[1]] = controlString;
		}
		
		var label:FlxText = new FlxText(0, 195, 0, "controls");
		label.setFormat(Main.gFont, 28, FlxColor.fromRGB(170,170,255), CENTER);
		label.antialiasing = false;
		label.screenCenter(X);
		add(label);
		
		var spawnY:Float = label.y + label.height + 12;
		
		for(i in 0...arrayTemp.length)
		{
			var daSize:Int = 24;
			var GRID:Float = daSize + 2;
			
			var newGuide = new FlxText(380, spawnY + (GRID * i), arrayTemp[i].replace("_", " "), daSize);
			newGuide.setFormat(Main.gFont, daSize, FlxColor.WHITE, LEFT); // 36
			newGuide.ID = i;
			allGuides.add(newGuide);
			
			for (j in 0...2)
			{
				var keyString = "";

				if (SaveData.gameControls.exists(arrayTemp[i]))
					keyString = getStringKey(SaveData.gameControls.get(arrayTemp[i])[0][j]);

				var newButton = new FlxText((newGuide.x + 150) + (200 * j), newGuide.y, keyString, daSize);
				newButton.setFormat(Main.gFont, daSize, FlxColor.WHITE, LEFT);
				newButton.ID = i;
				
				// adding it
				((j == 0) ? firstButtons : secondButtons).add(newButton);
			}
		}
	}
	
	private function getStringKey(arrayThingy:Dynamic):String
	{
		var keyString:String = 'none';
		if(arrayThingy != null && arrayThingy != FlxKey.NONE)
		{
			var keyDisplay:FlxKey = arrayThingy;
			keyString = keyDisplay.toString();
		}

		keyString = keyString.replace(" ", "");

		return formatKey(keyString);
	}
	
	var curTxt:String = '';
	var gElapsed:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		gElapsed = elapsed;
		
		curTxt = allGuides.members[curSelectedV].text;
		
		waitingTxt.visible = submenuOpen;
		
		if(!submenuOpen)
		{
			if(FlxG.keys.justPressed.ESCAPE)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				GlobalMenuState.nextMenu = new OptionsGroup();
				alive = false;
			}
			
			if(FlxG.keys.justPressed.ENTER)
				closeOpenSubmenu(true);
			
			if(FlxG.keys.justPressed.BACKSPACE)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeKey(FlxKey.NONE);
			}
			
			if(FlxG.keys.justPressed.UP)
				changeVertical(-1);
			if(FlxG.keys.justPressed.DOWN)
				changeVertical(1);
			if(FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
				changeHorizontal(true);
		}
		else
			submenuUpdate();
	}
	
	private function submenuUpdate()
	{
		if (FlxG.keys.justPressed.ANY)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				closeOpenSubmenu(false);
				return;
			}
		
			// converting it to an FlxKey for easier control
			var pressedKey:FlxKey = cast(FlxG.keys.firstJustPressed(), FlxKey);
			changeKey(pressedKey);
			// bye
			closeOpenSubmenu(false);
		}
	}
	
	public function changeKey(?pressedKey:FlxKey)
	{
		((curSelectedH == 0) ? firstButtons : secondButtons).members[curSelectedV].text = getStringKey(pressedKey);
		
		// saving
		SaveData.gameControls.get(reverseSpace(curTxt))[0][curSelectedH] = pressedKey;
		controls.setKeyboardScheme(None, false);
	}
	
	private function reverseSpace(daText:String):String
		return daText.replace(" ", "_");
	
	private function changeVertical(?change:Int = 0, playSound:Bool = true)
	{
		curSelectedV += change;
		if(playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
		
		if (curSelectedV < 0)
			curSelectedV = allGuides.length - 1;
		if (curSelectedV >= allGuides.length)
			curSelectedV = 0;
		
		for(item in allGuides.members)
		{
			item.color = FlxColor.fromRGB(170,170,255);
			if (item.ID == curSelectedV)
			{
				//item.color = FlxColor.fromRGB(173,253,255);
				item.color = FlxColor.fromRGB(236,157,0);
				if(item.text == '') // skip empty keys
					changeVertical(change, false);
			}
		}
		
		changeHorizontal();
	}
	
	public function changeHorizontal(switchH:Bool = false)
	{
		// ill just invert between 0 and 1 since theres only these two anyway
		if(switchH)
		{
			curSelectedH = (curSelectedH == 1) ? 0 : 1;
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
		}
		
		for(item in firstButtons.members)
			idCheck(item, 0);
		for(item in secondButtons.members)
			idCheck(item, 1);
	}
	
	private function idCheck(item:FlxText, daID:Int)
	{
		item.color = FlxColor.fromRGB(170,170,255);
		if (item.ID == curSelectedV && curSelectedH == daID)
			item.color = FlxColor.fromRGB(170,255,255);
	}
	
	private function closeOpenSubmenu(isOpen:Bool)
	{
		submenuOpen = isOpen;
		FlxG.sound.play(Paths.sound(isOpen ? 'confirmMenu' : 'scrollMenu'), 1);
	}
	
	// im sorry i couldn't find a better way to do this, im sad now
	final keyMap:Map<String, Int> = [
		'ZERO' => 0,
		'ONE'  => 1,
		'TWO'  => 2,
		'THREE'=> 3,
		'FOUR' => 4,
		'FIVE' => 5,
		'SIX'  => 6,
		'SEVEN'=> 7,
		'EIGHT'=> 8,
		'NINE' => 9,
	];
	private function formatKey(daKey:String):String
	{
		var formattedKey:String = daKey.replace("NUMPAD", "#");
		
		for(number => formatNumber in keyMap)
			if(formattedKey.endsWith(number))
				formattedKey = formattedKey.replace(number, Std.string(formatNumber));
		
		return formattedKey;
	}
}