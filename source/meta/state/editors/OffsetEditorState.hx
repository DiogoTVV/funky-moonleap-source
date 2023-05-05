package meta.state.editors;

import sys.io.File;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.*;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import gameObjects.*;
import meta.MusicBeat.MusicBeatState;

using StringTools;

class OffsetEditorState extends MusicBeatState
{
	public static var charName:String;
	// it starts here
	var UI_box:FlxUITabMenu;
	
	public var overlayChar:Character;
	public var character:Character;
	var animText:FlxText;
	
	var curAnimInt:Int = 0;
	var possibleAnims:Array<String> = [];
	
	var camEditor:FlxCamera;
	var camHUD:FlxCamera;
	var camFollow:FlxObject;
	
	override function create()
	{
		super.create();
		FlxG.mouse.visible = true;
		
		// create the editors camera
		camEditor = new FlxCamera();
		FlxG.cameras.reset(camEditor);
		FlxCamera.defaultCameras = [camEditor];
		
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);
		
		// actual stuff
		var gridBG:FlxSprite = FlxGridOverlay.create(40, 40, Math.floor(FlxG.width * 2), Math.floor(FlxG.height * 2), true, FlxColor.fromRGB(127,127,127), FlxColor.fromRGB(96,96,96));
		gridBG.x = (FlxG.width / 2) - (gridBG.width / 2);
		gridBG.y = (FlxG.height / 2) - (gridBG.height / 2);
		add(gridBG);
		
		character = new Character();
		character.adjustPos = false;
		character.setCharacter(350, 0, charName);
		character.setPosition((FlxG.width / 2) - (character.width / 2), (FlxG.height / 2) - (character.height / 2));
		add(character);
		character.specialAnim = true;
		character.specialAnimTimer = Math.NEGATIVE_INFINITY;
		
		overlayChar = new Character(false);
		overlayChar.adjustPos = false;
		overlayChar.setCharacter(character.x, character.y, charName);
		overlayChar.alpha = 0.25;
		overlayChar.visible = false;
		add(overlayChar);
		overlayChar.specialAnim = true;
		overlayChar.specialAnimTimer = Math.NEGATIVE_INFINITY;
		
		possibleAnims = character.animation.getNameList();
		
		// camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
		
