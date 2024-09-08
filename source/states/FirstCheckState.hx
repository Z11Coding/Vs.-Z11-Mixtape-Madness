package states;
import backend.Highscore;
import backend.Achievements;
import backend.util.WindowUtil;
import flixel.input.keyboard.FlxKey;
import states.UpdateState;
class FirstCheckState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	var updateAlphabet:Alphabet;
	var updateIcon:FlxSprite;
	var updateRibbon:FlxSprite;

	var thrd:Thread;

	override public function create()
	{
		FlxG.mouse.visible = false;

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		WindowUtil.initWindowEvents();
		WindowUtil.disableCrashHandler();
		FlxSprite.defaultAntialiasing = true;

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB, ALT];

		FlxG.save.bind('Mixtape', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();
		ClientPrefs.reloadVolumeKeys();

		Language.reloadPhrases();

		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		Highscore.load();

		super.create();

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
		for(c in updateAlphabet.members) {
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
			thrd = Thread.create(function() {
				try {
					var data = Http.requestUrl("https://raw.githubusercontent.com/Z11Coding/Z11-s-Modpack-Mixup-RELEASE/main/versions/list.txt");
					
					onUpdateData(data);
				} catch(e) {
					trace(e.details());
					trace(e.stack.toString());
					//FlxG.switchState(new MainMenuState());
					
				}
			});
			updateIcon.visible = true;
			updateAlphabet.visible = true;
			updateRibbon.visible = true;
			updateRibbon.alpha = 0;
		});
	}

	function onUpdateData(data:String) {
		var versions = [for(e in data.split("\n")) if (e.trim() != "") e];
		var currentVerPos = versions.indexOf(MainMenuState.mixtapeEngineVersion);
		var files:Array<String> = [];
		for(i in currentVerPos+1...versions.length) {
			var data:String = "";
			try {
				data = Http.requestUrl('https://raw.githubusercontent.com/Z11Coding/Z11-s-Modpack-Mixup-RELEASE/main/versions/${versions[i]}.txt');
			} catch(e) {
				trace(versions[i] + " data is incorrect");
			}
			var parsedFiles = [for(e in data.split("\n")) if (e.trim() != "") e];
			for(f in parsedFiles) {
				if (!files.contains(f)) {
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
		
		if (currentVerPos+1 < versions.length)
		{
			trace("OLD VER!!!");
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
}
