package states;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Promise;
import cutscenes.DialogueBoxPsych;
import flixel.FlxCamera;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import lime.app.Application;
import flixel.util.FlxSave;
#if windows
import Sys;
import sys.FileSystem;
#end
class WelcomeToPain extends MusicBeatState
{
	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;
	public var camMESSAGE:FlxCamera;
	var camfilters:Array<BitmapFilter> = [];
	var ch = 2 / 1000;
	public static var itsme:Bool = true;
	public var save:FlxSave = new FlxSave();
	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		camMESSAGE = new FlxCamera();
		camMESSAGE.bgColor.alpha = 0;
		FlxG.cameras.add(camMESSAGE);
		super.create();
		camMESSAGE.setFilters(camfilters);
		camMESSAGE.filtersEnabled = true;	
		camfilters.push(shaders.ShadersHandler.chromaticAberration);
		FlxG.sound.playMusic(Paths.music("WELCOME"),0);
		FlxG.sound.playMusic(Paths.music("hello"),1);
		var daStatic:FlxSprite = new FlxSprite(0, 0);
		daStatic.frames = Paths.getSparrowAtlas('static', 'pain');
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.screenCenter();
		daStatic.cameras = [camMESSAGE];
		daStatic.animation.addByPrefix('static','lestatic',24, false);
		add(daStatic);
		if (daStatic.alpha != 0)
			daStatic.alpha = 1;
		daStatic.animation.play('static');
		daStatic.animation.finishCallback = function(pog:String)
		{
			daStatic.animation.play('static');
		}
		new FlxTimer().start(4, function(deadTime:FlxTimer)
		{
			startDialogue(dialogueJson);
		});
		
	}

	override public function update(elapsed:Float)
	{
		ch = FlxG.random.int(1,5) / 1000;
		ch = FlxG.random.int(1,5) / 1000;
		shaders.ShadersHandler.setChrome(ch);
		super.update(elapsed);
		var file:String = Paths.json('secret/secretdialogue'); // Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file))
		{
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}
	}
	var dialogueCount:Int = 0;

	public var psychDialogue:DialogueBoxPsych;
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if (psychDialogue != null)
			return;

		if (dialogueFile.dialogue.length > 0)
		{
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			psychDialogue.finishThing = function()
			{
				Application.current.window.alert("Null Object Reference");
				ClientPrefs.data.gotit = true;
				MusicBeatState.switchState(new states.CacheState());
				psychDialogue = null;
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camMESSAGE];
			add(psychDialogue);
		}
		else
		{
			FlxG.log.warn('Your dialogue file is badly formatted!');
			MusicBeatState.switchState(new TitleState());
		}
	}
	function startNextDialogue()
	{
		dialogueCount++;
	}

	function skipDialogue()
	{
		//callOnLuas('onSkipDialogue', [dialogueCount]);
	}
	
}