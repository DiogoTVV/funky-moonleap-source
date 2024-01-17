package meta.state.menus.menuObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.data.dependency.Discord;
import meta.state.menus.*;
import meta.subState.WebsiteSubState;
#if windows import shaders.BrightnessShader; #end

using StringTools;

class CreditsGroup extends MusicBeatGroup
{
	static var isMoonleap:Bool = false;
	
	static var curMedia:Int = 0;
	static var curSelected:Int = 0;
	
	var curLogo:FlxSprite;
	#if windows var logoShader:BrightnessShader; #end
	
	var menuItems:FlxTypedGroup<FlxSprite>;
	var descTxt:FlxText;
	
	var funkyCredits:Array<Dynamic> = [];
	var leapyCredits:Array<Dynamic> = [];
	
	public function new()
	{
		super();
		groupName = 'credits';
		// foda
		#if !html5
		Discord.changePresence('CREDITS', 'Main Menu');
		#end
		// psych engine omg!!!
		funkyCredits =
		[
			['beastlychip',  'Director and Main Composer',  ["https://on.soundcloud.com/iFaZx", "https://youtube.com/channel/UCyl-osfFDVzYyFPyGwbu2oA", "https://twitter.com/BeastlyChip"]],
			['beastlymudoku','Co-Director and Main Artist', ["https://twitter.com/Mudoku__"]],
			['goldenfoxy',	 'Co-Director and Charter',		["https://youtube.com/channel/UCH8_WjWu4iTnYL4CY14rYbg", "https://twitter.com/goldenfoxy2604", "https://gamebanana.com/members/1798514", "https://steamcommunity.com/id/goldenfoxy2604/"]],
			['diogotv', 	 'Programmer and Artist', 	   	["https://youtube.com/DiogoTVV", "https://twitter.com/DiogoTVV", "https://on.soundcloud.com/NYBqS", "https://gamebanana.com/members/1904962", "https://diogotv.newgrounds.com", "https://github.com/DiogoTVV"]],
			['beastlyyoshi', 'BG Artist', 				    ["https://youtube.com/channel/UC-WRwHlGj9PhJmsQ5nqBOjw", "https://twitter.com/yoshizitosNG"]],
			['anakimplay',	 'Composer', 					["https://on.soundcloud.com/affy", "https://youtube.com/channel/UCHC1W3nZ1nVhaN2QrS-O4sg", "https://twitter.com/AnakimPlay"]],
			['julianobeta',  'Composer', 					["https://on.soundcloud.com/gLPYG", "https://youtube.com/channel/UCRDeljMur0lEz1nXhrFKE9A"]],
			['pi3tr0', 		 'Charter', 					["https://youtube.com/channel/UCEkf4h74pKFK9RO3FAze-7Q"]],
		];
		// just like the original!!
		leapyCredits =
		[
			['original game by', 'guselect', 	 ["https://youtube.com/@BotaoSelect", "https://twitter.com/guselect"]],
			['music by', 		 'dani serranú', ["https://youtube.com/@Danirrano", "https://twitter.com/daniserranu", "https://soundcloud.com/danielle-serranu"]],
			['monster design by','garope', 		 ["https://twitter.com/Garope_", "https://instagram.com/garope_art/"]],
		];
		
		// add the menu items
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		
		descTxt = new FlxText(0, 0, 0, '', 24);
		descTxt.scrollFactor.set();
		descTxt.setFormat(Main.gFont, 24, FlxColor.fromRGB(181,165,240), CENTER);
		add(descTxt);
		
		#if windows logoShader = new BrightnessShader(); #end
		reloadLogo(false);
	}
	
