package objects;

import states.editors.ChartingState;

import backend.animation.PsychAnimationController;

import shaders.ColorSwap;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

import states.PlayState.Wife3;
import haxe.io.Path;
import flixel.math.FlxPoint;
import math.Vector3;
import openfl.utils.Assets;
import scripts.*;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends NoteObject
{
	public var vec3Cache:Vector3 = new Vector3(); // for vector3 operations in modchart code

	override function destroy()
	{
		defScale.put();
		super.destroy();
	}
	public var mAngle:Float = 0;
	public var bAngle:Float = 0;

	public static var gfxLetter:Array<String> = [
		'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
		'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R'
	];

	//EK Data
	public static var ammo:Array<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
	public static var scales:Array<Float> = [0.9, 0.85, 0.8, 0.7, 0.66, 0.6, 0.55, 0.50, 0.46, 0.39, 0.36, 0.32, 0.31, 0.31, 0.3, 0.26, 0.26, 0.22]; 
	public static var lessX:Array<Int> = [0, 0, 0, 0, 0, 8, 7, 8, 8, 7, 6, 6, 8, 7, 6, 7, 6, 6];
	public static var separator:Array<Int> = [0, 0, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5, 6, 6, 7, 6, 5];
	public static var xtra:Array<Int> = [150, 89, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
	public static var posRest:Array<Int> = [0, 0, 0, 0, 25, 32,46, 52, 60, 40, 45, 30, 30, 29,72, 37, 61, 16];
	public static var gridSizes:Array<Int> = [40, 40, 40, 40, 40, 40, 40, 40, 40, 35, 30, 25, 25, 20, 20, 20, 20, 15];
	public static var xPosButBetter:Array<Float> = [2, 2, 2, 2, 1.5, 1.1, 1.1, 1, 1, 2, 2, 2, 2, 1.2, 2, 2, 2, 2];
	public static var xPosButBetter2:Array<Float> = [1, 1, 1, 1, 1.1, 1.2, 1.3, 1.5, 1.7, 1, 1, 1, 1, 2.9, 1, 1, 1, 1];
	public static var xPosButBetterOff:Array<Float> = [100, 100, 100, 100, 130, 250, 300, 300, 300, 100, 100, 100, 100, 250, 100, 100, 100, 100];
	public static var offsets:Array<Dynamic> = [[20, 10], [10, 10], [10, 10], [10, 10], [10, 10], [10, 10], [10, 10], [10, 10], [10, 10], [10, 20], [10, 10], [10, 10], [10, 10], [10, 10], [10, 10],[10, 10],[10, 10], [20, 20]];
	public static var noteSplashScales:Array<Float> = [1.3, 1.2, 1.1, 1, 1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.3, 0.3, 0.2, 0.18, 0.18, 0.15];
	public static var noteSplashOffsets:Map<Int, Array<Int>> = [0 => [20, 10], 9 => [10, 20]];

	public static var minMania:Int = 0;
	public static var maxMania:Int = 17;
	public static var defaultMania:Int = 3;
	public var downscrollNote:Bool = ClientPrefs.data.downScroll;
	public var baseAlpha:Float = 1;
	public var autoGenerated:Bool = false;
	public static var pixelNotesDivisionValue:Int = 18;

	public static var minManiaUI_integer:Int = minMania + 1;
	public static var maxManiaUI_integer:Int = maxMania + 1;

	public static var xmlMax:Int = 17; // This specifies the max of the splashes can go

	public static var keysShit:Map<Int, Map<String, Dynamic>> = [
		0 => [
			"letters" => ["E"], 
			"anims" => ["UP"], 
			"strumAnims" => ["SPACE"], 
			"pixelAnimIndex" => [4]
		],
		1 => [
				"letters" => ["A", "D"], 
				"anims" => ["LEFT", "RIGHT"], 
				"strumAnims" => ["LEFT", "RIGHT"], 
				"pixelAnimIndex" => [0, 3]
			],
		2 => [
				"letters" => ["A", "E", "D"], 
				"anims" => ["LEFT", "UP", "RIGHT"], 
				"strumAnims" => ["LEFT", "SPACE", "RIGHT"], 
				"pixelAnimIndex" => [0, 4, 3]
			],
		3 => [
				"letters" => ["A", "B", "C", "D"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT"], 
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3]
			],

		4 => [
				"letters" => ["A", "B", "E", "C", "D"], 
				"anims" => ["LEFT", "DOWN", "UP", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "SPACE", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 4, 2, 3]
			],
		5 => [
				"letters" => ["A", "C", "D", "F", "B", "I"], 
				"anims" => ["LEFT", "UP", "RIGHT", "LEFT", "DOWN", "RIGHT"],
				"strumAnims" => ["LEFT", "UP", "RIGHT", "LEFT", "DOWN", "RIGHT"], 
				"pixelAnimIndex" => [0, 2, 3, 5, 1, 8]
			],
		6 => [
				"letters" => ["A", "C", "D", "E", "F", "B", "I"], 
				"anims" => ["LEFT", "UP", "RIGHT", "UP", "LEFT", "DOWN", "RIGHT"],
				"strumAnims" => ["LEFT", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "RIGHT"], 
				"pixelAnimIndex" => [0, 2, 3, 4, 5, 1, 8]
			],
		7 => [
				"letters" => ["A", "B", "C", "D", "F", "G", "H", "I"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 5, 6, 7, 8]
			],
		8 => [
				"letters" => ["A", "B", "C", "D", "E", "F", "G", "H", "I"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "UP", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 4, 5, 6, 7, 8]
			],
		9 => [
				"letters" => ["A", "B", "C", "D", "E", "N", "F", "G", "H", "I"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "UP", "UP", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "SPACE", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 4, 13, 5, 6, 7, 8]
			],
		10 => [
				"letters" => ["A", "B", "C", "D", "J", "E", "M", "F", "G", "H", "I"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "CIRCLE", "SPACE", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 9, 4, 12, 5, 6, 7, 8]
			],
		11 => [
				"letters" => ["A", "B", "C", "D", "J", "K", "L", "M", "F", "G", "H", "I"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 9, 10, 11, 12, 5, 6, 7, 8]
			],
		12 => [
				"letters" => ["A", "B", "C", "D", "J", "K", "N", "L", "M", "F", "G", "H", "I"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 9, 10, 13, 11, 12, 5, 6, 7, 8]
			],
		13 => [
				"letters" => ["A", "B", "C", "D", "J", "K", "E", "N", "L", "M", "F", "G", "H", "I"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "UP", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "CIRCLE", "CIRCLE", "SPACE", "CIRCLE", "CIRCLE", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 9, 10, 4, 13, 11, 12, 5, 6, 7, 8]
			],
		14 => [
				"letters" => ["A", "B", "C", "D", "J", "K", "E", "N", "E", "L", "M", "F", "G", "H", "I"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "UP", "UP", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "CIRCLE", "CIRCLE", "SPACE", "CIRCLE", "SPACE", "CIRCLE", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 9, 10, 4, 13, 4, 11, 12, 5, 6, 7, 8]
			],
		15 => [
				"letters" => ["A", "B", "C", "D", "J", "K", "L", "M", "O", "P", "Q", "R", "F", "G", "H", "I"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 9, 10, 11, 12, 14, 15, 16, 17, 5, 6, 7, 8]
			],
		16 => [
				"letters" => ["A", "B", "C", "D", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "F", "G", "H", "I"], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 9, 10, 11, 12, 13, 14, 15, 16, 17, 5, 6, 7, 8]
		],
		17 => [
				"letters" => ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
				'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R'], 
				"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "UP", "LEFT", "DOWN", "UP", "RIGHT",
				"LEFT", "DOWN", "UP", "RIGHT", "UP", "LEFT", "DOWN", "UP", "RIGHT"],
				"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "UP", "RIGHT", 
				"LEFT", "DOWN", "UP", "RIGHT", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
				"pixelAnimIndex" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
		],
	];

	public static var pixelScales:Array<Float> = [
        1.2, //1k
        1.15, //2k
        1.1, //3k
        1, //4k
        0.9, //5k
        0.83, //6k
        0.8, //7k
        0.74, //8k
        0.7, //9k
        0.6, //10k
        0.55,//11k
        0.5, //12k
        0.48, //13k
        0.48, //14k
        0.42, //15k
        0.38, //16k
        0.38, //17k
        0.32 //18k
    ];

	// End of extra keys stuff
	//////////////////////////////////////////////////

	public var extraData:Map<String,Dynamic> = [];

	public var noteDiff:Float = 1000;
	
	// basic stuff
	public var beat:Float = 0;
	public var strumTime(default, set):Float = 0;
    function set_strumTime(val:Float){
        return strumTime=val;
    }
	public var visualTime:Float = 0;
	public var mustPress:Bool = false;
	@:isVar
	public var canBeHit(get, null):Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var missed:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;
	public var spawned:Bool = false;
	function get_canBeHit()return true;
	
	
	//note type/customizable shit
	
	public var noteType(default, set):String = null;  //the note type
	public var causedMiss:Bool = false;
