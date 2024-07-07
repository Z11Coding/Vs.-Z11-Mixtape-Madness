package states;
class FirstCheckState extends MusicBeatState
{

	override public function create()
	{
		FlxG.mouse.visible = false;

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
