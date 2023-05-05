package gameObjects.userInterface.menu;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class WaitingTxt extends FlxText
{
	final mainText:String = "Waiting Input";
	var curFrame:Int = 0;
	
	public function new()
	{
		super(0, 0, 0, mainText, 24);
		setFormat(Main.gFont, 22, FlxColor.fromRGB(173,253,255), CENTER);
		updateFrame();
	}
	
	var waitingCount:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		waitingCount += elapsed * 1.5;
		if(waitingCount > 1)
			updateFrame();
	}
	
	function updateFrame()
	{
		waitingCount = 0;
		curFrame++;
		// maximum is 4 because yes
		if(curFrame > 4)
			curFrame = 1;
		
		text = mainText;
		for(i in 0...curFrame)
			text += '.';
		
		x = (FlxG.width / 2) - (width / 2);
		y = FlxG.height - height - 10;
	}
}