/* 	public var hitbox:Float = Conductor.safeZoneOffset * Wife3.timeScale; // how far you can hit the note in ms
	public var earlyHitMult:Float = 1; // multiplier to hitbox to hit this note early
	public var lateHitMult:Float = 1; // multiplier to hitbox to hit this note late */
	// ^^ this is now determined by the judgements

	public var usesDefaultColours:Bool = true; // whether this note uses the default note colours (lets you change colours in options menu)

	public var blockHit:Bool = false; // whether you can hit this note or not
	public var lowPriority:Bool = false; // shadowmario's shitty workaround for really bad mine placement, yet still no *real* hitbox customization lol!
	public var noteSplashDisabled:Bool = false; // disables the notesplash when you hit this note
	public var noteSplashTexture:String = null; // spritesheet for the notesplash
	public var noteSplashHue:Float = 0; // hueshift for the notesplash, can be changed in note-type but otherwise its whatever the user sets in options
	public var noteSplashSat:Float = 0; // ditto, but for saturation
	public var noteSplashBrt:Float = 0; // ditto, but for brightness
	//public var ratingDisabled:Bool = false; // disables judging this note
	public var missHealth:Float = 0.0475; // health when you miss this note
	public var texture(default, set):String = null; // texture for the note
	public var noAnimation:Bool = false; // disables the animation for hitting this note
	public var noMissAnimation:Bool = false; // disables the animation for missing this note
	public var hitCausesMiss:Bool = false; // hitting this causes a miss
	public var breaksCombo:Bool = false; // hitting this will cause a combo break
	public var hitsoundDisabled:Bool = false; // hitting this does not cause a hitsound when user turns on hitsounds
	public var gfNote:Bool = false; // gf sings this note (pushes gf into characters array when the note is hit)
	public var characters:Array<Character> = []; // which characters sing this note, leave blank for the playfield's characters
	public var fieldIndex:Int = -1; // Used to denote which PlayField to be placed into
	// Leave -1 if it should be automatically determined based on mustPress and placed into either bf or dad's based on that.
	// Note that holds automatically have this set to their parent's fieldIndex
	public var field:PlayField; // same as fieldIndex but lets you set the field directly incase you wanna do that i  guess

	// custom health values
	public var ratingHealth:Map<String, Float> = [];

	// hold/roll shit
	public var sustainMult:Float = 1;
	public var tail:Array<Note> = []; 
	public var unhitTail:Array<Note> = [];
	public var parent:Note;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var holdingTime:Float = 0;
	public var tripTimer:Float = 0;

	// event shit (prob can be removed??????)
	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	// etc

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;
	public var desiredZIndex:Float = 0;
	
	// do not tuch
	public var baseScaleX:Float = 1;
	public var baseScaleY:Float = 1;
	public var zIndex:Float = 0;
	public var z:Float = 0;
	public var realColumn:Int;
	@:isVar
	public var realNoteData(get, set):Int; // backwards compat
    inline function get_realNoteData()
        return realColumn;
    inline function set_realNoteData(v:Int)
        return realColumn = v;

	public static var swagWidth:Float = 160 * 0.7;
	public static var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	public static var colArrayAlt:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'dark'];


	// mod manager
	public var garbage:Bool = false; // if this is true, the note will be removed in the next update cycle
	public var alphaMod:Float = 1;
	public var alphaMod2:Float = 1; // TODO: unhardcode this shit lmao
	public var typeOffsetX:Float = 0; // used to offset notes, mainly for note types. use in place of offset.x and offset.y when offsetting notetypes
	public var typeOffsetY:Float = 0;
	public var typeOffsetAngle:Float = 0;
	public var multSpeed(default, set):Float = 1;

	public var multAlpha:Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick

	public var distance:Float = 2000; //plan on doing scroll directions soon -bb

	//Mixtape Stuff
	public var parentNote:Note; 
	public var childrenNotes:Array<Note> = [];
	public var mania:Int = 3;
	public var animSuffix:String = '';
	var ogW:Float;
	var ogH:Float;
	public static var defaultWidth:Float = 0;
	public static var defaultHeight:Float = 0;
	public var earlyHitMult:Float = 0.5;
	public var exNote:Bool = false;
	public var ghostNote:Bool = false;
	public var changeAnim:Bool = true;
	public var changeColSwap:Bool = true;
	public var isParent:Bool; // ke input shits
	public var spotInLine:Int = 0;
	public var ratingDisabled:Bool = false;
	public var hitHealth:Float = 0.023;
	public var susActive:Bool = true;
	public var scrollSpeed(default, set):Float = 0;
	public var customHealthHit:Bool = false;
	public var centerNote:Bool = false;
	public var hitboxMultiplier:Float = 1;

	//Action Engine Stuff
	public var noteIndex:Int = -1;

	//Psych Engine Stuff
	public var rgbShader:RGBShaderReference;
	public static var globalRgbShaders:Array<RGBPalette> = [];
	public static var SUSTAIN_SIZE:Int = 44;

	//AI Stuff
	public var AIStrumTime:Float = 0;
	public var AIMiss:Bool = false;


	public static var defaultNotes = [
		'No Animation',
		'GF Sing',
		'',
		'Hurt Note',
		'Ghost Note',
		'EX Note',
		'GF Duet'
	];

	public var isSustainEnd:Bool = false;

	private function set_multSpeed(value:Float):Float {
		return multSpeed = value;
	}

	public function resizeByRatio(ratio:Float) //haha funny twitter shit
	{
/* 		if(isSustainNote && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= ratio;
			baseScaleY = scale.y;
			updateHitbox();
		} */
	}

	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	public function updateColours(ignore:Bool=false){		
		if(!ignore && !usesDefaultColours)return;
		if (colorSwap==null)return;
		if (noteData > -1 && noteData < ClientPrefs.data.arrowHSV.length && Note.ammo[PlayState.mania] > 3)
		{
			colorSwap.hue = ClientPrefs.data.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][0] / 360;
			colorSwap.saturation = ClientPrefs.data.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][1] / 100;
			colorSwap.brightness = ClientPrefs.data.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][2] / 100;
		}
	}

	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;

		updateColours();

		// just to make sure they arent 0, 0, 0
		colorSwap.hue += 0.0127;
		colorSwap.saturation += 0.0127;
		colorSwap.brightness += 0.0127;
		var hue = colorSwap.hue;
		var sat = colorSwap.saturation;
		var brt = colorSwap.brightness;

		
		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					usesDefaultColours = false;
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;

				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'GF Sing':
					gfNote = true;
				case 'Ghost Note':
					ghostNote = true;
				case 'EX Note':
					exNote = true;
				case 'Center Note':
					reloadNote('CENTER');
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0; 
					hitCausesMiss = false;
					centerNote = true;
						
			}
			noteType = value;
		}
		if(usesDefaultColours){
			if(colorSwap.hue != hue || colorSwap.saturation != sat || colorSwap.brightness != brt){
				usesDefaultColours = false;// just incase
			}
		}

		if(colorSwap.hue==hue)
			colorSwap.hue -= 0.0127;

		if(colorSwap.saturation==sat)
			colorSwap.saturation -= 0.0127;

		if(colorSwap.brightness==brt)
			colorSwap.brightness -= 0.0127;

		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		animation = new PsychAnimationController(this);

		mania = PlayState.mania;

		if (prevNote == null)
			prevNote = this;
		
		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		this.moves = false;

		beat = Conductor.getBeat(strumTime);

		x += (ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.data.noteOffset;
		if(!inEditor) visualTime = PlayState.instance.getNoteInitialTime(this.strumTime);

		if (isSustainNote && prevNote != null) {
			parentNote = prevNote;
			while (parentNote.parentNote != null)
				parentNote = parentNote.parentNote;
			parentNote.childrenNotes.push(this);
		} else if (!isSustainNote)
			parentNote = null;

		antialiasing = ClientPrefs.data.globalAntialiasing;
		
		this.noteData = noteData;

		if(noteData > -1) {
			texture = '';
			colorSwap = new ColorSwap();
			if (mania == 3) 
			{
				rgbShader = new RGBShaderReference(this, initializeGlobalRGBShader(noteData));
				rgbShader.enabled = false;
			
			}
			if(PlayState.SONG != null && PlayState.SONG.disableNoteRGB && mania == 3) 
			{
				rgbShader.enabled = false;
				shader = colorSwap.shader;
			}

			x += swagWidth * (noteData % Note.ammo[mania]);
			if(!isSustainNote && noteData > -1 && noteData < Note.maxManiaUI_integer) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				animToPlay = Note.keysShit.get(mania).get('letters')[noteData];
				animation.play(animToPlay);
			}
		}

		// trace(prevNote);

		if(prevNote!=null)
			prevNote.nextNote = this;

		if (isSustainNote && prevNote != null)
		{
			sustainMult = 0.5; // early hit mult but just so note-types can set their own and not have sustains fuck them
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			//if(ClientPrefs.downScroll) flipY = true;

			//offsetX += width* 0.5;
			copyAngle = false;

			animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' tail');

			updateHitbox();

			//offsetX -= width* 0.5;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[prevNote.noteData] + ' hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;

				if (PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if(PlayState.isPixelStage) { ///Y E  A H
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
				prevNote.defScale.copyFrom(prevNote.scale);
				// prevNote.setGraphicSize();
			}

			if (PlayState.isPixelStage)
			{
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		}
		else if (!isSustainNote)
		{
			earlyHitMult = 1;
		}
		defScale.copyFrom(scale);
		//x += offsetX;
	}

	public static function initializeGlobalRGBShader(noteData:Int)
	{
		if(globalRgbShaders[noteData] == null)
		{
			var newRGB:RGBPalette = new RGBPalette();
			globalRgbShaders[noteData] = newRGB;

			var arr:Array<FlxColor> = (!PlayState.isPixelStage) ? ClientPrefs.data.arrowRGB[noteData] : ClientPrefs.data.arrowRGBPixel[noteData];
			if (noteData > -1 && noteData <= arr.length) 
			{
				newRGB.r = arr[0];
				newRGB.g = arr[1];
				newRGB.b = arr[2];
			}
		}
		return globalRgbShaders[noteData];
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;
	public var originalHeightForCalcs:Float = 6;
	public var correctionOffset:Float = 0; //dont mess with this
	public function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';

		var animName:String = animation.curAnim != null ? animation.curAnim.name : null;
		var lastScaleY:Float = scale.y;

		var skin:String = texture;
		if(texture.length < 1){
			skin = PlayState.SONG.arrowSkin;
			if(skin == null || skin.length < 1)
				skin = 'NOTE';
			if (!Paths.doesImageAssetExist(Paths.modsImages('noteskins/'+PlayState.SONG.arrowSkin)) || !Paths.doesImageAssetExist(Paths.getPath('images/noteskins/'+PlayState.SONG.arrowSkin+'.png')))
				skin = 'NOTE';
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix; // add prefix and suffix to the texture file
		var blahblah:String = arraySkin.join('/');

		defaultWidth = 157;
		defaultHeight = 154;
		
		if (PlayState.isPixelStage)
		{
			if (isSustainNote)
			{
				loadGraphic(Paths.image('pixelUI/noteskins/' + blahblah + 'ENDS'));
				width = width / 18;
				height = height / 2;
				loadGraphic(Paths.image('pixelUI/noteskins/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			}
			else
			{
				loadGraphic(Paths.image('pixelUI/noteskins/' + blahblah));
				width = width / 18;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/noteskins/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			defaultWidth = width;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelScales[mania]));
			loadPixelNoteAnims();
			antialiasing = false;
		}
		else
		{
			frames = Paths.getSparrowAtlas('noteskins/'+blahblah);
			loadNoteAnims();
			antialiasing = ClientPrefs.data.globalAntialiasing;
		}
		
		if(isSustainNote) {
			scale.y = lastScaleY;
			if (ClientPrefs.data.inputSystem == 'Kade Engine')
			{
				scale.y *= 0.75;
			}
		}
		defScale.copyFrom(scale);
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);

		if(inEditor){
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	private var originalScale:Float = 1;

	private function set_scrollSpeed(value:Float):Float
	{
		scrollSpeed = value;
		/*

		if (isSustainNote && (animation.curAnim != null && !animation.curAnim.name.endsWith('end')))
		{
			scale.y = originalScale;
			updateHitbox();

			scale.y *= Conductor.stepCrochet / 100 * 1.05;
			if (PlayState.instance != null)
			{
				scale.y *= scrollSpeed;
			}

			if (PlayState.isPixelStage)
			{
				scale.y *= 1.19;
				scale.y *= (6 / height); // Auto adjust note size
			}
			updateHitbox();

			if (PlayState.isPixelStage)
			{
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
			updateHitbox();
			// prevNote.setGraphicSize();
		}*/

		return value;
	}

	public function loadNoteAnims() {
		_loadNoteAnims();
	}

	function _loadNoteAnims() {
		for (i in 0...gfxLetter.length)
		{
			animation.addByPrefix(gfxLetter[i], gfxLetter[i] + '0');

			if (isSustainNote)
			{
				animation.addByPrefix(gfxLetter[i] + ' hold', gfxLetter[i] + ' hold');
				animation.addByPrefix(gfxLetter[i] + ' tail', gfxLetter[i] + ' tail');
			}
		}

		ogW = width;
		ogH = height;
		if (!isSustainNote)
			setGraphicSize(Std.int(defaultWidth * scales[mania]));
		else
			setGraphicSize(Std.int(defaultWidth * scales[mania]), Std.int(defaultHeight * scales[0]));
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		if(isSustainNote) {
			for (i in 0...gfxLetter.length) {
				animation.add(gfxLetter[i] + ' hold', [i]);
				animation.add(gfxLetter[i] + ' tail', [i + pixelNotesDivisionValue]);
			}
		} else {
			for (i in 0...gfxLetter.length) {
				animation.add(gfxLetter[i], [i + pixelNotesDivisionValue]);
			}
		}
	}

	public function applyManiaChange()
	{
		if (isSustainNote)
			scale.y = 1;
		reloadNote(texture);
		if (isSustainNote)
			offsetX = width / 2;
		if (!isSustainNote)
		{
			var animToPlay:String = '';
			animToPlay = Note.keysShit.get(mania).get('letters')[noteData];
			animation.play(animToPlay);
		}

		if (isSustainNote && prevNote != null)
		{
			animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' tail');
			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' hold');
				prevNote.updateHitbox();
			}
		}

		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		mania = PlayState.mania;

		colorSwap.daAlpha = alphaMod * alphaMod2;

		if (hitByOpponent)
				wasGoodHit = true;
			var diff = (strumTime - Conductor.songPosition);
			if (diff < -Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;

		if (isSustainNote && !susActive)
			multAlpha = 0.2;

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}