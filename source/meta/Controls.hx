package meta;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
#if mobile
import mobile.flixel.FlxButton;
import mobile.flixel.FlxHitbox;
import mobile.flixel.FlxVirtualPad;
#end

enum abstract Action(String) to String from String
{
	var UI_UP = "ui_up";
	var UI_LEFT = "ui_left";
	var UI_RIGHT = "ui_right";
	var UI_DOWN = "ui_down";
	var UI_UP_P = "ui_up-press";
	var UI_LEFT_P = "ui_left-press";
	var UI_RIGHT_P = "ui_right-press";
	var UI_DOWN_P = "ui_down-press";
	var UI_UP_R = "ui_up-release";
	var UI_LEFT_R = "ui_left-release";
	var UI_RIGHT_R = "ui_right-release";
	var UI_DOWN_R = "ui_down-release";
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
	var ACTION = "action";
}

enum Device
{
	Keys;
	Gamepad(id:Int);
}

/**
 * Since, in many cases multiple actions should use similar keys, we don't want the
 * rebinding UI to list every action. ActionBinders are what the user percieves as
 * an input so, for instance, they can't set jump-press and jump-release to different keys.
 */
enum Control
{
	UP;
	LEFT;
	RIGHT;
	DOWN;
	UI_UP;
	UI_LEFT;
	UI_RIGHT;
	UI_DOWN;
	RESET;
	ACTION;
	ACCEPT;
	BACK;
	PAUSE;
	CHEAT;
}

