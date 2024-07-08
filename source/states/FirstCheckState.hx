package states;
import backend.Highscore;
import backend.Achievements;
import backend.util.WindowUtil;
class FirstCheckState extends MusicBeatState
{

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

		FlxG.save.bind('Mixtape' #if (flixel < "5.0.0"), 'Z11Gaming' #end);
		ClientPrefs.loadPrefs();

		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		Highscore.load();

		super.create();
	}

	override public function update(elapsed:Float)
	{
		switch (FlxG.random.bool(3) && !ClientPrefs.data.gotit)
		{
			case false:
				FlxG.switchState(new states.CacheState());
			case true:
				FlxG.switchState(new states.WelcomeToPain());
		}
	}
}
