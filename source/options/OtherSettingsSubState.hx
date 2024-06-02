package options;

class OtherSettingsSubState extends BaseOptionsMenu
{
	public static var curBPMList:Array<Int> =  [0, 160, 105, 130, 100, 160, 180, 100, 125, 150];
	public function new()
	{
		title = 'Misc. Settings.';
		rpcTitle = 'Misc. Settings'; // for Discord Rich Presence

		var option:Option = new Option('Cache Graphics', // even tho only one person asked, it here
			"If checked, The Graphics Will Be Cached.", 'graphicsPreload2', 'bool');
		addOption(option);

		var option:Option = new Option('Cache Music', // even tho only one person asked, it here
			"If checked, The Music Will Be Cached.", 'musicPreload2', 'bool');
		addOption(option); // now shut up before i put you in my basement

		var option:Option = new Option(
			'Silent Volume Noise', 
			"If checked, The volume wont make noise when you turn up/down the volume", 
			'silentVol', 
			'bool'
		);
		addOption(option);
		option.onChange = onChangeSound;

		var option:Option = new Option(
			'Volume Sound', 
			"The sound that plays when you change the volume.", 
			'volSound', 
			'string', 
			[
			"beep",
			"cancelMenu",
			"dialogue",
			"dialogueClose",
			"GF_4",
			"hitsound",
			"Metronome_Tick",
			"scrollMenu"]
		);
		addOption(option);
		option.onChange = onChangeSound;
		option.displayFormat = '< %v >';

		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			['None', 'Breakfast', 'Tea Time', 'Celebration', 'Drippy Genesis', 'Reglitch', 'False Memory', 'Funky Genesis', 'Late Night Cafe', 'Late Night Jersey']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		var option:Option = new Option(
			'Check For Updates', 
			"If checked, The engine will scan for updates", 
			'checkForUpdates', 
			'bool'
		);
		addOption(option);

		var option:Option = new Option('Discord Rich Presence',
			"Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord\nReccomended to turn off if the game crashes/freezes alot.",
			'discordRPC',
			'bool');
		addOption(option);

		var option:Option = new Option('Allow Username Detection',
			"Uncheck this to prevent the game from leaking your computer name. Usually a good idea for streamers.",
			'username',
			'bool');
		addOption(option);

		super();
	}

	var changedMusic:Bool = false;
	var indeed:Int = 0;
	function onChangePauseMusic()
	{
		switch (ClientPrefs.data.pauseMusic)
		{
			case 'None':
				indeed = 0;
			case 'Breakfast':
				indeed = 1;
			case 'Tea Time':
				indeed = 2;
			case 'Celebration':
				indeed = 3;
			case 'Drippy Genesis':
				indeed = 4;
			case 'Reglitch':
				indeed = 5;
			case 'False Memory':
				indeed = 6;
			case 'Funky Genesis':
				indeed = 7;
			case 'Late Night Cafe':
				indeed = 8;
			case 'Late Night Jersey':
				indeed = 9;
		}
		/*if (controls.UI_RIGHT_P)
			indeed++;
		if (controls.UI_LEFT_P)
			indeed--;
		if (indeed < 0)
			indeed = curBPMList.length - 1;
		if (indeed >= curBPMList.length)
			indeed = 0;*/
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
		Conductor.changeBPM(curBPMList[indeed]);
		ClientPrefs.data.pauseBPM = curBPMList[indeed];
	}

	function onChangeSound()
	{
		if (!ClientPrefs.data.silentVol) FlxG.sound.play(Paths.sound(ClientPrefs.data.volSound), FlxG.sound.volume);
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	override function update(e:Float)
	{
		super.update(e);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.camera.zoom = zoomies;

		FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1300, {
			ease: FlxEase.quadOut
		});
	}
}
