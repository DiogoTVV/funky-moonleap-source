package events;

import flixel.FlxSprite;
import gameObjects.Character;

class LuanoDevlogData
{
	// DEVLOG !!
	public static var devOffset:Array<Int> = [0, 0, 0];
	
	public static function update(dadOpponent:Character, boyfriend:Character)
	{
		var dadAnim = dadOpponent.animation.curAnim;
		switch(dadAnim.name)
		{
			case "danceLeft":
				switch(dadAnim.curFrame)
				{
					case 0|1: devOffset = [473,306,-9];
					case 2|3: devOffset = [486,308,-7];
					case 4|5: devOffset = [496,311,-2];
					case 6|7: devOffset = [504,309,0];
				}
			case "danceRight" | "idle": // uhh
				switch(dadAnim.curFrame)
				{
					case 0|1: devOffset = [548,356,9];
					case 2|3: devOffset = [542,348,7];
					case 4|5: devOffset = [508,315,2];
					case 6|7: devOffset = [504,309,0];
				}
			case "singLEFT":
				switch(dadAnim.curFrame)
				{
					case 0|1: devOffset = [412,274,-12];
					case 2|3: devOffset = [425,277,-10];
				}
			case "singDOWN":
				switch(dadAnim.curFrame)
				{
					case 0|1: devOffset = [564,418,16];
					case 2|3: devOffset = [558,406,13];
				}
			case "singUP":
				switch(dadAnim.curFrame)
				{
					case 0|1: devOffset = [418,246,-20];
					case 2|3: devOffset = [440,259,-16];
				}
			case "singRIGHT":
				switch(dadAnim.curFrame)
				{
					case 0|1: devOffset = [538,344,-13];
					case 2|3: devOffset = [536,336,-7];
				}
		}
		
		boyfriend.x = dadOpponent.x + devOffset[0];
		boyfriend.y = dadOpponent.y + devOffset[1];
		boyfriend.angle = devOffset[2];
	}
}