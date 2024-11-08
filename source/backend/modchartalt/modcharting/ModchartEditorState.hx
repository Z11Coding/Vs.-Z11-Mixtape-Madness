package backend.modchartalt.modcharting;

import lime.utils.Assets;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.util.FlxAxes;
import flixel.math.FlxPoint;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.Anchor;
import flixel.tweens.FlxEase;
import haxe.Json;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.util.FlxSort;
#if (flixel < "5.3.0")
import flixel.system.FlxSound;
#else
import flixel.sound.FlxSound;
#end
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUITabMenu;
import flixel.util.FlxDestroyUtil;
import flixel.addons.transition.FlxTransitionableState;
#if (PSYCH && PSYCHVERSION >= "0.7")
import flixel.addons.ui.FlxUIDropDownMenu;
import backend.Section.SwagSection;
import backend.MusicBeatSubstate;
import objects.Note;
import objects.StrumNote;
import backend.Song;
#else
import Section.SwagSection;
import Song;
import MusicBeatSubstate;
#end
import backend.modchartalt.modcharting.*;
import backend.modchartalt.modcharting.Modifier;
import backend.modchartalt.modcharting.ModchartFile;
import source.backend.modchart.ModManager;

class ModchartEditorEvent extends FlxSprite {
	#if ((PSYCH || LEATHER))
	public var data:Array<Dynamic>;

	public function new(data:Array<Dynamic>) {
		this.data = data;
		super(-300, 0);
		frames = Paths.getSparrowAtlas('editors/eventArrowModchart');
		animation.addByPrefix('note', 'idle0');
		// makeGraphic(48, 48);

		animation.play('note');
		setGraphicSize(ModchartEditorState.gridSize, ModchartEditorState.gridSize);
		updateHitbox();
		antialiasing = true;
	}

	public function getBeatTime():Float {
		return data[ModchartFile.EVENT_DATA][ModchartFile.EVENT_TIME];
	}
	#end
}

#if (PSYCH)
class ModchartEditorState extends backend.MusicBeatState
{
	var hasUnsavedChanges:Bool = false;

	override function closeSubState() {
		persistentUpdate = true;
		super.closeSubState();
	}

