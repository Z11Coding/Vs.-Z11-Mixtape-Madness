package states;

import backend.Achievements;
import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Song;
import backend.Section;
import backend.Rating;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.ui.FlxBar;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import haxe.Json;
import psychlua.FunkinLua;
import cutscenes.CutsceneHandler;
import cutscenes.DialogueBoxPsych;
import states.StoryMenuState;
import states.FreeplayState;
import states.editors.ChartingStateOG;
import states.editors.ChartingStatePsych;
import states.editors.CharacterEditorState;
import substates.PauseSubState;
import substates.PauseSubStateLost;
import substates.GameOverSubstate;
#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import objects.VideoSprite;
import objects.Note.EventNote;
import objects.*;
import states.stages.objects.*;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
#end

#if SScript
import tea.SScript;
#end


// Mixtape Stuff
import modchart.ModManager;
import openfl.filters.BitmapFilter;
import backend.STMetaFile.MetadataFile;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import openfl.Lib;
import backend.AIPlayer;
import objects.NoteObject.ObjectType;
import shaders.ShadersHandler;

import yutautil.Anomoly;

/**
 * This is where all the Gameplay stuff happens and is managed
 *
 * here's some useful tips if you are making a mod in source:
 *
 * If you want to add your stage to the game, copy states/stages/Template.hx,
 * and put your stage code there, then, on PlayState, search for
 * "switch (curStage)", and add your stage to that list.
 *
 * If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
 *
 * "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
 * "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
 * "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
 * "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for
**/
 
typedef SpeedEvent =
{
	position:Float, // the y position where the change happens (modManager.getVisPos(songTime))
	startTime:Float, // the song position (conductor.songTime) where the change starts
	songTime:Float, // the song position (conductor.songTime) when the change ends
	?startSpeed:Float, // the starting speed
	speed:Float // speed mult after the change
}

class PlayState extends MusicBeatState
{
	public var modManager:ModManager;

	public static var songCache:Map<SwagSong, Array<Note>> = [];

