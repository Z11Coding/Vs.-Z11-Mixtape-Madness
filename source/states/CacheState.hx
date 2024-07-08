package states;
#if sys
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import lime.app.Application;
import flixel.ui.FlxBar;
import flixel.FlxState;
import openfl.system.System;
import flixel.FlxSubState;
import openfl.display.BitmapData;
import backend.GPUBitmap;
import backend.ImageCache;
import options.CacheSettings;
#if windows
import backend.Discord.DiscordClient;
#end
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end
import sys.io.Process;
import backend.JSONCache;

using StringTools;

class CacheState extends MusicBeatState
{
	public static var bitmapData:Map<String, FlxGraphic>;
	var images:Array<String> = [];
	var music:Array<String> = [];
	var modImages:Array<String> = [];
	var modMusic:Array<String> = [];

	var boolshit = true;
	var daMods:Array<String> = [];
	var pathList:Array<String> = 
	[
		"", "characters", "dialogue", "pauseAlt", "pixelUI", "weeb", 
		"achievements", "credits", "icons", "loading", "mainmenu", "menubackgrounds", 
		"menucharacters", "menudifficulties", "storymenu", "pixelUI/noteskins", "cursor", 
		"editors", "effects", "globalIcons", "HUD", "mechanics", "noteColorMenu", "noteskins", 
		"pause", "soundtray", "stages"
	]; //keep it here just in case
	
	var shitz:FlxText;
	var totalthing = [];
	var curThing:String;
	var menuBG:FlxSprite;
	var cacheStart:Bool = false;
	var startCachingModImages:Bool = false;
	var startCachingSoundsAndMusic:Bool = false;
	var songsCached:Bool;
	var graphicsCached:Bool;
    var startCachingGraphics:Bool = false;
	var musicCached:Bool;
	var modImagesCached:Bool;
	var gameCached:Bool = false;
	var totalToDo:Int = 0;
	var modImI:Int = 0;
	var gfxI:Int = 0;
	var sNmI:Int = 0;
	public var percentLabel:FlxText;
	var filesDone = 0;
	var totalFiles = 0;

	var currentLoaded:Int = 0;
    var loadTotal:Int = 0;
	var loadingWhat:FlxText;
	var loadingBar:FlxBar;
	var loadingBox:FlxSprite;
	var loadingWhatMini:FlxText;
	var loadingBoxMini:FlxSprite;
	

	public static var newDest:FlxState;

	override function create()
	{
		trace('ngl pretty cool');

		//Cursor.cursorMode = Cross;

		if (FlxG.save.data.updated)
		{
			#if sys
			var countFiles:String->Void = null;
			countFiles = function(path) {
				for (f in FileSystem.readDirectory(path)) {
					if (FileSystem.isDirectory('$path/$f')) {
						countFiles('$path/$f');
					} else {
						try {
							totalFiles++;
						} catch(e) {
						}
					}
				}
				}
				countFiles('./_cache');

			add(new FlxText(0, 0, FlxG.width, 'Updating Game!\nDo not close the game\nAnd it\'s normal that the game isn\'t responding. ').setFormat(Paths.font("fridaynightfunkin.ttf"), 30, FlxColor.WHITE, 'center'));
			var downloadBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.75), 30, this, "filesDone", 0, totalFiles);
			downloadBar.createGradientBar([0x88222222], [0xFFFFA600, 0xFF7700FF], 1, 90, true, 0xFF000000);
			downloadBar.screenCenter(X);
			downloadBar.y = FlxG.height - 45;
			downloadBar.scrollFactor.set(0, 0);
			add(downloadBar);
			
			percentLabel = new FlxText(downloadBar.x, downloadBar.y + (downloadBar.height / 2), downloadBar.width, "0%");
			percentLabel.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
			percentLabel.y -= percentLabel.height / 2;
			add(percentLabel);
			
