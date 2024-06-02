package states;

import lime.app.Application;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class FirstCheckState extends MusicBeatState
{

	override public function create()
	{
		FlxG.mouse.visible = false;

		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];
		FlxG.updateFramerate = 60;
        FlxG.drawFramerate = 60;

		FlxG.worldBounds.set(0,0);

		Highscore.load();

		ClientPrefs.loadPrefs();
		
		Controls.init();

		Modifiers.loadModifiers();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.switchState(new CacheState());
	}
}
