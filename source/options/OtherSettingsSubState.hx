package options;

class OtherSettingsSubState extends BaseOptionsMenu
{
	public static var curBPMList:Array<Int> =  [0, 160, 105, 130, 100, 160, 180, 100, 125, 150, 140];
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

		var option:Option = new Option(
			'Raise Volume Sound', 
			"The sound that plays when you change the volume.", 
			'volUp', 
			'string', 
			[
			"beep",
			"bfBeep",
			"cancelMenu",
			"clickText",
			"confirmMenu",
			"dialogue",
			"dialogueClose",
			"GF_4",
			"hitsound",
			"Metronome_Tick",
			"pixelText",
			"scrollMenu",
			"snd_hurt1",
			"txtSans",
			"Volup"]
		);
		addOption(option);
		option.onChange = onChangeSoundUp;
		option.displayFormat = '< %v >';

		var option:Option = new Option(
			'Lower Volume Sound', 
			"The sound that plays when you change the volume.", 
			'volDown', 
			'string', 
			[
			"beep",
			"bfBeep",
			"cancelMenu",
			"clickText",
			"confirmMenu",
			"dialogue",
			"dialogueClose",
			"GF_4",
			"hitsound",
			"Metronome_Tick",
			"pixelText",
			"scrollMenu",
			"snd_hurt1",
			"txtSans",
			"Voldown"]
		);
		addOption(option);
		option.onChange = onChangeSoundDown;
		option.displayFormat = '< %v >';

		var option:Option = new Option(
			'Max Volume Sound', 
			"The sound that plays when you change the volume.", 
			'volMax', 
			'string', 
			[
			"beep",
			"bfBeep",
			"cancelMenu",
			"clickText",
			"confirmMenu",
			"dialogue",
			"dialogueClose",
			"GF_4",
			"hitsound",
			"Metronome_Tick",
			"pixelText",
			"scrollMenu",
			"snd_hurt1",
			"txtSans",
			"VolMAX"]
		);
		addOption(option);
		option.onChange = onChangeSoundMax;
		option.displayFormat = '< %v >';

		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			['None', 'Breakfast', 'Tea Time', 'Celebration', 'Drippy Genesis', 'Reglitch', 'False Memory', 'Funky Genesis', 'Late Night Cafe', 'Late Night Jersey', 'Silly Little Sample Song']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		var option:Option = new Option(
			'Check For Updates', 
			"If checked, The engine will scan for updates", 
			'checkForUpdates', 
			'bool'
		);
		addOption(option);

		var option:Option = new Option('Allow Username Detection',
			"Uncheck this to prevent the game from leaking your computer name. Usually a good idea for streamers.",
			'username',
			'bool');
		addOption(option);

		var option:Option = new Option('Break the sticker audio',
			"Literally just locks the sound to a funny bug I found.",
			'audioBreak',
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
		/*
		if (controls.UI_RIGHT_P)
			indeed++;
		if (controls.UI_LEFT_P)
			indeed--;
		if (indeed < 0)
			indeed = curBPMList.length - 1;
		if (indeed >= curBPMList.length)
			indeed = 0;
		*/
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
		Conductor.changeBPM(curBPMList[indeed]);
		ClientPrefs.data.pauseBPM = curBPMList[indeed];
	}

	function onChangeSoundDown()
	{
		if (!ClientPrefs.data.silentVol) FlxG.sound.play(Paths.sound('soundtray/'+ClientPrefs.data.volDown), FlxG.sound.volume);
	}

	function onChangeSoundUp()
	{
		if (!ClientPrefs.data.silentVol) FlxG.sound.play(Paths.sound('soundtray/'+ClientPrefs.data.volUp), FlxG.sound.volume);
	}

	function onChangeSoundMax()
	{
		if (!ClientPrefs.data.silentVol) FlxG.sound.play(Paths.sound('soundtray/'+ClientPrefs.data.volMax), FlxG.sound.volume);
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