enum KeyboardScheme
{
	Solo;
	Duo(first:Bool);
	None;
	Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet
{
	var _ui_up = new FlxActionDigital(Action.UI_UP);
	var _ui_left = new FlxActionDigital(Action.UI_LEFT);
	var _ui_right = new FlxActionDigital(Action.UI_RIGHT);
	var _ui_down = new FlxActionDigital(Action.UI_DOWN);
	var _ui_upP = new FlxActionDigital(Action.UI_UP_P);
	var _ui_leftP = new FlxActionDigital(Action.UI_LEFT_P);
	var _ui_rightP = new FlxActionDigital(Action.UI_RIGHT_P);
	var _ui_downP = new FlxActionDigital(Action.UI_DOWN_P);
	var _ui_upR = new FlxActionDigital(Action.UI_UP_R);
	var _ui_leftR = new FlxActionDigital(Action.UI_LEFT_R);
	var _ui_rightR = new FlxActionDigital(Action.UI_RIGHT_R);
	var _ui_downR = new FlxActionDigital(Action.UI_DOWN_R);
	var _up = new FlxActionDigital(Action.UP);
	var _left = new FlxActionDigital(Action.LEFT);
	var _right = new FlxActionDigital(Action.RIGHT);
	var _down = new FlxActionDigital(Action.DOWN);
	var _upP = new FlxActionDigital(Action.UP_P);
	var _leftP = new FlxActionDigital(Action.LEFT_P);
	var _rightP = new FlxActionDigital(Action.RIGHT_P);
	var _downP = new FlxActionDigital(Action.DOWN_P);
	var _upR = new FlxActionDigital(Action.UP_R);
	var _leftR = new FlxActionDigital(Action.LEFT_R);
	var _rightR = new FlxActionDigital(Action.RIGHT_R);
	var _downR = new FlxActionDigital(Action.DOWN_R);
	var _accept = new FlxActionDigital(Action.ACCEPT);
	var _back = new FlxActionDigital(Action.BACK);
	var _pause = new FlxActionDigital(Action.PAUSE);
	var _reset = new FlxActionDigital(Action.RESET);
	var _action = new FlxActionDigital(Action.ACTION);
	var _cheat = new FlxActionDigital(Action.CHEAT);

	#if (haxe >= "4.0.0")
	var byName:Map<String, FlxActionDigital> = [];
	#else
	var byName:Map<String, FlxActionDigital> = new Map<String, FlxActionDigital>();
	#end

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme = KeyboardScheme.None;

	public var UI_UP(get, never):Bool;

	inline function get_UI_UP()
		return _ui_up.check();

	public var UI_LEFT(get, never):Bool;

	inline function get_UI_LEFT()
		return _ui_left.check();

	public var UI_RIGHT(get, never):Bool;

	inline function get_UI_RIGHT()
		return _ui_right.check();

	public var UI_DOWN(get, never):Bool;

	inline function get_UI_DOWN()
		return _ui_down.check();

	public var UI_UP_P(get, never):Bool;

	inline function get_UI_UP_P()
		return _ui_upP.check();

	public var UI_LEFT_P(get, never):Bool;

	inline function get_UI_LEFT_P()
		return _ui_leftP.check();

	public var UI_RIGHT_P(get, never):Bool;

	inline function get_UI_RIGHT_P()
		return _ui_rightP.check();

	public var UI_DOWN_P(get, never):Bool;

	inline function get_UI_DOWN_P()
		return _ui_downP.check();

	public var UI_UP_R(get, never):Bool;

	inline function get_UI_UP_R()
		return _ui_upR.check();

	public var UI_LEFT_R(get, never):Bool;

	inline function get_UI_LEFT_R()
		return _ui_leftR.check();

	public var UI_RIGHT_R(get, never):Bool;

	inline function get_UI_RIGHT_R()
		return _ui_rightR.check();

	public var UI_DOWN_R(get, never):Bool;

	inline function get_UI_DOWN_R()
		return _ui_downR.check();

	public var UP(get, never):Bool;

	inline function get_UP()
		return _up.check();

	public var LEFT(get, never):Bool;

	inline function get_LEFT()
		return _left.check();

	public var RIGHT(get, never):Bool;

	inline function get_RIGHT()
		return _right.check();

	public var DOWN(get, never):Bool;

	inline function get_DOWN()
		return _down.check();

	public var UP_P(get, never):Bool;

	inline function get_UP_P()
		return _upP.check();

	public var LEFT_P(get, never):Bool;

	inline function get_LEFT_P()
		return _leftP.check();

	public var RIGHT_P(get, never):Bool;

	inline function get_RIGHT_P()
		return _rightP.check();

	public var DOWN_P(get, never):Bool;

	inline function get_DOWN_P()
		return _downP.check();

	public var UP_R(get, never):Bool;

	inline function get_UP_R()
		return _upR.check();

	public var LEFT_R(get, never):Bool;

	inline function get_LEFT_R()
		return _leftR.check();

	public var RIGHT_R(get, never):Bool;

	inline function get_RIGHT_R()
		return _rightR.check();

	public var DOWN_R(get, never):Bool;

	inline function get_DOWN_R()
		return _downR.check();

	public var ACCEPT(get, never):Bool;

	inline function get_ACCEPT()
		return _accept.check();

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return _back.check();

	public var PAUSE(get, never):Bool;

	inline function get_PAUSE()
		return _pause.check();

	public var RESET(get, never):Bool;

	inline function get_RESET()
		return _reset.check();
	
	public var ACTION(get, never):Bool;

	inline function get_ACTION()
		return _action.check();

	public var CHEAT(get, never):Bool;

	inline function get_CHEAT()
		return _cheat.check();

	public function new(name, scheme = None)
	{
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_ui_up);
		add(_ui_left);
		add(_ui_right);
		add(_ui_down);
		add(_ui_upP);
		add(_ui_leftP);
		add(_ui_rightP);
		add(_ui_downP);
		add(_ui_upR);
		add(_ui_leftR);
		add(_ui_rightR);
		add(_ui_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_action);
		add(_cheat);

		for (action in digitalActions)
			byName[action.name] = action;

		setKeyboardScheme(scheme, false);
	}

	override function update()
	{
		super.update();
	}

	#if mobile
	public var trackedInputsUI:Array<FlxActionInput> = [];
	public var trackedInputsNOTES:Array<FlxActionInput> = [];

	public function addButtonNOTES(action:FlxActionDigital, button:FlxButton, state:FlxInputState):Void
	{
		if (button == null)
			return;

		var input:FlxActionInputDigitalIFlxInput = new FlxActionInputDigitalIFlxInput(button, state);
		trackedInputsNOTES.push(input);
		action.add(input);
	}