	var iconSin:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(controls.BACK)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			GlobalMenuState.nextMenu = new MainMenuGroup();
			alive = false;
		}
		
		if(curSelected == 0)
		{
			if(controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				reloadLogo();
			}
			
			//curLogo.alpha = 0.75 + Math.sin(FlxG.game.ticks / 400) * 0.3;
			#if windows logoShader.value = 0.1 + Math.sin(FlxG.game.ticks / 200) * 0.6; #end
		}
		else
		{
			#if windows logoShader.value = 0; #end
			if(controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				var daCredit = (isMoonleap ? leapyCredits : funkyCredits);
				FlxG.state.openSubState(new WebsiteSubState(daCredit[curSelected - 1][2][curMedia]));
			}
			
			if(controls.UI_LEFT_P)
				changeMedia(-1);
			if(controls.UI_RIGHT_P)
				changeMedia(1);
		}
		
		iconSin += elapsed * 3;
		for(item in menuItems)
		{
			if(!Std.isOfType(item, FlxText))
			{
				if(curSelected == item.ID)
					item.angle = Math.sin(iconSin * 2) * 14;
				else
					item.angle = 0;
			}
		}
		
		if(controls.UI_UP_P)
			changeSelection(-1);
		if(controls.UI_DOWN_P)
			changeSelection(1);
	}
	
	public function reloadLogo(change:Bool = true)
	{
		if(change) isMoonleap = !isMoonleap;
		
		if(curLogo != null) remove(curLogo);
		
		curLogo = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/moonleap/logo' + (isMoonleap ? '-moonleap' : '')));
		curLogo.scale.set(4,4);
		curLogo.updateHitbox();
		curLogo.screenCenter(X);
		#if windows curLogo.shader = logoShader.shader; #end
		add(curLogo);
		
		var daY:Float = (isMoonleap ? 70 : 35);
		curLogo.y = daY - 15;
		
		FlxTween.tween(curLogo, {y: daY}, 0.1, {ease: FlxEase.cubeOut});
		
		reloadItems();
	}
	
	public function reloadItems()
	{
		while (menuItems.members.length > 0) menuItems.remove(menuItems.members[0], true);
		
		if(!isMoonleap)
		{
			for(i in 0...funkyCredits.length)
			{
				var mediaTxt = new FlxText(0, 0, 0, funkyCredits[i][0]);
				mediaTxt.scrollFactor.set();
				mediaTxt.setFormat(Main.gFont, 24, FlxColor.WHITE, CENTER);
				mediaTxt.screenCenter(X);
				mediaTxt.y = 200 + (48 * i);
				mediaTxt.ID = i + 1;
				menuItems.add(mediaTxt);
				
				var funnyIcon = new FlxSprite().loadGraphic(Paths.image('credits/' + funkyCredits[i][0]));
				funnyIcon.scale.set(4,4);
				funnyIcon.updateHitbox();
				funnyIcon.y = mediaTxt.y + (mediaTxt.height / 2) - (funnyIcon.height / 2);
				funnyIcon.x = (i % 2 == 0) ? 400 : 800;
				funnyIcon.ID = i + 1;
				menuItems.add(funnyIcon);
			}
		}
		else
		{
			for(i in 0...leapyCredits.length)
			{
				var topTxt = new FlxText(0, 0, 0, leapyCredits[i][0]);
				topTxt.scrollFactor.set();
				topTxt.setFormat(Main.gFont, 28, FlxColor.fromRGB(236,157,0), CENTER);
				topTxt.screenCenter(X);
				topTxt.y = 200 + (120 * i);
				topTxt.ID = 69420;
				menuItems.add(topTxt);
				
				var bottomTxt = new FlxText(0, 0, 0, leapyCredits[i][1]);
				bottomTxt.scrollFactor.set();
				bottomTxt.setFormat(Main.gFont, 28, FlxColor.WHITE, CENTER);
				bottomTxt.screenCenter(X);
				bottomTxt.y = topTxt.y + topTxt.height + 5;
				bottomTxt.ID = i + 1;
				menuItems.add(bottomTxt);
			}
		}
		
		changeSelection();
	}
	
	public function changeSelection(direction:Int = 0):Void
	{
		if(direction != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		
		curSelected += direction;
		curSelected = FlxMath.wrap(curSelected, 0, (isMoonleap ? leapyCredits : funkyCredits).length);
		
		for(item in menuItems)
		{
			if(item.ID != 69420)
				item.color = FlxColor.fromRGB(171,169,255);
			
			if (item.ID == curSelected)
				item.color = FlxColor.fromRGB(173,253,255);
		}
		
		changeMedia();
	}
	
	public function changeMedia(direction:Int = 0):Void
	{
		var daCredit = (isMoonleap ? leapyCredits : funkyCredits);
		curMedia += direction;
		if(curSelected != 0)
			curMedia = FlxMath.wrap(curMedia, 0, Math.floor(daCredit[curSelected - 1][2].length - 1));
		
		if(curSelected != 0)
		{
			descTxt.text = '';
			if(!isMoonleap)
				descTxt.text += daCredit[curSelected - 1][1].toLowerCase() + '\n';
			
			descTxt.text += '< ${formatMedia(daCredit[curSelected - 1][2][curMedia])} >';
			if(daCredit[curSelected - 1][2].length == 1)
			{
				for(i in 0...2)
					descTxt.text = descTxt.text.replace((i == 0) ? '< ' : ' >', '');
			}
		}
		else
		{
			descTxt.text = (isMoonleap ? 'go to funky moonleap credits' : 'go to moonleap credits');
		}
		
		descTxt.x = (FlxG.width / 2) - (descTxt.width / 2);
		descTxt.y = FlxG.height - descTxt.height - 10;
	}
	
	// converts links into names
	private final mediaMap:Map<String, String> = [
		"https://twitter" 	 => "twitter",
		"https://youtube"	 => "youtube",
		"newgrounds.com"	 => "newgrounds",
		"https://gamebanana" => "gamebanana",
		"https://steam"		 => "steam",
		"https://github"	 => "github",
		"https://instagram"  => "instagram",
		"https://soundcloud"  => "soundcloud",
		"https://on.soundcloud"  => "soundcloud",
	];
	private function formatMedia(rawMedia:String):String
	{
		var returnName:String = "unknown";
		// converting the map
		for(rawName => shortName in mediaMap)
			switch(rawName)
			{
				case 'newgrounds.com': // checks the end of the link instead
					if(rawMedia.endsWith(rawName))
						returnName = shortName;
				
				default:
					if(rawMedia.startsWith(rawName))
						returnName = shortName;
			}
		
		return returnName;
	}
}