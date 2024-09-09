package backend;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import openfl.geom.Rectangle;

import lime.utils.Assets;
import flash.media.Sound;

import haxe.Json;
import haxe.Http;


#if MODS_ALLOWED
import backend.Mods;
#end

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = ['assets/shared/music/freakyMenu.$SOUND_EXT'];
	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null) {
					// remove the key from all cache maps
					FlxG.bitmap._cache.remove(key);
					openfl.Assets.cache.removeBitmapData(key);
					currentTrackedAssets.remove(key);

					// and get rid of the object
					obj.persist = false; // make sure the garbage collector actually clears it up
					obj.destroyOnNoUse = true;
					obj.destroy();
				}
			}
		}

		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];
	public static function clearStoredMemory() {
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key => asset in currentTrackedSounds)
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		#if !html5 openfl.Assets.cache.clear("songs"); #end
	}

	static public var currentLevel:String;
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function crawlDirectoryOG(directoryPath:String, fileExtension:String, ?targetArray:Array<String>):Array<String> {
		var result:Array<String> = targetArray != null ? targetArray : [];
		var recurrsion = 0;
		var fileCount = 0;
		for (folder in FileSystem.readDirectory(FileSystem.absolutePath(directoryPath))) {
			if (FileSystem.isDirectory('$directoryPath/$folder')) {
				recurrsion++;
				var subDirectoryResult = crawlDirectoryOG('$directoryPath/$folder', fileExtension, result);
				if (targetArray == null) {
					result = result.concat(subDirectoryResult);
				}
			} else {
				if (folder.endsWith(fileExtension)) {
					fileCount++;
					result.push(directoryPath+'/'+folder);                    
				}
			}
		}
		//trace('Crawled directory: ${directoryPath}, and found ${fileCount} files with extension ${fileExtension}. Total files found: ${result.length}');
		//trace('Files found: ${result}');
		//trace('Recursion: $recurrsion');
		return result;
	}

	public static function crawlDirectory(directoryPath:String, fileExtension:String, ?targetArray:Array<String> = null):Array<String> {
		var result:Array<String> = targetArray != null ? targetArray : [];
		var recursion = 0;
		var fileCount = 0;
		try {
			for (folder in FileSystem.readDirectory(directoryPath)) {
				var fullPath = directoryPath + '/' + folder; // Construct the full path
				if (FileSystem.isDirectory(fullPath)) {
					recursion++;
					// Do not pass 'result' to the recursive call
					var subDirectoryResult = crawlDirectory(fullPath, fileExtension);
					// Concatenate the results after the call returns
					result = result.concat(subDirectoryResult);
				} else {
					if (folder.endsWith(fileExtension)) {
						fileCount++;
						result.push(fullPath); // Add the full path to the result
					}
				}
			}
			//trace('Crawled directory: ${directoryPath}, and found ${fileCount} files with extension ${fileExtension}. Total files found: ${result.length}');
			//trace('Recursion: $recursion');
		} catch (e:Dynamic) {
			//trace('Error crawling directory: $e');
		}
		return result;
	}


public static function url(url:String):String {
	// Basic validation (consider more robust validation/sanitization)
	if (!isValidUrl(url)) {
		throw "Invalid URL";
	}

	var curlCommand = "curl -s " + '"' + url + '"'; // -s for silent mode
	try {
		var process = new Process("curl", [url]);
		var output = process.stdout.readAll().toString();
		process.close();
		return output;
	} catch (e:Dynamic) {
		// Handle or log the error
		trace('Error executing curl command: $e');
		return null; // or handle as appropriate
	}
}

// Basic URL validation (implement a more comprehensive check)
static function isValidUrl(url:String):Bool {
	return url.startsWith("http://") || url.startsWith("https://");
}

// public static function getFileFromUrl(url:String, callback:Dynamic->Void):Void {
// 	var http:Http = new Http(url);

// 	// Handle successful response
// 	http.onData = function(data:String) {
// 		var fileData = parseData(data);
// 		trace("File loaded successfully");
// 		callback(fileData); // Call the callback with the data
// 	};