		var tabs = [
			{name: 'Settings', label: 'Settings'},
		];
		
		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 200);
		UI_box.x = FlxG.width - UI_box.width - 10;
		UI_box.y = 10;
		UI_box.cameras = [camHUD];
		add(UI_box);
		
		addUI();
		
		playNextAnim();
		overlayChar.playAnim(overlayChar.animation.curAnim.name, true);
	}
	
	function addUI():Void
	{
		animText = new FlxText(10, 10, 1100, "", 24);
		animText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		animText.cameras = [camHUD];
		add(animText);
		
		// just in case
		var helpTxt = new FlxText(0, 10, 1100, "", 18);
		helpTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		helpTxt.cameras = [camHUD];
		helpTxt.text // put here your keybind guides
		= "Arrow Keys - Change Current Offset"
		+ "\nW/S - Switch Between Animations"
		+ "\nSpace - Replay Current Animation\n"
		+ "\nI/J/K/L - Move the Camera Around"
		+ "\nQ/E - Remove/Add Zoom to the Camera\n"
		+ "\nCtrl+S - Save Offsets";
		helpTxt.x = FlxG.width - helpTxt.width - 10;
		helpTxt.y = FlxG.height - helpTxt.height - 10;
		add(helpTxt);
		// actual UI
		var mainY:Int = 15;
		
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = 'Settings';
		
		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var playerDropDown = new FlxUIDropDownMenu(10, mainY + 10, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			charName = characters[Std.parseInt(character)];
			Main.switchState(new OffsetEditorState());
		});
		playerDropDown.selectedLabel = character.curCharacter;
		
		var check_flip = new FlxUICheckBox(10, mainY + 30, null, null, "Flip X", 100);
		check_flip.checked = character.flipX;
		check_flip.callback = function()
		{
			character.flipX = check_flip.checked;
			overlayChar.flipX = check_flip.checked;
		};
		
		// the other one
		var ghostDropDown = new FlxUIDropDownMenu(10 + playerDropDown.width + 10, mainY + 10, FlxUIDropDownMenu.makeStrIdLabelArray(possibleAnims, true), function(character:String)
		{
			overlayChar.playAnim(possibleAnims[Std.parseInt(character)], true);
		});
		ghostDropDown.selectedLabel = character.curCharacter;
		
		var check_ghost = new FlxUICheckBox(ghostDropDown.x, mainY + 30, null, null, "Show Ghost", 100);
		check_ghost.callback = function()
		{
			overlayChar.visible = check_ghost.checked;
		};
		
		var saveButton:FlxButton = new FlxButton(10, mainY + 135, "Save", function()
		{
			saveOffsets();
		});
		
		// yeah
		tab_group.add(saveButton);
		tab_group.add(check_flip);
		tab_group.add(check_ghost);
		// i hate flixels layering system
		tab_group.add(new FlxText(playerDropDown.x, playerDropDown.y - 15, 0, 'Current Character:'));
		tab_group.add(new FlxText(ghostDropDown.x, ghostDropDown.y - 15, 0, 'Ghost Animation:'));
		tab_group.add(playerDropDown);
		tab_group.add(ghostDropDown);
		
		// adding stuff
		UI_box.addGroup(tab_group);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(controls.BACK)
			Main.switchState(new PlayState());
		
		var pControl = FlxG.keys.justPressed;
		// changes animation if CTRL inst pressed
		if(pControl.S)
		{
			if(FlxG.keys.pressed.CONTROL)
				saveOffsets();
			else
				playNextAnim(-1);
		}
		if(pControl.W)
			playNextAnim(1);
		if(pControl.SPACE)
			playNextAnim();
			
		if(pControl.LEFT)
			changeOffset(1);
		if(pControl.RIGHT)
			changeOffset(-1);
		if(pControl.UP)
			changeOffset(0, 1);
		if(pControl.DOWN)
			changeOffset(0, -1);
		
		// camera stuff
		if(FlxG.keys.pressed.Q)
			addCamZoom(-0.005);
		if(FlxG.keys.pressed.E)
			addCamZoom(0.005);
		
		if(FlxG.mouse.wheel != 0)
			addCamZoom(FlxG.mouse.wheel * 0.05);
			
		if(FlxG.keys.pressed.J)
			addCamPos(-1);
		if(FlxG.keys.pressed.L)
			addCamPos(1);
		if(FlxG.keys.pressed.I)
			addCamPos(0, -1);
		if(FlxG.keys.pressed.K)
			addCamPos(0, 1);
			
		FlxG.camera.follow(camFollow, LOCKON, 1);
		camEditor.zoom = FlxMath.lerp(camEditor.zoom, camZoom, 0.15);
		if(camZoom < 0.1)
			camZoom = 0.1;
	}
	
	function changeOffset(changeX:Int = 0, changeY:Int = 0)
	{
		var curAnim:String = possibleAnims[curAnimInt];
		var curOverlay:String = overlayChar.animation.curAnim.name;
		// changing the offsets
		var mult:Int = (FlxG.keys.pressed.SHIFT) ? 10 : 1;
		var newPos:Array<Float> = [character.offset.x + (changeX * mult), character.offset.y + (changeY * mult)];
		// saving the offsets
		character.addOffset(curAnim, newPos[0], newPos[1]);
		character.playAnim(curAnim, true);
		// same but for overlay
		overlayChar.addOffset(curAnim, newPos[0], newPos[1]);
		if(curOverlay == curAnim)
			overlayChar.playAnim(curOverlay, true);
		
		updateText();
	}
	
	// plays the next animation (or the current one if change is set to 0)
	function playNextAnim(change:Int = 0)
	{
		curAnimInt += change;
		if(curAnimInt < 0)
			curAnimInt = possibleAnims.length - 1;
		if(curAnimInt >= possibleAnims.length)
			curAnimInt = 0;
			
		character.playAnim(possibleAnims[curAnimInt], true);
		
		updateText();
	}
	
	function updateText()
	{
		animText.text = '';
		for(anim => offsets in character.animOffsets)
		{
			if(anim != '')
			{
				animText.text += anim;
				animText.text += ' ${offsets[0]}';
				animText.text += ' ${offsets[1]}\n';
			}
		}
		// sad face :(
		if(animText.text == '')
			animText.text += 'No Offsets Found!!';
		
		animText.y = FlxG.height - animText.height - 10;
	}
	
	var camZoom:Float = 1;
	function addCamZoom(change:Float)
	{
		var mult:Int = (FlxG.keys.pressed.SHIFT) ? 3 : 1;
		
		camZoom += change * mult;
	}
	
	function addCamPos(changeX:Float = 0, changeY:Float = 0)
	{
		var mult:Int = (FlxG.keys.pressed.SHIFT) ? 4 : 2;
		camFollow.x += changeX * mult;
		camFollow.y += changeY * mult;
	}
	
	// IT WORKS!11!!
	function saveOffsets()
	{
		// dont try to save without any offsets you jackass
		var canSave:Bool = (!animText.text.startsWith('No Offsets Found!!'));
		var funnyText:String = 'SAVED SUCCESSFULLY';
	
		if(canSave)
		{
			var pathFile:String = Paths.txt('images/characters/offsets/${CoolUtil.spaceToDash(character.curCharacter)}');
			File.write(pathFile, false);
			
			var output = File.append(pathFile, false);
			output.writeString(animText.text);
			output.close();
		}
		else
		{
			funnyText = 'ERROR NO OFFSETS FOUND';
		}
		
		// YOU SAVED!!!11!!1!
		var savedText = new FlxText(0, 0, 0, funnyText.toUpperCase() + '!!', 24);
		savedText.setFormat(Paths.font("vcr.ttf"), 36, canSave ? FlxColor.LIME : FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		savedText.cameras = [camHUD];
		add(savedText);
		// funny animation
		savedText.x = (FlxG.width / 2) - (savedText.width / 2);
		savedText.y = FlxG.height - savedText.height - 10;
		FlxTween.tween(savedText, {y: savedText.y - 50}, 2);
		FlxTween.tween(savedText, {alpha: 0}, 0.3, {startDelay: FlxG.random.float(0.5, 2), // 1
			onComplete: function(twn:FlxTween) {
				savedText.destroy(); // avoid memory leaking
			}
		});
	}
}