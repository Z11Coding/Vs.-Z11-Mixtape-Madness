package states;

import backend.Highscore;
import backend.Achievements;
import backend.util.WindowUtil;
import flixel.input.keyboard.FlxKey;
import states.UpdateState;
import flixel.ui.FlxBar;
import openfl.system.System;
import lime.app.Application;

class FirstCheckState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	public static var gameInitialized = false;

	var updateAlphabet:Alphabet;
	var updateIcon:FlxSprite;
	var updateRibbon:FlxSprite;

	var thrd:Thread;

	public var percentLabel:FlxText;

	var filesDone = 0;
	var totalFiles = 0;

	override public function create()
	{
		if (gameInitialized)
		{
			lime.app.Application.current.window.alert("You cannot access this state. It is for initialization only.", "Debug");
			throw new haxe.Exception("Invalid state access!");
		}
		FlxG.mouse.visible = false;

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		WindowUtil.initWindowEvents();
		WindowUtil.disableCrashHandler();
		FlxSprite.defaultAntialiasing = true;

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		FlxG.save.bind('Mixtape', CoolUtil.getSavePath());

		Highscore.load();

		ClientPrefs.loadPrefs();
		ClientPrefs.reloadVolumeKeys();

		Language.reloadPhrases();

		#if sys
		ArtemisIntegration.initialize();
		ArtemisIntegration.setGameState("title");
		ArtemisIntegration.resetModName();
		ArtemisIntegration.setFadeColor("#FF000000");
		ArtemisIntegration.sendProfileRelativePath("assets/artemis/modpack-mixup.json");
		ArtemisIntegration.resetAllFlags();
		ArtemisIntegration.autoUpdateControls();
		Application.current.onExit.add(function(exitCode)
		{
			ArtemisIntegration.setBackgroundColor("#00000000");
			ArtemisIntegration.setGameState("closed");
			ArtemisIntegration.resetModName();
		});
		#end

		//PlayerInfo.loadInfo();

		super.create();

		if (FlxG.save.data.updated)
		{
			#if sys
			var countFiles:String->Void = null;
			countFiles = function(path)
			{
				for (f in FileSystem.readDirectory(path))
				{
					if (FileSystem.isDirectory('$path/$f'))
					{
						countFiles('$path/$f');
					}
					else
					{
						try
						{
							totalFiles++;
						}
						catch (e)
						{
						}
					}
				}
			}
			countFiles('./_cache');

			add(new FlxText(0, 0, FlxG.width,
				'Updating Game!\nDo not close the game\nAnd it\'s normal that the game isn\'t responding. ').setFormat(Paths.font("fridaynightfunkin.ttf"),
					30, FlxColor.WHITE, 'center'));
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
				copyFolder = function(path, destPath)
				{
					FileSystem.createDirectory(path);
					FileSystem.createDirectory(destPath);
					for (f in FileSystem.readDirectory(path))
					{
						if (FileSystem.isDirectory('$path/$f'))
						{
							copyFolder('$path/$f', '$destPath/$f');
						}
						else
						{
							try
							{
								File.copy('$path/$f', '$destPath/$f');
								fileDone();
							}
							catch (e)
							{
							}
						}
					}
				}
				copyFolder('./_cache', '.');
				try
				{
					CoolUtil.deleteFolder('./_cache/');
					FileSystem.deleteDirectory('./_cache/');
				}
				catch (e)
				{
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
			updateRibbon = new FlxSprite(0, FlxG.height - 75).makeGraphic(FlxG.width, 75, 0x88FFFFFF, true);
			updateRibbon.visible = false;
			updateRibbon.alpha = 0;
			add(updateRibbon);

			updateIcon = new FlxSprite(FlxG.width - 75, FlxG.height - 75);
			updateIcon.frames = Paths.getSparrowAtlas("pauseAlt/bfLol", "shared");
			updateIcon.animation.addByPrefix("dance", "funnyThing instance 1", 20, true);
			updateIcon.animation.play("dance");
			updateIcon.setGraphicSize(65);
			updateIcon.updateHitbox();
			updateIcon.antialiasing = true;
			updateIcon.visible = false;
			add(updateIcon);

			updateAlphabet = new Alphabet(0, 0, "Checking Your Vibe...", true);
			for (c in updateAlphabet.members)
			{
				c.scale.x /= 2;
				c.scale.y /= 2;
				c.updateHitbox();
				c.x /= 2;
				c.y /= 2;
			}
			updateAlphabet.visible = false;
			updateAlphabet.x = updateIcon.x - updateAlphabet.width - 10;
			updateAlphabet.y = updateIcon.y;
			add(updateAlphabet);
			updateIcon.y += 15;

			var tmr = new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				thrd = Thread.create(function()
				{
					try
					{
						var data = Http.requestUrl("https://raw.githubusercontent.com/Z11Coding/Z11-s-Modpack-Mixup-RELEASE/main/versions/list.txt");
						onUpdateData(data);
					}
					catch (e)
					{
						trace(e.details());
						trace(e.stack.toString());
						switch (FlxG.random.bool(12) && !ClientPrefs.data.gotit && !FlxG.save.data.updated)
						{
							case false:
								FlxG.switchState(new states.CacheState());
							case true:
								FlxG.switchState(new states.WelcomeToPain());
						}
					}
				});
				updateIcon.visible = true;
				updateAlphabet.visible = true;
				updateRibbon.visible = true;
				updateRibbon.alpha = 0;
			});
		}
	}

	function onUpdateData(data:String)
	{
		var versions = [for (e in data.split("\n")) if (e.trim() != "") e];
		var currentVerPos = versions.indexOf(MainMenuState.mixtapeEngineVersion);
		var files:Array<String> = [];
		for (i in currentVerPos + 1...versions.length)
		{
			var data:String = "";
			try
			{
				data = Http.requestUrl('https://raw.githubusercontent.com/Z11Coding/Z11-s-Modpack-Mixup-RELEASE/main/versions/${versions[i]}.txt');
			}
			catch (e)
			{
				trace(versions[i] + " data is incorrect");
			}
			var parsedFiles = [for (e in data.split("\n")) if (e.trim() != "") e];
			for (f in parsedFiles)
			{
				if (!files.contains(f))
				{
					files.push(f);
				}
			}
		}

		var changeLog:String = Http.requestUrl('https://raw.githubusercontent.com/Z11Coding/Z11-s-Modpack-Mixup-RELEASE/main/versions/changelog.txt');

		trace(currentVerPos);
		trace(versions.length);

		updateIcon.visible = false;
		updateAlphabet.visible = false;
		updateRibbon.visible = false;

		if (currentVerPos + 1 < versions.length)
		{
			trace("OLD VER!!!");
			for (args in Sys.args())
			{
				if (args == "-livereload")
				{
					switch (FlxG.random.bool(12) && !ClientPrefs.data.gotit && !FlxG.save.data.updated)
					{
						case false:
							FlxG.switchState(new states.CacheState());
						case true:
							FlxG.switchState(new states.WelcomeToPain());
							break;
					}
				}
				else
				{
					FlxG.switchState(new states.OutdatedState(files, versions[versions.length - 1], changeLog));
				}
			}
			FlxG.switchState(new states.OutdatedState(files, versions[versions.length - 1], changeLog));
		}
		else
		{
			switch (FlxG.random.bool(12) && !ClientPrefs.data.gotit && !FlxG.save.data.updated)
			{
				case false:
					FlxG.switchState(new states.CacheState());
				case true:
					FlxG.switchState(new states.WelcomeToPain());
			}
		}
	}

	function fileDone()
	{
		filesDone++;
		percentLabel.text = '${Math.round(((filesDone / totalFiles * 100) * 100) / 100)}%';
		// trace(totalFiles);
	}
}
