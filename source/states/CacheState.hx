package states;
#if sys
import backend.Achievements;
import backend.WeekData;
import backend.Highscore;

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

using StringTools;

class CacheState extends MusicBeatState
{
	public static var bitmapData:Map<String, FlxGraphic>;
	var images:Array<String> = [];
	var music:Array<String> = [];
	var sounds:Array<String> = [];
	var modImages:Array<String> = [];
	var modMusic:Array<String> = [];
	var modSounds:Array<String> = [];

	var boolshit = true;
	var daMods:Array<String> = [];
	var pathList:Array<String> = 
	["", "characters", "dialogue", "pauseAlt", "pixelUI", "weeb", "characters", 
	"achievements", "credits", "icons", "loading", "mainmenu",
	"menubackgrounds", "menucharacters", "menudifficulties",
	"storymenu", "week2/images", "week3/images/philly",
	"week4/images/limo", "week4/images/gore", "week5/images/christmas",
	"week6/images/weeb", "week6/images/weeb/pixelUI", "week7/images",
	"week7/images/cutscenes", "week7/images/cutscenes/stressPico", "pixelUI/noteskins"]; //keep it here just in case
	
	var shitz:FlxText;
	var totalthing = [];
	var curThing:String;
	var menuBG:FlxSprite;
	var cacheStart:Bool = false;
	var startCachingModImages:Bool = false;
	var songsCached:Bool;
	var graphicsCached:Bool;
    var startCachingGraphics:Bool = false;
	var musicCached:Bool;
	var modImagesCached:Bool;
	var gameCached:Bool = false;
	var totalToDo:Int = 0;
	var modImI:Int = 0;
	var gfxI:Int = 0;
	public var percentLabel:FlxText;
	var filesDone = 0;
	var totalFiles = 0;

	var currentLoaded:Int = 0;
    var loadTotal:Int = 0;
	var loadingWhat:FlxText;
	var loadingBar:FlxBar;
	

	public static var newDest:FlxState;

	override function create()
	{
		trace('ngl pretty cool');

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB, ALT];