	public static function getBPMFromSeconds(time:Float) {
		#if PSYCH
		return Conductor.getBPMFromSeconds(time);
		#else
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: Conductor.bpm,
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (time >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange;
		#end
	}

	// pain
	// tried using a macro but idk how to use them lol
	public static var modifierList:Array<Class<Modifier>> = [
		// Basic Modifiers with no curpos math
		MiddleModifier,
		ReverseNotesModifier,
		SwapPlayfieldModifier,
		ReverseStrumsModifier,
		GlitchSpeedModifier,
		ExtraBoomModifier,
		ZigZagXModifier,
		ZigZagYModifier,
		ZigZagZModifier,
		SawToothXModifier,
		SawToothYModifier,
		SawToothZModifier,
		BeatAngleModifier,
		BeatScaleModifier,
		BeatScaleXModifier,
		BeatScaleYModifier,
		BeatSkewModifier,
		BeatSkewXModifier,
		BeatSkewYModifier,
		SquareXModifier,
		SquareYModifier,
		SquareZModifier,
		WaveLaneModifier,
		XModifier,
		YModifier,
		YDModifier,
		ZModifier,
		ConfusionModifier,
		MiniModifier,
		ScaleModifier,
		ScaleXModifier,
		ScaleYModifier,
		SkewModifier,
		SkewXModifier,
		SkewYModifier,
		// Modifiers with curpos math!!!
		// Drunk Modifiers
		DrunkXModifier,
		DrunkYModifier,
		DrunkZModifier,
		DrunkAngleModifier,
		TanDrunkXModifier,
		TanDrunkYModifier,
		TanDrunkZModifier,
		TanDrunkAngleModifier,
		CosecantXModifier,
		CosecantYModifier,
		CosecantZModifier,
		// Tipsy Modifiers
		TipsyXModifier,
		TipsyYModifier,
		TipsyZModifier,
		// Wave Modifiers
		WaveXModifier,
		WaveYModifier,
		WaveZModifier,
		WaveAngleModifier,
		TanWaveXModifier,
		TanWaveYModifier,
		TanWaveZModifier,
		TanWaveAngleModifier,
		// Scroll Modifiers
		ReverseModifier,
		CrossModifier,
		SplitModifier,
		AlternateModifier,
		SpeedModifier,
		BoostModifier,
		BrakeModifier,
		BoomerangModifier,
		WaveingModifier,
		TwirlModifier,
		RollModifier,
		// Stealth Modifiers
		StealthModifier,
		NoteStealthModifier,
		LaneStealthModifier,
		SuddenModifier,
		HiddenModifier,
		VanishModifier,
		BlinkModifier,
		// Path Modifiers
		IncomingAngleModifier,
		InvertSineModifier,
		DizzyModifier,
		TornadoModifier,
		EaseCurveModifier,
		EaseCurveXModifier,
		EaseCurveYModifier,
		EaseCurveZModifier,
		EaseCurveAngleModifier,
		BounceXModifier,
		BounceYModifier,
		BounceZModifier,
		BumpyModifier,
		BeatXModifier,
		BeatYModifier,
		BeatZModifier,
		ShrinkModifier,
		// Target Modifiers
		RotateModifier,
		StrumLineRotateModifier,
		JumpTargetModifier,
		LanesModifier,
		// Notes Modifiers
		TimeStopModifier,
		JumpNotesModifier,
		NotesModifier,
		// Misc Modifiers
		StrumsModifier,
		InvertModifier,
		FlipModifier,
		JumpModifier,
		StrumAngleModifier,
		EaseXModifier,
		EaseYModifier,
		EaseZModifier,
		ShakyNotesModifier,
		ArrowPath
	];
	public static var easeList:Array<String> = [
		"backIn", "backInOut", "backOut", "bounceIn", "bounceInOut", "bounceOut", "circIn", "circInOut", "circOut", "cubeIn", "cubeInOut", "cubeOut",
		"elasticIn", "elasticInOut", "elasticOut", "expoIn", "expoInOut", "expoOut", "linear", "quadIn", "quadInOut", "quadOut", "quartIn", "quartInOut",
		"quartOut", "quintIn", "quintInOut", "quintOut", "sineIn", "sineInOut", "sineOut", "smoothStepIn", "smoothStepInOut", "smoothStepOut",
		"smootherStepIn", "smootherStepInOut", "smootherStepOut",
	];
	
	// used for indexing
	public static var MOD_NAME = ModchartFile.MOD_NAME; // the modifier name
	public static var MOD_CLASS = ModchartFile.MOD_CLASS; // the class/custom mod it uses
	public static var MOD_TYPE = ModchartFile.MOD_TYPE; // the type, which changes if its for the player, opponent, a specific lane or all
	public static var MOD_PF = ModchartFile.MOD_PF; // the playfield that mod uses
	public static var MOD_LANE = ModchartFile.MOD_LANE; // the lane the mod uses

	public static var EVENT_TYPE = ModchartFile.EVENT_TYPE; // event type (set or ease)
	public static var EVENT_DATA = ModchartFile.EVENT_DATA; // event data
	public static var EVENT_REPEAT = ModchartFile.EVENT_REPEAT; // event repeat data

	public static var EVENT_TIME = ModchartFile.EVENT_TIME; // event time (in beats)
	public static var EVENT_SETDATA = ModchartFile.EVENT_SETDATA; // event data (for sets)
	public static var EVENT_EASETIME = ModchartFile.EVENT_EASETIME; // event ease time
	public static var EVENT_EASE = ModchartFile.EVENT_EASE; // event ease
	public static var EVENT_EASEDATA = ModchartFile.EVENT_EASEDATA; // event data (for eases)

	public static var EVENT_REPEATBOOL = ModchartFile.EVENT_REPEATBOOL; // if event should repeat
	public static var EVENT_REPEATCOUNT = ModchartFile.EVENT_REPEATCOUNT; // how many times it repeats
	public static var EVENT_REPEATBEATGAP = ModchartFile.EVENT_REPEATBEATGAP; // how many beats in between each repeat

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var notes:FlxTypedGroup<Note>;

	private var strumLine:FlxSprite;

	public var modManager:ModManager;
	public var playerField:PlayField;
	public var dadField:PlayField;

	public var notefields = new NotefieldManager();
	public var playfields = new FlxTypedGroup<PlayField>();
	public var allNotes:Array<Note> = []; // all notes
	public var mania:Int = 0;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var unspawnNotes:Array<Note> = [];
	public var loadedNotes:Array<Note> = []; // stored notes from the chart that unspawnNotes can copy from
	public var vocals:FlxSound;
	#if (PSYCH && PSYCHVERSION >= "0.7.3")
	public var opponentVocals:FlxSound;
	#end

	var generatedMusic:Bool = false;

	private var grid:FlxBackdrop;
	private var line:FlxSprite;
	var beatTexts:Array<FlxText> = [];

	public var eventSprites:FlxTypedGroup<ModchartEditorEvent>;

	public static var gridSize:Int = 64;

	public var highlight:FlxSprite;
	public var debugText:FlxText;

	var highlightedEvent:Array<Dynamic> = null;
	var stackedHighlightedEvents:Array<Array<Dynamic>> = [];

	var UI_box:FlxUITabMenu;

	var textBlockers:Array<FlxUIInputText> = [];
	var scrollBlockers:Array< #if (PSYCH && PSYCHVERSION >= "0.7" || SCEModchartingTools) FlxUIDropDownMenu #end> = [];

	var playbackSpeed:Float = 1;

	var activeModifiersText:FlxText;
	var selectedEventBox:FlxSprite;

	var inst:FlxSound;

	public var opponentMode:Bool = false;

	#if (PSYCH && PSYCHVERSION >= "0.7.1")
	var backupGpu:Bool;
	#end

	override public function new() {
		super();
	}

	override public function create() {
		// SCE Ed's and mine's engine already fixes this without this code.
		#if (!SCEModchartingTools && (PSYCH && PSYCHVERSION >= "0.7.1"))
		backupGpu = ClientPrefs.data.cacheOnGPU;
		ClientPrefs.data.cacheOnGPU = false;
		#end
		#if PSYCH
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		#end
		#if (PSYCH && PSYCHVERSION >= "0.7.3")
		camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);
		#else
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		#end

		persistentUpdate = true;
		persistentDraw = true;

		opponentMode = ClientPrefs.getGameplaySetting('opponentplay', false);

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		add(bg);

		#if PSYCH
		if (PlayState.isPixelStage) // Skew Kills Pixel Notes (How are you going to stretch already pixelated bit by bit notes?)
		{
			modifierList.remove(SkewModifier);
			modifierList.remove(SkewXModifier);
			modifierList.remove(SkewYModifier);
		}
		#end

		if (PlayState.SONG == null)
			PlayState.SONG = Song.loadFromJson('beat-battle-2-hard', 'beat-battle-2');
		Conductor.mapBPMChanges(PlayState.SONG);
		#if (PSYCH && PSYCHVERSION >= "0.7")
		Conductor.bpm = PlayState.SONG.bpm;
		#else
		Conductor.changeBPM(PlayState.SONG.bpm);
		#end

		speedChanges.push({
			position: 0,
			songTime: 0,
			startTime: 0,
			startSpeed: 1,
			speed: 1,
		});

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.mouse.visible = true;

		#if (PSYCH && PSYCHVERSION >= "0.7")
		strumLine = new FlxSprite(ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (ModchartUtil.getDownscroll(this))
			strumLine.y = FlxG.height - 150;
		#elseif (PSYCH && !(PSYCHVERSION >= "0.7"))
		strumLine = new FlxSprite(ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (ModchartUtil.getDownscroll(this))
			strumLine.y = FlxG.height - 150;
		#else
		strumLine = new FlxSprite(0, 100).makeGraphic(FlxG.width, 10);
		#end

		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		//opponentStrums = new FlxTypedGroup<StrumNote>();
		//playerStrums = new FlxTypedGroup<StrumNote>();

		modManager = new ModManager(this);
		playerField = new PlayField(modManager);
		playerField.modNumber = 0;
		playerField.characters = [];
		playerField.noteField.isEditor = true;
		playerField.isPlayer = true;
		playerField.autoPlayed = true;
		playerField.instance = this;
		//playerField.noteHitCallback = opponentmode ? opponentNoteHit : goodNoteHit;

		dadField = new PlayField(modManager);
		dadField.isPlayer = false;
		dadField.autoPlayed = true;
		dadField.modNumber = 1;
		dadField.characters = [];
		dadField.noteField.isEditor = true;
		dadField.instance = this;
		//dadField.noteHitCallback = opponentmode ? goodNoteHit : opponentNoteHit;

		playfields.add(dadField);
		playfields.add(playerField);

		initPlayfield(dadField);
		initPlayfield(playerField);

		generateSong(PlayState.SONG);

		for (field in playfields.members)
		{
			field.keyCount = Note.ammo[3];
			field.generateStrums();
			field.fadeIn(true);
		}

		modManager.registerDefaultModifiers();

		playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
		playfieldRenderer.cameras = [camHUD];
		playfieldRenderer.inEditor = true;
		//add(objects.playfields.PlayField.publicStrums);
		add(playfieldRenderer);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];

		#if ("flixel-addons" >= "3.0.0")
		grid = new FlxBackdrop(FlxGraphic.fromBitmapData(createGrid(gridSize, gridSize, FlxG.width, gridSize)), FlxAxes.X, 0, 0);
		#else
		grid = new FlxBackdrop(FlxGraphic.fromBitmapData(createGrid(gridSize, gridSize, FlxG.width, gridSize)), 0, 0, true, false);
		#end

		// #if ("flixel-addons" >= "3.0.0")
		// grid = new FlxBackdrop(FlxGraphic.fromBitmapData(createGrid(gridSize, gridSize, Std.int(gridSize*48), gridSize)), FlxAxes.X, 0, 0);
		// #else
		// grid = new FlxBackdrop(FlxGraphic.fromBitmapData(createGrid(gridSize, gridSize, Std.int(gridSize*48), gridSize)), 0, 0, true, false);
		// #end

		add(grid);

		for (i in 0...12) {
			var beatText = new FlxText(-50, gridSize, 0, i + "", 32);
			add(beatText);
			beatTexts.push(beatText);
		}

		eventSprites = new FlxTypedGroup<ModchartEditorEvent>();
		add(eventSprites);

		highlight = new FlxSprite().makeGraphic(gridSize, gridSize);
		highlight.alpha = 0.5;
		add(highlight);

		selectedEventBox = new FlxSprite().makeGraphic(32, 32);
		selectedEventBox.y = gridSize * 0.5;
		selectedEventBox.visible = false;
		add(selectedEventBox);

		updateEventSprites();

		line = new FlxSprite().makeGraphic(10, gridSize);
		line.color = FlxColor.BLACK;
		add(line);

		NoteMovement.getDefaultStrumPosEditor(this);

		// gridGap = FlxMath.remapToRange(Conductor.stepCrochet, 0, Conductor.stepCrochet, 0, gridSize); //idk why i even thought this was how i do it
		// trace(gridGap);

		//playerField.cameras = [camHUD];
		//dadField.cameras = [camHUD];
		//playfields.cameras = [camHUD];

		debugText = new FlxText(0, gridSize * 2, 0, "", 16);
		debugText.alignment = FlxTextAlign.LEFT;

		var tabs = [
			{name: "Editor", label: 'Editor'},
			{name: "Modifiers", label: 'Modifiers'},
			{name: "Events", label: 'Events'},
			{name: "Playfields", label: 'Playfields'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(FlxG.width - 200, 550);
		UI_box.x = 100;
		UI_box.y = gridSize * 2;
		UI_box.scrollFactor.set();
		add(UI_box);

		add(debugText);

		super.create(); // do here because tooltips be dumb
		_ui.load(null);
		setupEditorUI();
		setupModifierUI();
		setupEventUI();
		setupPlayfieldUI();

		var hideNotes:FlxButton = new FlxButton(0, FlxG.height, 'Show/Hide Notes', function() {
			// camHUD.visible = !camHUD.visible;
			playfieldRenderer.visible = !playfieldRenderer.visible;
		});
		hideNotes.scale.y *= 1.5;
		hideNotes.updateHitbox();
		hideNotes.y -= hideNotes.height;
		add(hideNotes);

		var hidenHud:Bool = false;
		var hideUI:FlxButton = new FlxButton(FlxG.width, FlxG.height, 'Show/Hide UI', function() {
			hidenHud = !hidenHud;
			if (hidenHud) {
				UI_box.alpha = 0;
				debugText.alpha = 0;
			} else {
				UI_box.alpha = 1;
				debugText.alpha = 1;
			}
			// camGame.visible = !camGame.visible;
		});
		hideUI.y -= hideUI.height;
		hideUI.x -= hideUI.width;
		add(hideUI);

		add(playfields);
		add(notefields);

		Cursor.cursorMode = Default;
	}

	public inline function getTimeFromSV(time:Float, event:SpeedEvent)
		return event.position + (modManager.getBaseVisPosD(time - event.songTime, 1) * event.speed);

	public inline function getVisualPosition()
		return getTimeFromSV(Conductor.songPosition, currentSV);

	public function getNoteInitialTime(time:Float)
	{
		var event:SpeedEvent = getSV(time);
		return getTimeFromSV(time, event);
	} 

	// good to call this whenever you make a playfield
	public function initPlayfield(field:PlayField)
	{
		notefields.add(field.noteField);

		//field.judgeManager = PlayState.instance.ratingsData[0];
		//field.holdPressCallback = stepHold;
		//field.holdReleaseCallback = dropHold;
		field.noteSpawned.add((dunceNote:Note, field:PlayField) ->	
		{
			notes.insert(0, dunceNote);
			dunceNote.spawned = true;

			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.splice(index, 1);
		});
	}

	#if (!SCEModchartingTools && (PSYCH && PSYCHVERSION >= "0.7.1"))
	override public function destroy() {
		ClientPrefs.data.cacheOnGPU = backupGpu;
		super.destroy();
	}
	#end

	var dirtyUpdateNotes:Bool = false;
	var dirtyUpdateEvents:Bool = false;
	var dirtyUpdateModifiers:Bool = false;
	var totalElapsed:Float = 0;

	override public function update(elapsed:Float) {
		modManager.update(elapsed, curDecBeat, curDecStep);
		for (field in playfields)
			field.noteField.songSpeed = 3.3;
		totalElapsed += elapsed;
		highlight.alpha = 0.8 + FlxMath.fastSin(totalElapsed * 5) * 0.15;
		super.update(elapsed);
		if (inst.time < 0) {
			inst.pause();
			inst.time = 0;
		} else if (inst.time > inst.length) {
			inst.pause();
			inst.time = 0;
		}
		Conductor.songPosition = inst.time;
		Conductor.visualPosition = getVisualPosition();
		currentSV = getSV(Conductor.songPosition);

		var songPosPixelPos = (((Conductor.songPosition / Conductor.stepCrochet) % 4) * gridSize);
		grid.x = -curDecStep * gridSize;
		line.x = gridSize * 4;

		for (i in 0...beatTexts.length) {
			beatTexts[i].x = -songPosPixelPos + (gridSize * 4 * (i + 1)) - 16;
			beatTexts[i].text = "" + (Math.floor(Conductor.songPosition / Conductor.crochet) + i);
		}
		var eventIsSelected:Bool = false;
		for (i in 0...eventSprites.members.length) {
			var pos = grid.x + (eventSprites.members[i].getBeatTime() * gridSize * 4) + (gridSize * 4);
			// var dec = eventSprites.members[i].beatTime-Math.floor(eventSprites.members[i].beatTime);
			eventSprites.members[i].x = pos; // + (dec*4*gridSize);
			if (highlightedEvent != null)
				if (eventSprites.members[i].data == highlightedEvent) {
					eventIsSelected = true;
					selectedEventBox.x = pos;
				}
		}
		selectedEventBox.visible = eventIsSelected;

		var blockInput = false;
		for (i in textBlockers)
			if (i.hasFocus) {
				blockInput = true;
				#if (PSYCH && PSYCHVERSION >= "0.7")
				ClientPrefs.toggleVolumeKeys(false);
				#elseif (PSYCH && !(PSYCHVERSION >= "0.7"))
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				#end
			}

		for (i in scrollBlockers)
			if (i.dropPanel.visible)
				blockInput = true;

		if (!blockInput) {
			#if (PSYCH && PSYCHVERSION >= "0.7")
			ClientPrefs.toggleVolumeKeys(true);
			#elseif (PSYCH && !(PSYCHVERSION >= "0.7"))
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			#end
			if (FlxG.keys.justPressed.SPACE) {
				if (inst.playing) {
					inst.pause();
					if (vocals != null)
						vocals.pause();
					#if (PSYCH && PSYCHVERSION >= "0.7.3")
					if (opponentVocals != null)
						opponentVocals.pause();
					#end
					playfieldRenderer.editorPaused = true;
				} else {
					if (vocals != null) {
						vocals.play();
						vocals.pause();
						vocals.time = inst.time;
						vocals.play();
					}
					#if (PSYCH && PSYCHVERSION >= "0.7.3")
					if (opponentVocals != null) {
						opponentVocals.play();
						opponentVocals.pause();
						opponentVocals.time = inst.time;
						opponentVocals.play();
					}
					#end
					inst.play();
					playfieldRenderer.editorPaused = false;
					dirtyUpdateNotes = true;
					dirtyUpdateEvents = true;
				}
			}
			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (FlxG.mouse.wheel != 0) {
				inst.pause();
				if (vocals != null)
					vocals.pause();
				#if (PSYCH && PSYCHVERSION >= "0.7.3")
				if (opponentVocals != null)
					opponentVocals.pause();
				#end
				inst.time += (FlxG.mouse.wheel * Conductor.stepCrochet * 0.8 * shiftThing);
				if (vocals != null) {
					vocals.pause();
					vocals.time = inst.time;
				}
				#if (PSYCH && PSYCHVERSION >= "0.7.3")
				if (opponentVocals != null) {
					opponentVocals.pause();
					opponentVocals.time = inst.time;
				}
				#end
				playfieldRenderer.editorPaused = true;
				dirtyUpdateNotes = true;
				dirtyUpdateEvents = true;
			}

			if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT) {
				inst.pause();
				if (vocals != null)
					vocals.pause();
				#if (PSYCH && PSYCHVERSION >= "0.7.3")
				if (opponentVocals != null)
					opponentVocals.pause();
				#end
				inst.time += (Conductor.crochet * 4 * shiftThing);
				dirtyUpdateNotes = true;
				dirtyUpdateEvents = true;
			}
			if (FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT) {
				inst.pause();
				if (vocals != null)
					vocals.pause();
				#if (PSYCH && PSYCHVERSION >= "0.7.3")
				if (opponentVocals != null)
					opponentVocals.pause();
				#end
				inst.time -= (Conductor.crochet * 4 * shiftThing);
				dirtyUpdateNotes = true;
				dirtyUpdateEvents = true;
			}
			var holdingShift = FlxG.keys.pressed.SHIFT;
			var holdingLB = FlxG.keys.pressed.LBRACKET;
			var holdingRB = FlxG.keys.pressed.RBRACKET;
			var pressedLB = FlxG.keys.justPressed.LBRACKET;
			var pressedRB = FlxG.keys.justPressed.RBRACKET;

			var curSpeed = playbackSpeed;

			if (!holdingShift && pressedLB || holdingShift && holdingLB)
				playbackSpeed -= 0.01;
			if (!holdingShift && pressedRB || holdingShift && holdingRB)
				playbackSpeed += 0.01;
			if (FlxG.keys.pressed.ALT && (pressedLB || pressedRB || holdingLB || holdingRB))
				playbackSpeed = 1;
			//
			if (curSpeed != playbackSpeed)
				dirtyUpdateEvents = true;
		}

		if (playbackSpeed <= 0.5)
			playbackSpeed = 0.5;
		if (playbackSpeed >= 3)
			playbackSpeed = 3;

		playfieldRenderer.speed = playbackSpeed; // adjust the speed of tweens
		#if FLX_PITCH
		inst.pitch = playbackSpeed;
		vocals.pitch = playbackSpeed;
		#if (PSYCH && PSYCHVERSION >= "0.7.3")
		if (opponentVocals != null)
			opponentVocals.pitch = playbackSpeed;
		#end
		#end

		if (FlxG.mouse.y < grid.y + grid.height && FlxG.mouse.y > grid.y) // not using overlap because the grid would go out of world bounds
		{
			if (FlxG.keys.pressed.SHIFT)
				highlight.x = FlxG.mouse.x;
			else
				highlight.x = (Math.floor((FlxG.mouse.x - (grid.x % gridSize)) / gridSize) * gridSize) + (grid.x % gridSize);
			if (FlxG.mouse.overlaps(eventSprites)) {
				if (FlxG.mouse.justPressed) {
					stackedHighlightedEvents = []; // reset stacked events
				}
				eventSprites.forEachAlive(function(event:ModchartEditorEvent) {
					if (FlxG.mouse.overlaps(event)) {
						if (FlxG.mouse.justPressed) {
							highlightedEvent = event.data;
							stackedHighlightedEvents.push(event.data);
							onSelectEvent();
							// trace(stackedHighlightedEvents);
						}
						if (FlxG.keys.justPressed.BACKSPACE)
							deleteEvent();
					}
				});
				if (FlxG.mouse.justPressed) {
					updateStackedEventDataStepper();
				}
			} else {
				if (FlxG.mouse.justPressed) {
					var timeFromMouse = ((highlight.x - grid.x) / gridSize / 4) - 1;
					// trace(timeFromMouse);
					var event = addNewEvent(timeFromMouse);
					highlightedEvent = event;
					onSelectEvent();
					updateEventSprites();
					dirtyUpdateEvents = true;
				}
			}
		}

		if (dirtyUpdateNotes) {
			clearNotesAfter(Conductor.songPosition + 2000); // so scrolling back doesnt lag shit
			unspawnNotes = loadedNotes.copy();
			allNotes = loadedNotes.copy();
			clearNotesBefore(Conductor.songPosition);
			dirtyUpdateNotes = false;
		}
		if (dirtyUpdateModifiers) {
			playfieldRenderer.modifierTable.clear();
			playfieldRenderer.modchart.loadModifiers();
			dirtyUpdateEvents = true;
			dirtyUpdateModifiers = false;
		}
		if (dirtyUpdateEvents) {
			playfieldRenderer.tweenManager.completeAll();
			playfieldRenderer.eventManager.clearEvents();
			playfieldRenderer.modifierTable.resetMods();
			playfieldRenderer.modchart.loadEvents();
			dirtyUpdateEvents = false;
			playfieldRenderer.update(0);
			updateEventSprites();
		}

		if (playfieldRenderer.modchart.data.playfields != playfieldCountStepper.value) {
			playfieldRenderer.modchart.data.playfields = Std.int(playfieldCountStepper.value);
			playfieldRenderer.modchart.loadPlayfields();
		}

		if (FlxG.keys.justPressed.ESCAPE) {
			var exitFunc = function() {
				#if (PSYCH && PSYCHVERSION >= "0.7")
				ClientPrefs.toggleVolumeKeys(true);
				#elseif (PSYCH && !(PSYCHVERSION >= "0.7"))
				FlxG.sound.muteKeys = TitleState.muteKeys;
				FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
				FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
				#end
				FlxG.mouse.visible = false;
				inst.stop();
				if (vocals != null)
					vocals.stop();
				#if (PSYCH && PSYCHVERSION >= "0.7.3")
				if (opponentVocals != null)
					opponentVocals.stop();
				#end

				#if (PSYCH && PSYCHVERSION >= "0.7")
				backend.StageData.loadDirectory(PlayState.SONG);
				#elseif (PSYCH && !(PSYCHVERSION >= "0.7"))
				StageData.loadDirectory(PlayState.SONG);
				#end
				LoadingState.loadAndSwitchState(new PlayState());
			};
			if (hasUnsavedChanges) {
				persistentUpdate = false;
				openSubState(new ModchartEditorExitSubstate(exitFunc));
			} else
				exitFunc();
		}

		var curBpmChange = getBPMFromSeconds(Conductor.songPosition);
		if (curBpmChange.songTime <= 0) {
			curBpmChange.bpm = PlayState.SONG.bpm; // start bpm
		}
		if (curBpmChange.bpm != Conductor.bpm) {
			// trace('changed bpm to ' + curBpmChange.bpm);
			#if (PSYCH && PSYCHVERSION >= "0.7")
			Conductor.bpm = curBpmChange.bpm;
			#else
			Conductor.changeBPM(curBpmChange.bpm);
			#end
		}

		debugText.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(inst.length / 1000, 2))
			+ "\nBeat: "
			+ Std.string(curDecBeat).substring(0, 4)
			+ "\nStep: "
			+ curStep
			+ "\n";

		var leText = "Active Modifiers: \n";
		for (modName => mod in playfieldRenderer.modifierTable.modifiers) {
			if (mod.currentValue != mod.baseValue) {
				leText += modName + ": " + FlxMath.roundDecimal(mod.currentValue, 2);
				for (subModName => subMod in mod.subValues) {
					leText += "    " + subModName + ": " + FlxMath.roundDecimal(subMod.value, 2);
				}
				leText += "\n";
			}
		}

		activeModifiersText.text = leText;
	}

	function addNewEvent(time:Float) {
		var event:Array<Dynamic> = ['ease', [time, 1, 'cubeInOut', ','], [false, 1, 1]];
		if (highlightedEvent != null) // copy over current event data (without acting as a reference)
		{
			event[EVENT_TYPE] = highlightedEvent[EVENT_TYPE];
			if (event[EVENT_TYPE] == 'ease') {
				event[EVENT_DATA][EVENT_EASETIME] = highlightedEvent[EVENT_DATA][EVENT_EASETIME];
				event[EVENT_DATA][EVENT_EASE] = highlightedEvent[EVENT_DATA][EVENT_EASE];
				event[EVENT_DATA][EVENT_EASEDATA] = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
			} else {
				event[EVENT_DATA][EVENT_SETDATA] = highlightedEvent[EVENT_TYPE][EVENT_SETDATA];
			}
			event[EVENT_REPEAT][EVENT_REPEATBOOL] = highlightedEvent[EVENT_REPEAT][EVENT_REPEATBOOL];
			event[EVENT_REPEAT][EVENT_REPEATCOUNT] = highlightedEvent[EVENT_REPEAT][EVENT_REPEATCOUNT];
			event[EVENT_REPEAT][EVENT_REPEATBEATGAP] = highlightedEvent[EVENT_REPEAT][EVENT_REPEATBEATGAP];
		}
		playfieldRenderer.modchart.data.events.push(event);
		hasUnsavedChanges = true;
		return event;
	}

	function updateEventSprites() {
		// var i = eventSprites.length - 1;
		// while (i >= 0) {
		//     var daEvent:ModchartEditorEvent = eventSprites.members[i];
		//     var beat:Float = playfieldRenderer.modchart.data.events[i][1][0];
		//     if(curBeat < beat-4 && curBeat > beat+16)
		//     {
		//         daEvent.active = false;
		//         daEvent.visible = false;
		//         daEvent.alpha = 0;
		//         eventSprites.remove(daEvent, true);
		//         trace(daEvent.getBeatTime());
		//         trace("removed event sprite "+ daEvent.getBeatTime());
		//     }
		//     --i;
		// }
		eventSprites.clear();
		for (i in 0...playfieldRenderer.modchart.data.events.length) {
			var beat:Float = playfieldRenderer.modchart.data.events[i][1][0];
			if (curBeat > beat - 5 && curBeat < beat + 5) {
				var daEvent:ModchartEditorEvent = new ModchartEditorEvent(playfieldRenderer.modchart.data.events[i]);
				eventSprites.add(daEvent);
				// trace("added event sprite "+beat);
			}
		}
	}

	function deleteEvent() {
		if (highlightedEvent == null)
			return;
		for (i in 0...playfieldRenderer.modchart.data.events.length) {
			if (highlightedEvent == playfieldRenderer.modchart.data.events[i]) {
				playfieldRenderer.modchart.data.events.remove(playfieldRenderer.modchart.data.events[i]);
				dirtyUpdateEvents = true;
				break;
			}
		}
		updateEventSprites();
	}

	override public function beatHit() {
		updateEventSprites();
		// trace("beat hit");
		super.beatHit();
	}

	override public function draw() {
		super.draw();
	}

	public function clearNotesBefore(time:Float) {
		var i:Int = allNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = allNotes[i];
			if (daNote.strumTime + 350 < time) {
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				for (field in playfields)
					field.removeNote(daNote);
			}
			--i;
		}

		i = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if (daNote.strumTime + 350 < time) {
				daNote.active = false;
				daNote.visible = false;
				// daNote.ignoreNote = true;

				// daNote.kill();
				unspawnNotes.remove(daNote);
				// daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if (daNote.strumTime + 350 < time) {
				daNote.active = false;
				daNote.visible = false;
				// daNote.ignoreNote = true;

				// daNote.kill();
				notes.remove(daNote, true);
				// daNote.destroy();
			}
			--i;
		}
	}

	public function clearNotesAfter(time:Float) {
		var i:Int = allNotes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = allNotes[i];
			if (daNote.strumTime > time)
			{
				daNote.ignoreNote = true;
				for (field in playfields)
					field.removeNote(daNote);
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if (daNote.strumTime > time) {
				daNote.active = false;
				daNote.visible = false;
				// daNote.ignoreNote = true;

				// daNote.kill();
				notes.remove(daNote, true);
				// daNote.destroy();
			}
			--i;
		}
	}

	public function generateSong(songData:SwagSong):Void {
		var songData = PlayState.SONG;
		Conductor.bpm = songData.bpm;

		#if (PSYCH && PSYCHVERSION >= "0.7.3")
		var boyfriendVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
		var dadVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
		#end

		vocals = new FlxSound();
		#if (PSYCH && PSYCHVERSION >= "0.7.3")
		opponentVocals = new FlxSound();
		#end
		try {
			if (PlayState.SONG.needsVoices) {
				#if (PSYCH && PSYCHVERSION >= "0.7.3" && !SCEModchartingTools)
				var normalVocals = Paths.voices(songData.song);
				var playerVocals = Paths.voices(songData.song, (boyfriendVocals == null || boyfriendVocals.length < 1) ? 'Player' : boyfriendVocals);
				vocals.loadEmbedded(playerVocals != null ? playerVocals : normalVocals);

				var oppVocals = Paths.voices(songData.song, (dadVocals == null || dadVocals.length < 1) ? 'Opponent' : dadVocals);
				if (oppVocals != null)
					opponentVocals.loadEmbedded(oppVocals);
				#end
			}
		} catch (e:Dynamic) {}

		FlxG.sound.list.add(vocals);
		// vocals.pitch = playbackRate;
		#if (PSYCH && PSYCHVERSION >= "0.7.3")
		FlxG.sound.list.add(opponentVocals);
		#end

		inst = new FlxSound();
		try {
			inst.loadEmbedded(Paths.inst(PlayState.SONG.song));
		} catch (e:Dynamic) {}
		FlxG.sound.list.add(inst);

		inst.onComplete = function() {
			inst.pause();
			Conductor.songPosition = 0;
			if (vocals != null) {
				vocals.pause();
				vocals.time = 0;
			}
			#if (PSYCH && PSYCHVERSION >= "0.7.3")
			if (opponentVocals != null) {
				opponentVocals.pause();
				opponentVocals.time = 0;
			}
			#end
		};

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;
		var songMania:Int = songData.startMania;
		mania = songMania;
		PlayState.mania = songMania;

		// NEW SHIT
		noteData = songData.notes;


		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		// var songName:String = Paths.formatToSongPath(PlayState.SONG.song);

		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3 && !opponentMode)
					gottaHitNote = !section.mustHitSection;
				else if (songNotes[1] <= 3 && opponentMode)
					gottaHitNote = !section.mustHitSection;
				
				var oldNote:Note;
				if (allNotes.length > 0)
					oldNote = allNotes[Std.int(allNotes.length - 1)];
				else
					oldNote = null;

				#if (PSYCH && PSYCHVERSION >= "0.7")
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, this);
				swagNote.sustainLength = songNotes[2];
				swagNote.mustPress = gottaHitNote;
				swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));
				swagNote.noteType = songNotes[3];
				if (!Std.isOfType(songNotes[3], String))
					swagNote.noteType = states.editors.ChartingStateOG.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
				#end

				swagNote.scrollFactor.set();

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

				final susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;
				final floorSus:Int = Math.floor(susLength);

				if (floorSus > 0) {
					for (susNote in 0...floorSus + 1) {
						oldNote = allNotes[Std.int(allNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote), daNoteData, oldNote, true, false, this);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
						sustainNote.noteType = swagNote.noteType;
						swagNote.tail.push(sustainNote);
						swagNote.unhitTail.push(sustainNote);
						sustainNote.parent = swagNote;
						sustainNote.scrollFactor.set();
						sustainNote.fieldIndex = swagNote.fieldIndex;
						playfield.queue(sustainNote);
						allNotes.push(sustainNote);

						#if (PSYCHVERSION >= "0.7")
						sustainNote.correctionOffset = swagNote.height / 2;
						if (!PlayState.isPixelStage)
						{
							if (oldNote.isSustainNote) {
								oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
								oldNote.scale.y /= playbackSpeed;
								oldNote.updateHitbox();
							}

							if (ClientPrefs.data.downScroll)
								sustainNote.correctionOffset = 0;
						}
						else if (oldNote.isSustainNote) {
							oldNote.scale.y /= playbackSpeed;
							oldNote.updateHitbox();
						}

						if (sustainNote.mustPress)
							sustainNote.x += FlxG.width / 2; // general offset
						else if (ClientPrefs.data.middleScroll) {
							sustainNote.x += 310;
							if (daNoteData > 1) // Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
						#end
					}
				}

				if (swagNote.mustPress) {
					swagNote.x += FlxG.width / 2; // general offset
				}
				#if (PSYCHVERSION >= "0.7")
				else if (ClientPrefs.data.middleScroll)
				#end
				{
					swagNote.x += 310;
					if (daNoteData > 1) // Up and Right
						swagNote.x += FlxG.width / 2 + 25;
				}
			}

			daBeats += 1;
		}

		allNotes.sort(sortByTime);
		for (fuck in allNotes)
			unspawnNotes.push(fuck);

		for (field in playfields.members)
		{
			var goobaeg:Array<Note> = [];
			for (column in field.noteQueue)
			{
				if (column.length >= Note.ammo[3])
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
		loadedNotes = allNotes.copy();
		generatedMusic = true;
	}

	function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	#if (PSYCH && PSYCHVERSION >= "0.7.3")
	function getVocalFromCharacter(char:String) {
		try {
			var path:String = Paths.getPath('characters/$char.json', TEXT, null, true);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		return null;
	}
	#end

	public static function createGrid(CellWidth:Int, CellHeight:Int, Width:Int, Height:Int):BitmapData {
		// How many cells can we fit into the width/height? (round it UP if not even, then trim back)
		var Color1 = FlxColor.GRAY; // quant colors!!!
		var Color2 = FlxColor.WHITE;
		// var Color3 = FlxColor.LIME;
		var rowColor:Int = Color1;
		var lastColor:Int = Color1;
		var grid:BitmapData = new BitmapData(Width, Height, true);

		// grid.lock();

		// FlxDestroyUtil.dispose(grid);

		// grid = null;

		// If there aren't an even number of cells in a row then we need to swap the lastColor value
		var y:Int = 0;
		var timesFilled:Int = 0;
		while (y <= Height) {
			var x:Int = 0;
			while (x <= Width) {
				if (timesFilled % 2 == 0)
					lastColor = Color1;
				else if (timesFilled % 2 == 1)
					lastColor = Color2;
				grid.fillRect(new Rectangle(x, y, CellWidth, CellHeight), lastColor);
				// grid.unlock();
				timesFilled++;

				x += CellWidth;
			}

			y += CellHeight;
		}

		return grid;
	}

	var currentModifier:Array<Dynamic> = null;
	var modNameInputText:FlxUIInputText;
	var modClassInputText:FlxUIInputText;
	var explainText:FlxText;
	var modTypeInputText:FlxUIInputText;
	var playfieldStepper:FlxUINumericStepper;
	var targetLaneStepper:FlxUINumericStepper;
	var modifierDropDown:FlxUIDropDownMenu;
	var mods:Array<String> = [];
	var subMods:Array<String> = [""];

	function updateModList() {
		mods = [];
		for (i in 0...playfieldRenderer.modchart.data.modifiers.length)
			mods.push(playfieldRenderer.modchart.data.modifiers[i][MOD_NAME]);
		if (mods.length == 0)
			mods.push('');
		modifierDropDown.setData(#if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end.makeStrIdLabelArray(mods, true));
		eventModifierDropDown.setData(#if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end
			.makeStrIdLabelArray(mods, true));
	}

	function updateSubModList(modName:String) {
		subMods = [""];
		if (playfieldRenderer.modifierTable.modifiers.exists(modName)) {
			for (subModName => subMod in playfieldRenderer.modifierTable.modifiers.get(modName).subValues) {
				subMods.push(subModName);
			}
		}
		subModDropDown.setData(#if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end.makeStrIdLabelArray(subMods, true));
	}

	function setupModifierUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Modifiers";

		for (i in 0...playfieldRenderer.modchart.data.modifiers.length)
			mods.push(playfieldRenderer.modchart.data.modifiers[i][MOD_NAME]);

		if (mods.length == 0)
			mods.push('');

		modifierDropDown = new
			#if (PSYCH && PSYCHVERSION >= "0.7")
			FlxUIDropDownMenu
			#end(25, 50, #if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end.makeStrIdLabelArray(mods, true),
				function(mod:String) {
					var modName = mods[Std.parseInt(mod)];
					for (i in 0...playfieldRenderer.modchart.data.modifiers.length)
						if (playfieldRenderer.modchart.data.modifiers[i][MOD_NAME] == modName)
							currentModifier = playfieldRenderer.modchart.data.modifiers[i];

					if (currentModifier != null) {
						// trace(currentModifier);
						modNameInputText.text = currentModifier[MOD_NAME];
						modClassInputText.text = currentModifier[MOD_CLASS];
						modTypeInputText.text = currentModifier[MOD_TYPE];
						playfieldStepper.value = currentModifier[MOD_PF];
						if (currentModifier[MOD_LANE] != null)
							targetLaneStepper.value = currentModifier[MOD_LANE];
					}
				});

		var refreshModifiers:FlxButton = new FlxButton(25 + modifierDropDown.width + 10, modifierDropDown.y, 'Refresh Modifiers', function() {
			updateModList();
		});
		refreshModifiers.scale.y *= 1.5;
		refreshModifiers.updateHitbox();

		var saveModifier:FlxButton = new FlxButton(refreshModifiers.x, refreshModifiers.y + refreshModifiers.height + 20, 'Save Modifier', function() {
			var alreadyExists = false;
			for (i in 0...playfieldRenderer.modchart.data.modifiers.length)
				if (playfieldRenderer.modchart.data.modifiers[i][MOD_NAME] == modNameInputText.text) {
					playfieldRenderer.modchart.data.modifiers[i] = [
						modNameInputText.text,
						modClassInputText.text,
						modTypeInputText.text,
						playfieldStepper.value,
						targetLaneStepper.value
					];
					alreadyExists = true;
				}

			if (!alreadyExists) {
				playfieldRenderer.modchart.data.modifiers.push([
					modNameInputText.text,
					modClassInputText.text,
					modTypeInputText.text,
					playfieldStepper.value,
					targetLaneStepper.value
				]);
			}
			dirtyUpdateModifiers = true;
			updateModList();
			hasUnsavedChanges = true;
		});

		var removeModifier:FlxButton = new FlxButton(saveModifier.x, saveModifier.y + saveModifier.height + 20, 'Remove Modifier', function() {
			for (i in 0...playfieldRenderer.modchart.data.modifiers.length)
				if (playfieldRenderer.modchart.data.modifiers[i][MOD_NAME] == modNameInputText.text) {
					playfieldRenderer.modchart.data.modifiers.remove(playfieldRenderer.modchart.data.modifiers[i]);
				}
			dirtyUpdateModifiers = true;
			updateModList();
			hasUnsavedChanges = true;
		});
		removeModifier.scale.y *= 1.5;
		removeModifier.updateHitbox();

		modNameInputText = new FlxUIInputText(modifierDropDown.x + 300, modifierDropDown.y, 160, '', 8);
		modClassInputText = new FlxUIInputText(modifierDropDown.x + 500, modifierDropDown.y, 160, '', 8);
		explainText = new FlxText(modifierDropDown.x + 200, modifierDropDown.y + 200, 160, '', 8);
		modTypeInputText = new FlxUIInputText(modifierDropDown.x + 700, modifierDropDown.y, 160, '', 8);
		playfieldStepper = new FlxUINumericStepper(modifierDropDown.x + 900, modifierDropDown.y, 1, -1, -1, 100, 0);
		targetLaneStepper = new FlxUINumericStepper(modifierDropDown.x + 900, modifierDropDown.y + 300, 1, -1, -1, 100, 0);

		textBlockers.push(modNameInputText);
		textBlockers.push(modClassInputText);
		textBlockers.push(modTypeInputText);
		scrollBlockers.push(modifierDropDown);

		var modClassList:Array<String> = [];
		for (i in 0...modifierList.length) {
			modClassList.push(Std.string(modifierList[i]).replace("modchartalt.modcharting.", "").replace("backend.", ""));
		}

		var modClassDropDown = new
			#if (PSYCH && PSYCHVERSION >= "0.7")
			FlxUIDropDownMenu
			#end(modClassInputText.x, modClassInputText.y + 30, #if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end
				.makeStrIdLabelArray(modClassList, true), function(mod:String) {
					modClassInputText.text = modClassList[Std.parseInt(mod)];
					if (modClassInputText.text != '')
						explainText.text = ('Current Modifier: ${modClassInputText.text}, Explaination: ' + modifierExplain(modClassInputText.text));
			});
		centerXToObject(modClassInputText, modClassDropDown);
		var modTypeList = ["All", "Player", "Opponent", "Lane"];
		var modTypeDropDown = new
			#if (PSYCH && PSYCHVERSION >= "0.7")
			FlxUIDropDownMenu
			#end(modTypeInputText.x, modClassInputText.y + 30, #if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end
				.makeStrIdLabelArray(modTypeList, true), function(mod:String) {
					modTypeInputText.text = modTypeList[Std.parseInt(mod)];
			});
		centerXToObject(modTypeInputText, modTypeDropDown);
		centerXToObject(modTypeInputText, explainText);

		scrollBlockers.push(modTypeDropDown);
		scrollBlockers.push(modClassDropDown);

		activeModifiersText = new FlxText(50, 180);
		tab_group.add(activeModifiersText);

		tab_group.add(modNameInputText);
		tab_group.add(modClassInputText);
		tab_group.add(explainText);
		tab_group.add(modTypeInputText);
		tab_group.add(playfieldStepper);
		tab_group.add(targetLaneStepper);

		tab_group.add(refreshModifiers);
		tab_group.add(saveModifier);
		tab_group.add(removeModifier);

		tab_group.add(makeLabel(modNameInputText, 0, -15, "Modifier Name"));
		tab_group.add(makeLabel(modClassInputText, 0, -15, "Modifier Class"));
		tab_group.add(makeLabel(explainText, 0, -15, "Modifier Explaination:"));
		tab_group.add(makeLabel(modTypeInputText, 0, -15, "Modifier Type"));
		tab_group.add(makeLabel(playfieldStepper, 0, -15, "Playfield (-1 = all)"));
		tab_group.add(makeLabel(targetLaneStepper, 0, -15, "Target Lane (only for Lane mods!)"));
		tab_group.add(makeLabel(playfieldStepper, 0, 15, "Playfield number starts at 0!"));

		tab_group.add(modifierDropDown);
		tab_group.add(modClassDropDown);
		tab_group.add(modTypeDropDown);
		UI_box.addGroup(tab_group);
	}

	// Thanks to glowsoony for the idea lol
	function modifierExplain(modifiersName:String):String {
		var explainString:String = '';

		switch modifiersName {
			case 'ZigZagXModifier':
				explainString = 'Modifier used to make the notes go zig-zag on the X axes';
			case 'ZigZagYModifier':
				explainString = 'Modifier used to make the notes go zig-zag on the Y axes';
			case 'ZigZagZModifier':
				explainString = 'Modifier used to make the notes go zig-zag on the Z axes';
			case 'SawToothXModifier':
				explainString = 'Modifier used to make the notes go saw-tooth on the X axes';
			case 'SawToothYModifier':
				explainString = 'Modifier used to make the notes go saw-tooth on the Y axes';
			case 'SawToothZModifier':
				explainString = 'Modifier used to make the notes go saw-tooth on the Z axes';
			case 'SquareXModifier':
				explainString = 'Modifier used to make the notes go square on the X axes';
			case 'SquareYModifier':
				explainString = 'Modifier used to make the notes go square on the Y axes';
			case 'SquareZModifier':
				explainString = 'Modifier used to make the notes go square on the Z axes';
			case 'BeatAngleModifier':
				explainString = 'Modifier similar to the Beat (X,Y,Z) but then for the angles';
			case 'BeatScaleModifier':
				explainString = 'Modifier similar to the Beat (X,Y,Z) but then for the scale';
			case 'BeatScaleXModifier':
				explainString = 'Modifier similar to the Beat (X,Y,Z) but then for the scale X';
			case 'BeatScaleYModifier':
				explainString = 'Modifier similar to the Beat (X,Y,Z) but then for the scale Y';
			case 'BeatSkewModifier':
				explainString = 'Modifier similar to the Beat (X,Y,Z) but then for the skew';
			case 'BeatSkewXModifier':
				explainString = 'Modifier similar to the Beat (X,Y,Z) but then for the skew X';
			case 'BeatSkewYModifier':
				explainString = 'Modifier similar to the Beat (X,Y,Z) but then for the skew Y';
			case 'WaveLaneModifier':
				explainString = 'Modifier similar to WaveAngleModifier but then rotates the lane with it';
			case 'DrunkXModifier':
				explainString = "Modifier used to do a wave at X poss of the notes and targets";
			case 'DrunkYModifier':
				explainString = "Modifier used to do a wave at Y poss of the notes and targets";
			case 'DrunkZModifier':
				explainString = "Modifier used to do a wave at Z (Far, Close) poss of the notes and targets";
			case 'TipsyXModifier':
				explainString = "Modifier similar to DrunkX but don't affect notes poss";
			case 'TipsyYModifier':
				explainString = "Modifier similar to DrunkY but don't affect notes poss";
			case 'TipsyZModifier':
				explainString = "Modifier similar to DrunkZ but don't affect notes poss";
			case 'ReverseModifier':
				explainString = "Flip the scroll type (Upscroll/Downscroll)";
			case 'ReverseNotesModifier':
				explainString = "Swaps opponent and player notes position";
			case 'SwapPlayfieldModifier':
				explainString = "Swaps opponent and player playfield position";
			case 'ReverseStrumsModifier':
				explainString = "Swaps opponent and player strum position";
			case 'MiddleModifier':
				explainString = "Makes gameplay middlescroll";
			case 'SplitModifier':
				explainString = "Flip the scroll type (HalfUpscroll/HalfDownscroll)";
			case 'CrossModifier':
				explainString = "Flip the scroll type (Upscroll/Downscroll/Downscroll/Upscroll)";
			case 'AlternateModifier':
				explainString = "Flip the scroll type (Upscroll/Downscroll/Upscroll/Downscroll)";
			case 'IncomingAngleModifier':
				explainString = "Modifier that changes how notes come to the target (if X and Y aplied it will use Z)";
			case 'RotateModifier':
				explainString = "Modifier used to rotate the lanes poss between a value aplied with rotatePoint (can be used with Y and X)";
			case 'StrumLineRotateModifier':
				explainString = "Modifier similar to RotateModifier but this one doesn't need a extra value (can be used with Y, X and Z)";
			case 'BumpyModifier':
				explainString = "Modifier used to make notes jump a bit in their own Perspective poss";
			case 'XModifier':
				explainString = "Moves notes and targets X";
			case 'YModifier':
				explainString = "Moves notes and targets Y";
			case 'YDModifier':
				explainString = "Moves notes and targets Y (Automatically reverses in downscroll)";
			case 'ZModifier':
				explainString = "Moves notes and targets Z (Far, Close)";
			case 'ConfusionModifier':
				explainString = "Changes notes and targets angle";
			case 'DizzyModifier':
				explainString = "Changes notes angle making a visual on them";
			case 'ScaleModifier':
				explainString = "Modifier used to make notes and targets bigger or smaller";
			case 'ScaleXModifier':
				explainString = "Modifier used to make notes and targets bigger or smaller (Only in X)";
			case 'ScaleYModifier':
				explainString = "Modifier used to make notes and targets bigger or smaller (Only in Y)";
			case 'SpeedModifier':
				explainString = "Modifier used to make notes be faster or slower";
			case 'StealthModifier':
				explainString = "Modifier used to change notes and targets alpha";
			case 'NoteStealthModifier':
				explainString = "Modifier used to change notes alpha";
			case 'LaneStealthModifier':
				explainString = "Modifier used to change targets alpha";
			case 'InvertModifier':
				explainString = "Modifier used to invert notes and targets X poss (down/left/right/up)";
			case 'FlipModifier':
				explainString = "Modifier used to flip notes and targets X poss (right/up/down/left)";
			case 'MiniModifier':
				explainString = "Modifier similar to ScaleModifier but this one does Z perspective";
			case 'ShrinkModifier':
				explainString = "Modifier used to add a boost of the notes (the more value the less scale it will be at the start)";
			case 'BeatXModifier':
				explainString = "Modifier used to move notes and targets X with a small jump effect";
			case 'BeatYModifier':
				explainString = "Modifier used to move notes and targets Y with a small jump effect";
			case 'BeatZModifier':
				explainString = "Modifier used to move notes and targets Z with a small jump effect";
			case 'BounceXModifier':
				explainString = "Modifier similar to beatX but it only affect notes X with a jump effect";
			case 'BounceYModifier':
				explainString = "Modifier similar to beatY but it only affect notes Y with a jump effect";
			case 'BounceZModifier':
				explainString = "Modifier similar to beatZ but it only affect notes Z with a jump effect";
			case 'EaseCurveModifier':
				explainString = "This enables the EaseModifiers";
			case 'EaseCurveXModifier':
				explainString = "Modifier similar to IncomingAngleMod (X), it will make notes come faster at X poss";
			case 'EaseCurveYModifier':
				explainString = "Modifier similar to IncomingAngleMod (Y), it will make notes come faster at Y poss";
			case 'EaseCurveZModifier':
				explainString = "Modifier similar to IncomingAngleMod (X+Y), it will make notes come faster at Z perspective";
			case 'EaseCurveScaleModifier':
				explainString = "Modifier similar to All easeCurve, it will make notes scale change, usually next to target";
			case 'EaseCurveAngleModifier':
				explainString = "Modifier similar to All easeCurve, it will make notes angle change, usually next to target";
			case 'InvertSineModifier':
				explainString = "Modifier used to do a curve in the notes it will be different for notes (Down and Right / Left and Up)";
			case 'BoostModifier':
				explainString = "Modifier used to make notes come faster to target";
			case 'BrakeModifier':
				explainString = "Modifier used to make notes come slower to target";
			case 'BoomerangModifier':
				explainString = "Modifier used to make notes come in reverse to target";
			case 'WaveingModifier':
				explainString = "Modifier used to make notes come faster and slower to target";
			case 'JumpModifier':
				explainString = "Modifier used to make notes and target jump";
			case 'WaveXModifier':
				explainString = "Modifier similar to drunkX but this one will simulate a true wave in X (don't affect the notes)";
			case 'WaveYModifier':
				explainString = "Modifier similar to drunkY but this one will simulate a true wave in Y (don't affect the notes)";
			case 'WaveZModifier':
				explainString = "Modifier similar to drunkZ but this one will simulate a true wave in Z (don't affect the notes)";
			case 'TimeStopModifier':
				explainString = "Modifier used to stop the notes at the top/bottom part of your screen to make it hard to read";
			case 'StrumAngleModifier':
				explainString = "Modifier combined between strumRotate, Confusion, IncomingAngleY, making a rotation easily";
			case 'JumpTargetModifier':
				explainString = "Modifier similar to jump but only target aplied";
			case 'JumpNotesModifier':
				explainString = "Modifier similar to jump but only notes aplied";
			case 'EaseXModifier':
				explainString = "Modifier used to make notes go left to right on the screen";
			case 'EaseYModifier':
				explainString = "Modifier used to make notes go up to down on the screen";
			case 'EaseZModifier':
				explainString = "Modifier used to make notes go far to near right on the screen";
			case 'HiddenModifier':
				explainString = "Modifier used to make an alpha boost on notes";
			case 'SuddenModifier':
				explainString = "Modifier used to make an alpha brake on notes";
			case 'VanishModifier':
				explainString = "Modifier fushion between sudden and hidden";
			case 'SkewModifier':
				explainString = "Modifier used to make note effects (skew)";
			case 'SkewXModifier':
				explainString = "Modifier based from SkewModifier but only in X";
			case 'SkewYModifier':
				explainString = "Modifier based from SkewModifier but only in Y";
			case 'NotesModifier':
				explainString = "Modifier based from other modifiers but only affects notes and no targets";
			case 'LanesModifier':
				explainString = "Modifier based from other modifiers but only affects targets and no notes";
			case 'StrumsModifier':
				explainString = "Modifier based from other modifiers but affects targets and notes";
			case 'TanDrunkXModifier':
				explainString = "Modifier similar to drunk but uses tan instead of sin in X";
			case 'TanDrunkYModifier':
				explainString = "Modifier similar to drunk but uses tan instead of sin in Y";
			case 'TanDrunkZModifier':
				explainString = "Modifier similar to drunk but uses tan instead of sin in Z";
			case 'TanWaveXModifier':
				explainString = "Modifier similar to wave but uses tan instead of sin in X";
			case 'TanWaveYModifier':
				explainString = "Modifier similar to wave but uses tan instead of sin in Y";
			case 'TanWaveZModifier':
				explainString = "Modifier similar to wave but uses tan instead of sin in Z";
			case 'TwirlModifier':
				explainString = "Modifier that makes the notes incoming rotating in a circle in X";
			case 'RollModifier':
				explainString = "Modifier that makes the notes incoming rotating in a circle in Y";
			case 'BlinkModifier':
				explainString = "Modifier that makes the notes alpha go to 0 and go back to 1 constantly";
			case 'CosecantXModifier':
				explainString = "Modifier similar to TanDrunk but uses cosecant instead of tan in X";
			case 'CosecantYModifier':
				explainString = "Modifier similar to TanDrunk but uses cosecant instead of tan in Y";
			case 'CosecantZModifier':
				explainString = "Modifier similar to TanDrunk but uses cosecant instead of tan in Z";
			case 'TanDrunkAngleModifier':
				explainString = "Modifier similar to TanDrunk but in angle";
			case 'DrunkAngleModifier':
				explainString = "Modifier similar to Drunk but in angle";
			case 'WaveAngleModifier':
				explainString = "Modifier similar to Wave but in angle";
			case 'TanWaveAngleModifier':
				explainString = "Modifier similar to TanWave but in angle";
			case 'ShakyNotesModifier':
				explainString = "Modifier used to make notes shake in their on possition";
			case 'TornadoModifier':
				explainString = "Modifier similar to invertSine, but notes will do their own path instead";
			case 'ArrowPath':
				explainString = "This modifier its able to make custom paths for the mods so this should be a very helpful tool";
		}

		return explainString;
	}

	function findCorrectModData(data:Array<Dynamic>) // the data is stored at different indexes based on the type (maybe should have kept them the same)
	{
		switch (data[EVENT_TYPE]) {
			case "ease":
				return data[EVENT_DATA][EVENT_EASEDATA];
			case "set":
				return data[EVENT_DATA][EVENT_SETDATA];
		}
		return null;
	}

	function setCorrectModData(data:Array<Dynamic>, dataStr:String) {
		switch (data[EVENT_TYPE]) {
			case "ease":
				data[EVENT_DATA][EVENT_EASEDATA] = dataStr;
			case "set":
				data[EVENT_DATA][EVENT_SETDATA] = dataStr;
		}
		return data;
	}

	// TODO: fix this shit
	function convertModData(data:Array<Dynamic>, newType:String) {
		switch (data[EVENT_TYPE]) // convert stuff over i guess
		{
			case "ease":
				if (newType == 'set') {
					trace('converting ease to set');
					var temp:Array<Dynamic> = [
						newType,
						[data[EVENT_DATA][EVENT_TIME], data[EVENT_DATA][EVENT_EASEDATA],],
						data[EVENT_REPEAT]
					];
					data = temp.copy();
				}
			case "set":
				if (newType == 'ease') {
					trace('converting set to ease');
					var temp:Array<Dynamic> = [
						newType,
						[data[EVENT_DATA][EVENT_TIME], 1, "linear", data[EVENT_DATA][EVENT_SETDATA],],
						data[EVENT_REPEAT]
					];
					trace(temp);
					data = temp.copy();
				}
		}
		// trace(data);
		return data;
	}

	function updateEventModData(shitToUpdate:String, isMod:Bool) {
		var data = getCurrentEventInData();
		if (data != null) {
			var dataStr:String = findCorrectModData(data);
			var dataSplit = dataStr.split(',');
			// the way the data works is it goes "value,mod,value,mod,....." and goes on forever, so it has to deconstruct and reconstruct to edit it and shit

			dataSplit[(getEventModIndex() * 2) + (isMod ? 1 : 0)] = shitToUpdate;
			dataStr = stringifyEventModData(dataSplit);
			data = setCorrectModData(data, dataStr);
		}
	}

	function getEventModData(isMod:Bool):String {
		var data = getCurrentEventInData();
		if (data != null) {
			var dataStr:String = findCorrectModData(data);
			var dataSplit = dataStr.split(',');
			return dataSplit[(getEventModIndex() * 2) + (isMod ? 1 : 0)];
		}
		return "";
	}

	function stringifyEventModData(dataSplit:Array<String>):String {
		var dataStr = "";
		for (i in 0...dataSplit.length) {
			dataStr += dataSplit[i];
			if (i < dataSplit.length - 1)
				dataStr += ',';
		}
		return dataStr;
	}

	function addNewModData() {
		var data = getCurrentEventInData();
		if (data != null) {
			var dataStr:String = findCorrectModData(data);
			dataStr += ",,"; // just how it works lol
			data = setCorrectModData(data, dataStr);
		}
		return data;
	}

	function removeModData() {
		var data = getCurrentEventInData();
		if (data != null) {
			if (selectedEventDataStepper.max > 0) // dont remove if theres only 1
			{
				var dataStr:String = findCorrectModData(data);
				var dataSplit = dataStr.split(',');
				dataSplit.resize(dataSplit.length - 2); // remove last 2 things
				dataStr = stringifyEventModData(dataSplit);
				data = setCorrectModData(data, dataStr);
			}
		}
		return data;
	}

	var eventTimeStepper:FlxUINumericStepper;
	var eventModInputText:FlxUIInputText;
	var eventValueInputText:FlxUIInputText;
	var eventDataInputText:FlxUIInputText;
	var eventModifierDropDown:#if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end;
	var eventTypeDropDown:#if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end;
	var eventEaseInputText:FlxUIInputText;
	var eventTimeInputText:FlxUIInputText;
	var selectedEventDataStepper:FlxUINumericStepper;
	var repeatCheckbox:FlxUICheckBox;
	var repeatBeatGapStepper:FlxUINumericStepper;
	var repeatCountStepper:FlxUINumericStepper;
	var easeDropDown:#if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end;
	var subModDropDown:#if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end;
	var builtInModDropDown:#if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end;
	var stackedEventStepper:FlxUINumericStepper;

	function setupEventUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Events";

		eventTimeStepper = new FlxUINumericStepper(850, 50, 0.25, 0, 0, 9999, 3);

		repeatCheckbox = new FlxUICheckBox(950, 50, null, null, "Repeat Event?");
		repeatCheckbox.checked = false;
		repeatCheckbox.callback = function() {
			var data = getCurrentEventInData();
			if (data != null) {
				data[EVENT_REPEAT][EVENT_REPEATBOOL] = repeatCheckbox.checked;
				highlightedEvent = data;
				dirtyUpdateEvents = true;
				hasUnsavedChanges = true;
			}
		}
		repeatBeatGapStepper = new FlxUINumericStepper(950, 100, 0.25, 0, 0, 9999, 3);
		repeatBeatGapStepper.name = 'repeatBeatGap';
		repeatCountStepper = new FlxUINumericStepper(950, 150, 1, 1, 1, 9999, 3);
		repeatCountStepper.name = 'repeatCount';
		centerXToObject(repeatCheckbox, repeatBeatGapStepper);
		centerXToObject(repeatCheckbox, repeatCountStepper);

		eventModInputText = new FlxUIInputText(25, 50, 160, '', 8);
		eventModInputText.callback = function(str:String, str2:String) {
			updateEventModData(eventModInputText.text, true);
			var data = getCurrentEventInData();
			if (data != null) {
				highlightedEvent = data;
				eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
				dirtyUpdateEvents = true;
				hasUnsavedChanges = true;
			}
		};
		eventValueInputText = new FlxUIInputText(25 + 200, 50, 160, '', 8);
		eventValueInputText.callback = function(str:String, str2:String) {
			updateEventModData(eventValueInputText.text, false);
			var data = getCurrentEventInData();
			if (data != null) {
				highlightedEvent = data;
				eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
				dirtyUpdateEvents = true;
				hasUnsavedChanges = true;
			}
		};

		selectedEventDataStepper = new FlxUINumericStepper(25 + 400, 50, 1, 0, 0, 0, 0);
		selectedEventDataStepper.name = "selectedEventMod";

		stackedEventStepper = new FlxUINumericStepper(25 + 400, 200, 1, 0, 0, 0, 0);
		stackedEventStepper.name = "stackedEvent";

		var addStacked:FlxButton = new FlxButton(stackedEventStepper.x, stackedEventStepper.y + 30, 'Add', function() {
			var data = getCurrentEventInData();
			if (data != null) {
				var event = addNewEvent(data[EVENT_DATA][EVENT_TIME]);
				highlightedEvent = event;
				onSelectEvent();
				updateEventSprites();
				dirtyUpdateEvents = true;
			}
		});
		centerXToObject(stackedEventStepper, addStacked);

		eventTypeDropDown = new
			#if (PSYCH && PSYCHVERSION >= "0.7")
			FlxUIDropDownMenu
			#else
			FlxUIDropDownMenuCustom
			#end(25 + 500, 50, #if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end
				.makeStrIdLabelArray(eventTypes, true), function(mod:String) {
					var et = eventTypes[Std.parseInt(mod)];
					trace(et);
					var data = getCurrentEventInData();
					if (data != null) {
						// if (data[EVENT_TYPE] != et)
						data = convertModData(data, et);
						highlightedEvent = data;
						trace(highlightedEvent);
					}
					eventEaseInputText.alpha = 1;
					eventTimeInputText.alpha = 1;
					if (et != 'ease') {
						eventEaseInputText.alpha = 0.5;
						eventTimeInputText.alpha = 0.5;
					}
					dirtyUpdateEvents = true;
					hasUnsavedChanges = true;
			});
		eventEaseInputText = new FlxUIInputText(25 + 650, 50 + 100, 160, '', 8);
		eventTimeInputText = new FlxUIInputText(25 + 650, 50, 160, '', 8);
		eventEaseInputText.callback = function(str:String, str2:String) {
			var data = getCurrentEventInData();
			if (data != null) {
				if (data[EVENT_TYPE] == 'ease')
					data[EVENT_DATA][EVENT_EASE] = eventEaseInputText.text;
			}
			dirtyUpdateEvents = true;
			hasUnsavedChanges = true;
		}
		eventTimeInputText.callback = function(str:String, str2:String) {
			var data = getCurrentEventInData();
			if (data != null) {
				if (data[EVENT_TYPE] == 'ease')
					data[EVENT_DATA][EVENT_EASETIME] = eventTimeInputText.text;
			}
			dirtyUpdateEvents = true;
			hasUnsavedChanges = true;
		}

		easeDropDown = new
			#if (PSYCH && PSYCHVERSION >= "0.7")
			FlxUIDropDownMenu
			#else
			FlxUIDropDownMenuCustom
			#end(25, eventEaseInputText.y + 30, #if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end
				.makeStrIdLabelArray(easeList, true), function(ease:String) {
					var easeStr = easeList[Std.parseInt(ease)];
					eventEaseInputText.text = easeStr;
					eventEaseInputText.callback("", ""); // make sure it updates
					hasUnsavedChanges = true;
			});
		centerXToObject(eventEaseInputText, easeDropDown);

		eventModifierDropDown = new
			#if (PSYCH && PSYCHVERSION >= "0.7")
			FlxUIDropDownMenu
			#else
			FlxUIDropDownMenuCustom
			#end(25, 50 + 20, #if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end.makeStrIdLabelArray(mods, true),
				function(mod:String) {
					var modName = mods[Std.parseInt(mod)];
					eventModInputText.text = modName;
					updateSubModList(modName);
					eventModInputText.callback("", ""); // make sure it updates
					hasUnsavedChanges = true;
				});
		centerXToObject(eventModInputText, eventModifierDropDown);

		subModDropDown = new
			#if (PSYCH && PSYCHVERSION >= "0.7")
			FlxUIDropDownMenu
			#else
			FlxUIDropDownMenuCustom
			#end(25, 50 + 80, #if (PSYCH && PSYCHVERSION >= "0.7") FlxUIDropDownMenu #end.makeStrIdLabelArray(subMods, true),
				function(mod:String) {
					var modName = subMods[Std.parseInt(mod)];
					var splitShit = eventModInputText.text.split(":"); // use to get the normal mod

					if (modName == "") {
						eventModInputText.text = splitShit[0]; // remove the sub mod
					} else {
						eventModInputText.text = splitShit[0] + ":" + modName;
					}

					eventModInputText.callback("", ""); // make sure it updates
					hasUnsavedChanges = true;
				});
		centerXToObject(eventModInputText, subModDropDown);

		eventDataInputText = new FlxUIInputText(25, 300, 300, '', 8);
		// eventDataInputText.resize(300, 300);
		eventDataInputText.callback = function(str:String, str2:String) {
			var data = getCurrentEventInData();
			if (data != null) {
				data[EVENT_DATA][EVENT_EASEDATA] = eventDataInputText.text;
				highlightedEvent = data;
				dirtyUpdateEvents = true;
				hasUnsavedChanges = true;
			}
		};

		var add:FlxButton = new FlxButton(0, selectedEventDataStepper.y + 30, 'Add', function() {
			var data = addNewModData();
			if (data != null) {
				highlightedEvent = data;
				updateSelectedEventDataStepper();
				eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
				eventModInputText.text = getEventModData(true);
				eventValueInputText.text = getEventModData(false);
				dirtyUpdateEvents = true;
				hasUnsavedChanges = true;
			}
		});
		var remove:FlxButton = new FlxButton(0, selectedEventDataStepper.y + 50, 'Remove', function() {
			var data = removeModData();
			if (data != null) {
				highlightedEvent = data;
				updateSelectedEventDataStepper();
				eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
				eventModInputText.text = getEventModData(true);
				eventValueInputText.text = getEventModData(false);
				dirtyUpdateEvents = true;
				hasUnsavedChanges = true;
			}
		});
		centerXToObject(selectedEventDataStepper, add);
		centerXToObject(selectedEventDataStepper, remove);
		tab_group.add(add);
		tab_group.add(remove);

		textBlockers.push(eventModInputText);
		textBlockers.push(eventDataInputText);
		textBlockers.push(eventValueInputText);
		textBlockers.push(eventEaseInputText);
		textBlockers.push(eventTimeInputText);
		scrollBlockers.push(eventModifierDropDown);
		scrollBlockers.push(eventTypeDropDown);
		scrollBlockers.push(subModDropDown);
		scrollBlockers.push(easeDropDown);

		addUI(tab_group, "addStacked", addStacked, 'Add New Stacked Event', 'Adds a new stacked event and duplicates the current one.');

		addUI(tab_group, "eventDataInputText", eventDataInputText, 'Raw Event Data', 'The raw data used in the event, you wont really need to use this.');
		addUI(tab_group, "stackedEventStepper", stackedEventStepper, 'Stacked Event Stepper', 'Allows you to find/switch to stacked events.');
		tab_group.add(makeLabel(stackedEventStepper, 0, -15, "Stacked Events Index"));

		addUI(tab_group, "eventValueInputText", eventValueInputText, 'Event Value', 'The value that the modifier will change to.');
		addUI(tab_group, "eventModInputText", eventModInputText, 'Event Modifier', 'The name of the modifier used in the event.');

		addUI(tab_group, "repeatBeatGapStepper", repeatBeatGapStepper, 'Repeat Beat Gap', 'The amount of beats in between each repeat.');
		addUI(tab_group, "repeatCheckbox", repeatCheckbox, 'Repeat', 'Check the box if you want the event to repeat.');
		addUI(tab_group, "repeatCountStepper", repeatCountStepper, 'Repeat Count', 'How many times the event will repeat.');
		tab_group.add(makeLabel(repeatBeatGapStepper, 0, -30, "How many beats in between\neach repeat?"));
		tab_group.add(makeLabel(repeatCountStepper, 0, -15, "How many times to repeat?"));

		addUI(tab_group, "eventEaseInputText", eventEaseInputText, 'Event Ease', 'The easing function used by the event (only for "ease" type).');
		addUI(tab_group, "eventTimeInputText", eventTimeInputText, 'Event Ease Time', 'How long the tween takes to finish in beats (only for "ease" type).');
		tab_group.add(makeLabel(eventEaseInputText, 0, -15, "Event Ease"));
		tab_group.add(makeLabel(eventTimeInputText, 0, -15, "Event Ease Time (in Beats)"));
		tab_group.add(makeLabel(eventTypeDropDown, 0, -15, "Event Type"));

		addUI(tab_group, "eventTimeStepper", eventTimeStepper, 'Event Time', 'The beat that the event occurs on.');
		addUI(tab_group, "selectedEventDataStepper", selectedEventDataStepper, 'Selected Event', 'Which modifier event is selected within the event.');
		tab_group.add(makeLabel(selectedEventDataStepper, 0, -15, "Selected Data Index"));
		tab_group.add(makeLabel(eventDataInputText, 0, -15, "Raw Event Data"));
		tab_group.add(makeLabel(eventValueInputText, 0, -15, "Event Value"));
		tab_group.add(makeLabel(eventModInputText, 0, -15, "Event Mod"));
		tab_group.add(makeLabel(subModDropDown, 0, -15, "Sub Mods"));

		addUI(tab_group, "subModDropDown", subModDropDown, 'Sub Mods', 'Drop down for sub mods on the currently selected modifier, not all mods have them.');
		addUI(tab_group, "eventModifierDropDown", eventModifierDropDown, 'Stored Modifiers', 'Drop down for stored modifiers.');
		addUI(tab_group, "eventTypeDropDown", eventTypeDropDown, 'Event Type',
			'Drop down to swtich the event type, currently there is only "set" and "ease", "set" makes the event happen instantly, and "ease" has a time and an ease function to smoothly change the modifiers.');
		addUI(tab_group, "easeDropDown", easeDropDown, 'Eases', 'Drop down that stores all the built-in easing functions.');
		UI_box.addGroup(tab_group);
	}

	function getCurrentEventInData() // find stored data to match with highlighted event
	{
		if (highlightedEvent == null)
			return null;
		for (i in 0...playfieldRenderer.modchart.data.events.length) {
			if (playfieldRenderer.modchart.data.events[i] == highlightedEvent) {
				return playfieldRenderer.modchart.data.events[i];
			}
		}

		return null;
	}

	function getMaxEventModDataLength() // used for the stepper so it doesnt go over max and break something
	{
		var data = getCurrentEventInData();
		if (data != null) {
			var dataStr:String = findCorrectModData(data);
			var dataSplit = dataStr.split(',');
			return Math.floor((dataSplit.length / 2) - 1);
		}
		return 0;
	}

	function updateSelectedEventDataStepper() // update the stepper
	{
		selectedEventDataStepper.max = getMaxEventModDataLength();
		if (selectedEventDataStepper.value > selectedEventDataStepper.max)
			selectedEventDataStepper.value = 0;
	}

	function updateStackedEventDataStepper() // update the stepper
	{
		stackedEventStepper.max = stackedHighlightedEvents.length - 1;
		stackedEventStepper.value = stackedEventStepper.max; // when you select an event, if theres stacked events it should be the one at the end of the list so just set it to the end
	}

	function getEventModIndex() {
		return Math.floor(selectedEventDataStepper.value);
	}

	var eventTypes:Array<String> = ["ease", "set"];

	function onSelectEvent(fromStackedEventStepper = false) {
		// update texts and stuff
		updateSelectedEventDataStepper();
		eventTimeStepper.value = Std.parseFloat(highlightedEvent[EVENT_DATA][EVENT_TIME]);
		eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];

		eventEaseInputText.alpha = 0.5;
		eventTimeInputText.alpha = 0.5;
		if (highlightedEvent[EVENT_TYPE] == 'ease') {
			eventEaseInputText.alpha = 1;
			eventTimeInputText.alpha = 1;
			eventEaseInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASE];
			eventTimeInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASETIME];
		}
		eventTypeDropDown.selectedLabel = highlightedEvent[EVENT_TYPE];
		eventModInputText.text = getEventModData(true);
		eventValueInputText.text = getEventModData(false);
		repeatBeatGapStepper.value = highlightedEvent[EVENT_REPEAT][EVENT_REPEATBEATGAP];
		repeatCountStepper.value = highlightedEvent[EVENT_REPEAT][EVENT_REPEATCOUNT];
		repeatCheckbox.checked = highlightedEvent[EVENT_REPEAT][EVENT_REPEATBOOL];
		if (!fromStackedEventStepper)
			stackedEventStepper.value = 0;
		dirtyUpdateEvents = true;
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			switch (wname) {
				case "selectedEventMod": // stupid steppers which dont have normal callbacks
					if (highlightedEvent != null) {
						eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
						eventModInputText.text = getEventModData(true);
						eventValueInputText.text = getEventModData(false);
					}
				case "repeatBeatGap":
					var data = getCurrentEventInData();
					if (data != null) {
						data[EVENT_REPEAT][EVENT_REPEATBEATGAP] = repeatBeatGapStepper.value;
						highlightedEvent = data;
						hasUnsavedChanges = true;
						dirtyUpdateEvents = true;
					}
				case "repeatCount":
					var data = getCurrentEventInData();
					if (data != null) {
						data[EVENT_REPEAT][EVENT_REPEATCOUNT] = repeatCountStepper.value;
						highlightedEvent = data;
						hasUnsavedChanges = true;
						dirtyUpdateEvents = true;
					}
				case "stackedEvent":
					if (highlightedEvent != null) {
						// trace(stackedHighlightedEvents);
						highlightedEvent = stackedHighlightedEvents[Std.int(stackedEventStepper.value)];
						onSelectEvent(true);
					}
			}
		}
	}

	var playfieldCountStepper:FlxUINumericStepper;

	function setupPlayfieldUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Playfields";

		playfieldCountStepper = new FlxUINumericStepper(25, 50, 1, 1, 1, 100, 0);
		playfieldCountStepper.value = playfieldRenderer.modchart.data.playfields;

		tab_group.add(playfieldCountStepper);
		tab_group.add(makeLabel(playfieldCountStepper, 0, -15, "Playfield Count"));
		tab_group.add(makeLabel(playfieldCountStepper, 55, 25, "Don't add too many or the game will lag!!!"));
		UI_box.addGroup(tab_group);
	}

	var sliderRate:FlxUISlider;

	function setupEditorUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Editor";

		sliderRate = new FlxUISlider(this, 'playbackSpeed', 20, 120, 0.5, 3, 250, null, 5, FlxColor.WHITE, FlxColor.BLACK);
		sliderRate.nameLabel.text = 'Playback Rate';
		sliderRate.callback = function(val:Float) {
			dirtyUpdateEvents = true;
		};

		var songSlider = new FlxUISlider(inst, 'time', 20, 200, 0, inst.length, 250, null, 5, FlxColor.WHITE, FlxColor.BLACK);
		songSlider.valueLabel.visible = false;
		songSlider.maxLabel.visible = false;
		songSlider.minLabel.visible = false;
		songSlider.nameLabel.text = 'Song Time';
		songSlider.callback = function(fuck:Float) {
			vocals.time = inst.time;
			#if (PSYCH && PSYCHVERSION >= "0.7.3")
			if (opponentVocals != null)
				opponentVocals.time = inst.time;
			#end
			Conductor.songPosition = inst.time;
			dirtyUpdateEvents = true;
			dirtyUpdateNotes = true;
		};

		var check_mute_inst = new FlxUICheckBox(10, 20, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function() {
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			inst.volume = vol;
		};
		var check_mute_vocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y, null, null, "Mute Main Vocals (in editor)", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function() {
			var vol:Float = 1;
			if (check_mute_vocals.checked)
				vol = 0;

			if (vocals != null)
				vocals.volume = vol;
		};
		#if (PSYCH && PSYCHVERSION >= "0.7.3")
		var check_mute_opponent_vocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y + 40, null, null, "Mute Opp. Vocals (in editor)", 100);
		check_mute_opponent_vocals.checked = false;
		check_mute_opponent_vocals.callback = function() {
			var vol:Float = 1;
			if (check_mute_opponent_vocals.checked)
				vol = 0;

			if (opponentVocals != null)
				opponentVocals.volume = vol;
		};
		#end

		var resetSpeed:FlxButton = new FlxButton(sliderRate.x + 300, sliderRate.y, 'Reset', function() {
			playbackSpeed = 1.0;
		});

		var saveJson:FlxUIButton = new FlxUIButton(20, 300, 'Save Modchart', function() {
			saveModchartJson(this);
		});
		addUI(tab_group, "saveJson", saveJson, 'Save Modchart', 'Saves the modchart to a .json file which can be stored and loaded later.');
		// tab_group.addAsset(saveJson, "saveJson");
		tab_group.add(sliderRate);
		addUI(tab_group, "resetSpeed", resetSpeed, 'Reset Speed', 'Resets playback speed to 1.');
		tab_group.add(songSlider);

		tab_group.add(check_mute_inst);
		tab_group.add(check_mute_vocals);
		#if (PSYCH && PSYCHVERSION >= "0.7.3") tab_group.add(check_mute_opponent_vocals); #end

		UI_box.addGroup(tab_group);
	}

	function addUI(tab_group:FlxUI, name:String, ui:FlxSprite, title:String = "", body:String = "", anchor:Anchor = null) {
		tooltips.add(ui, {
			title: title,
			body: body,
			anchor: anchor,
			style: {
				titleWidth: 150,
				bodyWidth: 150,
				bodyOffset: new FlxPoint(5, 5),
				leftPadding: 5,
				rightPadding: 5,
				topPadding: 5,
				bottomPadding: 5,
				borderSize: 1,
			}
		});

		tab_group.add(ui);
	}

	function centerXToObject(obj1:FlxSprite, obj2:FlxSprite) // snap second obj to first
	{
		obj2.x = obj1.x + (obj1.width / 2) - (obj2.width / 2);
	}

	function makeLabel(obj:FlxSprite, offsetX:Float, offsetY:Float, textStr:String) {
		var text = new FlxText(0, obj.y + offsetY, 0, textStr);
		centerXToObject(obj, text);
		text.x += offsetX;
		return text;
	}

	var _file:FileReference;

	public function saveModchartJson(?instance:ModchartMusicBeatState = null):Void {
		if (instance == null)
			instance = PlayState.instance;

		var data:String = Json.stringify(instance.playfieldRenderer.modchart.data, "\t");
		// data = data.replace("\n", "");
		// data = data.replace(" ", "");
		#if sys
		// sys.io.File.saveContent("modchart.json", data.trim());
		if ((data != null) && (data.length > 0)) {
			_file = new FileReference();
			_file.addEventListener(#if desktop openfl.events.Event.SELECT #else openfl.events.Event.COMPLETE #end, onSaveComplete);
			_file.addEventListener(openfl.events.Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "modchart.json");
		}
		#end

		hasUnsavedChanges = false;
	}

	function onSaveComplete(_):Void {
		_file.removeEventListener(#if desktop openfl.events.Event.SELECT #else openfl.events.Event.COMPLETE #end, onSaveComplete);
		_file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void {
		_file.removeEventListener(#if desktop openfl.events.Event.SELECT #else openfl.events.Event.COMPLETE #end, onSaveComplete);
		_file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void {
		_file.removeEventListener(#if desktop openfl.events.Event.SELECT #else openfl.events.Event.COMPLETE #end, onSaveComplete);
		_file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}
}
#end

class ModchartEditorExitSubstate extends MusicBeatSubstate {
	var exitFunc:Void->Void;

	override public function new(funcOnExit:Void->Void) {
		exitFunc = funcOnExit;
		super();
	}

	override public function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		var warning:FlxText = new FlxText(0, 0, 0, 'You have unsaved changes!\nAre you sure you want to exit?', 48);
		warning.alignment = CENTER;
		warning.screenCenter();
		warning.y -= 150;
		add(warning);

		var goBackButton:FlxUIButton = new FlxUIButton(0, 500, 'Go Back', function() {
			close();
		});
		goBackButton.scale.set(2.5, 2.5);
		goBackButton.updateHitbox();
		goBackButton.label.size = 12;
		goBackButton.autoCenterLabel();
		goBackButton.x = (FlxG.width * 0.3) - (goBackButton.width * 0.5);
		add(goBackButton);

		var exit:FlxUIButton = new FlxUIButton(0, 500, 'Exit without saving', function() {
			exitFunc();
		});
		exit.scale.set(2.5, 2.5);
		exit.updateHitbox();
		exit.label.size = 12;
		exit.label.fieldWidth = exit.width;
		exit.autoCenterLabel();

		exit.x = (FlxG.width * 0.7) - (exit.width * 0.5);
		add(exit);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
}
