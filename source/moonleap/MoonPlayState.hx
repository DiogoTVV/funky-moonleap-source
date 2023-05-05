package moonleap;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxCollision;
import moonleap.data.*;
import moonleap.data.Level.LevelData;
import moonleap.gameObjects.*;
import meta.MusicBeat.MusicBeatState;
import meta.state.menus.*;

class MoonPlayState extends MusicBeatState
{
	public var luano:Luano;
	public var background:Background;
	public var blocks:FlxTypedGroup<Block>;
	
	public static var LEVEL:Level;
	
	override function create()
	{
		super.create();
		if(LEVEL == null)
			LEVEL = Level.loadJson('test');
		
		background = new Background();
		background.updateBackground(LEVEL.data.name, true);
		add(background);
		
		blocks = new FlxTypedGroup<Block>();
		add(blocks);
		loadTheBlocks();
		
		luano = new Luano();
		luano.setPosition(LEVEL.data.luanoPos[0], LEVEL.data.luanoPos[1] + (16 * 4) - luano.height - 2);
		//luano.y -= 16;
		add(luano);
	}
	
	function loadTheBlocks()
	{
		for(i in 0...LEVEL.data.blockData.length)
		{
			var dataBlock:Array<Dynamic> = LEVEL.data.blockData[i];
			
			var newBlock = new Block(dataBlock[0][0], dataBlock[0][1]);
			newBlock.reloadBlock(dataBlock[1]);
			blocks.add(newBlock);
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(controls.BACK)
			Main.switchState(new GlobalMenuState());
		
		luanoControls(elapsed);
	}
	
	// separate function so i can disable it when luano dies
	public function luanoControls(elapsed:Float)
	{
		luano.move = (controls.UI_LEFT ? -1 : controls.UI_RIGHT ? 1 : 0);
		
		luano.hspeed = 300 * luano.move;
		luano.vspeed += 400 * elapsed;
		
		for(rawBlock in blocks.members)
		{
			var block:FlxSprite = rawBlock.collBox;
			
			switch(rawBlock.blockType)
			{
				default:
					for(i in 0...2)
					{
						var x:Float = luano.collBox.x;
						var y:Float = luano.collBox.y;
						
						if(i == 1)
						{
							x += luano.collBox.width;
							y += luano.collBox.height;
						}
						
						// horizontal stuff
						if(collides(x + luano.hspeed * elapsed, y, block))
						{
							if(luano.hspeed > 0)
								luano.hspeed = Math.abs(x - block.x) * 1;
							else
								luano.hspeed = Math.abs(x + block.width - block.x);
						}
						
						// jump stuff
						if(collides(x, y + luano.vspeed * elapsed, block))
						{
							if(luano.vspeed > 0)
								luano.vspeed = Math.abs(y - block.y);
							else
								luano.vspeed = Math.abs(y + block.height - block.y);
						}
						
						// making sure its rounded to 0
						if(Math.abs(luano.hspeed) <= 1)
							luano.hspeed = 0;
						if(Math.abs(luano.vspeed) <= 1)
							luano.vspeed = 0;
					}
			}
		}
		
		luano.x += luano.hspeed * elapsed;
		luano.y += luano.vspeed * elapsed;
		
		if(FlxG.keys.justPressed.SPACE)
		{
			luano.isDay = !luano.isDay;
			luano.vspeed = -300;
			luano.playAnim('jump', true);
		}
		
		if(luano.vspeed == 0)
		{
			if(luano.move == 0)
				luano.playAnim('idle');
			else
				luano.playAnim('walk');
		}
		else if(luano.vspeed > 0)
		{
			// if he falls without jumping
			luano.playAnim('jump');
			luano.luano.animation.curAnim.curFrame = 2;
		}
	}
	
	function sign(value:Float):Int
		return ((value > 0) ? 1 : (value < 0) ? -1 : 0);
	
	public function collides(PointX:Float, PointY:Float, Object:FlxSprite)
		return FlxCollision.pixelPerfectPointCheck(Math.floor(PointX), Math.floor(PointY), Object, 0);
}