	var prevNoteData:Int = -1;
	var initialNoteData:Int = -1;
	var caseExecutionCount:Int = FlxG.random.int(-50, 50);
	var currentModifier:Int = -1;

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], // From 0% to 19%
		['Shit', 0.4], // From 20% to 39%
		['Bad', 0.5], // From 40% to 49%
		['Bruh', 0.6], // From 50% to 59%
		['Meh', 0.69], // From 60% to 68%
		['Nice', 0.7], // 69%
		['Good', 0.8], // From 70% to 79%
		['Great', 0.9], // From 80% to 89%
		['Sick!', 1], // From 90% to 99%
		['Perfect!!', 1] // The value on this one isn't used actually, since Perfect is always "1"
	];

	// event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var boyfriendMap2:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap2:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	public var instancesExclude:Array<String> = [];
	#end

	#if LUA_ALLOWED
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#end
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var BF2_X:Float = 770;
	public var BF2_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var DAD2_X:Float = 100;
	public var DAD2_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var boyfriendGroup2:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var dadGroup2:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var stageUI:String = "normal";
	public static var isPixelStage(get, never):Bool;

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel" || stageUI.endsWith("-pixel");

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var CacheMode:Bool = false;
	public static var cachingSongs:Array<String> = [];

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;

	public static var fnfc:Bool = false;
	public static var fnfcData:Dynamic = null;

	public var opponentVocals:FlxSound;
	public var gfVocals:FlxSound;
	public var tracks:Array<FlxSound> = [];

	public var dad:Character = null;

	public static var dad2:Character = null;

	public var gf:Character = null;
	public var boyfriend:Character = null;
	public var bf2:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var curChart:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	public static var strumLine:FlxSprite;

	// Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var opponentStrums2:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;

	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health(default, set):Float = 1;
	public var healthGF:Float = 1;
	public var MaxHP:Float = 2;
	public var combo:Int = 0;
	public var comboOpp:Int = 0;

	public var healthBar:Bar;
	public var healthBar2:Bar;
	public var healthBarGF:Bar;

	var songPercent:Float = 0;

	public var timeBar:Bar;

	public var ratingsData:Array<Rating> = Rating.loadDefault();

	public static var mania:Int = 0;

	private var generatedMusic:Bool = false;

	public var endingSong:Bool = false;
	public var startingSong:Bool = false;

	private var updateTime:Bool = true;

	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	// Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var guitarHeroSustains:Bool = false;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled(default, set) = false;
	public var practiceMode:Bool = false;
	public var chartModifier:String = 'Normal';
	public var convertMania:Int = ClientPrefs.getGameplaySetting('convertMania', 3);
	public var opponentmode:Bool = ClientPrefs.getGameplaySetting('opponentplay', false);

	//Anticheat
	var hadBotplayOn:Bool = false;

	function set_cpuControlled(value)
	{
		cpuControlled = value;

		setOnScripts('botPlay', value);

		/// oughhh
		for (playfield in playfields.members)
		{
			if (playfield.isPlayer)
				playfield.autoPlayed = cpuControlled;
		}

		return value;
	}

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var iconP12:HealthIcon;
	public var iconP22:HealthIcon;
	public var iconGF:HealthIcon;
	public var camHUD:FlxCamera;
	public var camVisual:FlxCamera;
	public var camGame:FlxCamera;
	public var camCredit:FlxCamera;
	public var camOther:FlxCamera;
	public var camDialogue:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Int = 0;
	public var gfBopCombo:Int = 0;
	public var gfBopComboBest:Int = 0;
	public var songHits:Int = 0;
	public var gfHits:Int = 0;
	public var songMisses:Int = 0;
	public var gfMisses:Int = 0;
	public var scoreTxt:FlxText;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;
	var aiText:String;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public static var marvs:Int;
	public static var sicks:Int;
	public static var goods:Int;
	public static var bads:Int;
	public static var shits:Int;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;

	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var boyfriend2CameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var opponent2CameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if DISCORD_ALLOWED
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;

	#if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end

	#if LUA_ALLOWED
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	#end

	public var introSoundsSuffix:String = '';

	// Less laggy controls
	public var keysArray:Array<Dynamic>;

	private var controlArray:Array<String>;

	// aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
	public var bfkilledcheck = false;

	var filters:Array<BitmapFilter> = [];
	var camfilters2:Array<BitmapFilter> = [];
	var ch = 2 / 1000;

	public var shaderUpdates:Array<Float->Void> = [];

	var metadata:MetadataFile;
	var hasMetadataFile:Bool = false;
	var Text:Array<String> = [];
	var whiteBG:FlxSprite;
	var blackOverlay:FlxSprite;
	var blackUnderlay:FlxSprite;

	public var freezeNotes:Bool = false;
	public var sh_r:Float = 600;

	var rotRate:Float;
	var rotRateSh:Float;
	var derp = 20;
	var fly:Bool = false;
	var stageData:StageFile;
	var winX = Lib.application.window.x;
	var winY = Lib.application.window.y;
	var charFade:FlxTween;
	var charFade2:FlxTween;
	var chromCheck:Int = 0;
	var dadT:FlxTrail;
	var bfT:FlxTrail;
	var gfT:FlxTrail;
	var burst:FlxSprite;
	var cutTime = 0;

	public static var threeLanes:Bool = false;

	var hasGlow:Bool = false;
	var strumFocus:Bool = false;

	public static var playAsGF:Bool = false;
	public static var savedTime:Float = 0;
	public static var savedBeat:Int = 0;
	public static var savedStep:Int = 0;

	public var modifitimer:Int = 0;
	public var gimmicksAllowed:Bool = false;
	public var chromOn:Bool = false;
	public var beatchrom:Bool = false;
	public var beatchromfaster:Bool = false;
	public var beatchromfastest:Bool = false;
	public var beatchromslow:Bool = false;

	var abrrmult:Float = 1;
	var defMult:Float = 0.04;

	public var lyrics:FlxText;
	public var lyricsArray:Array<String> = [];

	var daStatic:FlxSprite;
	var daRain:FlxSprite;
	var thunderON:Bool = false;
	var rave:FlxTypedGroup<FlxSprite>;
	var gfScared:Bool = false;

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;

	public var playerField:PlayField;
	public var dadField:PlayField;

	public var notefields = new NotefieldManager();
	public var playfields = new FlxTypedGroup<PlayField>();
	public var allNotes:Array<Note> = []; // all notes

	public var noteHits:Array<Float> = [];
	public var nps:Int = 0;

	var speedChanges:Array<SpeedEvent> = [];

	public var currentSV:SpeedEvent = {
		position: 0,
		startTime: 0,
		songTime: 0,
		speed: 1,
		startSpeed: 1
	};

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	// stores the last judgement object
	public static var lastRatingOpp:FlxSprite;
	// stores the last combo sprite object
	public static var lastComboOpp:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScoreOpp:Array<FlxSprite> = [];

	public var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;
	public var halloweenWhite:BGSprite;
	public var blammedLightsBlack:FlxSprite;

	private var timerExtensions:Array<Float>;

	public var maskedSongLength:Float = -1;

	// things from trials
	var justmissed:Bool = false;
	var notesCentered:Bool = false;
	var circlefuntime:Bool = false;
	var middlecircle:FlxSprite;

	// AI things. You wouldn't get it.
	var AIMode:Bool = false;
	var AIDifficulty:Int = 2;

	// WeedEnd My Beloved
	public var rainIntensity:Float = 0;

	/*function chromaVideo(name:String){
		var video = new hxcodec.VideoSprite(0,0);
		video.scrollFactor.set();
		video.cameras = [camHUD];
		video.shader = new GreenScreenShader();
		video.playVideo(Paths.video(name));
		return video;
	}*/
	public static var Crashed:Bool = false;
	public static var gameplayArea:String = "Story";

	/**
	 * Gets set to true when the PlayState needs to reset (player opted to restart or died).
	 * Gets disabled once resetting happens.
	 */
	public var needsReset:Bool = false;

	/**
	 * Whether the player has dropped below zero health,
	 * and we are just waiting for an animation to play out before transitioning.
	 */
	public var isPlayerDying:Bool = false;

	var notesVwoosh:FlxTypedGroup<Note>;

    //Song Credits
	public var introStageBar:FlxSprite;
	public var introStageText:FlxTypedGroup<FlxText>;
	public var introStageStuff:FlxTypedGroup<Dynamic>;
	var credText:Array<String> = [];
	var songTxt:FlxText;
	var artistTxt:FlxText;
	var charterTxt:FlxText;
	var modTxt:FlxText;

	override public function create()
	{
		try
		{
			if ((PlayState.SONG == null || PlayState.storyPlaylist.length == 0)
				&& (PlayState.SONG == null && PlayState.storyPlaylist.length == 0)
				&& PlayState.cachingSongs.length == 0)
			{
				throw "Both PlayState.SONG and PlayState.storyPlaylist are null or empty";
			}
			else if (PlayState.SONG == null && PlayState.storyPlaylist.length > 0)
			{
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-' + Difficulty.list[PlayState.storyDifficulty],
					PlayState.storyPlaylist[0].toLowerCase());
			}
			else if (PlayState.SONG == null && PlayState.cachingSongs.length > 0 && CacheMode)
			{
				var index:Int = 0;
				while (index < PlayState.cachingSongs.length && PlayState.SONG == null)
				{
					try
					{
						PlayState.SONG = Song.parseJSONshit(PlayState.cachingSongs[index]);
					}
					catch (e:Dynamic)
					{
						trace("Error parsing song:", e + "\n" + PlayState.cachingSongs[index]);
						index++;
						continue;
					}
					index++;
				}
			}
		}
		catch (e:Dynamic)
		{
			trace("Error: PlayState was initialized with no, or invalid data");
			throw e;
		}

		if (!CacheMode)
			PlayState.cachingSongs = [];

		MemoryUtil.clearMajor();

		if (!CacheMode)
		{
			if (SONG.song == 'Fangirl Frenzy' && !seenCutscene)
			{
				trace('Loaded Fangirl Frenzy Cutscene!');
				startCallback = fanfrenOpenPrep;	
				endCallback = endSong;
			}
			else if (SONG.song == 'Funky Fanta' && !seenCutscene)
			{
				trace('Loaded Funky Fanta Cutscene!');
				startCallback = ffOpenPrep;
				endCallback = endSong;
			}
			else
			{
				trace('Loaded Normal Countdown!');
				startCallback = startCountdown;
				endCallback = endSong;
			}
		}

		// for lua
		instance = this;

		// Check if in CacheMode and cachingSongs array is not empty
		if (CacheMode && cachingSongs.length > 0)
		{
			// Change the SONG to the next one in the cachingSongs array

			// Assuming cachingSongs is an array of file paths
			var filePath:String = cachingSongs.shift();
			var fileContent:String = File.getContent(filePath);

			SONG = Song.parseJSON(fileContent);
			// Call the generateSong function again
			trace("Generating song from cache: " + filePath);
			try
			{
				generateSong(SONG.song);
			}
			catch (e:Dynamic)
			{
				// Handle the exception here
				FlxG.resetState();
				trace("Major Error while generating... Skipping!");
			}

			trace("Generating song from cache: " + cachingSongs[0]);
			trace("Preparing...");

			var counter:Int = 0;
			while (!generatedMusic)
			{
				trace("Generated notes: " + unspawnNotes.length);
				counter++;
				if (counter >= 400)
				{
					FlxG.resetState();
					break;
				}
			}

			// Store unspawned notes in the map
			songCache.set(SONG, unspawnNotes);
			try {trace("Song cached: " + SONG.song);} catch(e) {}
			trace("Unspawned notes: " + unspawnNotes.length);
			trace("Caching next song...");

			// Reset the state
			FlxG.resetState();
		}
		else if (CacheMode && cachingSongs.length == 0)
		{
			// Move to a new What state (because it's fucking called that for some reason-)
			CacheMode = false;
			FlxG.switchState(new What());
		}

		setOnScripts("modManager", modManager);
		setOnScripts("initPlayfield", initPlayfield);
		setOnScripts("newPlayField", newPlayfield);

		Cursor.hide();

		debugKeysChart = ClientPrefs.keyBinds.get('debug_1').copy();
		debugKeysCharacter = ClientPrefs.keyBinds.get('debug_2').copy();

		PauseSubState.songName = null; // Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = backend.Keybinds.fill();

		controlArray = ['NOTE_LEFT', 'NOTE_DOWN', 'NOTE_UP', 'NOTE_RIGHT'];

		speedChanges.push({
			position: 0,
			songTime: 0,
			startTime: 0,
			startSpeed: 1,
			speed: 1,
		});

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// if (PlayState.mania == -1 && SONG.startMania == -1) {
		// 	mania = 3;
		// 	SONG.startMania = 3;
		// }

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray[mania].length)
		{
			keysPressed.push(false);
		}

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);
		chartModifier = CacheMode ? "Normal" : (ClientPrefs.getGameplaySetting('chartModifier', 'Normal') ?? "Normal");
		trace("Chart Modifier: " + chartModifier);
		playAsGF = ClientPrefs.getGameplaySetting('gfMode', false); // dont do it to yourself its not worth it
		AIMode = ClientPrefs.getGameplaySetting('aiMode', false);
		AIDifficulty = ClientPrefs.getGameplaySetting('aiDifficulty', 1);
		opponentmode = ClientPrefs.getGameplaySetting('opponentplay', false);
		gimmicksAllowed = ClientPrefs.data.gimmicksAllowed;
		guitarHeroSustains = ClientPrefs.data.guitarHeroSustains;

		AIPlayer.active = AIMode;
		AIPlayer.diff = AIDifficulty;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camVisual = new FlxCamera();
		camCredit = new FlxCamera();
		camOther = new FlxCamera();
		camDialogue = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camVisual.bgColor.alpha = 0;
		camCredit.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camDialogue.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camVisual, false);
		FlxG.cameras.add(camCredit, false);
		FlxG.cameras.add(camDialogue, false);
		FlxG.cameras.add(camOther, false);
		if (ClientPrefs.data.starHidden)
			camHUD.alpha = 0;

		if (ClientPrefs.data.shaders)
		{
			camGame.setFilters(camfilters2);
			camGame.filtersEnabled = true;
			camHUD.setFilters(filters);
			camHUD.filtersEnabled = true;
			camVisual.setFilters(filters);
			camVisual.filtersEnabled = true;
			camOther.setFilters(filters);
			camOther.filtersEnabled = true;
			camDialogue.setFilters(filters);
			camDialogue.filtersEnabled = true;
			filters.push(shaders.ShadersHandler.chromaticAberration);
			camfilters2.push(shaders.ShadersHandler.chromaticAberration);
			// camfilters2.push(shaders.ShadersHandler.rainShader);
			/*filters.push(ShadersHandler.fuckingTriangle); //this shader has a cool feature for all the wrong reasons >:)
				camfilters.push(ShadersHandler.fuckingTriangle); */
		}

		camHUD.filtersEnabled = true;
		camGame.filtersEnabled = true;

		rave = new FlxTypedGroup<FlxSprite>();
		// add(rave);
		for (i in 0...8)
		{
			var light2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('rave/ravelight' + i, 'rave'));
			light2.scrollFactor.set(0, 0);
			light2.cameras = [camHUD];
			light2.visible = false;
			light2.updateHitbox();
			light2.antialiasing = true;
			rave.add(light2);
		}

		middlecircle = new FlxSprite(0, 0);
		middlecircle.loadGraphic(Paths.image('noteskins/center_receptor'));
		middlecircle.updateHitbox();
		middlecircle.screenCenter();
		middlecircle.antialiasing = true;
		middlecircle.scrollFactor.set(0, 0);
		middlecircle.active = false;
		middlecircle.alpha = 0;

		try
		{
			metadata = cast Json.parse(Assets.getText(Paths.json(Paths.formatToSongPath(SONG.song.toLowerCase()) + '/meta')));
			trace(Assets.getText(Paths.json(Paths.formatToSongPath(SONG.song.toLowerCase()) + '/meta')));
			trace(metadata);
			hasMetadataFile = true;
			trace("Found metadata for " + SONG.song.toLowerCase());
		}
		catch (e)
		{
			try {trace("No metadata for " + SONG.song.toLowerCase());} catch(e) {trace("No metadata found. No song either apparently.");}
		}

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG != null)
		{
		if (chartModifier == "4K Only")
			mania = 3;
		else if (chartModifier == "ManiaConverter")
			mania = convertMania;
		else
			mania = SONG.mania;

		if (mania > Note.maxMania)
			mania = Note.defaultMania;

		if (!CacheMode)
		{
			if (SONG == null)
				SONG = Song.loadFromJson('tutorial');

			Conductor.mapBPMChanges(SONG);
			Conductor.changeBPM(SONG.bpm);
		}
		}

		#if DISCORD_ALLOWED
		if (WeekData.getCurrentWeek() != null)
		{
			// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
			storyDifficultyText = Difficulty.getString();

			if (isStoryMode)
				try {
				detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
				} catch (e) { detailsText = "Story Mode: ???"; }
			else
				detailsText = "Freeplay";
			// String for when the game is paused
			detailsPausedText = "Paused - " + detailsText;
			#end
		}

		GameOverSubstate.resetVariables();
		songName = Paths.formatToSongPath(SONG.song);
		if (SONG.stage == null || SONG.stage.length < 1)
		{
			SONG.stage = StageData.vanillaSongStage(songName);
		}
		curStage = SONG.stage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = StageData.dummy();
		}

		defaultCamZoom = stageData.defaultZoom;

		stageUI = "normal";
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			stageUI = stageData.stageUI;
		else
		{
			if (stageData.isPixelStage)
				stageUI = "pixel";
		}

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		if (stageData.boyfriend2 != null)
		{
			BF2_X = stageData.boyfriend2[0];
			BF2_Y = stageData.boyfriend2[1];
		}
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		if (stageData.opponent2 != null)
		{
			DAD2_X = stageData.opponent2[0];
			DAD2_Y = stageData.opponent2[1];
		}

		if (stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null) // Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		boyfriend2CameraOffset = stageData.camera_boyfriend2;
		if (boyfriend2CameraOffset == null)
			boyfriend2CameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		opponent2CameraOffset = stageData.camera_opponent2;
		if (opponent2CameraOffset == null)
			opponent2CameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if (girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		boyfriendGroup2 = new FlxSpriteGroup(BF2_X, BF2_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		dadGroup2 = new FlxSpriteGroup(DAD2_X, DAD2_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage':
				new states.stages.StageWeek1(); // Week 1
			case 'spooky':
				new states.stages.Spooky(); // Week 2
			case 'philly':
				new states.stages.Philly(); // Week 3
			case 'limo':
				new states.stages.Limo(); // Week 4
			case 'mall':
				new states.stages.Mall(); // Week 5 - Cocoa, Eggnog
			case 'mallEvil':
				new states.stages.MallEvil(); // Week 5 - Winter Horrorland
			case 'school':
				new states.stages.School(); // Week 6 - Senpai, Roses
			case 'schoolEvil':
				new states.stages.SchoolEvil(); // Week 6 - Thorns
			case 'tank':
				new states.stages.Tank(); // Week 7 - Ugh, Guns, Stress
		}

		whiteBG = new FlxSprite(-480, -480).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
		whiteBG.updateHitbox();
		whiteBG.antialiasing = true;
		whiteBG.scrollFactor.set(0, 0);
		whiteBG.active = false;
		// whiteBG.cameras;
		whiteBG.alpha = 0.0;

		blackOverlay = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		blackOverlay.updateHitbox();
		blackOverlay.screenCenter();
		blackOverlay.antialiasing = true;
		blackOverlay.scrollFactor.set(0, 0);
		blackOverlay.active = false;
		blackOverlay.alpha = 0;
		blackOverlay.setGraphicSize(Std.int(blackOverlay.width * 10.5));

		blackUnderlay = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		blackUnderlay.updateHitbox();
		blackUnderlay.screenCenter();
		blackUnderlay.antialiasing = true;
		blackUnderlay.scrollFactor.set(0, 0);
		blackUnderlay.active = false;
		blackUnderlay.alpha = 0;
		blackUnderlay.setGraphicSize(Std.int(blackUnderlay.width * 10.5));

		if (isPixelStage)
		{
			introSoundsSuffix = '-pixel';
		}

		if(stageData.objects != null && stageData.objects.length > 0)
		{
			var list:Map<String, FlxSprite> = StageData.addObjectsToState(stageData.objects, !stageData.hide_girlfriend ? gfGroup : null, dadGroup, boyfriendGroup, dadGroup2, boyfriendGroup2, this);
			for (key => spr in list)
				if(!StageData.reservedNames.contains(key))
					variables.set(key, spr);
		}
		else
		{
			add(gfGroup); // Needed for blammed lights
			add(dadGroup2);
			add(boyfriendGroup2);
			add(dadGroup);
			add(boyfriendGroup);
		}

		if (curStage != 'spooky') // to avoid dups
		{
			halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
			halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
			halloweenWhite.alpha = 0;
			halloweenWhite.blend = ADD;
			add(halloweenWhite);
		}

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		luaDebugGroup = new FlxTypedGroup<psychlua.DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if (file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if (file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		// STAGE SCRIPTS
		#if LUA_ALLOWED
		startLuasNamed('stages/' + curStage + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		startHScriptsNamed('stages/' + curStage + '.hx');
		#end

		var gfVersion:String = SONG.gfVersion;
		if (gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}
			switch (Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; // Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			if (SONG.gfVersion == null || SONG.gfVersion.length < 1)
				SONG.gfVersion = 'gf'; // Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterScripts(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad);
		dadGroup.add(dad);
		startCharacterScripts(dad.curCharacter);

		if (SONG.player4 != null)
		{
			dad2 = new Character(0, 0, SONG.player4);
			startCharacterPos(dad2, true);
			dadGroup2.add(dad2);
			startCharacterScripts(dad2.curCharacter);
			threeLanes = true;
		}
		else
		{
			dad2 = null;
		}

		boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterScripts(boyfriend.curCharacter);

		if (SONG.player5 != null)
		{
			bf2 = new Character(0, 0, SONG.player5, true);
			startCharacterPos(bf2, true);
			boyfriendGroup2.add(bf2);
			startCharacterScripts(bf2.curCharacter);
		}
		else
		{
			bf2 = null;
		}

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if (gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if ((WeekData.getWeekFileName() != 'lost' || WeekData.getWeekFileName() != 'beat')
			&& !stageData.hide_girlfriend) // GF needs to still be there
		{
			if (dad.curCharacter.startsWith('gf'))
			{
				dad.setPosition(GF_X, GF_Y);
				if (gf != null)
					gf.visible = false;
			}
			if (dad2 != null && dad2.curCharacter.startsWith('gf'))
			{
				dad2.setPosition(GF_X, GF_Y);
				if (gf != null)
					gf.visible = false;
			}
		}

		if (!stageData.hide_girlfriend)
		{
			if (!dad.curCharacter.startsWith('gf'))
			{
				addCharacterToList('gf', 2);
				addCharacterToList('gf-cheer', 2);
			}
		}

		stagesFunc(function(stage:BaseStage) stage.createPost());

		add(rave);

		addBehindGF(whiteBG);
		addBehindGF(blackUnderlay);

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.data.downScroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("FridayNightFunkin.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if (ClientPrefs.data.downScroll)
			timeTxt.y = FlxG.height - 44;

		if (ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 4), 'timeBar', function() return songPercent, 0, 1);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		if (ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		opponentStrums = new FlxTypedGroup<StrumNote>();
		opponentStrums2 = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		modManager = new ModManager(this);

		callOnScripts("prePlayfieldCreation"); // backwards compat

		callOnScripts("onPlayfieldCreation"); // you should use this
		playerField = new PlayField(modManager);
		playerField.modNumber = 0;
		playerField.characters = [];
		playerField.noteField.isEditor = false;
		for (n => ch in boyfriendMap)
			playerField.characters.push(ch);
		for (n => ch in boyfriendMap2)
			playerField.characters.push(ch);

		playerField.isPlayer = !opponentmode && !playAsGF;
		playerField.autoPlayed = opponentmode || cpuControlled || playAsGF;
		playerField.noteHitCallback = opponentmode ? opponentNoteHit : goodNoteHit;

		dadField = new PlayField(modManager);
		dadField.isPlayer = opponentmode && !playAsGF;
		dadField.autoPlayed = !opponentmode || (opponentmode && cpuControlled) || playAsGF;
		dadField.AIPlayer = AIMode;
		dadField.modNumber = 1;
		dadField.characters = [];
		dadField.noteField.isEditor = false;
		for (n => ch in dadMap)
			dadField.characters.push(ch);
		for (n => ch in dadMap2)
			dadField.characters.push(ch);
		dadField.noteHitCallback = opponentmode ? goodNoteHit : opponentNoteHit;

		playfields.add(dadField);
		playfields.add(playerField);

		initPlayfield(dadField);
		initPlayfield(playerField);

		callOnScripts("postPlayfieldCreation"); // backwards compat

		callOnScripts("onPlayfieldCreationPost");

		if (!CacheMode) {
			if (chartModifier == "Normal") {
				var songExists = false;
				for (song in songCache.keys()) {
					if (song.song == SONG.song) {
						songExists = true;
						break;
					}
				}
		
				if (!songExists) {
					generateSong(SONG.song);
				} else {
					trace("Loading song from cache: " + SONG.song);
					unspawnNotes = songCache.get(SONG);
				}
			} else {
				trace("NO CACHE BECAUSE CUSTOM FUNNY!!!");
				trace("Modifier: " + chartModifier);
				generateSong(SONG.song);
			}
		}
		var fuckery:Anomoly = new Anomoly();
		fuckery.randomizeFields(instance, true);
		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camPos.put();

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.snapToTarget();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		if (!CacheMode) moveCameraSection();

		if (!playAsGF)
		{
			healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return health, 0, 2);
			healthBar.screenCenter(X);
			healthBar.leftToRight = false;
			healthBar.scrollFactor.set();
			healthBar.visible = !ClientPrefs.data.hideHud;
			healthBar.alpha = ClientPrefs.data.healthBarAlpha;

			healthBar2 = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return health, 0, 2);
			healthBar2.screenCenter(X);
			healthBar2.leftToRight = false;
			healthBar2.barHeight = Std.int(0.5);
			healthBar2.scrollFactor.set();
			healthBar2.visible = !ClientPrefs.data.hideHud;
			healthBar2.alpha = ClientPrefs.data.healthBarAlpha;
			add(healthBar);
			add(healthBar2);

			if (opponentmode)
			{
				healthBar.leftToRight = true;
				healthBar2.leftToRight = true;
			}

			iconP1 = new HealthIcon(boyfriend.healthIcon, true);
			iconP1.y = healthBar.y - 75;
			iconP1.visible = !ClientPrefs.data.hideHud;
			iconP1.alpha = ClientPrefs.data.healthBarAlpha;
			add(iconP1);

			if (bf2 != null && bf2.curCharacter != 'girlf')
			{
				iconP12 = new HealthIcon(bf2.healthIcon, true);
				iconP12.y = healthBar.y - 115;
				iconP12.visible = !ClientPrefs.data.hideHud;
				iconP12.alpha = ClientPrefs.data.healthBarAlpha;
				add(iconP12);
			}
			else
				iconP12 = null;

			iconP2 = new HealthIcon(dad.healthIcon, false);
			iconP2.y = healthBar.y - 75;
			iconP2.visible = !ClientPrefs.data.hideHud;
			iconP2.alpha = ClientPrefs.data.healthBarAlpha;
			add(iconP2);

			if (dad2 != null)
			{
				iconP22 = new HealthIcon(dad2.healthIcon, false);
				iconP22.y = healthBar.y - 115;
				iconP22.visible = !ClientPrefs.data.hideHud;
				iconP22.alpha = ClientPrefs.data.healthBarAlpha;
				add(iconP22);
			}
			reloadHealthBarColors();
		}

		scoreTxt = new FlxText(0, healthBar.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("FridayNightFunkin.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.data.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBar.y + 155, FlxG.width - 800, Language.getPhrase("Botplay").toUpperCase(), 32);
		botplayTxt.setFormat(Paths.font("FridayNightFunkin.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled || playAsGF && cpuControlled;
		add(botplayTxt);

		if (ClientPrefs.data.downScroll)
		{
			botplayTxt.y = timeBar.y - 78;
		}
		if (playAsGF)
		{
			botplayTxt.text = "GFPLAY";
			healthBarGF = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return health, 0, 2);
			healthBarGF.screenCenter(X);
			healthBarGF.leftToRight = false;
			healthBarGF.scrollFactor.set();
			healthBarGF.visible = !ClientPrefs.data.hideHud;
			healthBarGF.alpha = ClientPrefs.data.healthBarAlpha;
			add(healthBarGF);

			if (gf != null)
			{
				iconGF = new HealthIcon(gf.healthIcon, true);
				iconGF.y = healthBarGF.y - 75;
				iconGF.visible = !ClientPrefs.data.hideHud;
				iconGF.alpha = ClientPrefs.data.healthBarAlpha;
				add(iconGF);
			}
			reloadHealthBarColors();
		}

		introStageText = new FlxTypedGroup<FlxText>();

		songTxt = new FlxText(0, 1280/6, FlxG.width - 800, "", 32);
		songTxt.setFormat(Paths.font("mania-free.ttf"), 32, FlxColor.ORANGE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songTxt.scrollFactor.set();
		songTxt.screenCenter(X);
		songTxt.borderSize = 1.25;
		songTxt.alpha = 0;
		introStageText.insert(0, songTxt);

		artistTxt = new FlxText(songTxt.x, songTxt.y+40, FlxG.width - 800, "", 32);
		artistTxt.setFormat(Paths.font("mania-free.ttf"), 32, FlxColor.ORANGE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		artistTxt.scrollFactor.set();
		artistTxt.borderSize = 1.25;
		artistTxt.alpha = 0;
		introStageText.insert(0, artistTxt);

		charterTxt = new FlxText(artistTxt.x, artistTxt.y+40, FlxG.width - 800, "", 32);
		charterTxt.setFormat(Paths.font("mania-free.ttf"), 32, FlxColor.ORANGE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		charterTxt.scrollFactor.set();
		charterTxt.borderSize = 1.25;
		charterTxt.alpha = 0;
		introStageText.insert(0, charterTxt);

		modTxt = new FlxText(charterTxt.x, charterTxt.y+40, FlxG.width - 800, "", 32);
		modTxt.setFormat(Paths.font("mania-free.ttf"), 32, FlxColor.ORANGE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		modTxt.scrollFactor.set();
		modTxt.borderSize = 1.25;
		modTxt.alpha = 0;
		introStageText.insert(0, modTxt);

		if (hasMetadataFile)
		{
			Text = [metadata.song.name, metadata.song.artist, metadata.song.charter, metadata.song.mod];
		}
		else
		{
			Text = [curSong, '???', '???', 'Unknown'];
		}

		introStageStuff = new FlxTypedGroup<Dynamic>();
		add(introStageStuff);

		var daText:Array<FlxText> = [songTxt, artistTxt, charterTxt, modTxt];
		if (hasMetadataFile)
		{
			songTxt.text = metadata.song.name;
			artistTxt.text = 'Composed by: '+metadata.song.artist;
			charterTxt.text = 'Charted by: '+metadata.song.charter;
			modTxt.text = 'Song From: '+metadata.song.mod;
		}

		for (i in 0...Text.length)
		{
			introStageBar = new FlxSprite(daText[i].x, if (i == 2) daText[i].y else daText[i].y - 25).loadGraphic(Paths.image('invisabar'));
			introStageBar.scale.x = 2;
			introStageBar.scale.y = 3;
			introStageBar.scrollFactor.set();
			introStageBar.updateHitbox();
			introStageBar.screenCenter(X);
			introStageBar.ID = i;
			introStageBar.scrollFactor.set(0, 0);
			introStageStuff.insert(0, introStageBar);
			introStageStuff.insert(1, introStageText);
		}
		introStageStuff.visible = false;
		introStageStuff.cameras = [camCredit];

		if (!CacheMode)
		{
		if (!playAsGF)
		{
			playerField.cameras = [camHUD];
			dadField.cameras = [camHUD];
			playfields.cameras = [camHUD];
			strumLineNotes.cameras = [camHUD];
				if (notes != null) notes.cameras = [camHUD];
			healthBar.cameras = [camHUD];
			healthBar2.cameras = [camHUD];
			iconP1.cameras = [camHUD];
			iconP2.cameras = [camHUD];
			if (iconP12 != null)
				iconP12.cameras = [camHUD];
			if (dad2 != null)
				iconP22.cameras = [camHUD];
			scoreTxt.cameras = [camHUD];
		}
		else
		{
			healthBarGF.cameras = [camHUD];
			if (gf != null)
				iconGF.cameras = [camHUD];
			scoreTxt.cameras = [camHUD];
		}
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		}

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		#if LUA_ALLOWED
		for (notetype in noteTypes)
			startLuasNamed('custom_notetypes/' + notetype + '.lua');
		for (event in eventsPushed)
			startLuasNamed('custom_events/' + event + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');
		for (event in eventsPushed)
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end
		noteTypes = null;
		eventsPushed = null;

		if (eventNotes.length > 1)
		{
			for (event in eventNotes)
				event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if (file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if (file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		if (!CacheMode && SONG != null)
		{
			startCallback();
			RecalculateRating();
			if (AIPlayer.active)
				RecalculateRatingAI();
		}
		add(middlecircle);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		// PRECACHING THINGS THAT GET USED FREQUENTLY TO AVOID LAGSPIKES
		if (ClientPrefs.data.hitsoundVolume > 0)
			Paths.sound('hitsound');
		for (i in 1...4)
			Paths.sound('missnote$i');
		Paths.image('alphabet');

		if (PauseSubState.songName != null)
			Paths.music(PauseSubState.songName);
		else if (Paths.formatToSongPath(ClientPrefs.data.pauseMusic) != 'none')
			Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic));

		resetRPC();

		callOnScripts('onCreatePost');

		add(playfields);
		add(notefields);

		if (gf != null && !Crashed)
		{
			#if desktop
			// Updating Discord Rich Presence.
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")",
				if (playAsGF && gf != null) iconGF.getCharacter() else iconP2.getCharacter());
			#end
		}

		super.create();

		cacheCountdown();
		cachePopUpScore();

		add(blackOverlay);

		lyrics = new FlxText(0, 100, 1280, "", 32, true);
		lyrics.scrollFactor.set();
		lyrics.cameras = [camOther];
		// lyricsArray = CoolUtil.coolTextFile("assets/data/endless/endlessLyrics.txt");
		lyrics.alignment = FlxTextAlign.CENTER;
		lyrics.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		lyrics.borderSize = 4;
		lyrics.text = '';
		add(lyrics);

		daStatic = new FlxSprite(0, 0);
		daStatic.frames = Paths.getSparrowAtlas('effects/static');
		daStatic.animation.addByPrefix('static', 'lestatic', 24, true);
		daStatic.animation.play('static');
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.screenCenter();
		daStatic.cameras = [camOther];
		daStatic.alpha = 0;
		add(daStatic);

		/*daRain = new FlxSprite(0, 0);
			daRain.frames = Paths.getSparrowAtlas('effects/rain');
			daRain.animation.addByIndices('rain','rain tho', [0, 2, 4, 6, 8, 10, 12, 14, 16, 18], "", 24, true);
			daRain.animation.play('rain');
			daRain.setGraphicSize(FlxG.width, FlxG.height);
			daRain.screenCenter();
			daRain.cameras = [camFilters];
			daRain.alpha = 0;
			add(daRain);
			daRain.animation.play('rain');
			daRain.animation.finishCallback = function(pog:String)
			{
				daRain.animation.play('rain');
		}*/

		Paths.clearUnusedMemory();
		if (eventNotes.length < 1)
			checkEventNote();
	}

	function doStaticSign(lestatic:Int = 0)
	{
		trace('static Time Number: ' + lestatic);

		switch (lestatic)
		{
			case 0:
				daStatic.alpha = 1;
			case 1:
				daStatic.alpha = 0.5;
			case 2:
				daStatic.alpha = 0;

				daStatic.animation.play('static');
				daStatic.animation.finishCallback = function(pog:String)
				{
					daStatic.animation.play('static');
				}
		}
	}

	function doStaticSignFade(lestatictime:Float = 0, lestaticamount:Float = 0)
	{
		FlxTween.tween(daStatic, {alpha: lestaticamount}, lestatictime, {ease: FlxEase.expoInOut});

		daStatic.animation.play('static');
		daStatic.animation.finishCallback = function(pog:String)
		{
			daStatic.animation.play('static');
		}
	}

	function doThunderstorm(stormType:Int = 0)
	{
		switch (stormType)
		{
			case 0:
				FlxTween.num(rainIntensity, 0.04, 2, {ease: FlxEase.expoOut}, function(num)
				{
					rainIntensity = num;
				});
				thunderON = false;
			case 1:
				FlxTween.num(rainIntensity, 0.07, 2, {ease: FlxEase.expoOut}, function(num)
				{
					rainIntensity = num;
				});
				thunderON = false;
			case 2:
				FlxTween.num(rainIntensity, 0.09, 2, {ease: FlxEase.expoOut}, function(num)
				{
					rainIntensity = num;
				});
				thunderON = true;
			case 3:
				FlxTween.num(rainIntensity, 0, 2, {ease: FlxEase.expoOut}, function(num)
				{
					rainIntensity = num;
				});
				thunderON = false;
		}
	}

	function mirror()
	{
		camGame.flashSprite.scaleX *= -1;
		camHUD.flashSprite.scaleX *= -1;
	}

	function upsidedown()
	{
		camGame.flashSprite.scaleY *= -1;
		camHUD.flashSprite.scaleY *= -1;
	}

	function resetcam()
	{
		camGame.flashSprite.scaleY *= 1;
		camHUD.flashSprite.scaleY *= 1;
		camGame.flashSprite.scaleX *= 1;
		camHUD.flashSprite.scaleX *= 1;
	}

	public static function randString(Length:Int)
	{
		var string:String = '';
		var data:String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUBWXYZ1234567890';

		for (i in 0...Length)
		{
			string += data.charAt(FlxG.random.int(0, data.length - 1));
		}
		return string;
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}

	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}

	public function addBehindBF2(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup2), obj);
	}

	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function addBehindDad2(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup2), obj);
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();

	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if (!ClientPrefs.data.shaders)
			return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if (!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if (!ClientPrefs.data.shaders)
			return false;

		#if (MODS_ALLOWED && !flash && sys)
		if (runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/'))
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if (FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else
				frag = null;

			if (FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else
				vert = null;

			if (found)
			{
				runtimeShaders.set(name, [frag, vert]);
				// trace('Found shader $name!');
				return true;
			}
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
		#else
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		#end
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			var ratio:Float = value / songSpeed; // funny word huh
			if (ratio != 1)
			{
				for (note in allNotes)
					note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		#if FLX_PITCH
		if (generatedMusic)
		{
			vocals.pitch = value;
			opponentVocals.pitch = value;
			gfVocals.pitch = value;
			for (track in tracks)
				track.pitch = value;
			FlxG.sound.music.pitch = value;

			var ratio:Float = playbackRate / value; // funny word huh
			if (ratio != 1)
			{
				for (note in allNotes)
					note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		FlxG.animationTimeScale = value;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		setOnScripts('playbackRate', playbackRate);
		#else
		playbackRate = 1.0; // ensuring -Crow
		#end
		return playbackRate;
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor)
	{
		var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText)
		{
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}
	#end

	public function reloadHealthBarColors()
	{
		if (!playAsGF)
		{
			healthBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

			var dCol = if (dad2 != null) FlxColor.fromRGB(dad2.healthColorArray[0], dad2.healthColorArray[1],
				dad2.healthColorArray[2]) else FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
			var bCol = if (bf2 != null) FlxColor.fromRGB(bf2.healthColorArray[0], bf2.healthColorArray[1],
				bf2.healthColorArray[2]) else FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
			if (healthBar2 != null)
				healthBar2.setColors(dCol, bCol);
		}
		else
		{
			if (gf != null)
			{
				healthBarGF.setColors(FlxColor.fromRGB(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]),
					FlxColor.fromRGB(gf.healthColorArray[0] - 75, gf.healthColorArray[1] - 75, gf.healthColorArray[2] - 75));
			}
			else
			{
				healthBarGF.setColors(FlxColor.fromRGB(255, 0, 0), FlxColor.fromRGB(255 - 75, 0 - 75, 0 - 75));
			}
		}
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					if (playerField != null)
						playerField.characters.push(newBoyfriend);
					startCharacterScripts(newBoyfriend.curCharacter);
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					if (dadField != null)
						dadField.characters.push(newDad);
					startCharacterScripts(newDad.curCharacter);
				}

			case 2:
				if (gf != null && !gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterScripts(newGf.curCharacter);
				}
			case 3:
				if (dad2 != null && !dadMap2.exists(newCharacter))
				{
					var newDad2:Character = new Character(0, 0, newCharacter);
					newDad2.scrollFactor.set(0.95, 0.95);
					dadMap2.set(newCharacter, newDad2);
					dadGroup2.add(newDad2);
					startCharacterPos(newDad2);
					newDad2.alpha = 0.00001;
					startCharacterScripts(newDad2.curCharacter);
				}
			case 4:
				if (bf2 != null && !boyfriendMap2.exists(newCharacter))
				{
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap2.set(newCharacter, newBoyfriend);
					boyfriendGroup2.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					if (playerField != null)
						playerField.characters.push(newBoyfriend);
					startCharacterScripts(newBoyfriend.curCharacter);
				}
		}
	}

	function startCharacterScripts(name:String)
	{
		// Lua
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/$name.lua';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(replacePath))
		{
			luaFile = replacePath;
			doPush = true;
		}
		else
		{
			luaFile = Paths.getSharedPath(luaFile);
			if(FileSystem.exists(luaFile))
				doPush = true;
		}
		#else
		luaFile = Paths.getSharedPath(luaFile);
		if(Assets.exists(luaFile)) doPush = true;
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile)
				{
					doPush = false;
					break;
				}
			}
			if(doPush) new FunkinLua(luaFile);
		}
		#end

		// HScript
		#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var scriptFile:String = 'characters/' + name + '.hx';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(scriptFile);
		if(FileSystem.exists(replacePath))
		{
			scriptFile = replacePath;
			doPush = true;
		}
		else
		#end
		{
			scriptFile = Paths.getSharedPath(scriptFile);
			if(FileSystem.exists(scriptFile))
				doPush = true;
		}

		if(doPush)
		{
			if(Iris.instances.exists(scriptFile))
				doPush = false;

			if(doPush) initHScript(scriptFile);
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		#if LUA_ALLOWED
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		#end
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false, ?isGhost:Bool = false, ?isBF:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		if (isGhost)
		{
			if (isBF)
				char.x += char.positionArray[0] + 200
			else
				char.x += char.positionArray[0] - 200;
			if (isBF)
				char.y += char.positionArray[1] - 20
			else
				char.y += char.positionArray[1];
		}
		else
		{
			char.x += char.positionArray[0];
			char.y += char.positionArray[1];
		}
	}

	public var videoCutscene:VideoSprite = null;

	public function startVideo(name:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, playOnLoad:Bool = true)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var foundFile:Bool = false;
		var fileName:String = Paths.video(name);

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			var cutscene:VideoSprite = new VideoSprite(fileName, forMidSong, canSkip, loop);

			// Finish callback
			if (!forMidSong)
			{
				cutscene.finishCallback = function()
				{
					if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
					{
						moveCameraSection();
						FlxG.camera.snapToTarget();
					}
					startAndEnd();
				};

				// Skip callback
				cutscene.onSkip = function()
				{
					startAndEnd();
				};
			}
			add(cutscene);

			if (playOnLoad) cutscene.videoSprite.play();
			
			return cutscene;
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		else
			addTextToDebug("Video not found: " + fileName, FlxColor.RED);
		#else
		else
			FlxG.log.error("Video not found: " + fileName);
		#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		#end
		return null;
	}

	function startAndEnd()
	{
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;

	public var psychDialogue:DialogueBoxPsych;

	// You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if (psychDialogue != null)
			return;

		if (dialogueFile.dialogue.length > 0)
		{
			inCutscene = true;
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if (endingSong)
			{
				psychDialogue.finishThing = function()
				{
					psychDialogue = null;
					endSong();
				}
			}
			else
			{
				psychDialogue.finishThing = function()
				{
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camVisual];
			add(psychDialogue);
		}
		else
		{
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	// Same as above, but continues the cutscene timer instead of starting the song
	public var cutDialogue:DialogueBoxPsych;

	public function startCutDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if (cutDialogue != null)
			return;

		if (dialogueFile.dialogue.length > 0)
		{
			seenCutscene = true;
			// inCutscene = true;
			cutDialogue = new DialogueBoxPsych(dialogueFile, song);
			cutDialogue.scrollFactor.set();
			cutDialogue.finishThing = function()
			{
				cutDialogue = null;
				cutsceneHandler.pauseCutscene = false;
			}
			cutDialogue.nextDialogueThing = startNextDialogue;
			cutDialogue.skipDialogueThing = skipDialogue;
			cutDialogue.cameras = [camOther];
			add(cutDialogue);
		}
		else
		{
			FlxG.log.warn('Your dialogue file is badly formatted!');
			cutsceneHandler.pauseCutscene = false;
		}
	}

	var startTimer:FlxTimer;
	var startTimer2:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;

	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage)
			introAlts = introAssets.get('pixel');

		for (asset in introAlts)
			Paths.image(asset);

		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown()
	{
		if (startedCountdown)
		{
			callOnScripts('onStartCountdown');
			return false;
		}

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if (ret != LuaUtils.Function_Stop)
		{
			if (skipCountdown || startOnTime > 0)
				skipArrowStartTween = true;

			callOnScripts('preReceptorGeneration'); // backwards compat, deprecated
			callOnScripts('onReceptorGeneration');

			for (field in playfields.members)
			{
				field.keyCount = Note.ammo[mania];
				field.generateStrums();
			}

			callOnScripts('postReceptorGeneration'); // deprecated
			callOnScripts('onReceptorGenerationPost');

			for (field in playfields.members)
				field.fadeIn(isStoryMode || skipArrowStartTween); // TODO: check if its the first song so it should fade the notes in on song 1 of story mode

			callOnScripts('preModifierRegister'); // deprecated
			callOnScripts('onModifierRegister');
			modManager.registerDefaultModifiers();
			callOnScripts('postModifierRegister'); // deprecated
			callOnScripts('onModifierRegisterPost');

			startedCountdown = true;
			countActive = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted', null);
			changeMania(chartModifier != 'ManiaConverter' ? SONG.startMania : convertMania, isStoryMode || skipArrowStartTween);

			var swagCounter:Int = 0;

			if (startOnTime < 0)
				startOnTime = 0;

			if (startOnTime > 0)
			{
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return true;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null
					&& tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
					&& !gf.stunned
					&& gf.animation.curAnim.name != null
					&& !gf.animation.curAnim.name.startsWith("sing")
					&& !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0
					&& boyfriend.animation.curAnim != null
					&& !boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0
					&& dad.animation.curAnim != null
					&& !dad.animation.curAnim.name.startsWith('sing')
					&& !dad.stunned)
				{
					dad.dance();
				}
				if (bf2 != null
					&& tmr.loopsLeft % bf2.danceEveryNumBeats == 0
					&& bf2.animation.curAnim != null
					&& !bf2.animation.curAnim.name.startsWith('sing')
					&& !bf2.stunned)
					bf2.dance();
				if (dad2 != null)
				{
					if (tmr.loopsLeft % dad2.danceEveryNumBeats == 0
						&& dad2.animation.curAnim != null
						&& !dad2.animation.curAnim.name.startsWith('sing')
						&& !dad2.stunned)
					{
						dad2.dance();
					}
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.data.globalAntialiasing;
				if (isPixelStage)
				{
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						introStageStuff.visible = true;
						FlxTween.tween(songTxt, {alpha: 1}, 1, {ease: FlxEase.circOut});
						FlxTween.tween(artistTxt, {alpha: 1}, 1, {ease: FlxEase.circOut});
						FlxTween.tween(charterTxt, {alpha: 1}, 1, {ease: FlxEase.circOut});
						FlxTween.tween(modTxt, {alpha: 1}, 1, {ease: FlxEase.circOut});
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						add(countdownReady);
						FlxTween.tween(countdownReady, {y: countdownReady.y + 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						add(countdownSet);
						FlxTween.tween(countdownSet, {y: countdownSet.y + 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						add(countdownGo);
						FlxTween.tween(countdownGo, {y: countdownGo.y + 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						if (ClientPrefs.data.starHidden)
							FlxTween.tween(camHUD, {alpha: 1}, 5, {ease: FlxEase.circOut});
					case 4:
						new FlxTimer().start(2, function(tmr:FlxTimer) {
							FlxTween.tween(camCredit, {alpha: 0, y:1000}, 1, {ease: FlxEase.circInOut});
						});
				}

				notes.forEachAlive(function(note:Note)
				{
					if (ClientPrefs.data.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if (ClientPrefs.data.middleScroll && !note.mustPress)
						{
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
		return true;
	}

	public function restartCountdown()
	{
		if (startedCountdown)
		{
			callOnScripts('onStartCountdown');
			return false;
		}

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if (ret != LuaUtils.Function_Stop)
		{
			if (skipCountdown || startOnTime > 0)
				skipArrowStartTween = true;

			startedCountdown = true;
			countActive = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted', null);
			var swagCounter:Int = 0;

			if (startOnTime < 0)
				startOnTime = 0;

			if (startOnTime > 0)
			{
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return true;
			}

			startTimer2 = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null
					&& tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
					&& !gf.stunned
					&& gf.animation.curAnim.name != null
					&& !gf.animation.curAnim.name.startsWith("sing")
					&& !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0
					&& boyfriend.animation.curAnim != null
					&& !boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0
					&& dad.animation.curAnim != null
					&& !dad.animation.curAnim.name.startsWith('sing')
					&& !dad.stunned)
				{
					dad.dance();
				}
				if (bf2 != null
					&& tmr.loopsLeft % bf2.danceEveryNumBeats == 0
					&& bf2.animation.curAnim != null
					&& !bf2.animation.curAnim.name.startsWith('sing')
					&& !bf2.stunned)
					bf2.dance();
				if (dad2 != null)
				{
					if (tmr.loopsLeft % dad2.danceEveryNumBeats == 0
						&& dad2.animation.curAnim != null
						&& !dad2.animation.curAnim.name.startsWith('sing')
						&& !dad2.stunned)
					{
						dad2.dance();
					}
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.data.globalAntialiasing;
				if (isPixelStage)
				{
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						add(countdownReady);
						FlxTween.tween(countdownReady, {y: countdownReady.y + 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						add(countdownSet);
						FlxTween.tween(countdownSet, {y: countdownSet.y + 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						add(countdownGo);
						FlxTween.tween(countdownGo, {y: countdownGo.y + 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
		return true;
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = allNotes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = allNotes[i];
			if (daNote.strumTime - 350 < time)
			{
				daNote.ignoreNote = true;
				for (field in playfields)
					field.removeNote(daNote);
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		var ret:Dynamic = callOnScripts('preUpdateScore', [miss], true);
		if (ret == LuaUtils.Function_Stop)
			return;

		var str:String = Language.getPhrase('rating_$ratingName', ratingName);
		if (totalPlayed != 0)
		{
			var percent:Float = CoolUtil.floorDecimal(ratingPercent * 100, 2);
			str += ' (${percent}%) - ${Language.getPhrase(ratingFC)}';
		}

		var tempScore:String;
		if (!instakillOnMiss) tempScore = Language.getPhrase('score_text', 'Score: {1} | Misses: {2} | Rating: {3}', [songScore, songMisses, str]);
		else tempScore = Language.getPhrase('score_text_instakill', 'Score: {1} | Rating: {2}', [songScore, str]);
		scoreTxt.text = tempScore;

		if (!miss && !cpuControlled)
			doScoreBop();

		callOnScripts('onUpdateScore', [miss]);
	}

	public function updateScoreAI(miss:Bool = false)
	{
		var ret:Dynamic = callOnScripts('preUpdateScoreAI', [miss], true);
		if (ret == LuaUtils.Function_Stop)
			return;

		var str:String = ratingNameAI;
		if (totalPlayed != 0)
		{
			var percentAI:Float = CoolUtil.floorDecimal(ratingPercentAI * 100, 2);
			str += ' (${percentAI}%) - ${ratingFCAI}';
		}

		if (!miss && !cpuControlled)
			doScoreBop();

		callOnScripts('onUpdateScoreAI', [miss]);
	}

	public dynamic function fullComboFunction()
	{
		ratingFC = "";

		if (ClientPrefs.data.useMarvs)
		{
			marvs = ratingsData[0].hits;
			sicks = ratingsData[1].hits;
			goods = ratingsData[2].hits;
			bads = ratingsData[3].hits;
			shits = ratingsData[4].hits;

			if (songMisses == 0)
			{
				if (bads > 0 || shits > 0)
					ratingFC = 'FC';
				else if (goods > 0)
					ratingFC = 'GFC';
				else if (sicks > 0)
					ratingFC = 'SFC';
				else if (marvs > 0)
					ratingFC = 'MFC';
			}
			else
			{
				if (songMisses < 10)
					ratingFC = 'SDCB';
				else
					ratingFC = 'Clear';
			}
		}
		else
		{
			sicks = ratingsData[0].hits;
			goods = ratingsData[1].hits;
			bads = ratingsData[2].hits;
			shits = ratingsData[3].hits;
			if (songMisses == 0)
			{
				if (bads > 0 || shits > 0)
					ratingFC = 'FC';
				else if (goods > 0)
					ratingFC = 'GFC';
				else if (sicks > 0)
					ratingFC = 'SFC';
			}
			else
			{
				if (songMisses < 10)
					ratingFC = 'SDCB';
				else
					ratingFC = 'Clear';
			}
		}
	}

	public function doScoreBop():Void
	{
		if (!ClientPrefs.data.scoreZoom)
			return;

		if (scoreTxtTween != null)
			scoreTxtTween.cancel();

		scoreTxt.scale.x = 1.075;
		scoreTxt.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween)
			{
				scoreTxtTween = null;
			}
		});
	}

	public function setSongTime(time:Float)
	{
		if (time < 0)
			time = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();
		gfVocals.pause();
		for (track in tracks)
			track.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		// I don't trust 0.7.3's new resync system...
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			#if FLX_PITCH
			vocals.pitch = playbackRate;
			#end
		}
		if (Conductor.songPosition <= opponentVocals.length)
		{
			opponentVocals.time = time;
			#if FLX_PITCH
			opponentVocals.pitch = playbackRate;
			#end
		}
		if (Conductor.songPosition <= gfVocals.length)
		{
			gfVocals.time = time;
			#if FLX_PITCH
			gfVocals.pitch = playbackRate;
			#end
		}
		for (track in tracks)
		{
			if (Conductor.songPosition <= track.length)
			{
				track.time = time;
				#if FLX_PITCH
				track.pitch = playbackRate;
				#end
			}
		}
		vocals.play();
		opponentVocals.play();
		gfVocals.play();
		for (track in tracks)
			track.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	public function startNextDialogue()
	{
		dialogueCount++;
		callOnScripts('onNextDialogue', [dialogueCount]);
	}

	public function skipDialogue()
	{
		callOnScripts('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		opponentVocals.play();
		gfVocals.play();
		for (track in tracks)
			track.play();

		if (startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();
		gfVocals.pause();
		for (track in tracks)
			track.pause();
		Conductor.songPosition += savedTime;
		trace("Saved Time:" + savedTime);
		if (savedTime != 0)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
			gfVocals.pause();
			for (track in tracks)
				track.pause();
			Conductor.songPosition += savedTime;
			trace("Saved Time:");
			trace(savedTime);
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.strumTime > Conductor.songPosition - 1000 && daNote.strumTime < Conductor.songPosition + 1000)
				{
					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
			for (i in 0...unspawnNotes.length)
			{
				var daNote:Note = unspawnNotes[0];
				if (daNote.strumTime + 1200 >= Conductor.songPosition)
				{
					break;
				}

				daNote.active = false;
				daNote.visible = false;

				daNote.kill();
				unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
				daNote.destroy();
			}

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			opponentVocals.time = Conductor.songPosition;
			opponentVocals.play();
			gfVocals.time = Conductor.songPosition;
			gfVocals.play();
			for (track in tracks)
			{
				track.time = Conductor.songPosition;
				track.play();
			}
		}

		FlxG.sound.music.time = Conductor.songPosition;
		FlxG.sound.music.play();

		vocals.time = Conductor.songPosition;
		vocals.play();
		opponentVocals.time = Conductor.songPosition;
		opponentVocals.play();
		gfVocals.time = Conductor.songPosition;
		gfVocals.play();
		for (track in tracks)
		{
			track.time = Conductor.songPosition;
			track.play();
		}

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(healthBar.x + 80, healthBar.y - 110, 500);
			skipText.text = "Press Space to Skip Intro";
			skipText.size = 30;
			skipText.color = FlxColor.WHITE;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			skipText.alpha = 0;
			FlxTween.tween(skipText, {alpha: 1}, 0.2);
			add(skipText);
		}
		else
		{
			if (skipText != null)
				FlxTween.tween(skipText, {alpha: 0}, 0.2);
		}

		if (paused)
		{
			// trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
			gfVocals.pause();
			for (track in tracks)
				track.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart', []);
		if (!playAsGF && !Crashed)
		{
			#if DISCORD_ALLOWED
			// Updating Discord Rich Presence (with Time Left)
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")",
				if (playAsGF && gf != null) iconGF.getCharacter() else iconP2.getCharacter(), true, songLength);
			#end
		}
		if (songName.toLowerCase() == 'truly-lost' || songName.toLowerCase() == 'everlost')
		{
			healthBar.visible = false;
			healthBar.bg.visible = false;
			iconP1.visible = false;
			iconP2.visible = false;
			if (songName.toLowerCase() == 'everlost') triggerEvent('Enable or Disable Dad Trail', 'true', null, Conductor.crochet);
		}
		else if (songName.toLowerCase() == 'everfound')
		{
			health = 0.01;
			triggerEvent('Enable or Disable Dad Trail', 'true', null, Conductor.crochet);
		}
	}

public static function getNumberFromAnims(note:Int, mania:Int):Int {
    var animMap:Map<String, Int> = new Map<String, Int>();
    animMap.set("LEFT", 0);
    animMap.set("DOWN", 1);
    animMap.set("UP", 2);
    animMap.set("RIGHT", 3);

    var anims:Array<String> = Note.keysShit.get(mania).get("anims");
    var animKeys:Array<String> = [
        for (key in animMap.keys())
            if (key == "LEFT") "RIGHT" else if (key == "RIGHT") "LEFT" else key
    ];

    var result:Int;

    if (mania > 3) {
        var anim = animKeys[note];
        var matchingIndices:Array<Int> = [];
        if (note < animKeys.length) {
            for (i in 0...anims.length) {
                if (anims[i] == anim) {
                    matchingIndices.push(i);
                }
            }
            if (matchingIndices.length > 0) {
                var randomIndex = Std.int(Math.random() * matchingIndices.length);
                result = matchingIndices[randomIndex];
            } else {
                var randomIndex = Std.int(Math.random() * mania);
                result = randomIndex;
            }
        } else {
            if (matchingIndices.length > 0) {
                var randomIndex = Std.int(Math.random() * matchingIndices.length);
                result = matchingIndices[randomIndex];
            } else {
                var randomIndex = Std.int(Math.random() * mania);
                result = randomIndex;
            }
        }
    } else { // mania == 3
        var anim = anims[note];
        if (note < anims.length) {
            if (animMap.exists(anim)) {
                result = animMap.get(anim);
            } else {
                throw 'No matching animation found';
            }
        } else {
            result = animMap.get(anim);
        }
    }

    // Ensure result is within bounds
if (result < 0 || result > mania) {
	trace("OOB NOtE: " + note + " MANIA: " + mania + " RESULT: " + result);
    var foundValidAnimation = false;
    while (!foundValidAnimation) {
        var randomIndex = Std.int(Math.random() * anims.length);
        var randomAnim = anims[randomIndex];
        if (animMap.exists(randomAnim)) {
            result = animMap.get(randomAnim);
            foundValidAnimation = true;
        }
    }
}

    return result;
}

	var debugNum:Int = 0;
	var stair:Int = 0;
	var noteIndex:Int = -1;
	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];

	private function generateSong(dataPath:String):Void
	{
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype', 'multiplicative');

		switch (songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		var AIPlayMap = [];

		if (AIPlayer.active)
			AIPlayMap = AIPlayer.GeneratePlayMap(SONG, AIPlayer.diff);

		Paths.inst(curSong.toLowerCase());
		Paths.voices(curSong.toLowerCase());

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		gfVocals = new FlxSound();

		try
		{
			if (songData.needsVoices && songData.newVoiceStyle)
			{
				var playerVocals = Paths.voices(songData.song,
					(boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'player' : boyfriend.vocalsFile);
				if (playerVocals != null)
				{
					vocals.loadEmbedded(playerVocals != null ? playerVocals : Paths.music('empty'));
					FlxG.sound.list.add(vocals);
				}

				var oppVocals = Paths.voices(songData.song, (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'opponent' : dad.vocalsFile);
				if (oppVocals != null)
				{
					opponentVocals.loadEmbedded(oppVocals != null ? oppVocals : Paths.music('empty'));
					FlxG.sound.list.add(opponentVocals);
				}

				if (((dad.vocalsFile == null || dad.vocalsFile.length < 1) && dad.vocalsFile != 'gf')
					&& ((boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) && boyfriend.vocalsFile != 'gf'))
				{
					var gfVoc = Paths.voices(songData.song, (gf.vocalsFile == null || gf.vocalsFile.length < 1) ? 'gf' : gf.vocalsFile);
					if (gfVoc != null)
					{
						gfVocals.loadEmbedded(gfVoc != null ? gfVoc : Paths.music('empty'));
						FlxG.sound.list.add(gfVocals);
					}
				}
			}
			else if (songData.needsVoices && !songData.newVoiceStyle)
			{
				var playerVocals = Paths.voices(songData.song);
				if (playerVocals != null)
				{
					vocals.loadEmbedded(playerVocals != null ? playerVocals : Paths.voices(songData.song));
					FlxG.sound.list.add(vocals);
				}
			}
		}
		catch (e)
		{
		}

		inst = new FlxSound();
		try
		{
			inst.loadEmbedded(Paths.inst(songData.song));
		}
		catch (e:Dynamic)
		{
			inst.loadEmbedded(Paths.music('empty'));
		}
		FlxG.sound.list.add(inst);

		if (SONG.extraTracks != null)
		{
			for (trackName in SONG.extraTracks)
			{
				var newTrack = Paths.track(songData.song, trackName);
				if (newTrack != null)
				{
					tracks.push(newTrack);
					FlxG.sound.list.add(newTrack);
				}
			}
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		try
		{
			var eventsChart:SwagSong = Song.getChart('events', songName);
			if (eventsChart != null)
				for (event in eventsChart.events) // Event Notes
					for (i in 0...event[1].length)
						makeEvent(event, i);
		}
		catch (e:Dynamic)
		{
		}

		speedChanges.sort(svSort);

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int;
				if (chartModifier != "4K Only" && chartModifier != "ManiaConverter")
				{
					daNoteData = Std.int(songNotes[1] % Note.ammo[mania]);
				}
				else
				{
					daNoteData = Std.int(songNotes[1] % Note.ammo[SONG.mania]);
				}

				var gottaHitNote:Bool = section.mustHitSection;

				switch (chartModifier)
				{
					case "Random":
						daNoteData = FlxG.random.int(0, mania);
					case "RandomBasic":
						var randomDirection:Int;
						do
						{
							randomDirection = FlxG.random.int(0, mania);
						}
						while (randomDirection == prevNoteData && mania > 1);
						prevNoteData = randomDirection;
						daNoteData = randomDirection;
					case "RandomComplex":
						var thisNoteData = daNoteData;
						if (initialNoteData == -1)
						{
							initialNoteData = daNoteData;
							daNoteData = FlxG.random.int(0, mania);
						}
						else
						{
							var newNoteData:Int;
							do
							{
								newNoteData = FlxG.random.int(0, mania);
							}
							while (newNoteData == prevNoteData && mania > 1);
							if (thisNoteData == initialNoteData)
							{
								daNoteData = prevNoteData;
							}
							else
							{
								daNoteData = newNoteData;
							}
						}
						prevNoteData = daNoteData;
						initialNoteData = thisNoteData;

					// case "Sequential":
					// 	if (prevNoteData == 0) {
					// 		daNoteData = 1;
					// 		direction = 1;
					// 	} else if (prevNoteData == mania - 1) {
					// 		daNoteData = mania - 2;
					// 		direction = -1;
					// 	} else {
					// 		daNoteData = prevNoteData + direction;
					// 	}
					// 	break;
								case "Mirror": //Broken
									var length = mania;
									var mirroredIndex:Int;
									var middle = Math.floor(length / 2);
									if (daNoteData < middle) {
										mirroredIndex = (middle - daNoteData) + middle - 1;
									} else if (daNoteData > middle) {
										mirroredIndex = middle - (daNoteData - middle);
									} else {
										mirroredIndex = daNoteData;
									}
								daNoteData = mirroredIndex;
								case "ReverseMirror":
									var median:Float = (mania + 1) / 2;
								if (daNoteData <= median) {
									// For values below the median, mirror downwards
									daNoteData = Std.int(median - (median - daNoteData) - 1);
								} else {
									// For values above the median, mirror upwards
									daNoteData = Std.int(median + (daNoteData - median) + 1);
								}
								daNoteData = Std.int(Math.max(0, Math.min(daNoteData, mania - 1)));

					case "Skip":
						var skipStep = 2; // Define the step size for skipping notes.
						var randomLane = Math.random() < 0.5 ? prevNoteData : (prevNoteData + skipStep) % mania;
						var randomDuration = Math.random() * 30; // Randomize the duration before switching lanes (in notes).
						daNoteData = randomLane;
					case "Flip":
						if (gottaHitNote)
						{
							daNoteData = mania - Std.int(songNotes[1] % Note.ammo[mania]);
						}
					case "Pain":
						daNoteData = daNoteData - Std.int(songNotes[1] % Note.ammo[mania]);
					case "4K Only":
						daNoteData = getNumberFromAnims(daNoteData, SONG.mania);
					case "ManiaConverter":
						daNoteData = getNumberFromAnims(daNoteData, mania);
					case "Stairs":
						daNoteData = stair % Note.ammo[mania];
						stair++;
					case "Wave":
						// Sketchie... WHY?!
						var ammoFromFortnite:Int = Note.ammo[mania];
						var luigiSex:Int = (ammoFromFortnite * 2 - 2);
						var marioSex:Int = stair++ % luigiSex;
						if (marioSex < ammoFromFortnite)
						{
							daNoteData = marioSex;
						}
						else
						{
							daNoteData = luigiSex - marioSex;
						}
					case "Trills":
						var ammoFromFortnite:Int = Note.ammo[mania];
						var luigiSex:Int = (ammoFromFortnite * 2 - 2);
						var marioSex:Int;
						do
						{
							marioSex = Std.int((stair++ % (luigiSex * 4)) / 4 + stair % 2);
							if (marioSex < ammoFromFortnite)
							{
								daNoteData = marioSex;
							}
							else
							{
								daNoteData = luigiSex - marioSex;
							}
						}
						while (daNoteData == prevNoteData && mania > 1);
						prevNoteData = daNoteData;
					case "Ew":
						// I hate that I used Sketchie's variables as a base for this... ;-;
						var ammoFromFortnite:Int = Note.ammo[mania];
						var luigiSex:Int = (ammoFromFortnite * 2 - 2);
						var marioSex:Int = stair++ % luigiSex;
						var noteIndex:Int = Std.int(marioSex / 2);
						var noteDirection:Int = marioSex % 2 == 0 ? 1 : -1;
						daNoteData = noteIndex + noteDirection;
						// If the note index is out of range, wrap it around
						if (daNoteData < 0)
						{
							daNoteData = 1;
						}
						else if (daNoteData >= ammoFromFortnite)
						{
							daNoteData = ammoFromFortnite - 2;
						}
					case "Death":
						var ammoFromFortnite:Int = Note.ammo[mania];
						var luigiSex:Int = (ammoFromFortnite * 4 - 4);
						var marioSex:Int = stair++ % luigiSex;
						var step:Int = Std.int(luigiSex / 3);

						if (marioSex < ammoFromFortnite)
						{
							daNoteData = marioSex % step;
						}
						else if (marioSex < ammoFromFortnite * 2)
						{
							daNoteData = (marioSex - ammoFromFortnite) % step + step;
						}
						else if (marioSex < ammoFromFortnite * 3)
						{
							daNoteData = (marioSex - ammoFromFortnite * 2) % step + step * 2;
						}
						else
						{
							daNoteData = (marioSex - ammoFromFortnite * 3) % step + step * 3;
						}
					case "What":
						switch (stair % (2 * Note.ammo[mania]))
						{
							case 0:
							case 1:
							case 2:
							case 3:
							case 4:
								daNoteData = stair % Note.ammo[mania];
							default:
								daNoteData = Note.ammo[mania] - 1 - (stair % Note.ammo[mania]);
						}
						stair++;
					case "Amalgam":
						{
							var modifierNames:Array<String> = [
								"Random", "RandomBasic", "RandomComplex", "Flip", "Pain", "Stairs", "Wave", "Huh", "Ew", "What", "Jack Wave", "SpeedRando",
								"Trills"
							];

							if (caseExecutionCount <= 0)
							{
								currentModifier = FlxG.random.int(-1, (modifierNames.length - 1)); // Randomly select a case from 0 to 9
								caseExecutionCount = FlxG.random.int(1, 51); // Randomly select a number from 1 to 50
								trace("Active Modifier: " + modifierNames[currentModifier] + ", Notes to edit: " + caseExecutionCount);
							}
							// trace('Notes remaining: ' + caseExecutionCount);
							caseExecutionCount--;
							switch (currentModifier)
							{
								case 0: // "Random"
									daNoteData = FlxG.random.int(0, mania);
								case 1: // "RandomBasic"
									var randomDirection:Int;
									do
									{
										randomDirection = FlxG.random.int(0, mania);
									}
									while (randomDirection == prevNoteData && mania > 1);
									prevNoteData = randomDirection;
									daNoteData = randomDirection;
								case 2: // "RandomComplex"
									var thisNoteData = daNoteData;
									if (initialNoteData == -1)
									{
										initialNoteData = daNoteData;
										daNoteData = FlxG.random.int(0, mania);
									}
									else
									{
										var newNoteData:Int;
										do
										{
											newNoteData = FlxG.random.int(0, mania);
										}
										while (newNoteData == prevNoteData && mania > 1);
										if (thisNoteData == initialNoteData)
										{
											daNoteData = prevNoteData;
										}
										else
										{
											daNoteData = newNoteData;
										}
									}
									prevNoteData = daNoteData;
									initialNoteData = thisNoteData;
								case 3: // "Flip"
									if (gottaHitNote)
									{
										daNoteData = mania - Std.int(songNotes[1] % Note.ammo[mania]);
									}
								case 4: // "Pain"
									daNoteData = daNoteData - Std.int(songNotes[1] % Note.ammo[mania]);
								case 5: // "Stairs"
									daNoteData = stair % Note.ammo[mania];
									stair++;
								case 6: // "Wave"
									// Sketchie... WHY?!
									var ammoFromFortnite:Int = Note.ammo[mania];
									var luigiSex:Int = (ammoFromFortnite * 2 - 2);
									var marioSex:Int = stair++ % luigiSex;
									if (marioSex < ammoFromFortnite)
									{
										daNoteData = marioSex;
									}
									else
									{
										daNoteData = luigiSex - marioSex;
									}
								case 7: // "Huh"
									var ammoFromFortnite:Int = Note.ammo[mania];
									var luigiSex:Int = (ammoFromFortnite * 4 - 4);
									var marioSex:Int = stair++ % luigiSex;
									var step:Int = Std.int(luigiSex / 3);
									var waveIndex:Int = Std.int(marioSex / step);
									var waveDirection:Int = waveIndex % 2 == 0 ? 1 : -1;
									var waveRepeat:Int = Std.int(waveIndex / 2);
									var repeatStep:Int = marioSex % step;
									if (repeatStep < waveRepeat)
									{
										daNoteData = waveIndex * step + waveDirection * repeatStep;
									}
									else
									{
										daNoteData = waveIndex * step + waveDirection * (waveRepeat * 2 - repeatStep);
									}
									if (daNoteData < 0)
									{
										daNoteData = 0;
									}
									else if (daNoteData >= ammoFromFortnite)
									{
										daNoteData = ammoFromFortnite - 1;
									}
								case 8: // "Ew"
									// I hate that I used Sketchie's variables as a base for this... ;-;
									var ammoFromFortnite:Int = Note.ammo[mania];
									var luigiSex:Int = (ammoFromFortnite * 2 - 2);
									var marioSex:Int = stair++ % luigiSex;
									var noteIndex:Int = Std.int(marioSex / 2);
									var noteDirection:Int = marioSex % 2 == 0 ? 1 : -1;
									daNoteData = noteIndex + noteDirection;
									// If the note index is out of range, wrap it around
									if (daNoteData < 0)
									{
										daNoteData = 1;
									}
									else if (daNoteData >= ammoFromFortnite)
									{
										daNoteData = ammoFromFortnite - 2;
									}
								case 9: // "What"
									switch (stair % (2 * Note.ammo[mania]))
									{
										case 0:
										case 1:
										case 2:
										case 3:
										case 4:
											daNoteData = stair % Note.ammo[mania];
										default:
											daNoteData = Note.ammo[mania] - 1 - (stair % Note.ammo[mania]);
									}
									stair++;
								case 10: // Jack Wave
									var ammoFromFortnite:Int = Note.ammo[mania];
									var luigiSex:Int = (ammoFromFortnite * 2 - 2);
									var marioSex:Int = Std.int((stair++ % (luigiSex * 4)) / 4);
									if (marioSex < ammoFromFortnite)
									{
										daNoteData = marioSex;
									}
									else
									{
										daNoteData = luigiSex - marioSex;
									}
								case 11: // SpeedRando
								// Handled by SpeedRando Code below!
								case 12: // Trills
									var ammoFromFortnite:Int = Note.ammo[mania];
									var luigiSex:Int = (ammoFromFortnite * 2 - 2);
									var marioSex:Int;
									do
									{
										marioSex = Std.int((stair++ % (luigiSex * 4)) / 4 + stair % 2);
										if (marioSex < ammoFromFortnite)
										{
											daNoteData = marioSex;
										}
										else
										{
											daNoteData = luigiSex - marioSex;
										}
									}
									while (daNoteData == prevNoteData && mania > 1);
									prevNoteData = daNoteData;
								default:
									// Default case (optional)
							}
						}
				}

				if (chartModifier != "4K Only" && chartModifier != "ManiaConverter")
				{
					if (songNotes[1] > (Note.ammo[mania] - 1))
					{
						gottaHitNote = !section.mustHitSection;
					}
				}
				else
				{
					if (songNotes[1] > (Note.ammo[SONG.mania] - 1))
					{
						gottaHitNote = !section.mustHitSection;
					}
				}

				var oldNote:Note;
				if (allNotes.length > 0)
					oldNote = allNotes[Std.int(allNotes.length - 1)];
				else
					oldNote = null;

				var type:Dynamic = songNotes[3];
				// if(!Std.isOfType(type, String)) type = editors.ChartingStateOG.noteTypeList[type];

				// TODO: maybe make a checkNoteType n shit but idfk im lazy
				// or maybe make a "Transform Notes" event which'll make notes which don't change texture change into the specified one

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				if (!swagNote.mustPress)
				{
					if (AIPlayMap.length != 0 && [noteData.indexOf(section)] != null)
					{
						swagNote.AIStrumTime = AIPlayMap[noteData.indexOf(section)][section.sectionNotes.indexOf(songNotes)];
						if (Math.abs(swagNote.AIStrumTime) > Conductor.safeZoneOffset)
							swagNote.ignoreNote = swagNote.AIMiss = true;
					}
				}
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = section.gfSection;
				//swagNote.animSuffix = section.altAnim ? '-alt' : '';
				swagNote.noteType = type;
				swagNote.noteIndex = noteIndex++;
				if (!Std.isOfType(songNotes[3], String))
					swagNote.noteType = ChartingStateOG.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
				swagNote.scrollFactor.set();
				if (chartModifier == 'Amalgam' && currentModifier == 11)
				{
					swagNote.multSpeed = FlxG.random.float(0.1, 2);
				}

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				swagNote.ID = allNotes.length;

				if (swagNote.fieldIndex == -1 && swagNote.field == null)
					swagNote.field = swagNote.mustPress ? playerField : dadField;

				if (swagNote.field != null)
					swagNote.fieldIndex = playfields.members.indexOf(swagNote.field);

				var playfield:PlayField = playfields.members[swagNote.fieldIndex];

				if (playfield != null)
				{
					playfield.queue(swagNote); // queues the note to be spawned
					allNotes.push(swagNote); // just for the sake of convenience
				}
				else
				{
					swagNote.destroy();
					continue;
				}

				var floorSus:Int = Math.round(susLength);
				if (floorSus > 0)
				{
					for (susNote in 0...floorSus)
					{
						oldNote = allNotes[Std.int(allNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = swagNote.gfNote;
						sustainNote.animSuffix = swagNote.animSuffix;
						sustainNote.noteType = type;
						sustainNote.noteIndex = swagNote.noteIndex;
						if (chartModifier == 'Amalgam' && currentModifier == 11)
						{
							sustainNote.multSpeed = swagNote.multSpeed;
						}
						if (sustainNote == null || !sustainNote.alive)
							break;
						sustainNote.ID = allNotes.length;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						swagNote.unhitTail.push(sustainNote);
						sustainNote.parent = swagNote;
						// allNotes.push(sustainNote);
						sustainNote.fieldIndex = swagNote.fieldIndex;
						playfield.queue(sustainNote);
						allNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width * 0.5; // general offset
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width * 0.5; // general offset
				}
				else if (ClientPrefs.data.middleScroll)
				{
					swagNote.x += 310;
					if (daNoteData > 1) // Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if (!noteTypes.contains(swagNote.noteType))
				{
					noteTypes.push(swagNote.noteType);
				}
			}
			daBeats += 1;
		}

		for (event in songData.events) // Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);
		// playerCounter += 1;
		allNotes.sort(sortByNotes);
		for (fuck in allNotes)
		{
			unspawnNotes.push(fuck);
			curChart.push(fuck);
		}
		for (field in playfields.members)
		{
			var goobaeg:Array<Note> = [];
			for (column in field.noteQueue)
			{
				if (column.length >= Note.ammo[mania])
				{
					for (nIdx in 1...column.length)
					{
						var last = column[nIdx - 1];
						var current = column[nIdx];

						if (last == null || current == null)
							continue;
						if (last.isSustainNote || current.isSustainNote)
							continue; // holds only get fukt if their parents get fukt
						if (!last.alive || !current.alive)
							continue; // just incase
						if (Math.abs(last.strumTime - current.strumTime) <= Conductor.stepCrochet / (192 / 16))
						{
							if (last.sustainLength < current.sustainLength) // keep the longer hold
								field.removeNote(last);
							else
							{
								current.kill();
								goobaeg.push(current); // mark to delete after, cant delete here because otherwise it'd fuck w/ stuff
							}
						}
					}
				}
			}
			for (note in goobaeg)
				field.removeNote(note);
		}
		checkEventNote();
		generatedMusic = true;
		if (chartModifier == 'SpeedRando')
		{
			var curNotes:Array<Note> = [];
			var allowBrokenSustains = Math.random() < 0.2;

			trace('Broken Sustains?: ' + allowBrokenSustains);
			for (i in 0...unspawnNotes.length)
			{
				if (unspawnNotes[i] != null)
				{ // Null check
					if (unspawnNotes[i].mustPress)
					{
						if (!unspawnNotes[i].isSustainNote)
						{
							unspawnNotes[i].multSpeed = FlxG.random.float(0.1, 2);
							curNotes[unspawnNotes[i].noteData] = unspawnNotes[i];
						}
						else
						{
							if (curNotes[unspawnNotes[i].noteData] != null)
							{
								unspawnNotes[i].multSpeed = curNotes[unspawnNotes[i].noteData].multSpeed;
							}
						}
					}
					if (!unspawnNotes[i].mustPress)
					{
						if (!unspawnNotes[i].isSustainNote)
						{
							unspawnNotes[i].multSpeed = FlxG.random.float(0.1, 2);
							curNotes[unspawnNotes[i].noteData] = unspawnNotes[i];
						}
						else
						{
							if (curNotes[unspawnNotes[i].noteData] != null)
							{
								unspawnNotes[i].multSpeed = curNotes[unspawnNotes[i].noteData].multSpeed;
							}
						}
					}
				}
				if (!allowBrokenSustains)
				{
					if (unspawnNotes[i] != null)
					{
						if (unspawnNotes[i].isSustainNote)
						{
							for (note in unspawnNotes)
							{
								if (note != null && !note.isSustainNote && note.noteIndex == unspawnNotes[i].noteIndex)
								{
									unspawnNotes[i].multSpeed = note.multSpeed;
									break;
								}
							}
						}
					}
				}
			}
		}
		if (chartModifier == "SpeedUp")
		{
			var scaryMode:Bool = Math.random() < 0.5;

			var endSpeed:Float = Math.random() < 0.9 ? Math.random() * 10 : Math.random() * 2 - 1;
			var startSpeed:Float;
			if (endSpeed == 1)
			{
				// If endSpeed is exactly 1, startSpeed is a random float between -0.1 and 0.1
				startSpeed = Math.random() < 0.5 ? Math.random() * 0.1 : -Math.random() * 0.1;
			}
			else if (endSpeed > 1)
			{
				startSpeed = Math.random() * 1.1 - 0.1;
			}
			else
			{
				startSpeed = Math.random() * 1;
			}
			var speedMultiplier:Float = 0;
			var currentMultiplier:Float = 0;
			if (scaryMode)
			{
				speedMultiplier = (endSpeed - startSpeed) / unspawnNotes.length;
			}
			else
			{
				var nonSustainNotes = unspawnNotes.filter(function(note) return !note.isSustainNote);
				speedMultiplier = (endSpeed - startSpeed) / nonSustainNotes.length;
			}
			trace("startSpeed: " + startSpeed);
			trace("endSpeed: " + endSpeed);
			trace("speedMultiplier: " + speedMultiplier);
			trace("currentMultiplier: " + currentMultiplier);
			trace("scaryMode: " + scaryMode);
			trace("noteIndex: " + noteIndex);
			for (i in 0...unspawnNotes.length)
			{
				if (unspawnNotes[i] != null)
				{
					if (scaryMode)
					{
						currentMultiplier += speedMultiplier;
						var noteIndex = unspawnNotes[i].noteIndex;
						var multSpeed = unspawnNotes[i].multSpeed;
						var newMultSpeed = currentMultiplier;
						unspawnNotes[i].multSpeed = newMultSpeed;
					}
					else if (!scaryMode && !unspawnNotes[i].isSustainNote)
					{
						currentMultiplier += speedMultiplier;
						var noteIndex = unspawnNotes[i].noteIndex;
						var multSpeed = unspawnNotes[i].multSpeed;
						var newMultSpeed = currentMultiplier;
						unspawnNotes[i].multSpeed = newMultSpeed;
					}
				}
			}
			if (!scaryMode)
			{
				for (i in 0...unspawnNotes.length)
				{
					if (unspawnNotes[i] != null)
					{
						if (unspawnNotes[i].isSustainNote)
						{
							for (note in unspawnNotes)
							{
								if (note != null && !note.isSustainNote && note.noteIndex == unspawnNotes[i].noteIndex)
								{
									unspawnNotes[i].multSpeed = note.multSpeed;
									break;
								}
							}
						}
					}
				}
			}
		}
	}

	public function getNoteInitialTime(time:Float)
	{
		var event:SpeedEvent = getSV(time);
		return getTimeFromSV(time, event);
	}

	function ease(e:EaseFunction, t:Float, b:Float, c:Float, d:Float)
	{ // elapsed, begin, change (ending-beginning), duration
		var time = t / d;
		return c * e(time) + b;
	}

	public inline function getTimeFromSV(time:Float, event:SpeedEvent)
		return event.position + (modManager.getBaseVisPosD(time - event.songTime, 1) * event.speed);

	public function getSV(time:Float)
	{
		var event:SpeedEvent = {
			position: 0,
			songTime: 0,
			startTime: 0,
			startSpeed: 1,
			speed: 1
		};
		for (shit in speedChanges)
		{
			if (shit.startTime <= time && shit.startTime >= event.startTime)
			{
				if (shit.startSpeed == null)
					shit.startSpeed = event.speed;
				event = shit;
			}
		}

		return event;
	}

	public inline function getVisualPosition()
		return getTimeFromSV(Conductor.songPosition, currentSV);

	function eventPushed(event:EventNote)
	{
		switch (event.event)
		{
			case 'Mult SV' | 'Constant SV':
				var speed:Float = 1;
				if (event.event == 'Constant SV')
				{
					var b = Std.parseFloat(event.value1);
					speed = Math.isNaN(b) ? songSpeed : (songSpeed / b);
				}
				else
				{
					speed = Std.parseFloat(event.value1);
					if (Math.isNaN(speed))
						speed = 1;
				}

				speedChanges.sort(svSort);
				speedChanges.push({
					position: getNoteInitialTime(event.strumTime),
					songTime: event.strumTime,
					startTime: event.strumTime,
					speed: speed
				});
			case 'Change Character':
				var charType:Int = 0;
				switch (event.value1.toLowerCase())
				{
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					case 'dad2' | 'opponent2' | '2':
						charType = 3;
					default:
						charType = Std.parseInt(event.value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'False Timer':
				if (timerExtensions == null)
					timerExtensions = new Array();

				timerExtensions.push(event.strumTime);
				maskedSongLength = timerExtensions[0];

			case 'Play Sound':
				Paths.sound(event.value1); // Precache sound
		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		eventsPushed.push(event.event);
	}

	function eventEarlyTrigger(event:EventNote):Float
	{
		var returnedValue:Null<Float> = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true, [], [0]);
		if (returnedValue != null && returnedValue != 0 && returnedValue != LuaUtils.Function_Continue)
		{
			return returnedValue;
		}

		switch (event.event)
		{
			case 'Kill Henchmen': // Better timing so that the kill sound matches the beat intended
				return 280; // Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function sortByOrderNote(wat:Int, Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.zIndex, Obj2.zIndex);

	function sortByOrderStrumNote(wat:Int, Obj1:StrumNote, Obj2:StrumNote):Int
		return FlxSort.byValues(FlxSort.DESCENDING, Obj1.zIndex, Obj2.zIndex);

	function sortByNotes(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [
			subEvent.event,
			subEvent.value1 != null ? subEvent.value1 : '',
			subEvent.value2 != null ? subEvent.value2 : '',
			subEvent.strumTime
		]);
	}

	function svSort(Obj1:SpeedEvent, Obj2:SpeedEvent):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.startTime, Obj2.startTime);
	}

	public var skipArrowStartTween:Bool = false; // for lua

	private function generateStaticArrows(player:Int):Void
	{
		/* 		var targetAlpha:Float = 1;
			if (player < 1){
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			for (i in 0...4){
				var babyArrow:StrumNote = new StrumNote(
					ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X,
					ClientPrefs.downScroll ? FlxG.height - 162 : 50,
					i
				);

				babyArrow.downScroll = ClientPrefs.downScroll;

				if (!isStoryMode && !skipArrowStartTween)
				{
					//babyArrow.y -= 10;
					babyArrow.alpha = 0;
					FlxTween.tween(babyArrow, {alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				}
				else
				{
					babyArrow.alpha = targetAlpha;
				}

				if (player == 1)
				{
					playerStrums.add(babyArrow);
				}
				else
				{
					if(ClientPrefs.middleScroll)
					{
						babyArrow.x += 310;
						if(i > 1) { //Up and Right
							babyArrow.x += FlxG.width * 0.5 + 25;
						}
					}
					opponentStrums.add(babyArrow);
				}

				strumLineNotes.add(babyArrow);
				babyArrow.postAddedToGroup();
		}*/
	}

	function updateNote(note:Note)
	{
		var tMania:Int = mania + 1;
		var noteData:Int = note.noteData;

		note.scale.set(1, 1);
		note.updateHitbox();

		/*
			if (!isPixelStage) {
				note.setGraphicSize(Std.int(note.width * Note.noteScales[mania]));
				note.updateHitbox();
			} else {
				note.setGraphicSize(Std.int(note.width * daPixelZoom * (Note.noteScales[mania] + 0.3)));
				note.updateHitbox();
			}
		 */

		// Like reloadNote()

		var lastScaleY:Float = note.scale.y;
		if (isPixelStage)
		{
			// if (note.isSustainNote) {note.originalHeightForCalcs = note.height;}

			note.setGraphicSize(Std.int(note.width * daPixelZoom * Note.pixelScales[mania]));
		}
		else
		{
			// Like loadNoteAnims()

			note.setGraphicSize(Std.int(note.width * Note.scales[mania]));
			note.updateHitbox();
		}

		if (note.isSustainNote)
		{
			note.scale.y = lastScaleY;
		}
		note.updateHitbox();

		// Like new()

		var prevNote:Note = note.prevNote;

		if (note.isSustainNote && prevNote != null)
		{
			note.offsetX += note.width / 2;

			note.animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' tail');

			note.updateHitbox();

			note.offsetX -= note.width / 2;

			if (note != null && prevNote != null && prevNote.isSustainNote && prevNote.animation != null)
			{ // haxe flixel
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[noteData % tMania] + ' hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				prevNote.scale.y *= songSpeed;

				if (isPixelStage)
				{
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / note.height);
				}

				prevNote.updateHitbox();
				// trace(prevNote.scale.y);
			}

			if (isPixelStage)
			{
				prevNote.scale.y *= daPixelZoom * (Note.pixelScales[mania]); // Fuck urself
				prevNote.updateHitbox();
			}
		}
		else if (!note.isSustainNote && noteData > -1 && noteData < tMania)
		{
			if (note.changeAnim)
			{
				var animToPlay:String = '';

				animToPlay = Note.keysShit.get(mania).get('letters')[noteData % tMania];

				note.animation.play(animToPlay);
			}
		}

		// Like set_noteType()
	}

	public function changeMania(newValue:Int, skipStrumFadeOut:Bool = false, ?modifyNotes = false)
	{
		if (chartModifier == '4K Only' || chartModifier == 'maniaConverter')
			return;
		var daOldMania = mania;

		mania = newValue;

		playerField.strumNotes = [];
		dadField.strumNotes = [];
		setOnScripts('mania', mania);

		notes.forEachAlive(function(note:Note)
		{
			updateNote(note);
		});

		for (noteI in 0...allNotes.length)
		{
			var note:Note = allNotes[noteI];
			updateNote(note);
		}

		setOnScripts('onChangeMania', [mania, daOldMania]);

		callOnScripts('preReceptorGeneration'); // backwards compat, deprecated
		callOnScripts('onReceptorGeneration');

		for (field in playfields.members)
		{
			field.keyCount = Note.ammo[mania];
			if (modifyNotes)
			{
				for (note in allNotes)
				{
					field.unqueue(note);
					field.queue(note);
				}
			}
			field.generateStrums();
		}

		callOnScripts('postReceptorGeneration'); // deprecated
		callOnScripts('onReceptorGenerationPost');

		for (field in playfields.members)
			field.fadeIn(isStoryMode || skipArrowStartTween); // TODO: check if its the first song so it should fade the notes in on song 1 of story mode
	}

	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				opponentVocals.pause();
				gfVocals.pause();
				for (track in tracks)
					track.pause();
			}

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished)
				tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished)
				twn.active = false);
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		super.closeSubState();
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (paused)
		{
			paused = false;

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished)
				tmr.active = true);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished)
				twn.active = true);
			callOnScripts('onResume');
			resetRPC(startTimer != null && startTimer.finished);

			if (gf != null && !Crashed)
			{
				#if desktop
				if (startTimer != null && startTimer.finished)
				{
					DiscordClient.changePresence(detailsText, SONG.song
						+ " ("
						+ storyDifficultyText
						+ ")",
						if (playAsGF && gf != null) iconGF.getCharacter() else iconP2.getCharacter(), true,
						songLength
						- Conductor.songPosition
						- ClientPrefs.data.noteOffset);
				}
				else
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")",
						if (playAsGF && gf != null) iconGF.getCharacter() else iconP2.getCharacter());
				}
				#end
			}
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		if (!startingSong && startedCountdown && !endingSong && !paused && lostFocus)
		{
			if (FlxG.sound.music != null)
			{
				resyncVocals();
			}
			lostFocus = false;
		}
		if (gf != null)
		{
			resetRPC(Conductor.songPosition > 0.0);
		}

		super.onFocus();
	}

	var lostFocus = false;

	override public function onFocusLost():Void
	{
		if (!Crashed)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				if (vocals != null) vocals.pause();
				if (opponentVocals != null) opponentVocals.pause();
				if (gfVocals != null) gfVocals.pause();
				if (tracks != null)
				{
					for (track in tracks)
						track.pause();
				}
			}
			lostFocus = true;
			if (gf != null)
			{
				#if DISCORD_ALLOWED
				if (health > 0 && !paused)
				{
					DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")",
						if (playAsGF && gf != null) iconGF.getCharacter() else iconP2.getCharacter());
				}
				#end
			}
		}

		super.onFocusLost();
	}

	public function newPlayfield()
	{
		var field = new PlayField(modManager);
		field.modNumber = playfields.members.length;
		field.cameras = playfields.cameras;
		initPlayfield(field);
		playfields.add(field);
		return field;
	}

	// good to call this whenever you make a playfield
	public function initPlayfield(field:PlayField)
	{
		notefields.add(field.noteField);

		field.judgeManager = ratingsData[0];
		field.holdPressCallback = stepHold;
		field.holdReleaseCallback = dropHold;

		field.noteRemoved.add((note:Note, field:PlayField) ->
		{
			allNotes.remove(note);
			unspawnNotes.remove(note);
			notes.remove(note);
		});
		field.noteMissed.add((daNote:Note, field:PlayField) ->
		{
			if (field.isPlayer && !field.autoPlayed && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
				noteMiss(daNote, field);
		});
		field.noteSpawned.add((dunceNote:Note, field:PlayField) ->
		{
			callOnScripts('onSpawnNote', [dunceNote]);
			#if LUA_ALLOWED
			callOnLuas('onSpawnNote', [
				allNotes.indexOf(dunceNote),
				dunceNote.column,
				dunceNote.noteType,
				dunceNote.isSustainNote,
				dunceNote.strumTime
			]);
			#end

			notes.add(dunceNote);
			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.splice(index, 1);

			callOnScripts('onSpawnNotePost', [dunceNote]);
		});
	}

	// Updating Discord Rich Presence.
	function resetRPC(?cond:Bool = false)
	{
		#if desktop
		if (cond && !Crashed)
			DiscordClient.changePresence(detailsText, SONG.song
				+ " ("
				+ storyDifficultyText
				+ ")", iconP2.getCharacter(), true,
				songLength
				- Conductor.songPosition
				- ClientPrefs.data.noteOffset);
		else if (!Crashed)
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	var cutsceneHandler:CutsceneHandler;
	function fanfrenCutPrep()
	{
		cutsceneHandler = new CutsceneHandler();

		camHUD.visible = false;
		cutsceneHandler.finishCallback = function()
		{
			trace("Cutscene Finished! Starting Song!");
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			startCountdown();

			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};
		camFollow.setPosition(boyfriend.x + 280, boyfriend.y + 170);
	}

	function fanfrenOpenPrep()
	{
		fanfrenCutPrep();
		cutsceneHandler.endTime = 13;
		//FlxG.camera.zoom *= 1.2;
		boyfriend.alpha = 0.00001;
		gf.alpha = 0.00001;
		bf2.alpha = 0.00001;
		dad2.alpha = 0.00001;
		Paths.sound('pop');
		Paths.sound('ayy');

		cutsceneHandler.finishCallback = function()
		{
			FlxG.sound.music.volume = 0;
		};

		cutsceneHandler.timer(1, function()
		{
			boyfriend.alpha = 1;
			FlxG.sound.play(Paths.sound('pop'));
		});

		cutsceneHandler.timer(4, function()
		{
			boyfriend.playAnim("hey", true);
		});

		cutsceneHandler.timer(4.3, function()
		{
			//sync with the actual HEY part of the animation
			FlxG.sound.play(Paths.sound('ayy'));
		});

		cutsceneHandler.timer(4.6, function()
		{
			camFollow.x -= 750;
			camFollow.y -= 200;
		});

		cutsceneHandler.timer(6, function()
		{
			FlxG.sound.playMusic(Paths.music("The Shift"), 1, true);
			boyfriend.playAnim("idle", true);
			cutsceneHandler.pauseCutscene = true;
			startCutDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogueIntro1')));
		});

		cutsceneHandler.timer(7, function()
		{
			bf2.alpha = 1;
			FlxG.sound.play(Paths.sound('pop'));
		});

		cutsceneHandler.timer(8, function()
		{
			FlxG.sound.music.fadeOut(1, 1);
			cutsceneHandler.pauseCutscene = true;
			startCutDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogueIntro2')));
		});

		cutsceneHandler.timer(9, function()
		{
			dad2.alpha = 1;
			FlxG.sound.play(Paths.sound('pop'));
		});

		cutsceneHandler.timer(10, function()
		{
			FlxG.sound.music.fadeOut(1, 1);
			cutsceneHandler.pauseCutscene = true;
			startCutDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogueIntro3')));
		});

		cutsceneHandler.timer(11, function()
		{
			camFollow.x += (750/4);
			camFollow.y -= 100;
			gf.alpha = 1;
			FlxG.sound.play(Paths.sound('pop'));
		});

		cutsceneHandler.timer(12, function()
		{
			FlxG.sound.music.fadeOut(1, 1);
			cutsceneHandler.pauseCutscene = true;
			startCutDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogueIntro4')));
		});

		cutsceneHandler.timer(12.5, function()
		{
			trace("Cutscene Finished! Starting Song!");
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			startCountdown();
			moveCamera(true);

			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
			//Force end the cutscene cuz it doesn't wanna end by itself
		});

	}

	function ffOpenPrep()
	{
		startVideo('fanta_cutscene_wip_lol');
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var countActive:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;
	var alreadyChanged:Bool = false;
	var camResize:Float = 0;
	var freezeCamera:Bool = false;
	var allowDebugKeys:Bool = true;

	function die():Void
	{
		bfkilledcheck = true;
		doDeathCheck(true);
		health = 0;
		noteMissPress(3); // just to make sure you actually die
	}

	var didntPress:Bool = false;

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		if (!isStoryMode && playbackRate == 1)
		{
			var daNote:Note = allNotes[-1];
			if (daNote != null && daNote.strumTime > 100)
			{
				needSkip = true;
				skipTo = daNote.strumTime - 100;
			}
			else
			{
				needSkip = false;
			}
			
		}

		if (chartModifier == '4K Only' && mania != 3)
			changeMania(3);

		for (field in playfields)
			field.noteField.songSpeed = songSpeed;

		for (playfield in playfields.members)
		{
			if (playfield.isPlayer)
				playfield.autoPlayed = cpuControlled;
		}

		if (cpuControlled) hadBotplayOn = true;

		if (noteHits.length > 0)
		{
			while (noteHits.length > 0 && (noteHits[0] + 2000) < Conductor.songPosition)
				noteHits.shift();
		}

		nps = Math.floor(noteHits.length / 2);
		FlxG.watch.addQuick("notes per second", nps);

		if (!inCutscene && !paused && !freezeCamera)
		{
			FlxG.camera.followLerp = 2.4 * cameraSpeed * playbackRate;
			if (!startingSong && !endingSong && boyfriend.getAnimationName().startsWith('idle'))
			{
				boyfriendIdleTime += elapsed;
				if (boyfriendIdleTime >= 0.15)
				{ // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			}
			else
			{
				boyfriendIdleTime = 0;
			}
		}
		else
			FlxG.camera.followLerp = 0;

		/*shaders.ShadersHandler.updateRain(elapsed);
			shaders.ShadersHandler.setRainIntensity(rainIntensity);
			shaders.ShadersHandler.setRainScale(FlxG.height / 200); */

		callOnScripts('onUpdate', [elapsed]);

		setOnScripts('curDecStep', curDecStep);
		setOnScripts('curDecBeat', curDecBeat);

		if (dad.curCharacter.startsWith('gf'))
		{
			// Do Nothing
		}
		else
		{
			if (gf != null)
			{
				var changed:Bool = false;
				if (!changed && combo > 20 && gf.curCharacter == 'gf')
				{
					triggerEvent('Change Character', '2', 'gf-cheer', Conductor.crochet);
					changed = true;
				}
				if (justmissed && gf.curCharacter == 'gf-cheer')
				{
					triggerEvent('Change Character', '2', 'gf', Conductor.crochet);
					changed = false;
				}
			}
		}

		if (justmissed && boyfriend.animation.curAnim.name == 'idle')
		{
			justmissed = false;
			boyfriend.stunned = false;
		}

		if (strumFocus && !playAsGF)
		{
			if (SONG.notes[curSection].mustHitSection && !SONG.notes[curSection].exSection)
			{
				modManager.queueEase(curStep, curStep+4, 'alpha', 1, 'sineInOut', 0);
				modManager.queueEase(curStep, curStep+4, 'alpha', 0, 'sineInOut', 1);
			}
			else if (!SONG.notes[curSection].mustHitSection && !SONG.notes[curSection].exSection)
			{
				modManager.queueEase(curStep, curStep+4, 'alpha', 1, 'sineInOut', 1);
				modManager.queueEase(curStep, curStep+4, 'alpha', 0, 'sineInOut', 0);
			}
		}
		else if (startingSong)
		{
			for (i in 0...playerStrums.length)
			{
				FlxTween.tween(playerStrums.members[i], {alpha: 1}, 0.1, {ease: FlxEase.sineInOut});
			}
			for (i in 0...opponentStrums.length)
			{
				FlxTween.tween(opponentStrums.members[i], {alpha: 1}, 0.1, {ease: FlxEase.sineInOut});
			}
			for (i in 0...opponentStrums2.length)
			{
				FlxTween.tween(opponentStrums2.members[i], {alpha: 1}, 0.1, {ease: FlxEase.sineInOut});
			}
		}

		if (cpuControlled && !alreadyChanged && !playAsGF)
		{
			botplayTxt.color = FlxColor.RED;
			botplayTxt.visible = true;
			scoreTxt.visible = false;
			alreadyChanged = true;
			switch (FlxG.random.int(1, 5))
			{
				case 1:
					botplayTxt.text = "CHEATER'S NEVER PROSPER";
				case 2:
					botplayTxt.text = "NOT COOL, DUDE.";
				case 3:
					botplayTxt.text = "SMH. I THOUGHT YOU WERE BETTER.";
				case 4:
					botplayTxt.text = "YOU BOT";
				case 5:
					botplayTxt.text = "POV: SONG TOO HARD";
			}
		}
		else if (!cpuControlled && alreadyChanged && !playAsGF)
		{
			botplayTxt.color = FlxColor.fromInt(CoolUtil.dominantColor(iconP2));
			scoreTxt.visible = true;
			botplayTxt.visible = false;
			switch (FlxG.random.int(1, 5))
			{
				case 1:
					botplayTxt.text = "CHEATER'S NEVER PROSPER";
				case 2:
					botplayTxt.text = "NOT COOL, DUDE.";
				case 3:
					botplayTxt.text = "SMH. I THOUGHT YOU WERE BETTER.";
				case 4:
					botplayTxt.text = "YOU BOT";
				case 5:
					botplayTxt.text = "POV: SONG TOO HARD";
			}
			alreadyChanged = false;
		}
		else if (playAsGF)
		{
			botplayTxt.color = Std.parseInt("0xFFFF0000");
			scoreTxt.visible = true;
			botplayTxt.visible = true;
			botplayTxt.text = "GFPLAY";
		}
		else if (playAsGF && cpuControlled)
		{
			botplayTxt.color = FlxColor.fromInt(CoolUtil.dominantColor(iconP2));
			scoreTxt.visible = true;
			botplayTxt.visible = true;
			botplayTxt.text = "GFPLAY\n(What song are you playing that you can't tap to the beat?)";
		}

		rotRateSh = curStep / 9.5;
		var sh_toy = -Math.sin(rotRateSh * 2) * sh_r * 0.45;
		var sh_tox = -Math.cos(rotRateSh) * sh_r;

		if (fly)
		{
			if (SONG.notes[curSection] != null && !SONG.notes[curSection].mustHitSection)
				moveCameraSection();

			dad.x += 40 + (sh_tox - dad.x) / 12;
			dad.y += 35 + (sh_toy - dad.y) / 12;
			if (dad.animation.name == 'idle')
			{
				sh_r += (60 - sh_r) / 32;
				var pene = 0.07;
				dad.angle = Math.sin(rotRateSh) * sh_r * pene / 4;
			}
			else
			{
				sh_r += (60 - sh_r) / 32;
				dad.angle = 0;
			}
		}

		// Handle restarting the song when needed (player death or pressing Retry)
		// I'll make this work later
		if (needsReset)
		{
			callOnScripts('onSongRestart');

			moveCamera(true);

			var fromDeathState = isPlayerDying;

			persistentUpdate = true;
			persistentDraw = true;

			startingSong = true;
			isPlayerDying = false;

			boyfriend.stunned = true;

			// Reset music properly.
			if (FlxG.sound.music != null)
			{
				Conductor.songPosition = -5000;
				FlxG.sound.music.stop();

				Conductor.crochet = 0;
				Conductor.stepCrochet = 0;
				Conductor.visualPosition = 0;
			}

			if (opponentVocals != null)
				opponentVocals.pause();
			if (gfVocals != null)
				gfVocals.pause();
			vocals.pause();
			if (opponentVocals != null)
				opponentVocals.time = 0;
			if (gfVocals != null)
				gfVocals.time = 0;
			vocals.time = 0;

			if (FlxG.sound.music != null)
				FlxG.sound.music.volume = 1;
			vocals.volume = 1;
			if (opponentVocals != null)
				opponentVocals.volume = 1;
			if (gfVocals != null)
				gfVocals.volume = 1;

			if (!fromDeathState)
			{
				vwooshNotes();
			}

			// Delete all notes and reset the arrays.
			allNotes = curChart;
			unspawnNotes = curChart;

			health = 1;
			songScore = 0;
			combo = 0;
			startedCountdown = false;
			restartCountdown();

			needsReset = false;
		}

		super.update(elapsed);

		if (AIPlayer.active)
		{
			var AIAccuracy:Float = AITotalNotesHit / AITotalPlayed;

			if (Math.isNaN(AIAccuracy))
				AIAccuracy = 0;

			var AIRank:String = '';

			if (AITotalPlayed < 1) // Prevent divide by 0
				AIRank = '?';
			else
			{
				// Rating Percent
				// trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if (AIAccuracy >= 1)
				{
					AIRank = ratingStuff[ratingStuff.length - 1][0]; // Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length - 1)
					{
						if (AIAccuracy < ratingStuff[i][1])
						{
							AIRank = ratingStuff[i][0];
							break;
						}
					}
				}
			}
			AIAccuracy = CoolUtil.floorDecimal((AITotalNotesHit / AITotalPlayed) * 100, 2);

			var curRank = '?';

			if (AIRank == '?')
				curRank = '[Rating] ?';
			else
				curRank = AIRank + ' (' + CoolUtil.formatAccuracy(AIAccuracy) + '%)';

			aiText = '\n [AI] // Score: ' + AIScore + ' // Misses: ' + AIMisses + ' // Rating: ' + ratingNameAI;
		}

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if (!playAsGF)
		{
			if (health <= 0)
			{
				scoreTxt.text = "DON'T MISS!";
				scoreTxt.color = Std.parseInt("0xFFFF0000");
			}
			else if (ratingName == '?')
			{
				scoreTxt.color = Std.parseInt("0xFFFFE600");
				scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' | NPS: ' + nps;
			}
			else
			{
				scoreTxt.color = Std.parseInt("0xFFFFFFFF");
				scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' ('
					+ Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC + ' | NPS: ' + nps; // peeps wanted no integer rating
			}
			if (AIPlayer.active)
			{
				scoreTxt.y -= 50;
				scoreTxt.text += aiText;
			}
		}
		else
		{
			scoreTxt.text = 'Combo: ' + gfBopCombo + ' | Highest Combo: ' + gfBopComboBest + ' | Misses: ' + gfMisses;
		}

		if (botplayTxt.visible)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnScripts('onPause', null, true);
			if (ret != LuaUtils.Function_Stop)
			{
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					FlxG.camera.followLerp = 0;
					if (FlxG.sound.music != null)
					{
						FlxG.sound.music.pause();
						vocals.pause();
						opponentVocals.pause();
						gfVocals.pause();
						for (track in tracks)
							track.pause();
					}
					openSubState(new PauseSubStateLost(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				else
				{
					FlxG.camera.followLerp = 0;
					if (FlxG.sound.music != null)
					{
						FlxG.sound.music.pause();
						vocals.pause();
						opponentVocals.pause();
						gfVocals.pause();
						for (track in tracks)
							track.pause();
					}
					openSubState(new PauseSubState());
				}

				if (gf != null && !Crashed)
				{
					#if DISCORD_ALLOWED
					DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")",
						if (playAsGF && gf != null) iconGF.getCharacter() else iconP2.getCharacter());
					#end
				}
			}
		}

		if (!endingSong && !inCutscene && allowDebugKeys)
		{
			if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.SEVEN)
				openChartEditor(true);
			else if (FlxG.keys.justPressed.SEVEN)
				openChartEditor();
			else if (FlxG.keys.justPressed.EIGHT)
				openCharacterEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (playAsGF && !cpuControlled)
		{
			if (gf != null)
			{
				// this part is here for latency reasons
				// (cuz some people dont have rhythm)
				// also yeah i know there are better ways of doing it nut this took me weeks so if you wanna make it better be my guest and let me know
				if (((curStep % 16 / gfSpeed == 0 || curStep % 16 / gfSpeed == 8)
					|| (curStep % 16 / gfSpeed == 1 || curStep % 16 / gfSpeed == 9)
					|| (curStep % 16 / gfSpeed == 2 || curStep % 16 / gfSpeed == 10))
					&& gf.animation.curAnim.name != null
					&& gf.animation.curAnim.name == 'danceLeft')
				{
					if (FlxG.keys.justPressed.LEFT)
					{
						goodGFBop();
					}
				}
				else if (((curStep % 16 / gfSpeed == 4 || curStep % 16 / gfSpeed == 12)
					|| (curStep % 16 / gfSpeed == 5 || curStep % 16 / gfSpeed == 13)
					|| (curStep % 16 / gfSpeed == 6 || curStep % 16 / gfSpeed == 14))
					&& gf.animation.curAnim.name != null
					&& gf.animation.curAnim.name == 'danceRight')
				{
					if (FlxG.keys.justPressed.RIGHT)
					{
						goodGFBop();
					}
				}
				if ((((curStep % 16 / gfSpeed == 0 || curStep % 16 / gfSpeed == 8)
					|| (curStep % 16 / gfSpeed == 1 || curStep % 16 / gfSpeed == 9)
					|| (curStep % 16 / gfSpeed == 2 || curStep % 16 / gfSpeed == 10))
					&& gf.animation.curAnim.name != null
					&& gf.animation.curAnim.name == 'danceLeft'
					&& !didLastBeat)
					|| (((curStep % 16 / gfSpeed == 4 || curStep % 16 / gfSpeed == 12)
						|| (curStep % 16 / gfSpeed == 5 || curStep % 16 / gfSpeed == 13)
						|| (curStep % 16 / gfSpeed == 6 || curStep % 16 / gfSpeed == 14))
						&& gf.animation.curAnim.name != null
						&& gf.animation.curAnim.name == 'danceRight'
						&& !didLastBeat))
				{
					if (!didntPress)
					{
						didntPress = true;
					}
				}

				if (!((curStep % 16 / gfSpeed == 0 || curStep % 16 == 8) || (curStep % 16 / gfSpeed == 1 || curStep % 16 / gfSpeed == 9))
					&& gf.animation.curAnim.name != null
					&& gf.animation.curAnim.name == 'danceLeft')
				{
					if (FlxG.keys.justPressed.LEFT)
					{
						badGFBop();
					}
				}
				else if (!((curStep % 16 / gfSpeed == 4 || curStep % 16 / gfSpeed == 12)
					|| (curStep % 16 / gfSpeed == 5 || curStep % 16 / gfSpeed == 13))
					&& gf.animation.curAnim.name != null
					&& gf.animation.curAnim.name == 'danceRight')
				{
					if (FlxG.keys.justPressed.RIGHT)
					{
						badGFBop();
					}
				}
			}
			else
			{
				// this part is here for latency reasons
				// (cuz some people dont have rhythm)
				// does this even work?!?
				if (((curStep % 16 / gfSpeed == 0 || curStep % 16 / gfSpeed == 8)
					|| (curStep % 16 / gfSpeed == 1 || curStep % 16 / gfSpeed == 9)
					|| (curStep % 16 / gfSpeed == 2 || curStep % 16 / gfSpeed == 10)))
				{
					if (FlxG.keys.justPressed.LEFT)
					{
						goodGFBop();
					}
				}
				else if (((curStep % 16 / gfSpeed == 4 || curStep % 16 / gfSpeed == 12)
					|| (curStep % 16 / gfSpeed == 5 || curStep % 16 / gfSpeed == 13)
					|| (curStep % 16 / gfSpeed == 6 || curStep % 16 / gfSpeed == 14)))
				{
					if (FlxG.keys.justPressed.RIGHT)
					{
						goodGFBop();
					}
				}
				if ((((curStep % 16 / gfSpeed == 0 || curStep % 16 / gfSpeed == 8)
					|| (curStep % 16 / gfSpeed == 1 || curStep % 16 / gfSpeed == 9)
					|| (curStep % 16 / gfSpeed == 2 || curStep % 16 / gfSpeed == 10))
					&& !didLastBeat)
					|| (((curStep % 16 / gfSpeed == 4 || curStep % 16 / gfSpeed == 12)
						|| (curStep % 16 / gfSpeed == 5 || curStep % 16 / gfSpeed == 13)
						|| (curStep % 16 / gfSpeed == 6 || curStep % 16 / gfSpeed == 14))
						&& !didLastBeat))
				{
					if (!didntPress)
					{
						didntPress = true;
					}
				}

				if (!((curStep % 16 / gfSpeed == 0 || curStep % 16 == 8) || (curStep % 16 / gfSpeed == 1 || curStep % 16 / gfSpeed == 9)))
				{
					if (FlxG.keys.justPressed.LEFT)
					{
						badGFBop();
					}
				}
				else if (!((curStep % 16 / gfSpeed == 4 || curStep % 16 / gfSpeed == 12)
					|| (curStep % 16 / gfSpeed == 5 || curStep % 16 / gfSpeed == 13)))
				{
					if (FlxG.keys.justPressed.RIGHT)
					{
						badGFBop();
					}
				}
			}
		}

		if (health > MaxHP)
			health = MaxHP;
		if (health < 0)
			health = 0;

		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (skipActive && Conductor.songPosition >= skipTo)
		{
			remove(skipText);
			skipActive = false;
		}

		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			clearNotesBefore(skipTo);
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
			gfVocals.pause();
			for (track in tracks)
				track.pause();
			Conductor.songPosition = skipTo;

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			opponentVocals.time = Conductor.songPosition;
			opponentVocals.play();
			gfVocals.time = Conductor.songPosition;
			gfVocals.play();
			for (track in tracks)
			{
				track.time = Conductor.songPosition;
				track.play();
			}
			FlxTween.tween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}

		updateIconsScale(elapsed);
		updateIconsPosition();

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if (!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (updateTime)
				{
					var timeBarType:String = ClientPrefs.data.timeBarType;
					var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
					var lengthUsing:Float = (maskedSongLength > 0) ? maskedSongLength : songLength;

					songPercent = (curTime / lengthUsing);

					var songCalc:Float = (lengthUsing - curTime);
					if (ClientPrefs.data.timeBarType == 'Time Elapsed')
						songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;

					if (ClientPrefs.data.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (chromOn)
		{
			ch = FlxG.random.int(1, 5) / 1000;
			ch = FlxG.random.int(1, 5) / 1000;
			shaders.ShadersHandler.setChrome(ch);
			shaders.ShadersHandler.setTriangleX(ch);
			shaders.ShadersHandler.setTriangleY(ch);
			// ShadersHandler.setRadialBlur(640+(FlxG.random.int(-100,100)),360+(FlxG.random.int(-100,100)),FlxG.random.float(0.001,0.005));
			// ShadersHandler.setRadialBlur(640+(FlxG.random.int(-10,10)),360+(FlxG.random.int(-10,10)),FlxG.random.float(0.001,0.005));
		}
		else
		{
			if (!beatchrom)
			{
				shaders.ShadersHandler.setChrome(0);
			}
			// ShadersHandler.setRadialBlur(0,0,0);
			shaders.ShadersHandler.setTriangleX(0);
			shaders.ShadersHandler.setTriangleY(0);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
		}

		if (beatchrom)
		{
			abrrmult -= (Conductor.crochet / (400 / (defMult * 10))) * elapsed;
			if (abrrmult < 0)
				abrrmult = 0;
			shaders.ShadersHandler.setChrome(0.1 * abrrmult);
			beatchromfaster = false;
			beatchromfastest = false;
			beatchromslow = false;
		}
		else if (beatchromfaster)
		{
			abrrmult -= (Conductor.crochet / (400 / (defMult * 10))) * elapsed;
			if (abrrmult < 0)
				abrrmult = 0;
			shaders.ShadersHandler.setChrome(0.1 * abrrmult);
			beatchrom = false;
			beatchromfastest = false;
			beatchromslow = false;
		}
		else if (beatchromfastest)
		{
			abrrmult -= (Conductor.crochet / (400 / (defMult * 10))) * elapsed;
			if (abrrmult < 0)
				abrrmult = 0;
			shaders.ShadersHandler.setChrome(0.1 * abrrmult);
			beatchrom = false;
			beatchromfaster = false;
			beatchromslow = false;
		}
		else if (beatchromslow)
		{
			abrrmult -= (Conductor.crochet / (400 / (defMult * 10))) * elapsed;
			if (abrrmult < 0)
				abrrmult = 0;
			shaders.ShadersHandler.setChrome(0.1 * abrrmult);
			beatchrom = false;
			beatchromfaster = false;
			beatchromfastest = false;
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		daStatic.animation.play('static');

		currentSV = getSV(Conductor.songPosition);
		if (!freezeNotes) Conductor.visualPosition = getVisualPosition();
		FlxG.watch.addQuick("visualPos", Conductor.visualPosition);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.data.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			die();
			trace("RESET = True");
		}
		doDeathCheck();
		modManager.update(elapsed, curDecBeat, curDecStep);

		if (generatedMusic)
		{
			if (!inCutscene)
			{
				if (!cpuControlled || !playAsGF)
				{
					keyShit();
				}
				else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
					&& boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance();
					// boyfriend.animation.curAnim.finish();
				}
				if (bf2 != null
					&& bf2.holdTimer > Conductor.stepCrochet * 0.001 * bf2.singDuration
					&& bf2.animation.curAnim.name.startsWith('sing')
					&& !bf2.animation.curAnim.name.endsWith('miss'))
				{
					bf2.dance();
					// boyfriend.animation.curAnim.finish();
				}
				for (field in playfields)
				{
					if (field.isPlayer)
					{
						for (char in field.characters)
						{
							if (char.animation.curAnim != null
								&& char.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * char.singDuration
									&& char.animation.curAnim.name.startsWith('sing')
									&& !char.animation.curAnim.name.endsWith('miss')
									&& (!pressedGameplayKeys.contains(true)))
								char.dance();
						}
					}
				}
			}
		}
		checkEventNote();

		#if debug
		if (!endingSong && !startingSong)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if (FlxG.keys.justPressed.TWO)
			{ // Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnScripts('cameraX', camFollow.x);
		setOnScripts('cameraY', camFollow.y);
		setOnScripts('botPlay', cpuControlled);
		callOnScripts('onUpdatePost', [elapsed]);
		for (i in shaderUpdates)
		{
			i(elapsed);
		}

		// TODO:Make this actually work again
		var center = [640, 360];
		var sizeMULT = 3;
		var speed_dividend = 30;
		var justdid:Bool = false;
		notes.forEachAlive(function(daNote:Note)
		{
			for (i in notes)
			{
				if (daNote.centerNote)
				{
					justdid = false;
					var mod = (FlxG.sound.music.time - i.strumTime) / 1000;
					i.scale.set((1 - mod * sizeMULT) * 0.7, (1 - mod * sizeMULT) * 0.7);
					if (i.scale.x < 0.7)
						i.scale.set(0, 0);
					i.updateHitbox();
					i.x = center[0] - i.width / 2;
					i.y = center[1] - i.height / 2;
					middlecircle.alpha = 1;
					var velocity = speed_dividend * SONG.speed;
					switch (i.noteData)
					{
						case 0:
							i.x += mod * (velocity * 10);
						case 1:
							i.y -= mod * (velocity * 10);
						case 2:
							i.y += mod * (velocity * 10);
						case 3:
							i.x -= mod * (velocity * 10);
						case 4:
							i.x += mod * (velocity * 10);
						case 5:
							i.y -= mod * (velocity * 10);
						case 6:
							i.y += mod * (velocity * 10);
						case 7:
							i.x -= mod * (velocity * 10);
						case 8:
							i.x += mod * (velocity * 10);
						case 9:
							i.y -= mod * (velocity * 10);
						case 10:
							i.y += mod * (velocity * 10);
						case 11:
							i.x -= mod * (velocity * 10);
						case 12:
							i.x += mod * (velocity * 10);
						case 13:
							i.y -= mod * (velocity * 10);
						case 14:
							i.y += mod * (velocity * 10);
						case 15:
							i.x -= mod * (velocity * 10);
						case 16:
							i.x += mod * (velocity * 10);
						case 17:
							i.y -= mod * (velocity * 10);
					}
					if (i.isSustainNote)
					{
						i.flipY = false;
						switch (i.noteData)
						{
							case 0:
								i.angle = 90;
							case 1:
								i.angle = 0;
							case 2:
								i.angle = 180;
							case 3:
								i.angle = -90;
							case 4:
								i.angle = 90;
							case 5:
								i.angle = 0;
							case 6:
								i.angle = 180;
							case 7:
								i.angle = -90;
							case 8:
								i.angle = 90;
							case 9:
								i.angle = 0;
							case 10:
								i.angle = 180;
							case 11:
								i.angle = -90;
							case 12:
								i.angle = 90;
							case 13:
								i.angle = 0;
							case 14:
								i.angle = 180;
							case 15:
								i.angle = -90;
							case 16:
								i.angle = 90;
							case 17:
								i.angle = 0;
						}
					}
					else
					{
						i.hitboxMultiplier = 5;
					}
				}
				else
				{
					middlecircle.alpha = 0;
				}
				// TODO:Make this actually work again
				if (notesCentered)
				{
					if (daNote.mustPress && notesCentered)
					{
						justdid = false;
						var mod = (FlxG.sound.music.time - i.strumTime) / 1000;
						i.scale.set((1 - mod * 3) * 0.7, (1 - mod * 3) * 0.7);
						if (i.scale.x < 0.7)
							i.scale.set(0, 0);
						i.screenCenter();
						strumLineNotes.members[i.noteData + (i.mustPress ? 4 : 0)].screenCenter();
						opponentStrums.forEach(function(spr:StrumNote)
						{
							spr.alpha = 0;
						});
						middlecircle.angle = (i.noteData + 90) - 90;
						var velocity = 60;
						switch (i.noteData)
						{
							case 0:
								i.x += mod * (velocity * 10);
							case 1:
								i.y -= mod * (velocity * 10);
							case 2:
								i.y += mod * (velocity * 10);
							case 3:
								i.x -= mod * (velocity * 10);
							case 4:
								i.x += mod * (velocity * 10);
							case 5:
								i.y -= mod * (velocity * 10);
							case 6:
								i.y += mod * (velocity * 10);
							case 7:
								i.x -= mod * (velocity * 10);
							case 8:
								i.x += mod * (velocity * 10);
							case 9:
								i.y -= mod * (velocity * 10);
							case 10:
								i.y += mod * (velocity * 10);
							case 11:
								i.x -= mod * (velocity * 10);
							case 12:
								i.x += mod * (velocity * 10);
							case 13:
								i.y -= mod * (velocity * 10);
							case 14:
								i.y += mod * (velocity * 10);
							case 15:
								i.x -= mod * (velocity * 10);
							case 16:
								i.x += mod * (velocity * 10);
							case 17:
								i.y -= mod * (velocity * 10);
						}
						if (i.isSustainNote)
						{
							i.flipY = false;
							switch (i.noteData)
							{
								case 0:
									i.angle = 90;
								case 1:
									i.angle = 0;
								case 2:
									i.angle = 180;
								case 3:
									i.angle = -90;
								case 4:
									i.angle = 90;
								case 5:
									i.angle = 0;
								case 6:
									i.angle = 180;
								case 7:
									i.angle = -90;
								case 8:
									i.angle = 90;
								case 9:
									i.angle = 0;
								case 10:
									i.angle = 180;
								case 11:
									i.angle = -90;
								case 12:
									i.angle = 90;
								case 13:
									i.angle = 0;
								case 14:
									i.angle = 180;
								case 15:
									i.angle = -90;
								case 16:
									i.angle = 90;
								case 17:
									i.angle = 0;
							}
						}
						else
						{
							i.hitboxMultiplier = 5;
						}
					}
					else
					{
						opponentStrums.forEach(function(spr:StrumNote)
						{
							spr.alpha = 1;
						});
					}
				}
			}
		});

		// TODO: Get this working or remove it, I personally dont care which
		if (circlefuntime) // no you
		{
			playerStrums.forEach(function(spr:StrumNote)
			{
				spr.z = ((FlxG.height / 2) - (spr.height / 1)) + (Math.cos((elapsed + (spr.ID)) * 4) * 300);
			});
			opponentStrums.forEach(function(spr:StrumNote)
			{
				spr.z = ((FlxG.height / 2) - (spr.height / 1)) + (Math.cos((elapsed + (spr.ID)) * 4) * 300);
			});
		}
	}

	/**
	 * Call this when resetting the playstate.
	 */
	public function vwooshNotes():Void
	{
		notes.forEachAlive(function(note:Note)
		{
			var targetY:Float = FlxG.height + note.y;
			if (ClientPrefs.data.downScroll)
				targetY = 0 - note.height;
			FlxTween.tween(note, {y: targetY}, 0.5, {
				ease: FlxEase.expoIn,
				onComplete: function(twn)
				{
					note.kill();
					note.destroy();
				}
			});
		});
	}

	// Health icon updaters
	public dynamic function updateIconsScale(elapsed:Float)
	{
		if (!playAsGF)
		{
			var mult:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 9 * playbackRate));
			iconP1.scale.set(mult, mult);
			iconP1.updateHitbox();

			var mult:Float = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 9 * playbackRate));
			iconP2.scale.set(mult, mult);
			iconP2.updateHitbox();

			var multA:Float = FlxMath.lerp(1, iconP1.angle, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			iconP1.angle = multA;

			var multA:Float = FlxMath.lerp(1, iconP2.angle, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			iconP2.angle = multA;

			if (dad2 != null)
			{
				var multA:Float = FlxMath.lerp(1, iconP22.angle, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
				iconP22.angle = multA;
				var mult:Float = FlxMath.lerp(1, iconP22.scale.x, Math.exp(-elapsed * 9 * playbackRate));
				iconP22.scale.set(mult, mult);
				iconP22.updateHitbox();
			}

			if (iconP12 != null)
			{
				var multA:Float = FlxMath.lerp(1, iconP12.angle, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
				iconP12.angle = multA;
				var mult:Float = FlxMath.lerp(1, iconP12.scale.x, Math.exp(-elapsed * 9 * playbackRate));
				iconP12.scale.set(mult, mult);
				iconP12.updateHitbox();
			}
		}
		else
		{
			if (gf != null)
			{
				var mult:Float = FlxMath.lerp(1, iconGF.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
				var multA:Float = FlxMath.lerp(1, iconGF.angle, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
				iconGF.angle = multA;
				iconGF.scale.set(mult, mult);
				iconGF.updateHitbox();
			}
		}
	}

	public dynamic function updateIconsPosition()
	{
		var iconOffset:Int = 26;
		if (!playAsGF)
		{
			iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
			if (dad2 != null) iconP22.x = iconP2.x - 25;
			if (iconP12 != null) iconP12.x = iconP1.x + 25;
		}
		else
		{
			iconGF.x = healthBarGF.getGraphicMidpoint().x - 95;
		}
	}

	var iconsAnimations:Bool = true;

	function set_health(value:Float):Float // You can alter how icon animations work here
	{
		if (!iconsAnimations || healthBar == null || !healthBar.enabled || healthBar.valueFunction == null)
		{
			health = value;
			return health;
		}

		// update health bar
		health = value;
		var newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max),
			healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		if (!playAsGF)
		{
			if (opponentmode)
			{
				switch (iconP1.type)
				{
					case SINGLE:
						iconP1.animation.curAnim.curFrame = 0;
					case WINNING:
						iconP1.animation.curAnim.curFrame = (healthBar.percent > 80 ? 1 : (healthBar.percent < 20 ? 2 : 0));
					default:
						iconP1.animation.curAnim.curFrame = (healthBar.percent < 20 ? 0 : 1);
				}

				switch (iconP2.type)
				{
					case SINGLE:
						iconP2.animation.curAnim.curFrame = 0;
					case WINNING:
						iconP2.animation.curAnim.curFrame = (healthBar.percent > 80 ? 2 : (healthBar.percent < 20 ? 1 : 0));
					default:
						iconP2.animation.curAnim.curFrame = (healthBar.percent > 80 ? 0 : 1);
				}

				if (iconP22 != null)
				{
					switch (iconP22.type)
					{
						case SINGLE:
							iconP22.animation.curAnim.curFrame = 0;
						case WINNING:
							iconP22.animation.curAnim.curFrame = (healthBar.percent > 80 ? 2 : (healthBar.percent < 20 ? 1 : 0));
						default:
							iconP22.animation.curAnim.curFrame = (healthBar.percent > 80 ? 0 : 1);
					}
				}
				if (iconP12 != null)
				{
					switch (iconP12.type)
					{
						case SINGLE:
							iconP12.animation.curAnim.curFrame = 0;
						case WINNING:
							iconP12.animation.curAnim.curFrame = (healthBar.percent > 80 ? 1 : (healthBar.percent < 20 ? 2 : 0));
						default:
							iconP12.animation.curAnim.curFrame = (healthBar.percent < 20 ? 0 : 1);
					}
				}
			}
			else
			{
				switch (iconP1.type)
				{
					case SINGLE:
						iconP1.animation.curAnim.curFrame = 0;
					case WINNING:
						iconP1.animation.curAnim.curFrame = (healthBar.percent > 80 ? 2 : (healthBar.percent < 20 ? 1 : 0));
					default:
						iconP1.animation.curAnim.curFrame = (healthBar.percent < 20 ? 1 : 0);
				}

				switch (iconP2.type)
				{
					case SINGLE:
						iconP2.animation.curAnim.curFrame = 0;
					case WINNING:
						iconP2.animation.curAnim.curFrame = (healthBar.percent > 80 ? 1 : (healthBar.percent < 20 ? 2 : 0));
					default:
						iconP2.animation.curAnim.curFrame = (healthBar.percent > 80 ? 1 : 0);
				}

				if (iconP22 != null)
				{
					switch (iconP22.type)
					{
						case SINGLE:
							iconP22.animation.curAnim.curFrame = 0;
						case WINNING:
							iconP22.animation.curAnim.curFrame = (healthBar.percent > 80 ? 1 : (healthBar.percent < 20 ? 2 : 0));
						default:
							iconP22.animation.curAnim.curFrame = (healthBar.percent > 80 ? 1 : 0);
					}
				}
				if (iconP12 != null)
				{
					switch (iconP12.type)
					{
						case SINGLE:
							iconP12.animation.curAnim.curFrame = 0;
						case WINNING:
							iconP12.animation.curAnim.curFrame = (healthBar.percent > 80 ? 1 : (healthBar.percent < 20 ? 2 : 0));
						default:
							iconP12.animation.curAnim.curFrame = (healthBar.percent > 80 ? 1 : 0);
					}
				}
			}
		}
		else
		{
			if (gf != null)
			{
				switch (iconGF.type)
				{
					case SINGLE:
						iconP1.animation.curAnim.curFrame = 0;
					case WINNING:
						iconP1.animation.curAnim.curFrame = (healthBar.percent > 80 ? 2 : (healthBar.percent < 20 ? 1 : 0));
					default:
						iconP1.animation.curAnim.curFrame = (healthBar.percent < 20 ? 1 : 0);
				}
			}
		}
		return health;
	}

	function what(convertedvalue:String)
	{
		if (gimmicksAllowed)
		{
			if (convertedvalue == 'On' || convertedvalue == 'on')
			{
				circlefuntime = true;
			}
			else
			{
				circlefuntime = false;
			}
		}
	}

	function openChartEditor(?psychEditor:Bool = false)
	{
		FlxG.camera.followLerp = 0;
		paused = true;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		DiscordClient.resetClientID();
		#end

		if (psychEditor) FlxG.switchState(new ChartingStatePsych());
		else FlxG.switchState(new ChartingStateOG());
	}

	function openCharacterEditor()
	{
		FlxG.camera.followLerp = 0;
		paused = true;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		FlxG.switchState(new CharacterEditorState());
	}

	public var isDead:Bool = false; // Don't mess with this on Lua!!!

	function doDeathCheck(?skipHealthCheck:Bool = false)
	{
		if (((skipHealthCheck && instakillOnMiss) || health <= 0)
			&& !practiceMode
			&& !isDead
			&& bfkilledcheck
			|| playAsGF
			&& healthGF <= 0)
		{
			savedTime = 0;
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if (ret != LuaUtils.Function_Stop)
			{
				boyfriend.stunned = true;
				if (bf2 != null)
					bf2.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				opponentVocals.stop();
				gfVocals.stop();
				for (track in tracks)
					track.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				FlxTimer.globalManager.clear();
				FlxTween.globalManager.clear();
				isPlayerDying = true;
				halfReset();
				openSubState(new GameOverSubstate());

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				if (gf != null && !Crashed)
				{
					#if DISCORD_ALLOWED
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")",
						if (playAsGF && gf != null) iconGF.getCharacter() else iconP2.getCharacter());
					#end
				}
				isDead = true;
				return true;
			}
		}
		return false;
	}

	function halfReset()
	{
		// Reset music properly.
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.time = 0;
			Conductor.songPosition = 0;
			FlxG.sound.music.pitch = playbackRate;
			FlxG.sound.music.pause();
		}

		if (opponentVocals != null)
			opponentVocals.pause();
		if (gfVocals != null)
			gfVocals.pause();
		vocals.pause();
		if (opponentVocals != null)
			opponentVocals.time = 0;
		if (gfVocals != null)
			gfVocals.time = 0;
		vocals.time = 0;

		if (FlxG.sound.music != null)
			FlxG.sound.music.volume = 1;
		vocals.volume = 1;
		if (opponentVocals != null)
			opponentVocals.volume = 1;
		if (gfVocals != null)
			gfVocals.volume = 1;

		allNotes = [];
		unspawnNotes = [];
		notes.clear();

		// Delete all notes and reset the arrays.
		allNotes = curChart;
		unspawnNotes = curChart;

		health = 1;
		songScore = 0;
		combo = 0;
	}

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].strumTime;
			if (Conductor.songPosition < leStrumTime)
			{
				return;
			}

			var value1:String = '';
			if (eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if (eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEvent(eventNotes[0].event, value1, value2, leStrumTime);
			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		// trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEvent(eventName:String, value1:String, value2:String, ?strumTime:Float)
	{
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		if (Math.isNaN(flValue1))
			flValue1 = null;
		if (Math.isNaN(flValue2))
			flValue2 = null;

		switch (eventName)
		{
			case 'Change Focus':
				isCameraOnForcedPos = true;
				switch (value1.toLowerCase().trim())
				{
					case 'dad' | 'opponent':
						moveCamera(true);
					case 'gf':
						moveCamera(false, true);
					case 'dad2' | 'opponent2':
						moveCamera(false, false, true);
					case 'bf2' | 'boyfriend2':
						moveCamera(false, false, false, true);
					case 'bf' | 'boyfriend':
						moveCamera(false);
					default:
						isCameraOnForcedPos = false;
				}
			case 'Enable or Disable Dad Trail':
				if (value1.toLowerCase() == 'true')
				{
					dadT = new FlxTrail(dad, null, 3, 6, 0.3, 0.002);
					dadT.visible = false;
					dadT.color = ColorUtil.rgbToHex(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
					addBehindDad(dadT);
				}
				else
				{
					remove(dadT);
				}
			case 'Enable or Disable BF Trail':
				if (value1.toLowerCase() == 'true')
				{
					bfT = new FlxTrail(boyfriend, null, 3, 6, 0.3, 0.002);
					bfT.visible = false;
					bfT.color = ColorUtil.rgbToHex(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
					addBehindBF(bfT);
				}
				else
				{
					remove(bfT);
				}
			case 'Enable or Disable GF Trail':
				if (value1.toLowerCase() == 'true')
				{
					if (gf != null)
					{
						gfT = new FlxTrail(gf, null, 3, 6, 0.3, 0.002);
						gfT.visible = false;
						gfT.color = ColorUtil.rgbToHex(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]);
						addBehindGF(gfT);
					}
					else
					{
						remove(gfT);
					}
				}
			case 'Hey!':
				var value:Int = 2;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'bf2' | 'boyfriend2' | '00':
						value = 3;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
					case 'dad2' | 'opponent2' | '22':
						value = 4;
					case 'both':
						value = 5;
					case 'bothalt':
						value = 6;
					case 'all':
						value = 7;
					case 'allalt':
						value = 8;
					case 'trueall':
						value = 9;
					default: value = 2;
				}

				if (flValue2 == null || flValue2 <= 0)
					flValue2 = 0.6;

				switch (value)
				{
					case 0:
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = flValue2;
					case 1:
						if (dad.curCharacter.startsWith('gf'))
						{ // Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
							dad.playAnim('cheer', true);
							dad.specialAnim = true;
							dad.heyTimer = flValue2;
						}
						else if (gf != null)
						{
							gf.playAnim('cheer', true);
							gf.specialAnim = true;
							gf.heyTimer = flValue2;
						}
					case 2:
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					case 3:
						bf2.playAnim('hey', true);
						bf2.specialAnim = true;
						bf2.heyTimer = flValue2;
					case 4:
						dad2.playAnim('hey', true);
						dad2.specialAnim = true;
						dad2.heyTimer = flValue2;
					case 5:
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = flValue2;
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					case 6:
						bf2.playAnim('hey', true);
						bf2.specialAnim = true;
						bf2.heyTimer = flValue2;
						dad2.playAnim('hey', true);
						dad2.specialAnim = true;
						dad2.heyTimer = flValue2;
					case 7:
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = flValue2;
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					case 8:
						bf2.playAnim('hey', true);
						bf2.specialAnim = true;
						bf2.heyTimer = flValue2;
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
						dad2.playAnim('hey', true);
						dad2.specialAnim = true;
						dad2.heyTimer = flValue2;
					case 9:
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = flValue2;
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
						bf2.playAnim('hey', true);
						bf2.specialAnim = true;
						bf2.heyTimer = flValue2;
						dad2.playAnim('hey', true);
						dad2.specialAnim = true;
						dad2.heyTimer = flValue2;
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
				}

			case 'Set GF Speed':
				if (flValue1 == null || flValue1 < 1)
					flValue1 = 1;
				gfSpeed = Math.round(flValue1);

			case 'Add Camera Zoom':
				if (ClientPrefs.data.camZooms && FlxG.camera.zoom < 1.35)
				{
					if (flValue1 == null)
						flValue1 = 0.015;
					if (flValue2 == null)
						flValue2 = 0.03;

					FlxG.camera.zoom += flValue1;
					camHUD.zoom += flValue2;
				}

			case 'Play Animation':
				// trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch (value2.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'bf2' | 'boyfriend2':
						char = bf2;
					case 'dad2' | 'opponent2':
						char = dad2;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						if (flValue2 == null)
							flValue2 = 0;
						switch (Math.round(flValue2))
						{
							case 1: char = boyfriend;
							case 2: char = gf;
							case 3: char = dad2;
							case 4: char = bf2;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if (camFollow != null)
				{
					isCameraOnForcedPos = false;
					if (flValue1 != null || flValue2 != null)
					{
						isCameraOnForcedPos = true;
						if (flValue1 == null)
							flValue1 = 0;
						if (flValue2 == null)
							flValue2 = 0;
						camFollow.x = flValue1;
						camFollow.y = flValue2;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					case 'bf2' | 'boyfriend2':
						char = bf2;
					case 'dad2' | 'opponent2':
						char = dad2;
					default:
						var val:Int = Std.parseInt(value1);
						if (Math.isNaN(val))
							val = 0;

						switch (val)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
							case 3: char = dad2;
							case 4: char = bf2;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if (split[0] != null)
						duration = Std.parseFloat(split[0].trim());
					if (split[1] != null)
						intensity = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;

					if (duration > 0 && intensity != 0)
					{
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = 0;
				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					case 'dad2' | 'opponent2':
						charType = 3;
					case 'bf2' | 'boyfriend2':
						charType = 4;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				switch (charType)
				{
					case 0:
						if (boyfriend.curCharacter != value2)
						{
							if (!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);

							if (bfT != null)
							{
								//reset the trail if it was on
								triggerEvent('Enable or Disable Dad Trail', 'false', null, Conductor.crochet);
								triggerEvent('Enable or Disable Dad Trail', 'true', null, Conductor.crochet+0.1);
							}
						}
						setOnScripts('boyfriendName', boyfriend.curCharacter);

					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if (!dad.curCharacter.startsWith('gf'))
							{
								if (wasGf && gf != null)
								{
									gf.visible = true;
								}
							}
							else if (gf != null)
							{
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
							if (bfT != null)
							{
								//reset the trail if it was on
								triggerEvent('Enable or Disable BF Trail', 'false', null, Conductor.crochet);
								triggerEvent('Enable or Disable BF Trail', 'true', null, Conductor.crochet+0.1);
							}
						}
						setOnScripts('dadName', dad.curCharacter);

					case 2:
						if (gf != null)
						{
							if (gf.curCharacter != value2)
							{
								if (!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnScripts('gfName', gf.curCharacter);
						}
					case 3:
						if (dad2 != null)
						{
							if (dad2.curCharacter != value2)
							{
								if (!dadMap2.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var wasGf:Bool = dad2.curCharacter.startsWith('gf');
								var lastAlpha:Float = dad2.alpha;
								dad2.alpha = 0.00001;
								dad2 = dadMap2.get(value2);
								if (!dad2.curCharacter.startsWith('gf'))
								{
									if (wasGf && gf != null)
									{
										gf.visible = true;
									}
								}
								else if (gf != null)
								{
									gf.visible = false;
								}
								dad2.alpha = lastAlpha;
								iconP22.changeIcon(dad2.healthIcon);
							}
							setOnScripts('dad2Name', dad2.curCharacter);
						}
					case 4:
						if (bf2 != null)
						{
							if (bf2.curCharacter != value2)
							{
								if (!boyfriendMap2.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = bf2.alpha;
								bf2.alpha = 0.00001;
								bf2 = boyfriendMap2.get(value2);
								bf2.alpha = lastAlpha;
								iconP12.changeIcon(bf2.healthIcon);
							}
							setOnScripts('bf2Name', bf2.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if (flValue1 == null)
						flValue1 = 1;
					if (flValue2 == null)
						flValue2 = 0;

					var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * flValue1;
					if (flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {
							ease: FlxEase.linear,
							onComplete: function(twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if (killMe.length > 1)
				{
					LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(killMe, true, true), killMe[killMe.length - 1], value2);
				}
				else
				{
					LuaUtils.setVarInArray(this, value1, value2);
				}

			case 'Change Mania':
				var newMania:Int = 0;
				var skipTween:Bool = value2 == "true" ? true : false;

				newMania = Std.parseInt(value1);
				if (Math.isNaN(newMania) && newMania < Note.minMania && newMania > Note.maxMania)
					newMania = 0;
				changeMania(newMania, skipTween);

				case 'Change Mania (Special)':
					var newMania:Int = 0;
					var skipTween:Bool = value2 == "true" ? true : false;
					var prevNote1:Note = null;
					var prevNote2:Note = null;

					playfields.forEach(function(daPlayfield:PlayField)
					{
						for (note in allNotes)
							daPlayfield.unqueue(note);
					});
	
					if (value1.toLowerCase().trim() == "random") {
						newMania = FlxG.random.int(0, 8);
					} else {
						newMania = Std.parseInt(value1);
					}
					if (Math.isNaN(newMania) && newMania < 0 && newMania > 9)
						newMania = 0;
					notes.forEach(function(daNote:Note)
					{
						daNote.noteData = getNumberFromAnims(daNote.noteData, newMania);
					});
					for (i in 0...allNotes.length)
					{
						if (allNotes[i].mustPress)
						{
							if (!allNotes[i].isSustainNote)
							{
								allNotes[i].noteData = getNumberFromAnims(allNotes[i].noteData, newMania);
								prevNote1 = allNotes[i];
							}
							else if (prevNote1 != null && allNotes[i].isSustainNote) allNotes[i].noteData = prevNote1.noteData;
						}
						if (!allNotes[i].mustPress)
						{
							if (!allNotes[i].isSustainNote)
							{
								allNotes[i].noteData = getNumberFromAnims(allNotes[i].noteData, newMania);
								prevNote2 = allNotes[i];
							}
							else if (prevNote2 != null && allNotes[i].isSustainNote) allNotes[i].noteData = prevNote2.noteData;
						}
						playfields.forEach(function(daPlayfield:PlayField)
						{
							for (note in allNotes)
								daPlayfield.queue(note);
						});
					}
					changeMania(newMania, skipTween, true);
	

			case 'Super Burst':
				powerup(value1);

			case 'Burst Dad':
				burstRelease(dad.getMidpoint().x - 1000, dad.getMidpoint().y - 100);

			case 'Burst Dad 2':
				burstRelease(dad2.getMidpoint().x - 1000, dad2.getMidpoint().y - 100);

			case 'Burst Boyfriend':
				burstRelease(boyfriend.getMidpoint().x, boyfriend.getMidpoint().y - 100);

			case 'Burst BF2':
				burstRelease(bf2.getMidpoint().x, bf2.getMidpoint().y - 100);

			case 'Switch Scroll':
				daAnswer(value1);

			case 'Dad Fly':
				daAnswer2(value1);

			case 'Turn on StrumFocus':
				strumFocus = true;

			case 'Turn off StrumFocus':
				strumFocus = false;

			case 'Fade Out':
				FlxTween.tween(blackOverlay, {alpha: 1}, Std.parseFloat(value1));
				FlxTween.tween(camHUD, {alpha: 0}, Std.parseFloat(value1));

			case 'Fade In':
				FlxTween.tween(blackOverlay, {alpha: 0}, Std.parseFloat(value1));
				FlxTween.tween(camHUD, {alpha: 1}, Std.parseFloat(value1));

			case 'Silhouette':
				theShadow(value1);

			case 'Save Song Posititon':
				trace(Conductor.songPosition);
				savedTime = Conductor.songPosition;
				savedBeat = curBeat;
				savedStep = curStep;

			case 'False Timer':
				if (timerExtensions != null)
				{
					timerExtensions.shift();

					var next:Dynamic = timerExtensions[0];
					var toValue:Float = (next != null && next > 0) ? next : songLength;
					// maskedSongLength = value; instead of tweenMask.bind(timeTxt)
					FlxTween.num(maskedSongLength, toValue, if (flValue1 != null) flValue1 else Conductor.stepCrochet * 0.001 * 16, {
						ease: LuaUtils.getTweenEaseByString(value2),
						onComplete: function(twn:FlxTween)
						{
							maskedSongLength = toValue;
							if (twn.active)
								twn.cancel();
							twn.active = false;
							twn.destroy();
						}
					}, function(value:Float)
					{
						maskedSongLength = value;
					});
				}

			case 'Chromatic Aberration':
				why(value1);
				defMult = 0.0 + Std.parseFloat(value2);
				if (value2 == '' || value2 == null)
				{
					defMult = 0.04;
				}

			case 'Move Window':
				var val1:Int = Std.parseInt(value1);
				var val2:Int = Std.parseInt(value2);
				if (Math.isNaN(val1))
					val1 = winX;
				if (Math.isNaN(val2))
					val2 = winY;
				Lib.application.window.move(winX + val1, winY + val2);

			case 'Static':
				if (value1 == 'true' || value1 == 'True' || value1 == 'on' || value1 == 'On')
				{
					doStaticSign(Std.parseInt(value2));
					daStatic.alpha == 1;
				}
				else
				{
					daStatic.alpha == 0;
				}
				if (value2 == '' || value2 == null)
				{
					doStaticSign(3);
					daStatic.alpha == 0;
				}
			case 'Static Fade':
				doStaticSignFade(Std.parseFloat(value1), Std.parseFloat(value2));

			case 'Thunderstorm Trigger':
				if (value1 == '' || value1 == null)
				{
					doThunderstorm(3);
				}
				else
				{
					doThunderstorm(Std.parseInt(value1));
				}

			case 'Rave Mode':
				if (ClientPrefs.data.flashing)
				{
					switch (value1)
					{
						case '0':
							ravemode = false;
							ravemodeV2 = false;
						case '1':
							ravemode = true;
							ravemodeV2 = false;
						case '2':
							ravemode = false;
							ravemodeV2 = true;
					}
				}

				if (Std.string(value2) == 'A')
				{
					autoBotsRollOut = true;
				}
				else
				{
					autoBotsRollOut = false;
				}

			case 'gfScared':
				var newValue:Bool = false;
				if (value1.toLowerCase() == "true")
					newValue = true;
				gfScared = newValue;

			case 'Freeze Notes':
				if (value1 == 'true' || value1 == 'True')
				{
					freezeNotes = true;
				}
				else
				{
					freezeNotes = false;
				}

			case 'Funnie Window Tween':
				var split:Array<String> = value1.split(',');
				var val1:Int = Std.parseInt(split[0]);
				var val2:Int = Std.parseInt(split[1]);
				if (Math.isNaN(val1))
					val1 = winX;
				if (Math.isNaN(val2))
					val2 = winY;
				if (gimmicksAllowed)
					FlxTween.tween(openfl.Lib.application.window, {x: winX + Std.int(val1), y: winY + Std.int(val2)}, Std.parseInt(value2),
						{ease: FlxEase.quadInOut});

			case 'Chrom Beat Effect':
				if (gimmicksAllowed)
				{
					if (value1.toLowerCase() == 'slow')
					{
						beatchrom = true;
						beatchromfaster = false;
						beatchromfastest = false;
						beatchromslow = false;
					}
					else if (value1.toLowerCase() == 'fast')
					{
						beatchromfaster = true;
						beatchrom = false;
						beatchromfastest = false;
						beatchromslow = false;
					}
					else if (value1.toLowerCase() == 'faster')
					{
						beatchromfastest = true;
						beatchrom = false;
						beatchromfaster = false;
						beatchromslow = false;
					}
					else if (value1.toLowerCase() == 'slower')
					{
						beatchromslow = true;
						beatchrom = false;
						beatchromfaster = false;
						beatchromfastest = false;
					}
					else
					{
						beatchrom = false;
						beatchromslow = false;
						beatchromfaster = false;
						beatchromfastest = false;
					}
					defMult = 0.0 + Std.parseFloat(value2);
					if (value2 == '' || value2 == null)
					{
						defMult = 0.06;
					}
				}

			case 'Change Lyric':
				lyrics.text = value1;
				var split:Array<String> = value2.split(',');
				var color:String = split[0];
				var effect:String = split[1];
				if (split[0] != null)
					colorSwitch(split[0].trim());
				if (split[1] != null)
					effectSwitch(split[1].trim());
				if (color == null || color == '')
					colorSwitch('white');
				if (effect == null || effect == '')
					effectSwitch('none');

				/*
					case 'Note Screen Center':
						if (gimmicksAllowed)
						{
							if (value1.toLowerCase() == 'true' || value1.toLowerCase() == 'True' || value1.toLowerCase() == 'TRUE' || value1.toLowerCase() == 'on' || value1.toLowerCase() == 'On' || value1.toLowerCase() == 'ON') 
							{
								notesCentered = true;
							}
							else
							{
								notesCentered = false;
							}
						}

					case '???':
						what(value1); */
		}
		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime));
		callOnScripts('onEvent', [eventName, value1, value2, strumTime]);
	}

	function why(convertedvalue:String)
	{
		if (gimmicksAllowed)
		{
			if (convertedvalue == 'On' || convertedvalue == 'on')
			{
				chromOn = true;
			}
			else
			{
				chromOn = false;
			}
		}
	}

	function theShadow(convertedvalue:String)
	{
		if (gimmicksAllowed)
		{
			if (convertedvalue == 'black' || convertedvalue == 'Black')
			{
				FlxTween.tween(whiteBG, {alpha: 1}, 0.1);
				FlxTween.tween(blackUnderlay, {alpha: 0}, 0.1);
				if (dad2 != null)
					FlxTween.tween(dad2.colorTransform, {blueOffset: -255, redOffset: -255, greenOffset: -255}, 0.1, {ease: FlxEase.sineInOut});
				FlxTween.tween(boyfriend.colorTransform, {blueOffset: -255, redOffset: -255, greenOffset: -255}, 0.1, {ease: FlxEase.sineInOut});
				FlxTween.tween(dad.colorTransform, {blueOffset: -255, redOffset: -255, greenOffset: -255}, 0.1, {ease: FlxEase.sineInOut});
				if (gf != null)
					FlxTween.tween(gf.colorTransform, {blueOffset: -220, redOffset: -220, greenOffset: -220}, 0.1, {ease: FlxEase.sineInOut});
				FlxG.camera.zoom += 0.030;
				camHUD.zoom += 0.04;
				// boyfriend.color = FlxColor.BLACK;
				// gf.color = FlxColor.BLACK;
				// dad.color = FlxColor.BLACK;
			}
			else if (convertedvalue == 'white' || convertedvalue == 'White')
			{
				FlxTween.tween(blackUnderlay, {alpha: 1}, 0.1, {ease: FlxEase.sineInOut});
				FlxTween.tween(whiteBG, {alpha: 0}, 0.1, {ease: FlxEase.sineInOut});
				if (dad2 != null)
					FlxTween.tween(dad2.colorTransform, {blueOffset: 255, redOffset: 255, greenOffset: 255}, 0.1, {ease: FlxEase.sineInOut});
				FlxTween.tween(boyfriend.colorTransform, {blueOffset: 255, redOffset: 255, greenOffset: 255}, 0.1, {ease: FlxEase.sineInOut});
				FlxTween.tween(dad.colorTransform, {blueOffset: 255, redOffset: 255, greenOffset: 255}, 0.1, {ease: FlxEase.sineInOut});
				if (gf != null)
					FlxTween.tween(gf.colorTransform, {blueOffset: 220, redOffset: 220, greenOffset: 220}, 0.1, {ease: FlxEase.sineInOut});
				FlxG.camera.zoom += 0.030;
				camHUD.zoom += 0.04;
				// boyfriend.color = 0xffffffff;
				// gf.color = 0xffffffff;
				// dad.color = 0xffffffff;
			}
			else
			{
				FlxTween.tween(whiteBG, {alpha: 0}, 0.1);
				FlxTween.tween(blackUnderlay, {alpha: 0}, 0.1);
				if (dad2 != null)
					FlxTween.tween(dad2.colorTransform, {blueOffset: 0, redOffset: 0, greenOffset: 0}, 0.1, {ease: FlxEase.sineInOut});
				FlxTween.tween(boyfriend.colorTransform, {blueOffset: 0, redOffset: 0, greenOffset: 0}, 0.1, {ease: FlxEase.sineInOut});
				FlxTween.tween(dad.colorTransform, {blueOffset: 0, redOffset: 0, greenOffset: 0}, 0.1, {ease: FlxEase.sineInOut});
				if (gf != null)
					FlxTween.tween(gf.colorTransform, {blueOffset: 0, redOffset: 0, greenOffset: 0}, 0.1, {ease: FlxEase.sineInOut});
				FlxG.camera.zoom += 0.030;
				camHUD.zoom += 0.04;
				// boyfriend.color = FlxColor.WHITE;
				// gf.color = FlxColor.WHITE;
				// dad.color = FlxColor.WHITE;
			}
		}
	}

	public function colorSwitch(daColor:String):Void
	{
		switch (daColor)
		{
			case 'red':
				lyrics.color = FlxColor.RED;
			case 'blue':
				lyrics.color = FlxColor.BLUE;
			case 'green':
				lyrics.color = FlxColor.GREEN;
			case 'white':
				lyrics.color = FlxColor.WHITE;
		}
	}

	public function effectSwitch(daEffect:String):Void
	{
		switch (daEffect)
		{
			case 'none':
				lyrics.alpha = 1;
			case 'fadeout':
				FlxTween.tween(lyrics, {alpha: 0}, 1, {ease: FlxEase.expoIn});
			case 'fadein':
				FlxTween.tween(lyrics, {alpha: 1}, 1, {ease: FlxEase.expoIn});
		}
	}

	function daAnswer(ans:String)
	{
		if (ans == 'true' || ans == 'True' || ans == 'TRUE')
		{
			forceChange(true);
		}
		else
		{
			forceChange(false);
		}
	}

	function daAnswer2(ans:String)
	{
		if (ans == 'true' || ans == 'True' || ans == 'TRUE')
		{
			fly = true;
		}
		else
		{
			fly = false;
		}
	}

	function powerup(who:String)
	{
		var curDad:Character = dad;
		switch (who)
		{
			case 'dad':
				curDad = dad;
			case 'bf':
				curDad = boyfriend;
			case 'dad2':
				curDad = dad2;
			case 'bf2':
				curDad = bf2;
			default:
				curDad = dad;
		}
		new FlxTimer().start(0.008, function(ct:FlxTimer)
		{
			switch (cutTime)
			{
				case 0:
					camFollow.x = curDad.getMidpoint().x - 100;
					camFollow.y = curDad.getMidpoint().y;
				case 15:
					curDad.playAnim('powerup');
				case 48:
					curDad.playAnim('idle_s');
					burst = new FlxSprite(-1110, 0);
					FlxG.sound.play(Paths.sound('burst'));
					remove(burst);
					burst = new FlxSprite(curDad.getMidpoint().x - 1000, curDad.getMidpoint().y - 100);
					burst.frames = Paths.getSparrowAtlas('characters/shaggy');
					burst.animation.addByPrefix('burst', "burst", 30);
					burst.animation.play('burst');
					// burst.setGraphicSize(Std.int(burst.width * 1.5));
					burst.antialiasing = true;
					add(burst);

					FlxG.sound.play(Paths.sound('powerup'), 1);
					triggerEvent("Alt Idle Animation", who, "-alt");
				case 62:
					burst.y = 0;
					remove(burst);
				case 95:
					FlxG.camera.angle = 0;
			}

			var ssh:Float = 45;
			var stime:Float = 30;
			var corneta:Float = (stime - (cutTime - ssh)) / stime;

			if (cutTime % 6 >= 3)
			{
				corneta *= -1;
			}
			if (cutTime >= ssh && cutTime <= ssh + stime)
			{
				FlxG.camera.angle = corneta * 5;
			}
			cutTime++;
			ct.reset(0.008);
		});
	}

	public function burstRelease(bX:Float, bY:Float)
	{
		FlxG.sound.play(Paths.sound('burst'));
		remove(burst);
		burst = new FlxSprite(bX - 1000, bY - 100);
		burst.frames = Paths.getSparrowAtlas('characters/shaggy');
		burst.animation.addByPrefix('burst', "burst", 30);
		burst.animation.play('burst');
		// burst.setGraphicSize(Std.int(burst.width * 1.5));
		burst.antialiasing = true;
		add(burst);
		new FlxTimer().start(0.5, function(rem:FlxTimer)
		{
			remove(burst);
		});
	}

	function moveCameraSection(?sec:Null<Int>):Void
	{
		if (sec == null)
			sec = curSection;
		if (sec < 0)
			sec = 0;
		if (SONG.notes[sec] == null)
			return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnScripts('onMoveCamera', ['gf']);
			return;
		}

		if (dad2 != null && SONG.notes[curSection].exSection && !SONG.notes[curSection].mustHitSection)
		{
			camFollow.setPosition(dad2.getMidpoint().x, dad2.getMidpoint().y);
			camFollow.x += dad2.cameraPosition[0] + opponent2CameraOffset[0];
			camFollow.y += dad2.cameraPosition[1] + opponent2CameraOffset[1];
			tweenCamIn();
			callOnScripts('onMoveCamera', ['dad2']);
			return;
		}

		if (bf2 != null && SONG.notes[curSection].exSection && SONG.notes[curSection].mustHitSection)
		{
			camFollow.setPosition(bf2.getMidpoint().x, bf2.getMidpoint().y);
			camFollow.x += bf2.cameraPosition[0] + boyfriend2CameraOffset[0];
			camFollow.y += bf2.cameraPosition[1] + boyfriend2CameraOffset[1];
			tweenCamIn();
			callOnScripts('onMoveCamera', ['bf2']);
			return;
		}

		if (!SONG.notes[curSection].exSection && !SONG.notes[curSection].gfSection)
		{
			if (!SONG.notes[curSection].mustHitSection)
			{
				moveCamera(true);
				callOnScripts('onMoveCamera', ['dad']);
			}
			else if (SONG.notes[curSection].mustHitSection)
			{
				moveCamera(false);
				callOnScripts('onMoveCamera', ['boyfriend']);
			}
		}
	}

	var cameraTwn:FlxTween;

	public function moveCamera(isDad:Bool, ?isGF:Bool = false, ?isDad2:Bool = false, isBf2:Bool = false)
	{
		if (isDad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else if (isGF)
		{
			if (gf != null)
			{
				camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
				camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
				camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
				tweenCamIn();
				callOnLuas('onMoveCamera', ['gf']);
			}
		}
		else if (isDad2)
		{
			if (dad2 != null)
			{
				camFollow.setPosition(dad2.getMidpoint().x, dad2.getMidpoint().y);
				camFollow.x += dad2.cameraPosition[0] + opponent2CameraOffset[0];
				camFollow.y += dad2.cameraPosition[1] + opponent2CameraOffset[1];
				tweenCamIn();
				callOnLuas('onMoveCamera', ['dad2']);
			}
		}
		else if (isBf2)
		{
			if (bf2 != null)
			{
				camFollow.setPosition(bf2.getMidpoint().x, bf2.getMidpoint().y);
				camFollow.x += bf2.cameraPosition[0] + boyfriend2CameraOffset[0];
				camFollow.y += bf2.cameraPosition[1] + boyfriend2CameraOffset[1];
				tweenCamIn();
				callOnLuas('onMoveCamera', ['bf2']);
			}
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn()
	{
		if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	// Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();
		gfVocals.volume = 0;
		gfVocals.pause();
		for (track in tracks)
		{
			track.volume = 0;
			track.pause();
		}
		if (ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	var daEnding:String;

	public function endSong()
	{
		// Should kill you if you tried to cheat
		if (!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			}

			if (doDeathCheck())
			{
				return false;
			}
		}

		if (!startingSong)
		{
			for (field in playfields.members)
			{
				if (field.isPlayer)
				{
					for (daNote in field.spawnedNotes)
					{
						if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
						{
							health -= 0.05 * healthLoss;
						}
					}
				}
			}

			if (doDeathCheck())
				return false;
		}

		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		savedTime = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		var weekNoMiss:String = WeekData.getWeekFileName() + '_nomiss';
		checkForAchievement([
			weekNoMiss, 
			'ur_bad', 
			'ur_good', 
			'hype', 
			'two_keys', 
			'toastie', 
			'beat_battle', 
			'beat_battle_master', 
			'beat_battle_god', 
			'beat_battle_fanatic', 
			'feelinfrisky',
			'leantastic', 
			'punchout',
			'rawr',
			'underlust',
			'resistified',
			'skysthelimit',
			'potatogameplay',
			'mattdestroyer',
			'matteleminator',
			'mattgod',
			'matt',
			'mattbeyond',
			'perfectionist',
			'error404',
			'pokemon'
		]);
		#end

		var ret:Dynamic = callOnScripts('onEndSong', null, true);
		if (ret != LuaUtils.Function_Stop && !transitioning)
		{
			if (!cpuControlled && !playAsGF)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if (Math.isNaN(percent))
					percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return false;
			}

			if (isStoryMode)
			{
				if (!cpuControlled && !playAsGF)
				{
					campaignScore += songScore;
					campaignMisses += songMisses;
				}

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					gameplayArea = "Story";
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					// if ()
					if (!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false))
					{
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (!playAsGF)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						camHUD.alpha -= 1 / 10;
					}, 10);
					openSubState(new substates.RankingSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				else
				{
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						camHUD.alpha -= 1 / 10;
					}, 10);
					gameplayArea = "Story";
					openSubState(new substates.RankingSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
			}
			else
			{
				gameplayArea = "Freeplay";
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
				openSubState(new substates.RankingSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				changedDifficulty = false;
			}
			transitioning = true;
		}
		return true;
	}

	public function KillNotes()
	{
		while (allNotes.length > 0)
		{
			var daNote:Note = allNotes[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			allNotes.remove(daNote);
			notes.remove(daNote, true);
			// daNote.destroy();
		}
		allNotes = [];
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public static function getUiSkin(?uiSkin:String = 'base', ?file:String = '', ?alt:String = '', ?numSkin:Bool = false, ?num:Int = 0)
	{
		var path:String = 'HUD/' + (numSkin ? 'numbers/' : '') + uiSkin + '/' + (numSkin ? 'num' : file) + (numSkin ? Std.string(num) : '') + alt;
		if (!Paths.fileExists('images/' + path + '.png', IMAGE))
			path = 'HUD/' + (numSkin ? 'numbers/' : '') + 'base/' + (numSkin ? 'num' : file) + (numSkin ? Std.string(num) : '') + alt;
		return path;
	}

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		/*var pixelShitPart1:String = '';
			var pixelShitPart2:String = '';
			if (isPixelStage)
			{
				pixelShitPart1 = 'pixelUI/';
				pixelShitPart2 = '-pixel';
		}*/

		var uiSkin:String = '';
		var altPart:String = isPixelStage ? '-pixel' : '';

		switch (ClientPrefs.data.uiSkin)
		{
			case 'Bedrock':
				uiSkin = 'bedrock';
			case 'BEAT!':
				uiSkin = 'beat';
			case 'BEAT! Gradient':
				uiSkin = 'beat-alt';
			case 'Psych Engine':
				uiSkin = 'psych';
			case 'Mixtape Engine':
				uiSkin = 'mixtape';
			case 'Base Game':
				uiSkin = 'base';
			default:
				uiSkin = ClientPrefs.data.uiSkin;
		}

		Paths.image(getUiSkin(uiSkin, "marv", altPart));
		Paths.image(getUiSkin(uiSkin, "sick", altPart));
		Paths.image(getUiSkin(uiSkin, "good", altPart));
		Paths.image(getUiSkin(uiSkin, "bad", altPart));
		Paths.image(getUiSkin(uiSkin, "shit", altPart));
		Paths.image(getUiSkin(uiSkin, "combo", altPart));

		for (i in 0...10)
		{
			getUiSkin(uiSkin, '', altPart, true, Std.int(i));
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		// trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		opponentVocals.volume = 1;
		gfVocals.volume = 1;
		for (track in tracks)
			track.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		// tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if (!note.ratingDisabled)
			daRating.hits++;
		note.rating = daRating.name;
		score = daRating.score;

		if (!practiceMode && !cpuControlled)
		{
			songScore += score;
			if (!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		/*var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (PlayState.isPixelStage)
			{
				pixelShitPart1 = 'pixelUI/';
				pixelShitPart2 = '-pixel';
		}*/

		var uiSkin:String = '';
		var altPart:String = isPixelStage ? '-pixel' : '';

		switch (ClientPrefs.data.uiSkin)
		{
			case 'Bedrock':
				uiSkin = 'bedrock';
			case 'BEAT!':
				uiSkin = 'beat';
			case 'BEAT! Gradient':
				uiSkin = 'beat-alt';
			case 'Psych Engine':
				uiSkin = 'psych';
			case 'Mixtape Engine':
				uiSkin = 'mixtape';
			case 'Base Game':
				uiSkin = 'base';
			default:
				uiSkin = ClientPrefs.data.uiSkin;
		}

		rating.loadGraphic(Paths.image(getUiSkin(uiSkin, daRating.name, altPart)));
		rating.cameras = [if (ClientPrefs.data.inGameRatings) camGame else camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.data.hideHud && showRating);
		rating.x += ClientPrefs.data.comboOffset[0];
		rating.y -= ClientPrefs.data.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(getUiSkin(uiSkin, 'combo', altPart)));
		comboSpr.cameras = [if (ClientPrefs.data.inGameRatings) camGame else camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.data.hideHud && showCombo);
		comboSpr.x += ClientPrefs.data.comboOffset[0];
		comboSpr.y -= ClientPrefs.data.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		insert(members.indexOf(strumLineNotes), rating);

		if (!ClientPrefs.data.comboStacking)
		{
			if (lastRating != null)
				lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.data.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.data.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if (combo >= 1000)
		{
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.data.comboStacking)
		{
			if (lastCombo != null)
				lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(getUiSkin(uiSkin, '', altPart, true, Std.int(i))));
			numScore.cameras = [if (ClientPrefs.data.inGameRatings) camGame else camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90 + ClientPrefs.data.comboOffset[2];
			numScore.y += 80 - ClientPrefs.data.comboOffset[3];

			if (!ClientPrefs.data.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.data.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.data.hideHud;

			// if (combo >= 10 || combo == 0)
			if (showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if (numScore.x > xThing)
				xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0, angle: FlxG.random.float(-15, 15)}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0, angle: FlxG.random.float(-15, 15)}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	private function popUpScoreOpp(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		// trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		opponentVocals.volume = 1;
		gfVocals.volume = 1;
		for (track in tracks)
			track.volume = 1;

		var placement:String = Std.string(comboOpp);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		// tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);

		AITotalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if (!note.ratingDisabled)
			daRating.hits++;
		note.rating = daRating.name;
		score = daRating.score;

		if (!practiceMode && !cpuControlled)
		{
			AIScore += score;
			if (!note.ratingDisabled)
			{
				AITotalPlayed++;
				RecalculateRatingAI(false);
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [if (ClientPrefs.data.inGameRatings) camGame else camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.data.hideHud && showRating);
		rating.x += ClientPrefs.data.comboOffset[0] + 400;
		rating.y -= ClientPrefs.data.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [if (ClientPrefs.data.inGameRatings) camGame else camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.data.hideHud && showCombo);
		comboSpr.x += ClientPrefs.data.comboOffset[0] + 400;
		comboSpr.y -= ClientPrefs.data.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.x -= 200;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		insert(members.indexOf(strumLineNotes), rating);

		if (!ClientPrefs.data.comboStacking)
		{
			if (lastRatingOpp != null)
				lastRatingOpp.kill();
			lastRatingOpp = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.data.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.data.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if (comboOpp >= 1000)
		{
			seperatedScore.push(Math.floor(comboOpp / 1000) % 10);
		}
		seperatedScore.push(Math.floor(comboOpp / 100) % 10);
		seperatedScore.push(Math.floor(comboOpp / 10) % 10);
		seperatedScore.push(comboOpp % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.data.comboStacking)
		{
			if (lastComboOpp != null)
				lastComboOpp.kill();
			lastComboOpp = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [if (ClientPrefs.data.inGameRatings) camGame else camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90 + ClientPrefs.data.comboOffset[2] + 400;
			numScore.y += 80 - ClientPrefs.data.comboOffset[3];

			if (!ClientPrefs.data.comboStacking)
				lastScoreOpp.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.data.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.data.hideHud;

			// if (combo >= 10 || combo == 0)
			if (showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if (numScore.x > xThing)
				xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0, angle: FlxG.random.float(-15, 15)}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0, angle: FlxG.random.float(-15, 15)}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	/*private function onKeyPress(event:KeyboardEvent):Void
		{
			var eventKey:FlxKey = event.keyCode;
			var key:Int = getKeyFromEvent(eventKey);
			//trace('Pressed: ' + eventKey);

			if (!controls.controllerMode && FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
	}*/
	var closestNotes:Array<Note> = [];

	public var strumsBlocked:Array<Bool> = [];

	var pressed:Array<FlxKey> = [];

	private function onKeyPress(event:KeyboardEvent):Void
	{
		if (paused || !startedCountdown || inCutscene)
			return;

		var eventKey:FlxKey = event.keyCode;
		var data:Int = getKeyFromEvent(eventKey);

		if (pressed.contains(eventKey))
			return;
		pressed.push(eventKey);

		if (callOnScripts("onKeyDown", [event]) == LuaUtils.Function_Stop)
			return;

		if (data > -1)
		{
			var hitNotes:Array<Note> = [];
			var controlledFields:Array<PlayField> = [];

			if (strumsBlocked[data])
				return;

			if (callOnScripts("onKeyPress", [data]) == LuaUtils.Function_Stop)
				return;

			for (field in playfields.members)
			{
				if (!field.autoPlayed && field.isPlayer && field.inControl)
				{
					controlledFields.push(field);
					field.keysPressed[data] = true;
					if (generatedMusic && !endingSong)
					{
						var note:Note = null;
						var ret:Dynamic = callOnScripts("onFieldInput", [field, data, hitNotes]);
						if (ret == LuaUtils.Function_Stop)
							continue;
						else if ((ret.objType == NOTE))
							note = ret;
						else
							note = field.input(data);

						if (note == null)
						{
							var spr:StrumNote = field.strumNotes[data];
							if (spr != null && spr.animation.curAnim.name != 'confirm')
							{
								spr.playAnim('pressed');
								spr.resetAnim = 0;
							}
						}
						else
						{
							hitNotes.push(note);
						}
					}
				}
			}
			if (hitNotes.length == 0 && controlledFields.length > 0)
			{
				callOnScripts('onGhostTap', [data]);

				if (!ClientPrefs.data.ghostTapping)
					noteMissPress(data);
			}
		}
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if (pressed.contains(eventKey))
			pressed.remove(eventKey);

		if (callOnScripts("onKeyUp", [event]) == LuaUtils.Function_Stop)
			return;

		if (startedCountdown && key > -1)
		{
			// doesnt matter if THIS is done while paused
			// only worry would be if we implemented Lifts
			// but afaik we arent doing that
			// (though could be interesting to add)
			for (field in playfields.members)
			{
				if (field.inControl && !field.autoPlayed && field.isPlayer)
				{
					field.keysPressed[key] = false;

					if (!field.isHolding[key])
					{
						var spr:StrumNote = field.strumNotes[key];
						if (spr != null)
						{
							spr.playAnim('static');
							spr.resetAnim = 0;
						}
					}
				}
			}
			callOnScripts('onKeyRelease', [key]);
		}
		// trace('released: ' + controlArray);
	}

	public function getKeyFromEvent(key:FlxKey):Int
	{
		// var tempKeys:Array<Dynamic> = backend.Keybinds.fill();
		if (key != NONE)
		{
			for (i in 0...keysArray[mania].length)
			{
				for (j in 0...keysArray[mania][i].length)
				{
					if (key == keysArray[mania][i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	private function keysArePressed():Bool
	{
		for (i in 0...keysArray[mania].length)
		{
			for (j in 0...keysArray[mania][i].length)
			{
				if (FlxG.keys.checkStatus(keysArray[mania][i][j], PRESSED))
					return true;
			}
		}

		return false;
	}

	private function dataKeyIsPressed(data:Int):Bool
	{
		for (i in 0...keysArray[mania][data].length)
		{
			if (FlxG.keys.checkStatus(keysArray[mania][data][i], PRESSED))
				return true;
		}

		return false;
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	// Hold notes
	public static var pressedGameplayKeys:Array<Bool> = [];

	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();
		pressedGameplayKeys = parsedHoldArray;
		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (parsedHoldArray.contains(true) && !endingSong)
				{
					#if ACHIEVEMENTS_ALLOWED
					checkForAchievement(['oversinging']);
					#end
				}
			});

			if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();

			if (ClientPrefs.data.controllerMode || strumsBlocked.contains(true))
			{
				var parsedArray:Array<Bool> = parseKeys('_R');
				if (parsedArray.contains(true))
				{
					for (i in 0...parsedArray.length)
					{
						if (parsedArray[i] || strumsBlocked[i] == true)
							onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[mania][i][0]));
					}
				}
			}
		}
	}

	function noteMiss(daNote:Note, field:PlayField):Void
	{ // You didn't hit the key and let it go offscreen, also used by Hurt Notes
		// Dupe note remove
		for (note in field.spawnedNotes)
		{
			if (!note.alive || daNote.tail.contains(note) || note.isSustainNote)
				continue;
			if (daNote != note && field.isPlayer && daNote.noteData == note.noteData && Math.abs(daNote.strumTime - note.strumTime) < 1)
				field.removeNote(note);
		}
		if (!daNote.isSustainNote && daNote.unhitTail.length > 0)
		{
			for (tail in daNote.unhitTail)
			{
				tail.tooLate = true;
				tail.blockHit = true;
				tail.ignoreNote = true;
				// health -= daNote.missHealth * healthLoss; // this is kinda dumb tbh no other VSRG does this just FNF
			}
		}
		if (!daNote.noMissAnimation)
		{
			var chars:Array<Character> = daNote.characters;

			if (daNote.gfNote && gf != null)
				chars.push(gf);
			else if (chars.length == 0)
				chars = field.characters;

			if (combo > 10 && gf != null && chars.contains(gf) == false && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}

			for (char in chars)
			{
				if (char != null)
				{
					var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + daNote.animSuffix + 'miss';

					char.playAnim(animToPlay, true);
				}
			}
		}
		if (!daNote.isSustainNote) // i missed this sound
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		combo = 0;

		bfkilledcheck = true;

		health -= daNote.missHealth * healthLoss;
		if (instakillOnMiss)
		{
			vocals.volume = 0;
			opponentVocals.volume = 0;
			gfVocals.volume = 0;
			for (track in tracks)
				track.volume = 0;
			doDeathCheck(true);
			bfkilledcheck = true;
		}

		// For testing purposes
		// trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if (!practiceMode && !playAsGF)
			songScore -= 10;

		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if (opponentmode)
			char = dad;
		if (daNote.gfNote)
			char = gf;
		if (daNote.exNote)
			char = bf2;

		if (char != null && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		if (combo > 10 && gf != null && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}

		var result:Dynamic = callOnLuas('noteMiss', [
			notes.members.indexOf(daNote),
			daNote.noteData,
			daNote.noteType,
			daNote.isSustainNote
		]);
		if (result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
			callOnHScript('noteMiss', [daNote]);
	}

	function noteMissPress(direction:Int = 1):Void // You pressed a key when there was no notes to press for this key
	{
		if (ClientPrefs.data.ghostTapping)
			return; // fuck it
		bfkilledcheck = true;
		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if (instakillOnMiss)
			{
				vocals.volume = 0;
				opponentVocals.volume = 0;
				gfVocals.volume = 0;
				for (track in tracks)
					track.volume = 0;
				doDeathCheck(true);
				bfkilledcheck = true;
			}

			if (ClientPrefs.data.ghostTapping)
				return;

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode && !playAsGF)
				songScore -= 10;
			if (!endingSong)
			{
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

				// get stunned for 1/60 of a second, makes you able to
				new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
				{
					boyfriend.stunned = false;
			});*/

			for (field in playfields.members)
			{
				if (!field.isPlayer)
					continue;

				for (char in field.characters)
				{
					char.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
					if (!char.hasMissAnimations)
						char.color = 0xFFC6A6FF;
				}
			}

			if (boyfriend.hasMissAnimations)
			{
				boyfriend.playAnim('sing' + Note.keysShit.get(mania).get('anims')[direction] + 'miss', true);
			}
			if (bf2 != null && bf2.hasMissAnimations)
			{
				bf2.playAnim('sing' + Note.keysShit.get(mania).get('anims')[direction] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnScripts('noteMissPress', [direction]);
	}

	function getFieldFromNote(note:Note)
	{
		for (playfield in playfields)
		{
			if (playfield.hasNote(note))
				return playfield;
		}

		return playfields.members[0];
	}

	function opponentNoteHit(note:Note, field:PlayField):Void
	{
		if (opponentmode)
		{
			var result:Dynamic = callOnLuas('goodNoteHitPre', [
				notes.members.indexOf(note),
				Math.abs(note.noteData),
				note.noteType,
				note.isSustainNote
			]);
			if (result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
				callOnHScript('goodNoteHitPre', [note]);
		}
		else
		{
			var result:Dynamic = callOnLuas('opponentNoteHitPre', [
				notes.members.indexOf(note),
				Math.abs(note.noteData),
				note.noteType,
				note.isSustainNote
			]);
			if (result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
				callOnHScript('opponentNoteHitPre', [note]);
		}

		if (note.wasGoodHit || (field.autoPlayed && (note.ignoreNote || note.breaksCombo)))
			return;

		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);
		if (songName != 'tutorial')
			camZooming = true;

		var chars:Array<Character> = note.characters;
		if (note.gfNote)
			chars.push(gf);
		else if (chars.length == 0)
			chars = field.characters;

		/*for(char in chars){
			if(note.noteType == 'Hey!' && char.animOffsets.exists('hey')) {
				dad.playAnim('hey', true);
				dad.specialAnim = true;
				dad.heyTimer = 0.6;
			} else if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];
				animToPlay += note.animSuffix;

				if (dad != null){
					dad.playAnim(animToPlay, true);
					dad.holdTimer = 0;
				}
			}
		}*/

		if (AIPlayer.active && !note.isSustainNote && !playAsGF)
		{
			comboOpp += 1;
			popUpScoreOpp(note);
			// if(combo > 9999) combo = 9999;
		}

		if (!note.noAnimation)
		{
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection)
					altAnim = '-alt';

			if (opponentmode)
			{
				if (!note.exNote && !note.gfNote && note.noteType != 'GF Duet')
				{
					if (boyfriend != null)
					{
						if (!note.animation.curAnim.name.endsWith('tail'))
						{
							boyfriend.playAnim('sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))] + altAnim, true);
							boyfriend.holdTimer = 0;
						}
					}
				}

				if (!note.exNote && !note.gfNote && note.noteType == 'GF Duet')
				{
					gf.playAnim('sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))] + altAnim, true);
					gf.holdTimer = 0;
					boyfriend.playAnim('sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))] + altAnim, true);
					boyfriend.holdTimer = 0;
				}

				if (!note.exNote && note.gfNote && note.noteType != 'GF Duet')
				{
					if (gf != null)
					{
						if (!note.animation.curAnim.name.endsWith('tail'))
						{
							gf.playAnim('sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))] + altAnim, true);
							gf.holdTimer = 0;
						}
					}
				}

				if (note.exNote && !note.gfNote && note.noteType != 'GF Duet')
				{
					if (bf2 != null)
					{
						if (!note.animation.curAnim.name.endsWith('tail'))
						{
							bf2.playAnim('sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))] + altAnim, true);
							bf2.holdTimer = 0;
						}
					}
				}

				if (note.noteType == 'Hey!')
				{
					if (boyfriend.animOffsets.exists('hey'))
					{
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
					if (bf2 != null && bf2.animOffsets.exists('hey'))
					{
						bf2.playAnim('hey', true);
						bf2.specialAnim = true;
						bf2.heyTimer = 0.6;
					}
					if (gf != null && gf.animOffsets.exists('cheer'))
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}
			else
			{
				if (!note.exNote && !note.gfNote && note.noteType != 'GF Duet')
				{
					if (dad != null)
					{
						if (!note.animation.curAnim.name.endsWith('tail'))
						{
							dad.playAnim('sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))] + altAnim, true);
							dad.holdTimer = 0;
						}
					}
				}

				if (!note.exNote && !note.gfNote && note.noteType == 'GF Duet')
				{
					gf.playAnim('sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))] + altAnim, true);
					gf.holdTimer = 0;
					dad.playAnim('sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))] + altAnim, true);
					dad.holdTimer = 0;
				}

				if (!note.exNote && note.gfNote && note.noteType != 'GF Duet')
				{
					if (gf != null)
					{
						if (!note.animation.curAnim.name.endsWith('tail'))
						{
							gf.playAnim('sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))] + altAnim, true);
							gf.holdTimer = 0;
						}
					}
				}

				if (note.exNote && !note.gfNote && note.noteType != 'GF Duet')
				{
					if (dad2 != null)
					{
						if (!note.animation.curAnim.name.endsWith('tail'))
						{
							dad2.playAnim('sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))] + altAnim, true);
							dad2.holdTimer = 0;
						}
					}
				}

				if (note.noteType == 'Hey!')
				{
					if (dad.animOffsets.exists('hey'))
					{
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					}
					if (dad2 != null && bf2.animOffsets.exists('hey'))
					{
						dad2.playAnim('hey', true);
						dad2.specialAnim = true;
						dad2.heyTimer = 0.6;
					}
					if (gf != null && gf.animOffsets.exists('cheer'))
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}
		}

		if (note.visible)
		{
			var time:Float = 0.15;
			if (note.isSustainNote && !note.animation.curAnim.name.endsWith('tail'))
				time += 0.15;

			StrumPlayAnim(field, Std.int(Math.abs(note.noteData)) % Note.ammo[mania], time, note);
		}

		note.hitByOpponent = true;
		if (opponentVocals.length <= 0)
			vocals.volume = 1;
		if (gfVocals.length <= 0 && (note.gfNote || note.noteType == 'GF Duet'))
			gfVocals.volume = 1;
		for (track in tracks)
			track.volume = 1;

		if (opponentmode)
		{
			var result:Dynamic = callOnLuas('goodNoteHit', [
				notes.members.indexOf(note),
				Math.abs(note.noteData),
				note.noteType,
				note.isSustainNote
			]);
			if (result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
				callOnHScript('goodNoteHit', [note]);
		}
		else
		{
			var result:Dynamic = callOnLuas('opponentNoteHit', [
				notes.members.indexOf(note),
				Math.abs(note.noteData),
				note.noteType,
				note.isSustainNote
			]);
			if (result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
				callOnHScript('opponentNoteHit', [note]);
		}

		if (!note.isSustainNote && note.sustainLength == 0)
		{
			field.removeNote(note);
		}
		else if (note.isSustainNote)
			if (note.parent.unhitTail.contains(note))
				note.parent.unhitTail.remove(note);
	}

	function how(convertedvalue:String)
	{
		if (convertedvalue == 'true' || convertedvalue == 'True')
		{
			sh_r += (60 - sh_r) / 32;
		}
		else
		{
			sh_r = 600;
		}
	}

	function opponentMiss(daNote:Note, field:PlayField):Void
	{
		// Dupe note remove
		for (note in field.spawnedNotes)
		{
			if (!note.alive || daNote.tail.contains(note) || note.isSustainNote)
				continue;
			if (daNote != note && field.isPlayer && daNote.noteData == note.noteData && Math.abs(daNote.strumTime - note.strumTime) < 1)
				field.removeNote(note);
		}
		if (AIMode)
		{
			AIMisses++;
			AITotalPlayed++;
			if (!practiceMode)
				AIScore -= 10;
		}
		if (opponentVocals != null && opponentVocals.length <= 0)
			opponentVocals.volume = 0;
		if (gfVocals != null && gfVocals.length <= 0 && (daNote.gfNote || daNote.noteType == 'GF Duet'))
			gfVocals.volume = 1;
		comboOpp = 0;
	}

	private var AIScore:Int = 0;
	private var AIMisses:Int = 0;
	private var AITotalNotesHit:Float = 0;
	private var AITotalPlayed:Int = 0;

	// diff from goodNoteHit because it gets called when you release and re-press a hold
	// prob be useful for noteskins too

	inline function stepHold(note:Note, field:PlayField)
		callOnScripts("onHoldPress", [note, field]);

	inline function dropHold(note:Note, field:PlayField):Void
		callOnScripts("onHoldRelease", [note, field]);

	function goodNoteHit(note:Note, field:PlayField):Void
	{
		// if(note.wasGoodHit) return;
		if (cpuControlled && note.ignoreNote)
			return;

		var isSus:Bool = note.isSustainNote; // GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;

		if (opponentmode)
		{
			var result:Dynamic = callOnLuas('opponentNoteHitPre', [notes.members.indexOf(note), leData, leType, isSus]);
			if (result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
				callOnHScript('opponentNoteHitPre', [note]);
		}
		else
		{
			var result:Dynamic = callOnLuas('goodNoteHitPre', [notes.members.indexOf(note), leData, leType, isSus]);
			if (result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
				callOnHScript('goodNoteHitPre', [note]);
		}

		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if (!note.isSustainNote)
			noteHits.push(Conductor.songPosition);

		if (ClientPrefs.data.hitsoundVolume > 0 && !note.hitsoundDisabled)
			FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);

		// Strum animations
		if (note.visible)
		{
			if (field.autoPlayed)
			{
				var time:Float = 0.15;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('tail'))
					time += 0.15;

				StrumPlayAnim(field, Std.int(Math.abs(note.noteData)) % Note.ammo[mania], time, note);
			}
			else
			{
				var spr = field.strumNotes[note.noteData];
				if (spr != null && field.keysPressed[note.noteData])
					spr.playAnim('confirm', true, note);
			}
		}

		// if (cpuControlled)SONG.validScore = false; // if botplay hits a note, then you lose scoring

		if (note.hitCausesMiss)
		{
			switch (note.noteType)
			{
				case 'Hurt Note': // Hurt note
					if (boyfriend.animation.getByName('hurt') != null)
					{
						boyfriend.playAnim('hurt', true);
						boyfriend.specialAnim = true;
					}
			}
			note.wasGoodHit = true;
			if (!note.isSustainNote && note.tail.length == 0)
				field.removeNote(note);
			else if (note.isSustainNote)
			{
				if (note.parent != null)
					if (note.parent.unhitTail.contains(note))
						note.parent.unhitTail.remove(note);
			}
			return;
		}

		if (!note.isSustainNote)
		{
			// combo += 1;
			// popUpScore(note);
			// if(combo > 9999) combo = 9999;
		}

		var chars:Array<Character> = note.characters;
		if (note.gfNote)
			chars.push(gf);
		else if (chars.length == 0)
			chars = field.characters;

		if (!note.noAnimation)
		{
			var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[Std.int(Math.abs(note.noteData))];
			animToPlay += note.animSuffix;

			/*for(char in chars){
				if (char != null){
					char.playAnim(animToPlay, true);
					char.holdTimer = 0;
				}
			}*/

			if (opponentmode)
			{
				if (note.noteType == 'GF Duet' && !note.gfNote && !note.exNote)
				{
					gf.playAnim(animToPlay, true);
					gf.holdTimer = 0;
					dad.playAnim(animToPlay, true);
					dad.holdTimer = 0;
				}

				if (!note.gfNote && !note.exNote && note.noteType != 'GF Duet')
				{
					dad.playAnim(animToPlay, true);
					dad.holdTimer = 0;
				}

				if (note.exNote && note.mustPress && note.noteType != 'GF Duet')
				{
					if (dad2 != null)
					{
						dad2.playAnim(animToPlay, true);
						dad2.holdTimer = 0;
					}
				}

				if (gf != null && note.gfNote && !note.exNote && note.noteType != 'GF Duet')
				{
					gf.playAnim(animToPlay, true);
					gf.holdTimer = 0;
				}

				if (note.noteType == 'Hey!')
				{
					if (dad.animOffsets.exists('hey'))
					{
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					}
					if (dad2 != null && bf2.animOffsets.exists('hey'))
					{
						dad2.playAnim('hey', true);
						dad2.specialAnim = true;
						dad2.heyTimer = 0.6;
					}
					if (gf != null && gf.animOffsets.exists('cheer'))
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}
			else
			{
				if (note.noteType == 'GF Duet' && !note.gfNote && !note.exNote)
				{
					gf.playAnim(animToPlay, true);
					gf.holdTimer = 0;
					boyfriend.playAnim(animToPlay, true);
					boyfriend.holdTimer = 0;
				}

				if (!note.gfNote && !note.exNote && note.noteType != 'GF Duet')
				{
					boyfriend.playAnim(animToPlay, true);
					boyfriend.holdTimer = 0;
				}

				if (note.exNote && note.mustPress && note.noteType != 'GF Duet')
				{
					if (bf2 != null)
					{
						bf2.playAnim(animToPlay, true);
						bf2.holdTimer = 0;
					}
				}

				if (gf != null && note.gfNote && !note.exNote && note.noteType != 'GF Duet')
				{
					gf.playAnim(animToPlay, true);
					gf.holdTimer = 0;
				}

				if (note.noteType == 'Hey!')
				{
					if (boyfriend.animOffsets.exists('hey'))
					{
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
					if (bf2 != null && bf2.animOffsets.exists('hey'))
					{
						bf2.playAnim('hey', true);
						bf2.specialAnim = true;
						bf2.heyTimer = 0.6;
					}
					if (gf != null && gf.animOffsets.exists('cheer'))
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}
		}
		note.wasGoodHit = true;

		if (!note.isSustainNote && !playAsGF)
		{
			combo += 1;
			popUpScore(note);
			// if(combo > 9999) combo = 9999;
		}
		health += note.hitHealth * healthGain;
		bfkilledcheck = false;
		vocals.volume = 1;
		var isSus:Bool = note.isSustainNote; // GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;

		if (opponentmode)
		{
			var result:Dynamic = callOnLuas('opponentNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
			if (result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
				callOnHScript('opponentNoteHit', [note]);
		}
		else
		{
			var result:Dynamic = callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
			if (result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
				callOnHScript('goodNoteHit', [note]);
		}

		if (!note.isSustainNote && note.tail.length == 0)
			field.removeNote(note);
		else if (note.isSustainNote)
		{
			if (note.parent != null)
				if (note.parent.unhitTail.contains(note))
					note.parent.unhitTail.remove(note);
		}
	}

	var didLastBeat:Bool = false;

	function goodGFBop():Void
	{
		gfBopCombo++;
		if (gfBopCombo > gfBopComboBest)
		{
			gfBopComboBest++;
		}
		healthGF += 0.023;
		bfkilledcheck = false;
		didntPress = false;
		didLastBeat = true;
	}

	function badGFBop():Void
	{
		gfBopCombo = 0;
		gfMisses++;
		healthGF -= 0.0475;
		bfkilledcheck = true;
		if (gf != null)
		{
			gf.color = Std.parseInt("0xFFFF0000");
			FlxTween.tween(gf, {color: FlxColor.WHITE}, 0.1);
		}
		didntPress = true;
		didLastBeat = false;
	}

	function lightningStrikeShitAlt():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (boyfriend.animOffsets.exists('scared'))
		{
			boyfriend.playAnim('scared');
		}

		if (bf2 != null && bf2.animOffsets.exists('scared'))
		{
			bf2.playAnim('scared');
		}

		if (gf != null)
		{
			if (gf.animOffsets.exists('scared'))
			{
				gf.playAnim('scared');
			}
		}

		if (ClientPrefs.data.camZooms)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if (!camZooming)
			{ // Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if (ClientPrefs.data.flashing)
		{
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
			FlxG.camera.flash(FlxColor.WHITE);
		}
	}

	override function destroy()
	{
		#if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if (script != null)
			{
				script.call('onDestroy');
				script.destroy();
			}

		while (hscriptArray.length > 0)
			hscriptArray.pop();
		#end

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		FlxG.animationTimeScale = 1;
		#if FLX_PITCH FlxG.sound.music.pitch = 1; #end
		instance = null;
		super.destroy();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null) return;

		//trace('resynced vocals at ' + Math.floor(Conductor.songPosition));

		vocals.pause();
		opponentVocals.pause();
		gfVocals.pause();
		for (track in tracks)
			track.pause();

		FlxG.sound.music.play();
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			#if FLX_PITCH vocals.pitch = playbackRate; #end
		}
		if (Conductor.songPosition <= opponentVocals.length)
		{
			opponentVocals.time = Conductor.songPosition;
			#if FLX_PITCH opponentVocals.pitch = playbackRate; #end
		}
		if (Conductor.songPosition <= gfVocals.length)
		{
			gfVocals.time = Conductor.songPosition;
			#if FLX_PITCH gfVocals.pitch = playbackRate; #end
		}
		for (track in tracks)
		{
			if (Conductor.songPosition <= track.length)
			{
				track.time = Conductor.songPosition;
				#if FLX_PITCH track.pitch = playbackRate; #end
			}
		}
		vocals.play();
		opponentVocals.play();
		gfVocals.play();
		for (track in tracks)
			track.play();
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();
		if (vocals != null)
		{
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
				|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
			{
				resyncVocals();
			}
		}

		if (opponentVocals != null)
		{
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
				|| (SONG.needsVoices
					&& SONG.newVoiceStyle
					&& opponentVocals.playing
					&& Math.abs(opponentVocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
			{
				resyncVocals();
			}
		}

		if (gfVocals != null)
		{
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
				|| (SONG.needsVoices
					&& SONG.newVoiceStyle
					&& gfVocals.playing
					&& Math.abs(gfVocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
			{
				resyncVocals();
			}
		}

		for (track in tracks)
		{
			if (track != null)
			{
				if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
					|| (SONG.needsVoices
						&& SONG.newVoiceStyle
						&& Math.abs(track.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
				{
					resyncVocals();
				}
			}
		}

		if (gfScared && curStep % 2 == 0)
		{
			gf.playAnim('scared', true);
		}

		if (curStep == lastStepHit)
		{
			return;
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lastBeatHit:Int = -1;
	var ravemode:Bool = false;
	var ravemodeV2:Bool = false;
	var autoBotsRollOut:Bool = false;
	var isActiveRN:Bool = false;
	var chromvar:Float = 0.01;

	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat)
		{
			// trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		/*if (generatedMusic)
			{
				notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}*/

		if (curBeat % 4 / gfSpeed == 0)
			didLastBeat = false;

		if (!playAsGF)
		{
			iconP1.scale.set(1.2, 1.2);
			iconP2.scale.set(1.2, 1.2);
			if (dad2 != null)
				iconP22.scale.set(1.2, 1.2);
			if (iconP12 != null)
				iconP12.scale.set(1.2, 1.2);

			if (curBeat % 2 / gfSpeed == 0)
			{
				iconP1.angle = -15;
				iconP2.angle = -15;
				if (iconP22 != null)
					iconP22.angle = -15;
				if (iconP12 != null)
					iconP12.angle = -15;
			}
			else if (curBeat % 2 / gfSpeed == 1)
			{
				iconP1.angle = 15;
				iconP2.angle = 15;
				if (iconP22 != null)
					iconP22.angle = 15;
				if (iconP12 != null)
					iconP12.angle = 15;
			}

			iconP1.updateHitbox();
			iconP2.updateHitbox();
			if (dad2 != null)
				iconP22.updateHitbox();
			if (iconP12 != null)
				iconP12.updateHitbox();
		}
		else
		{
			if (gf != null)
			{
				if (gf.animation.curAnim.name == 'danceRight')
					iconGF.angle = -15;
				else if (gf.animation.curAnim.name == 'danceLeft')
					iconGF.angle = 15;
				iconGF.updateHitbox();
			}
		}

		if ((ravemode || ravemodeV2) && ClientPrefs.data.flashing)
		{
			if (ClientPrefs.data.flashing)
			{
				rave.forEach(function(light2:FlxSprite)
				{
					light2.visible = false;
				});

				curLight++;
				if (curLight > rave.length - 1)
					curLight = 0;

				rave.members[curLight].visible = true;
				rave.members[curLight].alpha = 1;
				FlxTween.tween(rave.members[curLight], {alpha: 0}, 0.3, {});
			}

			FlxG.camera.zoom += 0.030;
			camHUD.zoom += 0.04;
		}
		else
		{
			rave.members[curLight].visible = false;
			rave.members[curLight].alpha = 0;
		}

		if (didntPress)
		{
			badGFBop();
			didntPress = false;
		}

		if (gf != null
			&& !gfScared
			&& curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
			&& !gf.stunned
			&& gf.animation.curAnim.name != null
			&& !gf.animation.curAnim.name.startsWith("sing")
			&& !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0
			&& boyfriend.animation.curAnim != null
			&& !boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (bf2 != null
			&& curBeat % bf2.danceEveryNumBeats == 0
			&& bf2.animation.curAnim != null
			&& !bf2.animation.curAnim.name.startsWith('sing')
			&& !bf2.stunned)
		{
			bf2.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0
			&& dad.animation.curAnim != null
			&& !dad.animation.curAnim.name.startsWith('sing')
			&& !dad.stunned)
		{
			dad.dance();
		}
		if (dad2 != null)
		{
			if (curBeat % dad2.danceEveryNumBeats == 0
				&& dad2.animation.curAnim != null
				&& !dad2.animation.curAnim.name.startsWith('sing')
				&& !dad2.stunned)
			{
				dad2.dance();
			}
		}

		if (thunderON && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShitAlt();
		}
		lastBeatHit = curBeat;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.data.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}
			setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnScripts('altAnim', SONG.notes[curSection].altAnim);
			setOnScripts('gfSection', SONG.notes[curSection].gfSection);
			setOnScripts('exSection', SONG.notes[curSection].exSection);
		}

		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getSharedPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getSharedPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad))
		{
			if (SScript.global.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		try
		{
			var newScript:HScript = new HScript(null, file);
			if(newScript.parsingException != null)
			{
				addTextToDebug('ERROR ON LOADING: ${newScript.parsingException.message}', FlxColor.RED);
				newScript.destroy();
				return;
			}

			hscriptArray.push(newScript);
			if(newScript.exists('onCreate'))
			{
				var callValue = newScript.call('onCreate');
				if(!callValue.succeeded)
				{
					for (e in callValue.exceptions)
					{
						if (e != null)
						{
							var len:Int = e.message.indexOf('\n') + 1;
							if(len <= 0) len = e.message.length;
								addTextToDebug('ERROR ($file: onCreate) - ${e.message.substr(0, len)}', FlxColor.RED);
						}
					}

					newScript.destroy();
					hscriptArray.remove(newScript);
					trace('failed to initialize tea interp!!! ($file)');
				}
				else trace('initialized tea interp successfully: $file');
			}

		}
		catch(e)
		{
			var len:Int = e.message.indexOf('\n') + 1;
			if(len <= 0) len = e.message.length;
			addTextToDebug('ERROR - ' + e.message.substr(0, len), FlxColor.RED);
			var newScript:HScript = cast (SScript.global.get(file), HScript);
			if(newScript != null)
			{
				newScript.destroy();
				hscriptArray.remove(newScript);
			}
		}
	}
	#end

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;
		for(i in 0...len) {
			var script:HScript = hscriptArray[i];
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var myValue:Dynamic = null;
			try {
				var callValue = script.call(funcToCall, args);
				if(!callValue.succeeded)
				{
					var e = callValue.exceptions[0];
					if(e != null)
					{
						var len:Int = e.message.indexOf('\n') + 1;
						if(len <= 0) len = e.message.length;
						addTextToDebug('ERROR (${callValue.calledFunction}) - ' + e.message.substr(0, len), FlxColor.RED);
					}
				}
				else
				{
					myValue = callValue.returnValue;
					if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
					{
						returnVal = myValue;
						break;
					}

					if(myValue != null && !excludeValues.contains(myValue))
						returnVal = myValue;
				}
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			if(!instancesExclude.contains(variable))
				instancesExclude.push(variable);
			script.set(variable, arg);
		}
		#end
	}

	public var lastUpdatedDownscroll = false;

	public function forceChange(bool:Bool)
	{
		trace('changing downscroll to ' + bool);
		ClientPrefs.data.downScroll = bool;
		// ClientPrefs.downScroll = bool;
		// SaveData.P2downscroll = bool;
		lastUpdatedDownscroll = bool;
		if (ClientPrefs.data.downScroll)
		{
			strumLine.y = FlxG.height - 150;
			timeTxt.y = FlxG.height - 44;
			timeBar.x = timeTxt.x + 4;
			timeBar.y = timeTxt.y + (timeTxt.height / 4) + 4;
			if (!playAsGF)
			{
				healthBar.y = 0.11 * FlxG.height + 4;
				healthBar2.y = 0.11 * FlxG.height + 4;
				iconP1.y = healthBar.y - 75;
				iconP2.y = healthBar.y - 75;
				if (dad2 != null)
					iconP22.y = healthBar.y - 115;
				if (bf2 != null)
					iconP12.y = healthBar.y - 115;
			}
			else
			{
				healthBarGF.y = 0.11 * FlxG.height + 4;
				if (gf != null)
					iconGF.y = healthBar.y - 75;
			}
			scoreTxt.y = healthBar.y + 36;
			botplayTxt.y = timeBar.y - 78;
		}
		else
		{
			strumLine.y = 50;
			timeTxt.y = 19;
			timeBar.x = timeTxt.x + 4;
			timeBar.y = timeTxt.y + (timeTxt.height / 4) + 4;
			if (!playAsGF)
			{
				healthBar.y = FlxG.height * 0.89 + 4;
				healthBar2.y = FlxG.height * 0.89 + 4;
				iconP1.y = healthBar.y - 75;
				iconP2.y = healthBar.y - 75;
				if (dad2 != null)
					iconP22.y = healthBar.y - 115;
				if (bf2 != null)
					iconP12.y = healthBar.y - 115;
			}
			else
			{
				healthBarGF.y = FlxG.height * 0.89 + 4;
				if (gf != null)
					iconGF.y = healthBar.y - 75;
			}
			scoreTxt.y = healthBar.y + 36;
			botplayTxt.y = timeBar.y + 55;
		}

		for (i in strumLineNotes.members)
			i.y = strumLine.y;
	}

	function StrumPlayAnim(field:PlayField, id:Int, time:Float, ?note:Note)
	{
		var spr:StrumNote = field.strumNotes[id];

		if (spr != null)
		{
			spr.playAnim('confirm', true, note);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;

	public function RecalculateRating(badHit:Bool = false)
	{
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
		if (ret != LuaUtils.Function_Stop)
		{
			if (totalPlayed != 0) // Prevent divide by 0
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				// trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				ratingName = ratingStuff[ratingStuff.length - 1][0]; // Uses last string
				if (ratingPercent < 1)
					for (i in 0...ratingStuff.length - 1)
						if (ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
			}
			fullComboFunction();
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnScripts('rating', ratingPercent);
		setOnScripts('ratingName', ratingName);
		setOnScripts('ratingFC', ratingFC);
	}

	public var ratingNameAI:String = '?';
	public var ratingPercentAI:Float;
	public var ratingFCAI:String;

	public function RecalculateRatingAI(badHit:Bool = false)
	{
		setOnScripts('scoreAI', AIScore);
		setOnScripts('missesAI', AIMisses);
		setOnScripts('hitsAI', AITotalNotesHit);

		var ret:Dynamic = callOnScripts('onRecalculateRatingAI', null, true);
		if (ret != LuaUtils.Function_Stop)
		{
			if (AITotalPlayed != 0) // Prevent divide by 0
			{
				// Rating Percent
				ratingPercentAI = Math.min(1, Math.max(0, AITotalNotesHit / AITotalPlayed));
				// trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				ratingName = ratingStuff[ratingStuff.length - 1][0]; // Uses last string
				if (ratingPercentAI < 1)
					for (i in 0...ratingStuff.length - 1)
						if (ratingPercentAI < ratingStuff[i][1])
						{
							ratingNameAI = ratingStuff[i][0];
							break;
						}
			}
			fullComboFunction();
		}
		updateScoreAI(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnScripts('ratingAI', ratingPercentAI);
		setOnScripts('ratingNameAI', ratingNameAI);
		setOnScripts('ratingFCAI', ratingFCAI);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null)
	{
		if (chartingMode)
			return;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice') || ClientPrefs.getGameplaySetting('botplay'));
		if (cpuControlled || hadBotplayOn) //So that if it's turned off last second, they still dont get the achievement
			return;

		var altsongname = StringTools.replace(songName, '-', ' ');
		var a = [
			'resistance',
			'resistance-k',
			'resistance awsome mix',
			'resistance-kai',
			'resistalovania',
			'resistalovania-(mega-mix)',
			'fightback'
		];
		if (FlxG.save.data.resistCheck == null)
			FlxG.save.data.resistCheck = [false, false, false, false, false, false, false];
		for (name in achievesToCheck)
		{
			if (!Achievements.exists(name))
				continue;

			var unlock:Bool = false;
			if (name != WeekData.getWeekFileName() + '_nomiss') // common achievements
			{
				switch (name)
				{
					case 'ur_bad':
						unlock = (ratingPercent < 0.2 && !usedPractice);

					case 'ur_good':
						unlock = (ratingPercent >= 1 && !usedPractice);

					case 'oversinging':
						unlock = (boyfriend.holdTimer >= 10 && !usedPractice);

					case 'hype':
						unlock = (!boyfriendIdled && !usedPractice);

					case 'two_keys':
						unlock = (!usedPractice && keysPressed.length <= 2);

					case 'toastie':
						unlock = (!ClientPrefs.data.cacheOnGPU && !ClientPrefs.data.shaders && ClientPrefs.data.lowQuality
							&& !ClientPrefs.data.globalAntialiasing);

					case 'debugger':
						unlock = (songName == 'test' && !usedPractice);

					case 'smooth_moves':
						unlock = (songName.toLowerCase() == 'tutorial'
							&& Difficulty.getString().toUpperCase() == 'HARD'
							&& !changedDifficulty
							&& !usedPractice
							&& ratingName == 'SFC'
							&& !playAsGF);

					case 'beat_battle':
						unlock = (altsongname.toLowerCase() == 'beat battle'
							&& (Difficulty.getString().toUpperCase() == 'REASONABLE'
								|| Difficulty.getString().toUpperCase() == 'UNREASONABLE'
								|| Difficulty.getString().toUpperCase() == 'SEMIIMPOSSIBLE'
								|| Difficulty.getString().toUpperCase() == 'IMPOSSIBLE')
							&& !changedDifficulty
							&& !usedPractice
							&& !playAsGF);

					case 'beat_battle_master':
						unlock = (altsongname.toLowerCase() == 'beat battle'
							&& (Difficulty.getString().toUpperCase() == 'REASONABLE'
								|| Difficulty.getString().toUpperCase() == 'UNREASONABLE'
								|| Difficulty.getString().toUpperCase() == 'SEMIIMPOSSIBLE'
								|| Difficulty.getString().toUpperCase() == 'IMPOSSIBLE')
							&& !changedDifficulty
							&& !usedPractice
							&& songMisses < 11
							&& !playAsGF);

					case 'beat_battle_god':
						unlock = (altsongname.toLowerCase() == 'beat battle'
							&& (Difficulty.getString().toUpperCase() == 'SEMIIMPOSSIBLE'
								|| Difficulty.getString().toUpperCase() == 'IMPOSSIBLE')
							&& !changedDifficulty
							&& !usedPractice
							&& songMisses < 26
							&& !playAsGF);

					case 'beat_battle_fanatic':
						if (altsongname.toLowerCase() == 'beat battle'
							&& (Difficulty.getString().toUpperCase() == 'SEMIIMPOSSIBLE'
								|| Difficulty.getString().toUpperCase() == 'IMPOSSIBLE')
							&& !changedDifficulty
							&& !usedPractice
							&& songMisses < 26
							&& !playAsGF
							&& Achievements.isUnlocked('beat_battle_god'))
						{
							Achievements.addScore('beat_battle_fanatic');
						}

						if (altsongname.toLowerCase() == 'beat battle 2'
							&& ClientPrefs.data.modcharts
							&& !usedPractice
							&& !playAsGF)
						{
							Achievements.addScore('beat_battle_fanatic');
						}


					case 'feelinfrisky':
						unlock = (altsongname.toLowerCase() == 'funky fanta' && songMisses == 0 && !usedPractice && !playAsGF);

					case 'leantastic':
						unlock = (songName.toLowerCase() == 'uls' && songMisses == 0 && !usedPractice && !playAsGF);

					case 'punchout':
						unlock = (altsongname.toLowerCase() == 'pack a punch' && songMisses == 0 && !usedPractice && !playAsGF);

					case 'rawr':
						unlock = (songName.toLowerCase() == 'rawr' && songMisses == 0 && !changedDifficulty && !usedPractice && !playAsGF);

					case 'underlust':
						unlock = (altsongname.toLowerCase() == 'resistalovania (mega mix)'
							&& Difficulty.getString().toLowerCase() == 'unreal'
							&& !changedDifficulty
							&& !usedPractice
							&& !playAsGF);

					case 'resistified':
						for (i in a)
						{
							switch (i)
							{
								case 'resistance':
									if (songName.toLowerCase() == 'resistance'
										&& songMisses == 0
										&& !changedDifficulty
										&& !usedPractice
										&& !playAsGF
										&& FlxG.save.data.resistCheck[0] == false)
									{
										FlxG.save.data.resistCheck[0] = true;
										Achievements.addScore("resistified");
										FlxG.save.flush();
									}
								case 'resistance-k':
									if (songName.toLowerCase() == 'resistance-k'
										&& songMisses == 0
										&& !changedDifficulty
										&& !usedPractice
										&& !playAsGF
										&& FlxG.save.data.resistCheck[1] == false)
									{
										FlxG.save.data.resistCheck[1] = true;
										Achievements.addScore("resistified");
										FlxG.save.flush();
									}
								case 'resistance awsome mix':
									if (altsongname.toLowerCase() == 'resistance awsome mix'
										&& songMisses == 0
										&& !changedDifficulty
										&& !usedPractice
										&& !playAsGF
										&& FlxG.save.data.resistCheck[2] == false)
									{
										FlxG.save.data.resistCheck[2] = true;
										Achievements.addScore("resistified");
										FlxG.save.flush();
									}
								case 'resistance-kai':
									if (songName.toLowerCase() == 'resistance-kai'
										&& songMisses == 0
										&& !changedDifficulty
										&& !usedPractice
										&& !playAsGF
										&& FlxG.save.data.resistCheck[3] == false)
									{
										FlxG.save.data.resistCheck[3] = true;
										Achievements.addScore("resistified");
										FlxG.save.flush();
									}
								case 'resistalovania':
									if (songName.toLowerCase() == 'resistalovania'
										&& songMisses == 0
										&& !changedDifficulty
										&& !usedPractice
										&& !playAsGF
										&& FlxG.save.data.resistCheck[4] == false)
									{
										FlxG.save.data.resistCheck[4] = true;
										Achievements.addScore("resistified");
										FlxG.save.flush();
									}
								case 'resistalovania-(mega-mix)':
									if (altsongname.toLowerCase() == 'resistalovania (mega mix)'
										&& songMisses == 0
										&& !changedDifficulty
										&& !usedPractice
										&& !playAsGF
										&& FlxG.save.data.resistCheck[5] == false)
									{
										FlxG.save.data.resistCheck[5] = true;
										Achievements.addScore("resistified");
										FlxG.save.flush();
									}
								case 'fightback':
									if (altsongname.toLowerCase() == 'fightback'
										&& songMisses == 0
										&& !changedDifficulty
										&& !usedPractice
										&& !playAsGF
										&& FlxG.save.data.resistCheck[6] == false)
									{
										FlxG.save.data.resistCheck[6] = true;
										Achievements.addScore("resistified");
										FlxG.save.flush();
									}
							}
						}

					case 'skysthelimit':
						unlock = (songName.toLowerCase() == 'fangirl frenzy' && songMisses == 0 && !changedDifficulty && !usedPractice && !playAsGF);

					case 'mattdestroyer':
						unlock = (playbackRate >= 2 && !usedPractice && !playAsGF);

					case 'matteleminator':
						unlock = (playbackRate >= 5 && !usedPractice && !playAsGF);

					case 'mattgod':
						unlock = (playbackRate >= 10 && !usedPractice && !playAsGF);

					case 'matt':
						unlock = (playbackRate >= 15 && !usedPractice && !playAsGF);

					case 'mattbeyond':
						unlock = (playbackRate >= 20 && !usedPractice && !playAsGF);
					case 'possessed':
						unlock = (altsongname.toLowerCase() == 'possessed by the blood moon'
							&& (Difficulty.getString().toUpperCase() == 'FNF'
								|| Difficulty.getString().toUpperCase() == 'NITG')
							&& !changedDifficulty
							&& !usedPractice
							&& songMisses < 1
							&& !playAsGF);
					case 'themoon':
						unlock = (altsongname.toLowerCase() == 'possessed by the blood moon'
							&& Difficulty.getString().toUpperCase() == 'POSSESSED'
							&& !changedDifficulty
							&& !usedPractice
							&& songMisses < 1
							&& !playAsGF);
					case 'potatogameplay':
						unlock = (ClientPrefs.data.framerate == 1 && !usedPractice && !playAsGF);
					case 'error404':
						unlock = (songName.toLowerCase() == 'eternity' && songMisses == 0 && !changedDifficulty && !usedPractice && !playAsGF);
					case 'pokemon':
						if (!changedDifficulty && !usedPractice && !playAsGF)
						{
							unlock = (FlxG.save.data.PBTBM && FlxG.save.data.FF && FlxG.save.data.TL);
						}
					case 'waldosworstnightmare':
						if (!changedDifficulty && !usedPractice && !playAsGF)
						{
							unlock = (FlxG.save.data.PBTBM && FlxG.save.data.FF && FlxG.save.data.TL && FlxG.save.data.slowdown);
						}	
				}
			}

			if (unlock)
				Achievements.unlock(name);
		}
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}