		FlxG.save.bind('Mixtape' #if (flixel < "5.0.0"), 'Z11Gaming' #end);
		ClientPrefs.loadPrefs();

		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		Highscore.load();

		if (FlxG.save.data.updated)
		{
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
				&& FlxG.save.data.songsPreload2 != null && ClientPrefs.data.songsPreload2 == false 
				&& FlxG.save.data.graphicsPreload2 != null && ClientPrefs.data.graphicsPreload2 == false) {
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					LoadingState.loadAndSwitchState(new TitleState());
				});
			}	

			menuBG = new FlxSprite().loadGraphic(Paths.image('loading/' + FlxG.random.int(0, 16, [3])));
			menuBG.screenCenter();
			add(menuBG);

			#if cpp
			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('characters/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push(i);
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/dialogue")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('dialogue/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/pauseAlt")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('pauseAlt/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/pixelUI")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('pixelUI/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/weeb")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('weeb/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/achievements")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('achievements/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/credits")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('credits/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/icons")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('icons/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/loading")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('loading/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/mainmenu")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('mainmenu/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/menubackgrounds")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('menubackgrounds/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/menucharacters")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('menucharacters/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/menudifficulties")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('menudifficulties/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/storymenu")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push('storymenu/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
			{
				if (!i.endsWith(".ogg"))
					continue;
				music.push(i);
				totalthing.push(i);
				trace(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/music")))
			{
				if (!i.endsWith(".ogg"))
					continue;
				music.push(i);
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/sounds")))
			{
				if (!i.endsWith(".ogg"))
					continue;
				music.push(i);
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/images")))
			{
				if (!i.endsWith(".png"))
					continue;
				modImages.push(i);
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
				modImages.push('characters/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/images/dialogue")))
			{
				if (!i.endsWith(".png"))
					continue;
				modImages.push('dialogue/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/images/icons")))
			{
				if (!i.endsWith(".png"))
					continue;
				modImages.push('icons/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/images/menubackgrounds")))
			{
				if (!i.endsWith(".png"))
					continue;
				modImages.push('menubackgrounds/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/images/menucharacters")))
			{
				if (!i.endsWith(".png"))
					continue;
				modImages.push('menucharacters/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/images/storymenu")))
			{
				if (!i.endsWith(".png"))
					continue;
				modImages.push('storymenu/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/music")))
			{
				if (!i.endsWith(".ogg"))
					continue;
				modMusic.push('music/$i');
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/sounds")))
			{
				if (!i.endsWith(".ogg"))
					continue;
				modMusic.push(i);
				totalthing.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/songs")))
			{
				if (!i.endsWith(".ogg"))
					continue;
				modMusic.push(i);
				totalthing.push(i);
			}
			
			for (ii in daMods)
			{
				if (FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images")) != null)
				{
					for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images")))
					{
						if (!i.endsWith(".png"))
							continue;
						modImages.push(i);
						totalthing.push(i);
					}
				}

				if (FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/characters")) != null)
				{
					for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/characters")))
					{
						if (!i.endsWith(".png"))
							continue;
						modImages.push('characters/$i');
						totalthing.push(i);
					}
				}

				if (FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/dialogue")) != null)
				{
					for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/dialogue")))
					{
						if (!i.endsWith(".png"))
							continue;
						modImages.push('dialogue/$i');
						totalthing.push(i);
					}
				}

				if (FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/icons")) != null)
				{
					for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/icons")))
					{
						if (!i.endsWith(".png"))
							continue;
						modImages.push('icons/$i');
						totalthing.push(i);
					}
				}

				if (FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/menubackgrounds")) != null)
				{
					for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/menubackgrounds")))
					{
						if (!i.endsWith(".png"))
							continue;
						modImages.push('menubackgrounds/$i');
						totalthing.push(i);
					}
				}

				if (FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/menucharacters")) != null)
				{
					for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/menucharacters")))
					{
						if (!i.endsWith(".png"))
							continue;
						modImages.push('menucharacters/$i');
						totalthing.push(i);
					}
				}

				if (FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/storymenu")) != null)
				{
					for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "images/storymenu")))
					{
						if (!i.endsWith(".png"))
							continue;
						modImages.push('storymenu/$i');
						totalthing.push(i);
					}
				}

				if (FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "music")) != null)
				{
					for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "music")))
					{
						if (!i.endsWith(".ogg"))
							continue;
						modMusic.push(i);
						totalthing.push(i);
					}
				}

				if (FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "sounds")) != null)
				{
					for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "sounds")))
					{
						if (!i.endsWith(".ogg"))
							continue;
						modMusic.push(i);
						totalthing.push(i);
					}
				}

				if (FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "songs")) != null)
				{
					for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/" + ii + "songs")))
					{
						if (!i.endsWith(".ogg"))
							continue;
						modMusic.push(i);
						totalthing.push(i);
					}
				}
			} //this took me waaay too long to just delete

			/*images = images.concat(Assets.list(IMAGE));
			sounds = sounds.concat(Assets.list(SOUND));
			music = music.concat(Assets.list(MUSIC));

			if (FileSystem.exists("modsList.txt"))
			{
				for (folder in Paths.getModDirectories())
				{
					if(!Paths.ignoreModFolders.contains(folder))
					{
						modImages = modImages.concat(Assets.list(IMAGE));
						modSounds = modSounds.concat(Assets.list(SOUND));
						modMusic = modMusic.concat(Assets.list(MUSIC));
					}
				}
			}
			for (i in images)
			{
				totalthing.push(i);
			}
			for (i in sounds)
			{
				totalthing.push(i);
			}
			for (i in music)
			{
				totalthing.push(i);
			}
			for (i in modImages)
			{
				totalthing.push(i);
			}
			for (i in modSounds)
			{
				totalthing.push(i);
			}
			for (i in modMusic)
			{
				totalthing.push(i);
			}*/

			
			#end

			/*sys.thread.Thread.create(() -> {
				cache();
			});*/ //this is probably important

			loadTotal = totalthing.length;

			if(loadTotal > 0){
				loadingBar = new FlxBar(0, 605, LEFT_TO_RIGHT, 600, 24, this, 'currentLoaded', 0, loadTotal);
				loadingBar.createGradientBar([0xFF333333, 0xFFFFFFFF], [0xFF7233D8, 0xFFD89033]);
				loadingBar.screenCenter(X);
				loadingBar.visible = false;
				add(loadingBar);
			}

			loadingWhat = new FlxText(FlxG.width/2 - 500, 0, 0, "", 24);
			loadingWhat.setFormat(Paths.font("FridayNightFunkin.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			loadingWhat.screenCenter(XY);
			add(loadingWhat);

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
				GPUBitmap.disposeAll();
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
            FlxG.switchState(newDest);  
        }

		if(gameCached && !(menuBG.alpha == 0)){
            FlxTween.tween(menuBG, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
			loadingWhat.text = "Done!";
			loadingWhat.screenCenter(XY);
			if(loadingBar != null){
				FlxTween.tween(loadingBar, {alpha: 0}, 0.3);
			}
            menuBG.updateHitbox();
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
				loadingWhat.text = 'Loading';
				loadingWhat.screenCenter(XY);
				if(CoolUtil.exists(Paths.file2(StringTools.replace(images[gfxI], '.png', ''), "images", "png"))){
					ImageCache.add(Paths.file2(StringTools.replace(images[gfxI], '.png', ''), "images", "png"));
				}
				else{
					trace("Image: File at " + Paths.file2(StringTools.replace(images[gfxI], '.png', ''), "images", "png") + " not found, skipping cache.");
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
						if (CoolUtil.exists(Paths.file2(StringTools.replace(modImages[modImI], '.png', ''), '$i/images/$ii', "png", "mods"))) 
							ImageCache.add(Paths.file2(StringTools.replace(modImages[modImI], '.png', ''), '$i/images/$ii', "png", "mods"));
					}
				}
				modImI++;
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

		#if !linux
		if(!songsCached){ 
            #if sys sys.thread.Thread.create(() -> { #end
                preloadMusic();
            #if sys }); #end
        }

        if(!graphicsCached){
            startCachingGraphics = true;
        }

		#end
	}

	function preloadMusic(){
        for(x in music){
			if(CoolUtil.exists(Paths.cacheInst(x))){
                FlxG.sound.cache(Paths.cacheInst(x));
            }
			else if(CoolUtil.exists(Paths.cacheVoices(x))){
                FlxG.sound.cache(Paths.cacheVoices(x));
            }
			else if(CoolUtil.exists(Paths.cacheSound(x))){
                FlxG.sound.cache(Paths.cacheSound(x));
            }
            else{
                FlxG.sound.cache(Paths.cacheMusic(x));
            }
			//loadingWhat.text = 'Loading: ' + x;
			currentLoaded++;
        }

		for(x in modMusic){
            if(CoolUtil.exists(Paths.cacheInst(x))){
                FlxG.sound.cache(Paths.cacheInst(x));
            }
			else if(CoolUtil.exists(Paths.cacheVoices(x))){
                FlxG.sound.cache(Paths.cacheVoices(x));
            }
			else if(CoolUtil.exists(Paths.cacheSound(x))){
                FlxG.sound.cache(Paths.cacheSound(x));
            }
            else{
                FlxG.sound.cache(Paths.cacheMusic(x));
            }
			//loadingWhat.text = 'Loading: ' + x;
			currentLoaded++;
        }
        loadingWhat.text = "Loading";
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