package meta.state.menus.menuObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import meta.subState.WebsiteSubState;
import meta.data.*;

class TitleGroup extends MusicBeatGroup
{
	var titleTexts:FlxTypedGroup<FlxText>;
	
	public function new()
	{
		super();
		groupName = GlobalMenuState.spawnMenu = 'title';
		
		var bg = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(0,0,85));
        bg.screenCenter();
        add(bg);

        titleTexts = new FlxTypedGroup<FlxText>();
        add(titleTexts);
	}
	
		#if mobile
    var justTouched:Bool = false;
    
	  for (touch in FlxG.touches.list)
	{
		if (touch.justPressed)
	 {
    justTouched = true;
	}
	 }
  #end
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if(controls.ACCEPT #if mobile || justTouched #end)
			endItAll();
	}
	
	override function stepHit(curStep:Int = 0)
	{
		switch(curStep)
		{
			case 4:
				addText("Moony Team", false);
				
			case 8:
				addText("Presents");
				
			case 12:
				removeText();
				
			case 16:
				removeText();
				addText("inspired by", false);
				
			case 20:
				addText("Guselect Productions");
				
			case 24:
				removeText();
				addText("Funky", false);
				
			case 28:
				addText("Moonleap");
				
			case 32:
				endItAll();
		}
	}
	
    function addText(text:String = 'oof', ?animated:Bool = true)
    {
		var lastY:Float = 200; // 130
		if(titleTexts.members.length > 0)
		{
			var lastText = titleTexts.members[titleTexts.members.length - 1];
			lastY = lastText.y + lastText.height;
		}
		
        var newText = new FlxText(0,0,0,text);
		newText.setFormat(Main.gFont, 36, FlxColor.WHITE, CENTER);
		newText.color = FlxColor.fromRGB(170,170,255);
		newText.screenCenter(X);
        titleTexts.add(newText);
		
		newText.y = lastY;
		
		if(animated)
		{
			newText.y = FlxG.height * 1.2;
			FlxTween.tween(newText, {y: lastY}, Conductor.stepCrochet / 1000 * 2, {ease: FlxEase.cubeOut});
		}
    }
	
    function removeText()
    {
        while(titleTexts.members.length > 0)
            titleTexts.remove(titleTexts.members[0], true);
    }
	
	function zoomCam()
	{
		FlxG.camera.zoom += 0.35;
		FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut});
	}
	
	function endItAll()
    {
		zoomCam();
        FlxG.camera.flash(FlxColor.fromRGB(0,0,85), Conductor.crochet / 1000, null, true);
        GlobalMenuState.nextMenu = new MainMenuGroup();
        alive = false;
    }
}