// 	// Handle HTTP error (e.g., network issues)
// 	http.onError = function(error:String) {
// 		trace("HTTP Error: " + error);
// 		callback(null); // Indicate an error occurred
// 	};

// 	// Optionally handle non-200 status codes
// 	http.onStatus = function(status:Int) {
// 		if (status != 200) {
// 			trace("HTTP Status Error: " + status);
// 			callback(null); // Indicate an error occurred
// 		}
// 	};

// 	// Make the request
// 	http.request();
// }

// private static function parseData(data:String):Dynamic {
// 	// Attempt to figure out the kind of data
// 	if (data.startsWith("{") && data.endsWith("}")) {
// 		// JSON data
// 		return haxe.Json.parse(data);
// 	} else if (data.startsWith("<") && data.endsWith(">")) {
// 		// XML data
// 		return new haxe.xml.Fast(Xml.parse(data));
// 	} else {
// 		// Plain text data
// 		return data;
// 	}
// }
	
// 	// Make the request
// 	http.request();
// }

public static function crawlDirectoryAlt(directoryPath:String, fileExtension:String, ?targetArray:Array<String>):Array<String> {
    // Helper function with an additional parameter for counting subdirectories
    function crawl(directoryPath:String, fileExtension:String, result:Array<String>, subdirectoryCount:Int):Array<String> {
        for (folder in FileSystem.readDirectory(FileSystem.absolutePath(directoryPath))) {
            if (FileSystem.isDirectory('$directoryPath/$folder')) {
                // Increment the subdirectory count
                result = crawl('$directoryPath/$folder', fileExtension, result, subdirectoryCount + 1);
            } else {
                if (folder.endsWith(fileExtension)) {
                    result.push(directoryPath+'/'+folder);                    
                }
            }
        }
        // Trace the count at the root level of recursion
        if (subdirectoryCount == 0) {
           // trace('Total subdirectories crawled in: ${directoryPath} = ${subdirectoryCount}');
        }
        return result;
    }

    // Initialize the helper function with a subdirectory count of 0
    return crawl(directoryPath, fileExtension, targetArray != null ? targetArray : [], 0);
}

	public static function getPath(file:String, ?type:AssetType = TEXT, ?library:Null<String> = null, ?modsAllowed:Bool = false):String
	{
		#if MODS_ALLOWED
		if(modsAllowed)
		{
			var customFile:String = file;
			if (library != null)
				customFile = '$library/$file';

			var modded:String = modFolders(customFile);
			if(FileSystem.exists(modded)) return modded;
		}
		#end

		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, 'week_assets', currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}
		}

		return getSharedPath(file);
	}

	static public function getLibraryPath(file:String, library = "shared")
	{
		return if (library == "shared") getSharedPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String, ?level:String)
	{
		if(level == null) level = library;
		var returnPath = '$library:assets/$level/$file';
		return returnPath;
	}

	inline public static function getSharedPath(file:String = '')
	{
		return 'assets/shared/$file';
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}
	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function video(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsVideo(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return 'assets/videos/$key.$VIDEO_EXT';
	}

	static public function sound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
		return sound(key + FlxG.random.int(min, max), library);

	inline static public function track(song:String, track:String):Any
		return returnSound('${formatToSongPath(song)}/$track', 'songs');

	inline static public function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}
	
	inline static public function voices(song:String, postfix:String = null):Any
	{
		var songKey:String = '${formatToSongPath(song).toLowerCase()}/Voices';
		if(postfix != null) songKey += '-' + postfix;
		//trace('songKey test: $songKey');
		var voices = returnSound(null, songKey, 'songs');
		return voices;
	}

	inline static public function inst(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song).toLowerCase()}/Inst';
		var inst = returnSound(null, songKey, 'songs');
		return inst;
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	static public function image(key:String, ?library:String = null, ?allowGPU:Bool = false):FlxGraphic
	{
		if(ImageCache.exists(getPath('images/$key.png', IMAGE, library)) && !allowGPU){
            trace(key + " is in the cache");
            return ImageCache.get(getPath('images/$key.png', IMAGE, library));
        }
		else if(ImageCache.exists(modsImages(key)) && !allowGPU){
            trace(key + " is in the cache");
            return ImageCache.get(modsImages(key));
        }
        else{
			//if (allowGPU) trace(key + " can't be loaded due to GPU Cache being on");
			//else trace(key + " is NOT in the cache");
		
			var bitmap:BitmapData = null;
			var file:String = null;

			#if MODS_ALLOWED
			file = modsImages(key);
			if (currentTrackedAssets.exists(file))
			{
				localTrackedAssets.push(file);
				return currentTrackedAssets.get(file);
			}
			else if (FileSystem.exists(file))
				bitmap = BitmapData.fromFile(file);
			else
			#end
			{
				file = getPath('images/$key.png', IMAGE, library);
				if (currentTrackedAssets.exists(file))
				{
					localTrackedAssets.push(file);
					return currentTrackedAssets.get(file);
				}
				else if (OpenFlAssets.exists(file, IMAGE))
					bitmap = OpenFlAssets.getBitmapData(file);
			}

			if (bitmap != null)
			{
				var retVal = cacheBitmap(file, bitmap, allowGPU);
				if(retVal != null) return retVal;
			}

			trace('oh no its returning null NOOOO ($file)');
			return null;
		}
	}

	public static function cacheBitmap(key:String, ?parentFolder:String = null, ?bitmap:BitmapData, ?allowGPU:Bool = true):FlxGraphic
	{
		if (bitmap == null)
		{
			var file:String = getPath(key, IMAGE, parentFolder, true);
			#if MODS_ALLOWED
			if (FileSystem.exists(file))
				bitmap = BitmapData.fromFile(file);
			else #end if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);

			if (bitmap == null)
			{
				trace('oh no its returning null NOOOO ($file)');
				return null;
			}
		}

		if (allowGPU && ClientPrefs.data.cacheOnGPU && bitmap.image != null)
		{
			bitmap.lock();
			/*if (bitmap.__texture == null)
			{
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}*/
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			//bitmap.image = null;
			//bitmap.readable = true;
		}

		var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;

		currentTrackedAssets.set(key, graph);
		localTrackedAssets.push(key);
		return graph;
	}	

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		#if MODS_ALLOWED
		if (!ignoreMods && FileSystem.exists(modFolders(key)))
			return File.getContent(modFolders(key));
		#end

		if (FileSystem.exists(getSharedPath(key)))
			return File.getContent(getSharedPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(key, 'week_assets', currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}
		}
		#end
		var path:String = getPath(key, TEXT);
		if(OpenFlAssets.exists(path, TEXT)) return Assets.getText(path);
		return null;
	}

	inline static public function font(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsFont(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return 'assets/fonts/$key';
	}

	public static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String = null)
	{
		#if MODS_ALLOWED
		if(!ignoreMods)
		{
			for(mod in Mods.getGlobalMods())
				if (FileSystem.exists(mods('$mod/$key')))
					return true;

			if (FileSystem.exists(mods(Mods.currentModDirectory + '/' + key)) || FileSystem.exists(mods(key)))
				return true;
			
			if (FileSystem.exists(mods('$key')))
				return true;
		}
		#end

		if(OpenFlAssets.exists(getPath(key, type, library, false))) {
			return true;
		}
		return false;
	}

	static public function getAtlas(key:String, ?library:String = null, ?allowGPU:Bool = false):FlxAtlasFrames
	{
		var useMod = false;
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		var myXml:Dynamic = getPath('images/$key.xml', TEXT, library, true);
		if(OpenFlAssets.exists(myXml) #if MODS_ALLOWED || (FileSystem.exists(myXml) && (useMod = true)) #end )
		{
			#if MODS_ALLOWED
			return FlxAtlasFrames.fromSparrow(imageLoaded, (useMod ? File.getContent(myXml) : myXml));
			#else
			return FlxAtlasFrames.fromSparrow(imageLoaded, myXml);
			#end
		}
		else
		{
			var myJson:Dynamic = getPath('images/$key.json', TEXT, library, true);
			if(OpenFlAssets.exists(myJson) #if MODS_ALLOWED || (FileSystem.exists(myJson) && (useMod = true)) #end )
			{
				#if MODS_ALLOWED
				return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, (useMod ? File.getContent(myJson) : myJson));
				#else
				return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, myJson);
				#end
			}
		}
		return getPackerAtlas(key, library);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String = null, ?allowGPU:Bool = false):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		#if MODS_ALLOWED
		var xmlExists:Bool = false;

		var xml:String = modsXml(key);
		if(FileSystem.exists(xml)) xmlExists = true;

		return FlxAtlasFrames.fromSparrow(imageLoaded, (xmlExists ? File.getContent(xml) : getPath('images/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(imageLoaded, getPath('images/$key.xml', library));
		#end
	}

	inline static public function getPackerAtlas(key:String, ?library:String = null, ?allowGPU:Bool = false):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		#if MODS_ALLOWED
		var txtExists:Bool = false;
		
		var txt:String = modsTxt(key);
		if(FileSystem.exists(txt)) txtExists = true;

		return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, (txtExists ? File.getContent(txt) : getPath('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, getPath('images/$key.txt', library));
		#end
	}

	inline static public function getAsepriteAtlas(key:String, ?library:String = null, ?allowGPU:Bool = false):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		#if MODS_ALLOWED
		var jsonExists:Bool = false;

		var json:String = modsImagesJson(key);
		if(FileSystem.exists(json)) jsonExists = true;

		return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, (jsonExists ? File.getContent(json) : getPath('images/$key.json', library)));
		#else
		return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, getPath('images/$key.json', library));
		#end
	}

	inline static public function formatToSongPath(path:String) {
		final invalidChars = ~/[~&;:<>#\s]/g;
		final hideChars = ~/[.,'"%?!]/g;

		return hideChars.replace(invalidChars.replace(path, '-'), '').trim().toLowerCase();
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(path:Null<String>, key:String, ?library:String) {
		#if MODS_ALLOWED
		var modLibPath:String = '';
		if (library != null) modLibPath = '$library/';
		if (path != null) modLibPath += '$path';

		var file:String = modsSounds(modLibPath, key);
		if(FileSystem.exists(file)) {
			if(!currentTrackedSounds.exists(file))
			{
				currentTrackedSounds.set(file, Sound.fromFile(file));
				//trace('precached mod sound: $file');
			}
			localTrackedAssets.push(file);
			return currentTrackedSounds.get(file);
		}
		#end

		// I hate this so god damn much
		var gottenPath:String = '$key.$SOUND_EXT';
		if(path != null) gottenPath = '$path/$gottenPath';
		gottenPath = getPath(gottenPath, SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if(!currentTrackedSounds.exists(gottenPath))
		{
			var retKey:String = (path != null) ? '$path/$key' : key;
			retKey = ((path == 'songs') ? 'songs:' : '') + getPath('$retKey.$SOUND_EXT', SOUND, library);
			if(OpenFlAssets.exists(retKey, SOUND))
			{
				currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(retKey));
				//trace('precached vanilla sound: $retKey');
			}
		}
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	static public function exists(someString:String):Bool
	{
		var toRet:Bool = false;
		if (OpenFlAssets.exists(someString))
		{
			toRet = true;
		}
		return toRet;
	}

	#if MODS_ALLOWED
	inline static public function mods(key:String = '') {
		return 'mods/' + key;
	}

	inline static public function modsFont(key:String) {
		return modFolders('fonts/' + key);
	}

	inline static public function modsJson(key:String) {
		return modFolders('data/' + key + '.json');
	}

	inline static public function modsVideo(key:String) {
		return modFolders('videos/' + key + '.' + VIDEO_EXT);
	}

	inline static public function modsSounds(path:String, key:String) {
		return modFolders(path + '/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsImages(key:String) {
		return modFolders('images/' + key + '.png');
	}

	inline static public function modsXml(key:String) {
		return modFolders('images/' + key + '.xml');
	}

	inline static public function modsTxt(key:String) {
		return modFolders('images/' + key + '.txt');
	}

	inline static public function modsImagesJson(key:String) {
		return modFolders('images/' + key + '.json');
	}

	/* Goes unused for now

	inline static public function modsShaderFragment(key:String, ?library:String)
	{
		return modFolders('shaders/'+key+'.frag');
	}
	inline static public function modsShaderVertex(key:String, ?library:String)
	{
		return modFolders('shaders/'+key+'.vert');
	}
	inline static public function modsAchievements(key:String) {
		return modFolders('achievements/' + key + '.json');
	}*/

	static public function modFolders(key:String) {
		if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) {
			var fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			}
		}

		for(mod in Mods.getGlobalMods()){
			var fileToCheck:String = mods(mod + '/' + key);
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;
		}
		return 'mods/' + key;
	}
	#end

	#if flxanimate
	public static function loadAnimateAtlas(spr:FlxAnimate, folderOrImg:Dynamic, spriteJson:Dynamic = null, animationJson:Dynamic = null)
	{
		var changedAnimJson = false;
		var changedAtlasJson = false;
		var changedImage = false;
		
		if(spriteJson != null)
		{
			changedAtlasJson = true;
			spriteJson = File.getContent(spriteJson);
		}

		if(animationJson != null) 
		{
			changedAnimJson = true;
			animationJson = File.getContent(animationJson);
		}

		// is folder or image path
		if(Std.isOfType(folderOrImg, String))
		{
			var originalPath:String = folderOrImg;
			for (i in 0...10)
			{
				var st:String = '$i';
				if(i == 0) st = '';

				if(!changedAtlasJson)
				{
					spriteJson = getTextFromFile('images/$originalPath/spritemap$st.json');
					if(spriteJson != null)
					{
						//trace('found Sprite Json');
						changedImage = true;
						changedAtlasJson = true;
						folderOrImg = Paths.image('$originalPath/spritemap$st');
						break;
					}
				}
				else if(Paths.fileExists('images/$originalPath/spritemap$st.png', IMAGE))
				{
					//trace('found Sprite PNG');
					changedImage = true;
					folderOrImg = Paths.image('$originalPath/spritemap$st');
					break;
				}
			}

			if(!changedImage)
			{
				//trace('Changing folderOrImg to FlxGraphic');
				changedImage = true;
				folderOrImg = Paths.image(originalPath);
			}

			if(!changedAnimJson)
			{
				//trace('found Animation Json');
				changedAnimJson = true;
				animationJson = getTextFromFile('images/$originalPath/Animation.json');
			}
		}

		//trace(folderOrImg);
		//trace(spriteJson);
		//trace(animationJson);
		spr.loadAtlasEx(folderOrImg, spriteJson, animationJson);
	}

	inline static public function cacheVoices(key:String){
        return 'assets/songs/$key/Voices.ogg';
    }

    inline static public function cacheInst(key:String){
        return 'assets/songs/$key/Inst.ogg';
    }

	inline static public function cacheSound(key:String){
		var fold = '';
		for (i in 0...1)
		{
			if (i == 0) 
				fold = 'assets/shared';
			else 
				fold = 'mods';
			return file2(key, "sounds", audioExtension, fold);
		}
    }

	inline static public function cacheMusic(key:String){
		var fold = '';
		for (i in 0...1)
		{
			if (i == 0) 
				fold = 'assets/shared';
			else 
				fold = 'mods';
        	return file2(key, "music", audioExtension, fold);
		}
    }
	
	static public function doesImageAssetExist(path:String)
	{
		if (path == null || path == "")
			return false;
		return OpenFlAssets.exists(path, AssetType.IMAGE);
	}

	public static function file(file:String, type:AssetType = TEXT, ?library:String):String
	{
		return getPath(file, type, library);
	}
	
	static final audioExtension:String = "ogg";

    inline static public function file2(key:String, location:String, extension:String, ?startFolder:String = 'assets/shared'):String{
        var data:String = '$startFolder/$location/$key.$extension';
        return data;
    }

	/*private static function getContentFromFile(path:String):String
	{
		var onAssets:Bool = false;
		var path:String = Paths.getPath(path, TEXT, true);
		if(FileSystem.exists(path) || (onAssets = true && Assets.exists(path, TEXT)))
		{
			//trace('Found text: $path');
			return !onAssets ? File.getContent(path) : Assets.getText(path);
		}
		return null;
	}*/
	#end
}