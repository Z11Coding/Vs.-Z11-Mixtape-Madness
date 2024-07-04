package;

import flixel.graphics.FlxGraphic;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import states.CacheState;
import backend.AudioSwitchFix;
import backend.FunkinRatioScaleMode;
import backend.MemoryCounter;
import haxe.ui.Toolkit;
import backend.ImageCache;
import backend.JSONCache;

#if linux
import lime.graphics.Image;
#end

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

//Gamejolt
import gamejolt.GameJolt;
import gamejolt.GameJolt.GJToastManager;

class Main extends Sprite
{
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: CacheState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};
	public static var cmdArgs:Array<String> = Sys.args();

	//public var initStuff = game;

	public static var fpsVar:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	@:dox(hide)
	public static var audioDisconnected:Bool = false;
	public static var changeID:Int = 0;
	public static var scaleMode:FunkinRatioScaleMode;

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	public static function dumpObject(graphic:FlxGraphic)
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null)
			{
				if (obj == graphic)
				{
					Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					break;
				}
			}
		}
	}

	//Gamejolt
	public static var gjToastManager:GJToastManager;

	// taken from forever engine, cuz optimization very pog.
	// thank you shubs :)
	public static function dumpCache()
	{
		///* SPECIAL THANKS TO HAYA
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null)
			{
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}
		Assets.cache.clear("songs");
		// */
	}

	private function setupGame():Void
	{
		//initHaxeUI();
		Toolkit.init();
		//Toolkit.theme = 'dark'; // don't be cringe
		backend.Cursor.registerHaxeUICursors();

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
		
		MemoryUtil.init();

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		try{
			addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		}
		catch (e:haxe.Exception)
		{
			addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		}

		ClientPrefs.loadPrefs();
		AudioSwitchFix.init();
		FlxG.signals.preStateSwitch.add(onStateSwitch);
		FlxG.signals.postStateSwitch.add(onStateSwitchPost);
		FlxGraphic.defaultPersist = false;
		FlxG.signals.preStateSwitch.add(function()
		{

			//i tihnk i finally fixed it

			@:privateAccess
			for (key in FlxG.bitmap._cache.keys())
			{
				var obj = FlxG.bitmap._cache.get(key);
				if (obj != null)
				{
					lime.utils.Assets.cache.image.remove(key);
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					//obj.destroy(); //breaks the game lol
				}
			}

			//idk if this helps because it looks like just clearing it does the same thing
			for (k => f in lime.utils.Assets.cache.font)
				lime.utils.Assets.cache.font.remove(k);
			for (k => s in lime.utils.Assets.cache.audio)
				lime.utils.Assets.cache.audio.remove(k);

			/* 
			@:privateAccess
			{
				for (k => f in openfl.Assets.cache._font)
					openfl.Assets.cache._font.removeFont(k);
				for (k => s in openfl.Assets.cache._audio)
					openfl.Assets.cache.audio.removeSound(k);
			}
			*/

			


			//Paths.clearMemory();
			lime.utils.Assets.cache.clear();

			openfl.Assets.cache.clear();
	
			FlxG.bitmap.dumpCache();
	
			#if polymod
			polymod.Polymod.clearCache();
			
			#end

			#if cpp
			cpp.vm.Gc.enable(true);
			#end
	
			#if sys
			openfl.system.System.gc();	
			#end
		});

		FlxG.signals.postStateSwitch.add(function()
		{
			#if cpp
			cpp.vm.Gc.enable(true);
			#end
	
			#if sys
			openfl.system.System.gc();	
			#end
		});

		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		memoryCounter = new MemoryCounter(10, 3, 0xffffff);
		addChild(memoryCounter);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		if(memoryCounter != null) {
			memoryCounter.visible = ClientPrefs.data.showFPS;
		}
		#end

		FlxG.scaleMode = scaleMode = new FunkinRatioScaleMode();

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
			if (FlxG.cameras != null) {
			  for (cam in FlxG.cameras.list) {
			   if (cam != null && cam.filters != null)
				   resetSpriteCache(cam.flashSprite);
			  }
		   }

		   if (FlxG.game != null)
		   resetSpriteCache(FlxG.game);
	   });

		#if android
			FlxG.android.preventDefaultKeys = [flixel.input.android.FlxAndroidKey.BACK];
		#end

		gjToastManager = new GJToastManager();
		addChild(gjToastManager);
		backend.modules.EvacuateDebugPlugin.initialize();
		backend.modules.ForceCrashPlugin.initialize();
		backend.modules.MemoryGCPlugin.initialize();
	}

	function initHaxeUI():Void
	{
		// Calling this before any HaxeUI components get used is important:
		// - It initializes the theme styles.
		// - It scans the class path and registers any HaxeUI components.
		Toolkit.init();
		Toolkit.theme = 'gradient'; // don't be cringe
		// Toolkit.theme = 'light'; // embrace cringe
		Toolkit.autoScale = false;
		// Don't focus on UI elements when they first appear.
		haxe.ui.focus.FocusManager.instance.autoFocus = false;
		haxe.ui.tooltips.ToolTipManager.defaultDelay = 200;
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	private static function onStateSwitch() {
		scaleMode.resetSize();
	}

	private static function onStateSwitchPost() {
		// manual asset clearing since base openfl one doesnt clear lime one
		// doesnt clear bitmaps since flixel fork does it auto

		MemoryUtil.clearMajor();
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}
	public static var memoryCounter:MemoryCounter;

	public static function toggleMem(memEnabled:Bool):Void
	{
		memoryCounter.visible = memEnabled;
	}

	public static var fpsCounter:FPS;

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	public static function onCrash(e:UncaughtErrorEvent):Void {
	// Prevent further propagation of the error to avoid crashing the application
	e.preventDefault();
		var errMsg:String = "";
		var errType:String = e.error;
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		var crashState:String = Std.string(FlxG.state);

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "MixtapeEngine_" + dateNow + ".txt";

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/Z11Coding/Mixtape-Engine\n\n> Crash Handler written by: sqirra-rng\n> Crash prevented!";

		if (!FileSystem.exists("./crash/")) {
			FileSystem.createDirectory("./crash/");
		}

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		trace("Crash caused in: " + Type.getClassName(Type.getClass(FlxG.state)));
		// Handle different states
		switch (Type.getClassName(Type.getClass(FlxG.state)).split(".")[Lambda.count(Type.getClassName(Type.getClass(FlxG.state)).split(".")) - 1])
		{
			case "PlayState":
				PlayState.instance.Crashed = true;
				// Check if it's a Null Object Reference error
				if (errType.contains("Null Object Reference"))
				{
					if (PlayState.isStoryMode)
					{
						FlxG.switchState(new states.StoryMenuState());
					}
					else
					{
						FlxG.switchState(new states.FreeplayState());
					}
				}


			case "ChartingState":
				// Check if it's a "Chart doesn't exist" error
				if (e.error.toLowerCase().contains("null object reference"))
				{
					// Show an extra error dialog
					Application.current.window.alert("You tried to load a Chart that doesn't exist!", "Chart Error");
				}


			case "FreeplayState", "StoryModeState":
				// Switch back to MainMenuState
				FlxG.switchState(new states.MainMenuState());


			case "MainMenuState":
				// Go back to TitleState
				FlxG.switchState(new states.TitleState());


			case "TitleState":
				// Show an error dialog and close the game
				Application.current.window.alert("Something went extremely wrong... You may want to check some things in the files!\nFailed to load TitleState!", "Fatal Error");
							trace("Unable to recover...");
							//var assetWaitState:AssetWaitState = new AssetWaitState(MusicBeatState); // Provide the initial state
							Sys.exit(1);

			case "CacheState":
				Application.current.window.alert("Major Error occurred while caching data.\nSkipping Cache Operation.", "Fatal Error");
				FlxG.switchState(new states.What());

			case "OptionsState", "GameJoltState", "What":
				// Show an error dialog and restart the game
				if (Sys.args().indexOf("-livereload") != -1) {
					Sys.println("Cannot restart from compiled build.");
					Application.current.window.alert("The game encountered a critical error.", "Game Bricked");
					Application.current.window.alert("Unable to restart due to running a Compiled build.", "Error");

				} else {
					Application.current.window.alert("The game encountered a critical error and will now restart.", "Game Bricked");
					trace("The game was bricked. Restarting...");
					var mainInstance = new Main();
					var mainGame = mainInstance.game;
					var initialState = Type.getClass(mainGame.initialState);
					// var cachedData = new haxe.ds.StringMap<Dynamic>();
					// var cachedData = new haxe.ds.StringMap<Dynamic>();
					// cachedData.set("ImageCache", ImageCache.cache);
					// cachedData.set("JSONCache", JSONCache.cache);
					// var cache = Json.stringify(cachedData);
					
					var restartProcess = new Process("MixEngine.exe", ["GameJoltBug", "restart"]);
					// FlxG.switchState(restartProcess);
					Sys.exit(1);
				}
				trace("Recommended to recompile the game to fix the issue.");

			default:
				// For other states, reset to MainMenuState
				var mainInstance = new Main();
				var mainGame = mainInstance.game;
				FlxG.switchState(Type.createInstance(mainGame.initialState, []));
				trace("Unhandled state: " + (Type.getClassName(Type.getClass(FlxG.state))));
				trace("Restarting Game...");
		}
	


	    // Additional error handling or recovery mechanisms can be added here


	}
	#end
}