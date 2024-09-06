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

		UpdateState.getRecentGithubRelease();
		UpdateState.checkOutOfDate();
		UpdateState.clearTemps("./");

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (Main.outOfDate)
			FlxG.switchState(new UpdateState(Main.recentRelease)); // UPDATE!!
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
