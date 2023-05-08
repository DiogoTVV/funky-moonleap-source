package meta.data;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameObjects.userInterface.notes.*;
import meta.data.Section.SwagSection;
import meta.data.Song.SwagSong;
import meta.state.PlayState;
import meta.state.editors.ChartingState;

/**
	This is the chartloader class. it loads in charts, but also exports charts, the chart parameters are based on the type of chart, 
	say the base game type loads the base game's charts, the forever chart type loads a custom forever structure chart with custom features,
	and so on. This class will handle both saving and loading of charts with useful features and scripts that will make things much easier
	to handle and load, as well as much more modular!
**/
class ChartLoader
{
	// hopefully this makes it easier for people to load and save chart features and such, y'know the deal lol
	public static function generateChartType(songData:SwagSong, ?typeOfChart:String = "FNF"):Array<Note>
	{
		var unspawnNotes:Array<Note> = [];
		//var noteData:Array<SwagSection> = songData.notes;
		
		switch (typeOfChart)
		{
			default:
				// load fnf style charts (PRE 2.8) but with a few tweaks
				var daSection:Int = 0; // each section lol
				
				// bpm change stuff for sustain notes
				var noteCrochet:Float = Conductor.stepCrochet;
				
				for(section in songData.notes)//noteData)
				{
					for(event in Conductor.bpmChangeMap)
						if(event.stepTime == (daSection * 16))
						{
							noteCrochet = Conductor.calcStep(event.bpm);
							trace('changed note bpm ${event.bpm}');
						}
					
					for (songNotes in section.sectionNotes)
					{
						/* - late || + early */
						var daStrumTime:Float = songNotes[0] - SaveData.trueSettings.get('Offset');
						var daNoteData:Int = Std.int(songNotes[1] % 4);
						var daNoteType:String = 'none';
						// very stupid but I'm lazy
						if (songNotes.length > 2)
							daNoteType = songNotes[3];
						
						// check the base section
						var gottaHitNote:Bool = section.mustHitSection;
						// if the note is on the other side, flip the base section of the note
						if (songNotes[1] > 3)
							gottaHitNote = !section.mustHitSection;
						
						// define the note that comes before (previous note)
						var oldNote:Note = null;
						if (unspawnNotes.length > 0) // if it exists, that is
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						
						// create the new note
						var swagNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, daNoteData, daNoteType, 0);
						
						// set the note's length (sustain note)
						swagNote.sustainLength = songNotes[2];
						//swagNote.scrollFactor.set();
						// push the note to the array we'll push later to the playstate
						unspawnNotes.push(swagNote);
						
						// STOP POSTING ABOUT AMONG US
						// basically said push the sustain notes to the array respectively
						var susLength:Float = swagNote.sustainLength / noteCrochet;
						// sus amogus
						for (susNote in 0...Math.floor(susLength))
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
							var sustainNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier,
								daStrumTime + (noteCrochet * susNote) + noteCrochet, daNoteData, daNoteType, 0, true, oldNote);
							//sustainNote.scrollFactor.set();
							
							unspawnNotes.push(sustainNote);
							sustainNote.mustPress = gottaHitNote;
						}
						
						// oh and set the note's must hit section
						swagNote.mustPress = gottaHitNote;
					}
					daSection++;
				}
				
				var noteCount:Int = 0;
				for(note in unspawnNotes)
					if(!note.isSustainNote && note.mustPress)
						noteCount++;
				
				trace('${songData.song} got $noteCount notes lol');
				
			/*
				This is basically the end of this section, of course, it loops through all of the notes it has to,
				But any optimisations and such like the ones sammu is working on won't be handled here, I want to keep this code as
				close to the original as possible with a few tweaks and optimisations because I want to go for the abilities to 
				load charts from the base game, export charts to the base game, and generally handle everything with an accuracy similar to that
				of the main game so it feels like loading things in works well.
			*/
			case 'forever':
				/*
					That being said, however, we also have forever charts, which are complete restructures with new custom features and such.
					Will be useful for projects later on, and it will give you more control over things you can do with the chart and with the game.
					I'll also make it really easy to convert charts, you'll just have to load them in and pick an export option! If you want to play
					songs made in forever engine with the base game then you can do that too.
				*/
		}
		
		return unspawnNotes;
	}
}