	public function addButtonUI(action:FlxActionDigital, button:FlxButton, state:FlxInputState):Void
	{
		if (button == null)
			return;

		var input:FlxActionInputDigitalIFlxInput = new FlxActionInputDigitalIFlxInput(button, state);
		trackedInputsUI.push(input);
		action.add(input);
	}

	public function setHitBox(Hitbox:FlxHitbox):Void
	{
		if (Hitbox == null)
			return;

		inline forEachBound(Control.NOTE_UP, (action, state) -> addButtonNOTES(action, Hitbox.buttonUp, state));
		inline forEachBound(Control.NOTE_DOWN, (action, state) -> addButtonNOTES(action, Hitbox.buttonDown, state));
		inline forEachBound(Control.NOTE_LEFT, (action, state) -> addButtonNOTES(action, Hitbox.buttonLeft, state));
		inline forEachBound(Control.NOTE_RIGHT, (action, state) -> addButtonNOTES(action, Hitbox.buttonRight, state));
	}

	public function setVirtualPadUI(VirtualPad:FlxVirtualPad, DPad:FlxDPadMode, Action:FlxActionMode):Void
	{
		if (VirtualPad == null)
			return;

		switch (DPad)
		{
			case UP_DOWN:
				inline forEachBound(Control.UI_UP, (action, state) -> addButtonUI(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.UI_DOWN, (action, state) -> addButtonUI(action, VirtualPad.buttonDown, state));
			case LEFT_RIGHT:
				inline forEachBound(Control.UI_LEFT, (action, state) -> addButtonUI(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.UI_RIGHT, (action, state) -> addButtonUI(action, VirtualPad.buttonRight, state));
			case UP_LEFT_RIGHT:
				inline forEachBound(Control.UI_UP, (action, state) -> addButtonUI(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.UI_LEFT, (action, state) -> addButtonUI(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.UI_RIGHT, (action, state) -> addButtonUI(action, VirtualPad.buttonRight, state));
			case LEFT_FULL | RIGHT_FULL:
				inline forEachBound(Control.UI_UP, (action, state) -> addButtonUI(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.UI_DOWN, (action, state) -> addButtonUI(action, VirtualPad.buttonDown, state));
				inline forEachBound(Control.UI_LEFT, (action, state) -> addButtonUI(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.UI_RIGHT, (action, state) -> addButtonUI(action, VirtualPad.buttonRight, state));
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				inline forEachBound(Control.ACCEPT, (action, state) -> addButtonUI(action, VirtualPad.buttonA, state));
			case B:
				inline forEachBound(Control.BACK, (action, state) -> addButtonUI(action, VirtualPad.buttonB, state));
			case A_B | A_B_C | A_B_X_Y | A_B_C_X_Y | A_B_C_X_Y_Z | A_B_C_D_V_X_Y_Z:
				inline forEachBound(Control.ACCEPT, (action, state) -> addButtonUI(action, VirtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> addButtonUI(action, VirtualPad.buttonB, state));
			case NONE: // do nothing
		}
	}

	public function setVirtualPadNOTES(VirtualPad:FlxVirtualPad, DPad:FlxDPadMode, Action:FlxActionMode):Void
	{
		if (VirtualPad == null)
			return;

		switch (DPad)
		{
			case UP_DOWN:
				inline forEachBound(Control.NOTE_UP, (action, state) -> addButtonNOTES(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.NOTE_DOWN, (action, state) -> addButtonNOTES(action, VirtualPad.buttonDown, state));
			case LEFT_RIGHT:
				inline forEachBound(Control.NOTE_LEFT, (action, state) -> addButtonNOTES(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.NOTE_RIGHT, (action, state) -> addButtonNOTES(action, VirtualPad.buttonRight, state));
			case UP_LEFT_RIGHT:
				inline forEachBound(Control.NOTE_UP, (action, state) -> addButtonNOTES(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.NOTE_LEFT, (action, state) -> addButtonNOTES(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.NOTE_RIGHT, (action, state) -> addButtonNOTES(action, VirtualPad.buttonRight, state));
			case LEFT_FULL | RIGHT_FULL:
				inline forEachBound(Control.NOTE_UP, (action, state) -> addButtonNOTES(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.NOTE_DOWN, (action, state) -> addButtonNOTES(action, VirtualPad.buttonDown, state));
				inline forEachBound(Control.NOTE_LEFT, (action, state) -> addButtonNOTES(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.NOTE_RIGHT, (action, state) -> addButtonNOTES(action, VirtualPad.buttonRight, state));
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				inline forEachBound(Control.ACCEPT, (action, state) -> addButtonNOTES(action, VirtualPad.buttonA, state));
			case B:
				inline forEachBound(Control.BACK, (action, state) -> addButtonNOTES(action, VirtualPad.buttonB, state));
			case A_B | A_B_C | A_B_X_Y | A_B_C_X_Y | A_B_C_X_Y_Z | A_B_C_D_V_X_Y_Z:
				inline forEachBound(Control.ACCEPT, (action, state) -> addButtonNOTES(action, VirtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> addButtonNOTES(action, VirtualPad.buttonB, state));
			case NONE: // do nothing
		}
	}

	public function removeVirtualControlsInput(Tinputs:Array<FlxActionInput>):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var x = Tinputs.length;
				while (x-- > 0)
				{
					if (Tinputs[x] == action.inputs[i])
						action.remove(action.inputs[i]);
				}
			}
		}
	}
	#end

	// inline
	public function checkByName(name:Action):Bool
	{
		#if debug
		if (!byName.exists(name))
			throw 'Invalid name: $name';
		#end
		return byName[name].check();
	}

	public function getDialogueName(action:FlxActionDigital):String
	{
		var input = action.inputs[0];
		return switch input.device
		{
			case KEYBOARD: return '[${(input.inputID : FlxKey)}]';
			case GAMEPAD: return '(${(input.inputID : FlxGamepadInputID)})';
			case device: throw 'unhandled device: $device';
		}
	}

	public function getDialogueNameFromToken(token:String):String
	{
		return getDialogueName(getActionFromControl(Control.createByName(token.toUpperCase())));
	}

	public function getActionFromControl(control:Control):FlxActionDigital
	{
		return switch (control)
		{
			case UP: _up;
			case DOWN: _down;
			case LEFT: _left;
			case RIGHT: _right;
			case UI_UP: _ui_up;
			case UI_DOWN: _ui_down;
			case UI_LEFT: _ui_left;
			case UI_RIGHT: _ui_right;
			case ACCEPT: _accept;
			case BACK: _back;
			case PAUSE: _pause;
			case RESET: _reset;
			case ACTION: _action;
			case CHEAT: _cheat;
		}
	}

	static function init():Void
	{
		var actions = new FlxActionManager();
		FlxG.inputs.add(actions);
	}

	/**
	 * Calls a function passing each action bound by the specified control
	 * @param control
	 * @param func
	 * @return ->Void)
	 */
	function forEachBound(control:Control, func:FlxActionDigital->FlxInputState->Void)
	{
		switch (control)
		{
			case UP:
				func(_up, PRESSED);
				func(_upP, JUST_PRESSED);
				func(_upR, JUST_RELEASED);
			case LEFT:
				func(_left, PRESSED);
				func(_leftP, JUST_PRESSED);
				func(_leftR, JUST_RELEASED);
			case RIGHT:
				func(_right, PRESSED);
				func(_rightP, JUST_PRESSED);
				func(_rightR, JUST_RELEASED);
			case DOWN:
				func(_down, PRESSED);
				func(_downP, JUST_PRESSED);
				func(_downR, JUST_RELEASED);
			case UI_UP:
				func(_ui_up, PRESSED);
				func(_ui_upP, JUST_PRESSED);
				func(_ui_upR, JUST_RELEASED);
			case UI_LEFT:
				func(_ui_left, PRESSED);
				func(_ui_leftP, JUST_PRESSED);
				func(_ui_leftR, JUST_RELEASED);
			case UI_RIGHT:
				func(_ui_right, PRESSED);
				func(_ui_rightP, JUST_PRESSED);
				func(_ui_rightR, JUST_RELEASED);
			case UI_DOWN:
				func(_ui_down, PRESSED);
				func(_ui_downP, JUST_PRESSED);
				func(_ui_downR, JUST_RELEASED);
			case ACCEPT:
				func(_accept, JUST_PRESSED);
			case BACK:
				func(_back, JUST_PRESSED);
			case PAUSE:
				func(_pause, JUST_PRESSED);
			case RESET:
				func(_reset, JUST_PRESSED);
			case ACTION:
				func(_action, JUST_PRESSED);
			case CHEAT:
				func(_cheat, JUST_PRESSED);
		}
	}

	public function replaceBinding(control:Control, device:Device, ?toAdd:Int, ?toRemove:Int)
	{
		if (toAdd == toRemove)
			return;

		switch (device)
		{
			case Keys:
				if (toRemove != null)
					unbindKeys(control, [toRemove]);
				if (toAdd != null && toAdd != FlxKey.NONE)
					bindKeys(control, [toAdd]);

			case Gamepad(id):
				if (toRemove != null)
					unbindButtons(control, id, [toRemove]);
				if (toAdd != null && toAdd != FlxKey.NONE)
					bindButtons(control, id, [toAdd]);
		}
	}

	public function copyFrom(controls:Controls, ?device:Device)
	{
		#if (haxe >= "4.0.0")
		for (name => action in controls.byName)
		{
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#else
		for (name in controls.byName.keys())
		{
			var action = controls.byName[name];
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#end

		switch (device)
		{
			case null:
				// add all
				#if (haxe >= "4.0.0")
				for (gamepad in controls.gamepadsAdded)
					if (!gamepadsAdded.contains(gamepad))
						gamepadsAdded.push(gamepad);
				#else
				for (gamepad in controls.gamepadsAdded)
					if (gamepadsAdded.indexOf(gamepad) == -1)
						gamepadsAdded.push(gamepad);
				#end

				mergeKeyboardScheme(controls.keyboardScheme);

			case Gamepad(id):
				gamepadsAdded.push(id);
			case Keys:
				mergeKeyboardScheme(controls.keyboardScheme);
		}
	}

	inline public function copyTo(controls:Controls, ?device:Device)
	{
		controls.copyFrom(this, device);
	}

	function mergeKeyboardScheme(scheme:KeyboardScheme):Void
	{
		if (scheme != None)
		{
			switch (keyboardScheme)
			{
				case None:
					keyboardScheme = scheme;
				default:
					keyboardScheme = Custom;
			}
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	#if !mobile
	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		var copyKeys:Array<FlxKey> = keys.copy();
		for (i in 0...copyKeys.length)
			if(i == NONE)
				copyKeys.remove(i);

		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addKeys(action, copyKeys, state));
		#else
		forEachBound(control, function(action, state) addKeys(action, copyKeys, state));
		#end
	}

	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		var copyKeys:Array<FlxKey> = keys.copy();
		for (i in 0...copyKeys.length)
			if(i == NONE)
				copyKeys.remove(i);

		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeKeys(action, copyKeys));
		#else
		forEachBound(control, function(action, _) removeKeys(action, copyKeys));
		#end
	}
	#else
	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addKeys(action, keys, state));
		#else
		forEachBound(control, function(action, state) addKeys(action, keys, state));
		#end
	}

	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeKeys(action, keys));
		#else
		forEachBound(control, function(action, _) removeKeys(action, keys));
		#end
	}	
	#end

	inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
	{
		for (key in keys)
			if(key != FlxKey.NONE)
				action.addKey(key, state);
	}

	static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true)
	{
		// if (reset)
		removeKeyboard();
		
		// quick way to add keybinds
		function addKeybind(daControl:Control, daKey:String):Void
			return inline bindKeys(daControl, SaveData.gameControls.get(daKey)[0]);
		
		addKeybind(Control.UP, 		'UP');
		addKeybind(Control.DOWN, 	'DOWN');
		addKeybind(Control.LEFT,	'LEFT');
		addKeybind(Control.RIGHT,	'RIGHT');
		addKeybind(Control.UI_UP,	'UI_UP');
		addKeybind(Control.UI_DOWN,	'UI_DOWN');
		addKeybind(Control.UI_LEFT,	'UI_LEFT');
		addKeybind(Control.UI_RIGHT,'UI_RIGHT');
		addKeybind(Control.ACCEPT,	'ACCEPT');
		addKeybind(Control.BACK,	'BACK');
		addKeybind(Control.PAUSE,	'PAUSE');
		addKeybind(Control.RESET,	'RESET');
		addKeybind(Control.ACTION,	'ACTION');
	}

	function removeKeyboard()
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == KEYBOARD)
					action.remove(input);
			}
		}
	}

	public function addGamepad(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
		inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
		inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID))
					action.remove(input);
			}
		}

		gamepadsAdded.remove(deviceID);
	}

	public function addDefaultGamepad(id):Void
	{
		#if !switch
		addGamepadLiteral(id, [
			Control.LEFT 	=> [DPAD_LEFT, 	LEFT_STICK_DIGITAL_LEFT, 	LEFT_TRIGGER],
			Control.DOWN 	=> [DPAD_DOWN, 	LEFT_STICK_DIGITAL_DOWN, 	LEFT_SHOULDER],
			Control.UP 		=> [DPAD_UP,	LEFT_STICK_DIGITAL_UP, 		RIGHT_SHOULDER, Y],
			Control.RIGHT 	=> [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT,	RIGHT_TRIGGER,	B],
			Control.UI_LEFT => [DPAD_LEFT, 	LEFT_STICK_DIGITAL_LEFT],
			Control.UI_DOWN => [DPAD_DOWN, 	LEFT_STICK_DIGITAL_DOWN],
			Control.UI_UP	=> [DPAD_UP, 	LEFT_STICK_DIGITAL_UP],
			Control.UI_RIGHT=> [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			// extra buttons
			Control.ACCEPT 	=> [A, X],
			Control.ACTION 	=> [A, X],
			Control.BACK 	=> [B],
			Control.PAUSE 	=> [START],
			Control.RESET 	=> [FlxGamepadInputID.BACK],
		]);
		#else
		addGamepadLiteral(id, [
			Control.LEFT 	=> [DPAD_LEFT, 	LEFT_STICK_DIGITAL_LEFT],
			Control.DOWN 	=> [DPAD_DOWN, 	LEFT_STICK_DIGITAL_DOWN],
			Control.UP 		=> [DPAD_UP, 	LEFT_STICK_DIGITAL_UP,		X],
			Control.RIGHT 	=> [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT,	A],
			Control.UI_LEFT => [DPAD_LEFT, 	LEFT_STICK_DIGITAL_LEFT],
			Control.UI_DOWN => [DPAD_DOWN, 	LEFT_STICK_DIGITAL_DOWN],
			Control.UI_UP 	=> [DPAD_UP, 	LEFT_STICK_DIGITAL_UP],
			Control.UI_RIGHT=> [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			// Swap A and B // Y and X for switch
			Control.ACCEPT 	=> [B, Y],
			Control.ACTION 	=> [B, Y],
			Control.BACK 	=> [A],
			Control.PAUSE 	=> [START],
			Control.RESET 	=> [FlxGamepadInputID.BACK],
		]);
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindButtons(control:Control, id, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
		#else
		forEachBound(control, function(action, state) addButtons(action, buttons, state, id));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindButtons(control:Control, gamepadID:Int, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
		#else
		forEachBound(control, function(action, _) removeButtons(action, gamepadID, buttons));
		#end
	}

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function getInputsFor(control:Control, device:Device, ?list:Array<Int>):Array<Int>
	{
		if (list == null)
			list = [];

		switch (device)
		{
			case Keys:
				for (input in getActionFromControl(control).inputs)
				{
					if (input.device == KEYBOARD)
						list.push(input.inputID);
				}
			case Gamepad(id):
				for (input in getActionFromControl(control).inputs)
				{
					if (input.deviceID == id)
						list.push(input.inputID);
				}
		}
		return list;
	}

	public function removeDevice(device:Device)
	{
		switch (device)
		{
			case Keys:
				setKeyboardScheme(None);
			case Gamepad(id):
				removeGamepad(id);
		}
	}

	static function isDevice(input:FlxActionInput, device:Device)
	{
		return switch device
		{
			case Keys: input.device == KEYBOARD;
			case Gamepad(id): isGamepad(input, id);
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int)
	{
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}
