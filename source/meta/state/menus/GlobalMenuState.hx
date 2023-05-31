package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import meta.MusicBeat.MusicBeatState;
import meta.data.Highscore;
import meta.state.menus.menuObjects.*;
import gameObjects.userInterface.ParticleGroup;
import gameObjects.userInterface.RealClock;

class GlobalMenuState extends MusicBeatState
{
	public static var spawnMenu:String = 'title';
	public static var nextMenu:MusicBeatGroup = null;
	var curMenu:MusicBeatGroup = null;
	
	public static var realClock:RealClock;
	public static var gameLogo:FlxSprite;
	
	override function create()
	{
		super.create();
		ForeverTools.resetMenuMusic(true);
		meta.data.Conductor.changeBPM(120);
		
		/// spawn the backgrounds here
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/moonleap/menuBack'));
		bg.scale.set(4,4);
		bg.updateHitbox();
		bg.antialiasing = false;
		bg.screenCenter();
		add(bg);
		
		for(row in 0...2) // 2 colunas de vinha
		{
			for(i in 0...4) // 4 vinhas
			{
				var isDay:Bool = (row == 0);
		
				var vinhaFoda:FlxSprite = new FlxSprite(0, (64 * 2) + (64 * i));
				vinhaFoda.loadGraphic(Paths.image('menus/moonleap/vine' + (isDay ? 'Day' : 'Night')), true, 16, 16);
				vinhaFoda.animation.add('idle', [0,1,2,3,4,5,6,7], 8, true);
				vinhaFoda.animation.play('idle', true, false, i);
				vinhaFoda.setGraphicSize(Std.int(vinhaFoda.width * 4));
				vinhaFoda.updateHitbox();
				add(vinhaFoda);
				
				vinhaFoda.x = isDay ? 0 : FlxG.width - vinhaFoda.width;
			}
			
			// 2 luano tbm pq sim
			var luano = new moonleap.Luano();
			luano.setPosition(((row == 0) ? 64 : 1152), 380);
			luano.flipX = (row == 1);
			add(luano);
			
			luano.isDay = !luano.flipX;
			luano.playAnim('idle');
		}
		
		var part = new ParticleGroup();
		add(part);
		
		gameLogo = new FlxSprite(0, 130).loadGraphic(Paths.image('menus/moonleap/logo'));
		gameLogo.scale.set(4,4);
		gameLogo.updateHitbox();
		gameLogo.screenCenter(X);
		add(gameLogo);
		
		realClock = null;
		if(Highscore.getHighscore('leap-(d-side-mix)').score > 0
		&& SaveData.trueSettings.get('Locked Songs').contains('midnight-secrets'))
		{
			realClock = new RealClock();
			realClock.x = FlxG.width - realClock.width;
			realClock.y = FlxG.height - realClock.height;
			add(realClock);
		}
		
		var watermark = new FlxText(0, 0, 0, "Funky Moonleap v2.1 - [Doido Engine v2.0]");
		watermark.setFormat(Main.gFont, 12, FlxColor.fromRGB(170,255,255), LEFT);
		watermark.setPosition(5,FlxG.height - watermark.height - 5);
		add(watermark);
		
		// i hate this so much but theres nothing i can do about it
		switch(spawnMenu)
		{
			case 'title': 	nextMenu = new TitleGroup();
			case 'options': nextMenu = new OptionsGroup();
			case 'freeplay':nextMenu = new FreeplayGroup();
			default: 		nextMenu = new MainMenuGroup();
		}
		
		curMenu = nextMenu;
		
		add(curMenu);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		// refreshes the current group when it isnt alive anymore
		if(!curMenu.alive)
		{
			remove(curMenu);
			curMenu = nextMenu;
			add(curMenu);
		}
		
		var logoY:Float = 130;
		switch(nextMenu.groupName)
		{
			case 'freeplay': logoY = 190; // 180
			case 'credits' | 'gamepad':  logoY = -FlxG.height * 2; // 12
			case 'controls': logoY = 40;
			case 'options': // it depends on the category
				switch(OptionsGroup.curCategory) {
					case 'main':logoY = 120;
					default: 	logoY = 60;
				}
		}
		gameLogo.y = FlxMath.lerp(gameLogo.y, logoY, elapsed * 8);
	}
	
	// uhhh
	override function stepHit()
	{
		super.stepHit();
		if(curMenu != null)
		{
			curMenu.stepHit(curStep);
			if(curStep % 4 == 0)
				curMenu.beatHit(Math.floor(curStep / 4));
		}
	}
}