			sys.thread.Thread.create(function()
			{
				var copyFolder:String->String->Void = null;
				copyFolder = function(path, destPath) {
				FileSystem.createDirectory(path);
				FileSystem.createDirectory(destPath);
				for (f in FileSystem.readDirectory(path)) {
					if (FileSystem.isDirectory('$path/$f')) {
						copyFolder('$path/$f', '$destPath/$f');
					} else {
						try {
							File.copy('$path/$f', '$destPath/$f');
							fileDone();
						} catch(e) {
						}
					}
				}
				}
				copyFolder('./_cache', '.');
				try {
					CoolUtil.deleteFolder('./_cache/');
					FileSystem.deleteDirectory('./_cache/');
				}
				catch (e) {
				}
				FlxG.save.data.updated = false;
				FlxG.save.flush();
				#if windows
				new Process('start /B MixEngine.exe', null);
				#else
				new Process('start /B MixEngine.app', null);
				#end
				System.exit(0);
			});
			#end
		}
		else
		{
			newDest = new What();
			//FlxG.sound.play(Paths.music('celebration'));
			for (folder in Mods.getModDirectories())
			{
				if(!Mods.ignoreModFolders.contains(folder))
				{
					daMods.push(folder);
				}
			}
			
			if(FlxG.save.data.musicPreload2 != null && ClientPrefs.data.musicPreload2 == false
				&& FlxG.save.data.graphicsPreload2 != null && ClientPrefs.data.graphicsPreload2 == false) {
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					LoadingState.loadAndSwitchState(new What());
				});
			}	

			menuBG = new FlxSprite().loadGraphic(Paths.image('loading/' + FlxG.random.int(0, 16, [3])));
			menuBG.screenCenter();
			add(menuBG);



			#if cpp
			if (ClientPrefs.data.graphicsPreload2)
			{
				Paths.crawlDirectory("assets", ".png", images);
				Paths.crawlDirectory("mods", ".png", modImages);
			}

			if (ClientPrefs.data.musicPreload2)
			{
				Paths.crawlDirectory("assets", ".ogg", music);
				Paths.crawlDirectory("mods", ".png", modMusic);
			}
			//this took me waaay too long to just delete
			//nvm I ended up deleting it anyway

			//JSONCache.addToCache(Paths.crawlDirectory("assets/shared", ".json"));
			//JSONCache.addToCache(Paths.crawlDirectory("mods", ".json"));

			var jsonCache = function() {
				var jsonCache:Array<String> = [];
				Paths.crawlDirectory("assets", ".json", jsonCache);
				Paths.crawlDirectory("mods", ".json", jsonCache);
				
				for (json in jsonCache)
				{
					JSONCache.addToCache(json);
				}
				return true;
			}

			jsonCache();

			trace(JSONCache.charts());


			#end


			loadTotal = images.length + modImages.length + music.length + modMusic.length;
			trace("Files: " + "Images: " + images + "Images(Mod): " + modImages + "Music: " + music + "Music(Mod): " + modMusic);
			trace(loadTotal + " files to load");
			
			if(loadTotal > 0){
				loadingBar = new FlxBar(0, 605, LEFT_TO_RIGHT, 600, 24, this, 'currentLoaded', 0, loadTotal);
				loadingBar.createGradientBar([0xFF333333, 0xFFFFFFFF], [0xFF7233D8, 0xFFD89033]);
				loadingBar.screenCenter(X);
				loadingBar.visible = false;
				add(loadingBar);
			}

			loadingWhat = new FlxText(FlxG.width/2 - 500, 0, 0, "Press ENTER to see cache options\nLoading will being soon", 24);
			loadingWhat.setFormat(Paths.font("DS-DIGIB.TTF"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			loadingWhat.screenCenter(XY);

			loadingWhatMini = new FlxText(loadingWhat.x, loadingWhat.y+285, 0, "Currently Loading: Music", 24);
			loadingWhatMini.setFormat(Paths.font("DS-DIGIB.TTF"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			loadingWhatMini.setGraphicSize(Std.int(loadingWhatMini.width) * 0.5);
			loadingWhatMini.screenCenter(X);

			loadingBox = new FlxSprite(FlxG.width/2 - 500, 0).makeGraphic(Std.int(loadingWhat.width), Std.int(loadingWhat.height), FlxColor.BLACK);
			loadingBox.screenCenter(XY);
			loadingBox.alpha = 0.5;

			add(loadingBox);
			add(loadingWhat);
			add(loadingWhatMini);

			if(!cacheStart){
				#if web
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					modImagesCached = true;
					graphicsCached = true;
					songsCached = true;
				});
				#else
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					cacheStart = true;
					cache();
				});
				#end
			}

			if(ClientPrefs.data.graphicsPreload2){
				GPUBitmap.disposeAll(); //cuz we moved to a pack without the undertale or origins and i didnt wanna complain about it cuz i know they were causing issues so i was being
				ImageCache.cache.clear();
			}
			else{
				modImagesCached = true;
				graphicsCached = true;
			}

			if(ClientPrefs.data.musicPreload2){
				Assets.cache.clear("music");
			}
			else{
				songsCached = true;
			}

			totalToDo = totalthing.length;

			FlxG.sound.playMusic(Paths.music('greetings'), 1, true);
		}

		super.create();
	}
	function fileDone() {
		filesDone++;
		percentLabel.text = '${Math.round(((filesDone / totalFiles * 100)*100)/100)}%';
		trace(totalFiles);
	}

	function openPreloadSettings(){
        #if desktop
        FlxG.sound.play(Paths.sound('cancelMenu'));
        FlxG.switchState(new CacheSettings());
        #end
    }

	var move:Bool = false;
	override function update(elapsed) 
	{
		loadingBox.width = Std.int(loadingWhat.width);
		loadingBox.height = Std.int(loadingWhat.height);
		if (currentLoaded == loadTotal) gameCached = true;

		if (!ClientPrefs.data.graphicsPreload2 && !ClientPrefs.data.musicPreload2) gameCached = true;

		if (loadingWhat.text == "Loading: null") 
		{
			gameCached = true; //I love null checking
		}

		if (!cacheStart && FlxG.keys.justPressed.ESCAPE)
		{
			System.gc();
			FlxG.switchState(newDest); 
		}

		if(menuBG.alpha == 0){
			System.gc();
			FlxG.sound.music.time = 0;
            FlxG.switchState(newDest);  
        }

		if(!gameCached)
		{
			loadingWhat.text = 'Loading...\n(${loadingBar.percent}% // $currentLoaded out of $loadTotal)';
			loadingWhat.screenCenter();
		}

		if(gameCached && menuBG.alpha == 1){
            FlxTween.tween(FlxG.camera, {zoom: 0}, 1, {ease: FlxEase.sineOut});
			FlxTween.tween(FlxG.camera, {angle: 360}, 1, {ease: FlxEase.sineOut});
			FlxTween.tween(menuBG, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			loadingWhat.text = "Done!";
			loadingWhat.screenCenter(XY);
			loadingWhatMini.text = "Done!";
			loadingWhatMini.screenCenter(X);
			if(loadingBar != null){
				FlxTween.tween(loadingBar, {alpha: 0}, 0.3);
			}
            menuBG.updateHitbox();
			FlxG.sound.music.fadeOut(1, 0);
        }

		if(!cacheStart){
            if(FlxG.keys.justPressed.ANY){
                openPreloadSettings();
            }
        }
	
        if(startCachingGraphics){
            if(gfxI >= images.length){
				trace("Graphics cached");
                startCachingGraphics = false;
				startCachingModImages = true;
                graphicsCached = true;
            }
            else{
				loadingWhatMini.text = images[gfxI];
				loadingWhatMini.screenCenter(X);
				loadingWhat.screenCenter(XY);
				if(CoolUtil.exists(images[gfxI])){
					ImageCache.add(images[gfxI]);
				}
				else{
					trace("Image: File at " + images[gfxI] + " not found, skipping cache.");
				}
                gfxI++;
				currentLoaded++;
            }
        }

		if(startCachingModImages){
            if(modImI >= modImages.length){
				trace("Mod Graphics cached");
                startCachingModImages = false;
                modImagesCached = true;
            }
            else{
				loadingWhat.text = 'Loading Mods';
				loadingWhat.screenCenter(XY);
				for (i in daMods)
				{
					for (ii in pathList)
					{
						loadingWhatMini.text = modImages[modImI];
						loadingWhatMini.screenCenter(X);
						if (CoolUtil.exists(Paths.file2(StringTools.replace(modImages[modImI], '.png', ''), '$i/images/$ii', "png", "mods"))) 
							ImageCache.add(Paths.file2(StringTools.replace(modImages[modImI], '.png', ''), '$i/images/$ii', "png", "mods"));
					}
				}
				modImI++;
				currentLoaded++;
            }
        }

		if(startCachingSoundsAndMusic){
            if(sNmI >= music.length){
				trace("Music and Sounds cached");
                startCachingSoundsAndMusic = false;
                startCachingGraphics = true;
            }
            else{
				loadingWhatMini.text = music[sNmI];
				loadingWhatMini.screenCenter(X);
				loadingWhat.screenCenter(XY);
				if(CoolUtil.exists(music[sNmI])){
					if(CoolUtil.exists(Paths.cacheInst(music[sNmI]))){
						FlxG.sound.cache(Paths.cacheInst(music[sNmI]));
					}
					if(CoolUtil.exists(Paths.cacheVoices(music[sNmI]))){
						FlxG.sound.cache(Paths.cacheVoices(music[sNmI]));
					}
					if(CoolUtil.exists(Paths.cacheSound(music[sNmI]))){
						FlxG.sound.cache(Paths.cacheSound(music[sNmI]));
					}
					if(CoolUtil.exists(Paths.cacheMusic(music[sNmI]))) {
						FlxG.sound.cache(Paths.cacheMusic(music[sNmI]));
					}
				}
				else{
					trace("Music/Sound: File at " + music[sNmI] + " not found, skipping cache.");
				}
                sNmI++;
				currentLoaded++;
            }
        }
		
		super.update(elapsed);
	}

	function cache()
	{
		if(loadingBar != null){
            loadingBar.visible = true;
        }

		#if sys
		startCachingSoundsAndMusic = true;
		#end
	}

	function preloadMusic(){
        for(x in music){
			if(CoolUtil.exists(Paths.cacheInst(x))){
                FlxG.sound.cache(Paths.cacheInst(x));
            }
			if(CoolUtil.exists(Paths.cacheVoices(x))){
                FlxG.sound.cache(Paths.cacheVoices(x));
            }
			if(CoolUtil.exists(Paths.cacheSound(x))){
                FlxG.sound.cache(Paths.cacheSound(x));
            }
            if(CoolUtil.exists(Paths.cacheMusic(x))) {
                FlxG.sound.cache(Paths.cacheMusic(x));
            }
			//loadingWhat.text = 'Loading: ' + x;
			currentLoaded++;
        }

		for(x in modMusic){
            if(CoolUtil.exists(Paths.cacheInst(x))){
                FlxG.sound.cache(Paths.cacheInst(x));
            }
			if(CoolUtil.exists(Paths.cacheVoices(x))){
                FlxG.sound.cache(Paths.cacheVoices(x));
            }
			if(CoolUtil.exists(Paths.cacheSound(x))){
                FlxG.sound.cache(Paths.cacheSound(x));
            }
            if(CoolUtil.exists(Paths.cacheMusic(x))) {
                FlxG.sound.cache(Paths.cacheMusic(x));
            }
			//loadingWhat.text = 'Loading: ' + x;
			currentLoaded++;
        }
		loadingWhat.screenCenter(XY);
        //FlxG.sound.play(Paths.sound("tick"), 1);
        songsCached = true;
    }
}
#else
import flixel.FlxG;
import flixel.FlxState;
using StringTools;
class CacheState extends MusicBeatState
{
	public static var newDest:FlxState;
	override function create()
	{
		Paths.clearStoredMemory();
		Main.dumpCache();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end

		ClientPrefs.loadPrefs();
		super.create();
		newDest = new What();
		trace('simply be better');
		FlxG.switchState(newDest);
	}
}
#end