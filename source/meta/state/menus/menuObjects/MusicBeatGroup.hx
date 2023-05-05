package meta.state.menus.menuObjects;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import meta.data.PlayerSettings;

/*
*	just a FlxTypedGroup with step/beat hit functions and controls
*/
class MusicBeatGroup extends FlxTypedGroup<FlxBasic>
{
	public var groupName:String = 'none';
	
	private var controls(get, never):Controls;
	
	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
	
	public function new()
		super();
	
	// funny beat stuff if you want to use it i guess
	public function stepHit(curStep:Int = 0) {}
	public function beatHit(curBeat:Int = 0) {}
}