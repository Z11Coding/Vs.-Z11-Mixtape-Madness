package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;

import states.editors.ChartingStateOG;

import flixel.addons.ui.FlxUIInputText;

import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;
import flixel.addons.transition.FlxTransitionableState;

import flixel.math.FlxMath;
import flixel.ui.FlxButton;
import flixel.input.keyboard.FlxKey;

import flixel.util.FlxDestroyUtil;
import haxe.Json;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var iconList:FlxTypedGroup<HealthIcon>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	public static var searchBar:FlxUIInputText;
	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	public var camGame:FlxCamera;
	public static var SONG:SwagSong = null;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;

	var songChoices:Array<String> = [];
	var listChoices:Array<String> = [];
	var multiSongs:Array<String> = ["resistance", "resistalovania"];

	public static var archipelago:Bool = false;

	public static var curUnlocked:Array<String> = ['Tutorial'];
	
	public static var doChange:Bool = false;
	
	public static var multisong:Bool = false;
	
	var rankTable:Array<String> = [
		'P-small', 'X-small', 'X--small', 'SS+-small', 'SS-small', 'SS--small', 'S+-small', 'S-small', 'S--small', 'A+-small', 'A-small', 'A--small',
		'B-small', 'C-small', 'D-small', 'E-small', 'NA'
	];
	var rank:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('rankings/NA'));

	public static var allowedSongs:Array<String> = [];

	override function create()
	{
		curSelected = 0; //so it doesn't do weird things. might rework later
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		if (FlxG.save.data.allowedSongs != null) allowedSongs = FlxG.save.data.allowedSongs;
		if (FlxG.save.data.allowedSongs == null) 
		{
			FlxG.save.data.allowedSongs = allowedSongs;
			FlxG.save.flush();
		}
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		camGame = new FlxCamera();
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if sys
		ArtemisIntegration.setGameState ("menu");
		ArtemisIntegration.resetModName ();
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var categoryWhaat:String = leWeek.category;
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				if (categoryWhaat.toLowerCase() == CategoryState.loadWeekForce || (CategoryState.loadWeekForce == "mods" && categoryWhaat == null))
				{
					addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
				}
			}
		}
		//if I need to manually add songs to any other week, that's why it's like this
		switch (CategoryState.loadWeekForce)
		{
			case "secret":
				if (ClientPrefs.data.beatSky) 
				{
					addSong("Fangirl Frenzy", 0, 'sky', FlxColor.fromRGB(26, 173, 253));
					addSong("Familiar Freakout", 0, "sky", FlxColor.fromRGB(146, 113, 253));
				}
		}
		Mods.loadTopMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		iconList = new FlxTypedGroup<HealthIcon>();
		add(iconList);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.targetY = i;
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			
			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			// using a FlxGroup is too much fuss!
			// but over on mixtape engine we do arrays better
			iconArray.push(icon);
			iconList.add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		//Search bar my belovid
		searchBar = new FlxUIInputText(FlxG.height, 100, 800, '', 20);
		searchBar.screenCenter(X);
		//searchBar.x -= 200;
		add(searchBar);
		searchBar.backgroundColor = FlxColor.GRAY;
		searchBar.lines = 1;
		searchBar.autoSize = false;
		searchBar.alignment = FlxTextAlign.CENTER;
		searchBar.bold = true;
		searchBar.font = Paths.font("FridayNightFunkin.ttf");
		searchBar.alpha = 0.8;
		searchBar.text = 'CLICK TO SEARCH FREEPLAY!';
		searchBar.updateHitbox();
		//searchBar.blend = BlendMode.DARKEN;
		blockPressWhileTypingOn.push(searchBar);
		FlxG.mouse.visible = true;

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		rank.scale.x = rank.scale.y = 80 / rank.height;
		rank.updateHitbox();
		rank.antialiasing = true;
		rank.scrollFactor.set();
		rank.y = 690 - rank.height;
		rank.x = -200 + FlxG.width - 50;
		add(rank);
		rank.antialiasing = true;

		rank.alpha = 0;


		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = songs.length;
		try {
			bg.color = songs[curSelected].color;
			intendedColor = bg.color;
			#if sys
			ArtemisIntegration.setBackgroundFlxColor (intendedColor);
			#end
		}
		catch(e)
		{
			bg.color = FlxColor.WHITE;
			intendedColor = bg.color;
			#if sys
			ArtemisIntegration.setBackgroundFlxColor (intendedColor);
			#end
		}
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = Language.getPhrase("freeplay_tip", "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.");
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		
		player = new MusicPlayer(this);
		add(player);
		
		changeSelection();
		updateTexts();
		super.create();
		FlxTween.tween(rank, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});
		FlxTween.tween(searchBar, {y: 100}, 0.6, {
			ease: FlxEase.elasticInOut, 
			onComplete: function(twn:FlxTween){
				searchBar.updateHitbox();
		}});

		if (CategoryState.loadWeekForce == 'secrets') reloadSongs('secrets');

		/*if (archipelago)
		{ 
			var playButton = new FlxButton(0, 0, "Get Random Song", onAddSong);
			//playButton.onUp.sound = FlxG.sound.load(Paths.sound('confirmMenu'));
			playButton.x = (FlxG.width / 2) - 10 - playButton.width;
			playButton.y = FlxG.height - playButton.height - 10;
			add(playButton);
		}*/
	}

	override function closeSubState() {
		if (doChange) 
		{
			changeSelection(0, false);
			doChange = false;
		}
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	function reloadSongs(?category:String = null)
	{
		grpSongs.clear();
		songs = [];
		iconArray = [];
		iconList.clear();
		
		for (i in 0...iconArray.length)
		{
			iconArray.pop();
		}
		
		for (i in 0...WeekData.weeksList.length) {
			if(!allowedSongs.contains(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				if (category != null && category == 'secrets')
				{
					if (Std.string(song[0]).toLowerCase().trim().contains(allowedSongs[i]))
					{
						var colors:Array<Int> = song[2];
						if(colors == null || colors.length < 3)
						{
							colors = [146, 113, 253];
						}
						addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
					}
				}
				else if (Std.string(song[0]).toLowerCase().trim().contains(searchBar.text.toLowerCase().trim()))
				{
					var colors:Array<Int> = song[2];
					if(colors == null || colors.length < 3)
					{
						colors = [146, 113, 253];
					}
					addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
				}
			}
		}
		
		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.targetY = i;
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			
			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			// using a FlxGroup is too much fuss!
			// but over on mixtape engine we do arrays better
			iconArray.push(icon);
			iconList.add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();
		if (songs.length == -1 || songs.length == 0)
		{
			addSong('SONG NOT FOUND', -999, 'face', FlxColor.fromRGB(255, 255, 255));
		}
		changeSelection();
		updateTexts();
		changeDiff();
		if (PlayState.SONG != null) Conductor.bpm = PlayState.SONG.bpm;
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	public static var gfVocals:FlxSound = null;
	var holdTime:Float = 0;
	var stopMusicPlay:Bool = false;
	override function update(elapsed:Float)
	{
		switch(Paths.formatToSongPath(songs[curSelected].songName))
		{
			case 'resistance':
				diffText.visible = false;
				multisong = true;
			case 'resistalovania':
				diffText.visible = false;
				multisong = true;
			default:
				diffText.visible = true;
				multisong = false;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (multisong) FlxTween.tween(rank, {alpha: 0}, 0.5, {ease: FlxEase.quartInOut});
		else FlxTween.tween(rank, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});

		if (searchBar.text == 'CLICK TO SEARCH FREEPLAY!' && searchBar.hasFocus)
		{
			searchBar.text = '';
			reloadSongs(null);
			searchBar.updateHitbox();
		}
		if (!searchBar.hasFocus)
		{
			if (searchBar.y == 100)
				FlxTween.tween(searchBar, {y: 0}, 0.6, {
				ease: FlxEase.elasticInOut, 
				onComplete: function(twn:FlxTween){
					searchBar.updateHitbox();
				}});
			searchBar.updateHitbox();
			searchBar.text = 'CLICK TO SEARCH FREEPLAY!';
		}
		else 
		{
			if (searchBar.y == 0)
				FlxTween.tween(searchBar, {y: 100}, 0.6, {
				ease: FlxEase.elasticInOut, 
				onComplete: function(twn:FlxTween){
					searchBar.updateHitbox();
				}});
			searchBar.updateHitbox();
		}

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (!player.playingMusic && (searchBar.hasFocus == false || searchBar.text == null))
		{
			scoreText.text = Language.getPhrase('personal_best', 'PERSONAL BEST: {1} ({2}%)', [lerpScore, ratingSplit.join('.')]);
			positionHighscore();
			
			if(songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;
					searchBar.hasFocus = false;	
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
					searchBar.hasFocus = false;
				}
				if (controls.UI_UP_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
					searchBar.hasFocus = false;
				}
				if (controls.UI_DOWN_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
					searchBar.hasFocus = false;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					searchBar.hasFocus = false;
				}

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
					searchBar.hasFocus = false;
				}
			}

			if (controls.UI_LEFT_P)
			{
				changeDiff(-1);
				_updateSongLastDifficulty();
				searchBar.hasFocus = false;
			}
			else if (controls.UI_RIGHT_P)
			{
				changeDiff(1);
				_updateSongLastDifficulty();
				searchBar.hasFocus = false;
			}
		}
		if (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.ALT)
		{
			searchBar.hasFocus = false;
		}
		if (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.ALT)
		{
			searchBar.hasFocus = false;
		}
		if (FlxG.keys.justPressed.ANY && searchBar.hasFocus) reloadSongs(null);

		if (searchBar.hasFocus == false || searchBar.text == null)
		{
			if (controls.BACK)
			{
				searchBar.hasFocus = false;
				if (player.playingMusic)
				{
					FlxG.sound.music.stop();
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
					instPlaying = -1;

					player.playingMusic = false;
					player.switchPlayMusic();

					FlxG.sound.playMusic(Paths.music('panixPress'), 0);
					FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
				}
				else 
				{
					persistentUpdate = false;
					if(colorTween != null) {
						colorTween.cancel();
					}
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxG.switchState(new CategoryState());
				}
			}

			if (FlxG.keys.justPressed.ALT)
			{
				searchBar.hasFocus = false;
			}

			if(FlxG.keys.justPressed.CONTROL && !player.playingMusic)
			{
				searchBar.hasFocus = false;
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(FlxG.keys.justPressed.SPACE && !searchBar.hasFocus)
			{
				if(instPlaying != curSelected && !player.playingMusic)
				{
					searchBar.hasFocus = false;
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
	
					Mods.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					if (PlayState.SONG.needsVoices)
					{
						vocals = new FlxSound();
						try
						{
							var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
							var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
							if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
							
							if(loadedVocals != null)
							{
								vocals.loadEmbedded(loadedVocals);
								FlxG.sound.list.add(vocals);
								vocals.persist = vocals.looped = true;
								vocals.volume = 0.8;
								vocals.play();
								vocals.pause();
							}
							else vocals = FlxDestroyUtil.destroy(vocals);
						}
						catch(e:Dynamic)
						{
							vocals = FlxDestroyUtil.destroy(vocals);
						}
						
						opponentVocals = new FlxSound();
						gfVocals = new FlxSound();
						try
						{
							//trace('please work...');
							var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
							var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
							var loadedgfVocals = Paths.voices(PlayState.SONG.song, 'gf');
							
							if(loadedVocals != null)
							{
								opponentVocals.loadEmbedded(loadedVocals);
								FlxG.sound.list.add(opponentVocals);
								opponentVocals.persist = opponentVocals.looped = true;
								opponentVocals.volume = 0.8;
								opponentVocals.play();
								opponentVocals.pause();
								//trace('yaaay!!');
							}
							else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);

							if(loadedgfVocals != null)
							{
								gfVocals.loadEmbedded(loadedgfVocals);
								FlxG.sound.list.add(gfVocals);
								gfVocals.persist = gfVocals.looped = true;
								gfVocals.volume = 0.8;
								gfVocals.play();
								gfVocals.pause();
								//trace('yaaay!!');
							}
							else gfVocals = FlxDestroyUtil.destroy(gfVocals);
						}
						catch(e:Dynamic)
						{
							//trace('FUUUCK');
							opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
							gfVocals = FlxDestroyUtil.destroy(gfVocals);
						}
					}
	
					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
					FlxG.sound.music.pause();
					instPlaying = curSelected;
	
					player.playingMusic = true;
					player.curTime = 0;
					player.switchPlayMusic();
					player.pauseOrResume(true);
				}
				else if (instPlaying == curSelected && player.playingMusic)
				{
					player.pauseOrResume(!player.playing);
				}
			}
			else if (controls.ACCEPT && !player.playingMusic && !searchBar.hasFocus)
			{
				searchBar.hasFocus = false;
				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				trace(poop);
				switch(songLowercase)
				{
					case 'resistance':
						songChoices = ['Resistance', 'Resistance-k', 'Resistance Awsome Mix', 'Resistance-kai'];
						listChoices = ['Resistance', 'Resistance (Kyren Mix)', 'Resistance (Awsome Mix)', 'Resistance (Kai Mix)'];
					case 'resistalovania':
						songChoices = ['Resistalovania', 'Resistalovania Mega Mix'];
						listChoices = ['Resistalovania', 'Resistalovania (Mega Mix)'];
					default:
						songChoices = [];
						listChoices = [];
				}

				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				if (!multisong)
				{
					try
					{
						if (songLowercase == "song-not-found")
						{
							FlxG.save.data.slowdown = true;
							FlxG.save.flush();
							FreeplayState.allowedSongs.push('slow');
							Achievements.unlock('secretsunveiled');
							Song.loadFromJson('slowdown-hard', 'slowdown');
							PlayState.isStoryMode = false;
							PlayState.storyDifficulty = curDifficulty;

							trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
						}
						else
						{
							Song.loadFromJson(poop, songLowercase);
							PlayState.isStoryMode = false;
							PlayState.storyDifficulty = curDifficulty;

							trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
						}
					}
					catch(e:Dynamic)
					{
						trace('ERROR! $e');

						var errorStr:String = e.toString();
						if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
						missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
						missingText.screenCenter(Y);
						missingText.visible = true;
						missingTextBG.visible = true;
						FlxG.sound.play(Paths.sound('cancelMenu'));

						updateTexts(elapsed);
						super.update(elapsed);
						return;
					}
				
					if (FlxG.keys.pressed.SHIFT){
						TransitionState.transitionState(ChartingStateOG, {transitionType: "stickers"});
					} else{
						if (!CacheState.didPreCache)
						{
							if (!alreadyClicked)
							{
								MusicBeatState.reopen = false; //Fix a sticker bug
								LoadingState.prepareToSong();
								LoadingState.loadAndSwitchState(new PlayState());
							}
							else TransitionState.transitionState(PlayState, {transitionType: "stickers"});
						}
						else TransitionState.transitionState(PlayState, {transitionType: "stickers"});
						#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
						stopMusicPlay = true;
					}
				}
				else {
					substates.DiffSubState.songChoices = songChoices;
					substates.DiffSubState.listChoices = listChoices;
					openSubState(new substates.DiffSubState());
				}

				FlxG.sound.music.volume = 0;
						
				destroyFreeplayVocals();
				#if (MODS_ALLOWED && DISCORD_ALLOWED)
				DiscordClient.loadModRPC();
				#end
			}
			else if(controls.RESET && !player.playingMusic)
			{
				searchBar.hasFocus = false;
				persistentUpdate = false;
				openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}
		else if (FlxG.keys.justPressed.ENTER)
		{
			for (i in 0...blockPressWhileTypingOn.length)
			{
				if (blockPressWhileTypingOn[i].hasFocus)
				{
					blockPressWhileTypingOn[i].hasFocus = false;
				}
			}
			searchBar.hasFocus = false;
		}
		for (inputText in blockPressWhileTypingOn)
		{
			if (inputText.hasFocus)
			{
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				break;
			}
			else 
			{
				FlxG.sound.muteKeys = FirstCheckState.muteKeys;
				FlxG.sound.volumeDownKeys = FirstCheckState.volumeDownKeys;
				FlxG.sound.volumeUpKeys = FirstCheckState.volumeUpKeys;
				FlxG.keys.preventDefaultKeys = [TAB];
				break;
			}
		}

		updateTexts(elapsed);
		super.update(elapsed);
	}

	var alreadyClicked:Bool = false;
	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		catch (e:Dynamic) {}
		return null;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function changeDiff(change:Int = 0)
	{
		if (player.playingMusic)
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		#if !switch
		Highscore.isOppMode = ClientPrefs.getGameplaySetting('opponentplay', false);
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		rank.loadGraphic(Paths.image('rankings/' + rankTable[Highscore.getRank(songs[curSelected].songName, curDifficulty)]));
		rank.scale.x = rank.scale.y = 140 / rank.height;
		rank.updateHitbox();
		rank.antialiasing = true;
		rank.scrollFactor.set();
		rank.y = 690 - rank.height;
		rank.x = -200 + FlxG.width - 50;
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
		else
			diffText.text = lastDifficultyName.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic)
			return;

		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		if (songs.length >= 0)
		{
			var newColor:Int = songs[curSelected].color;
			if(newColor != intendedColor) {
				if(colorTween != null) {
					colorTween.cancel();
				}
				intendedColor = newColor;
				#if sys
				ArtemisIntegration.setBackgroundFlxColor (intendedColor);
				#end
				colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
				});
			}
		}

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			if (iconArray[i] != null)
			{
				iconArray[i].alpha = 0.4;
				/*switch (iconArray[i].type) {
					case SINGLE: iconArray[i].animation.curAnim.curFrame = 0;
					case WINNING: iconArray[i].animation.curAnim.curFrame = 0;
					default: iconArray[i].animation.curAnim.curFrame = 0;
				}*/
			}
		}

		if (iconArray[curSelected] != null)
		{
			iconArray[curSelected].alpha = 1;
			/*switch (iconArray[curSelected].type) {
				case SINGLE: iconArray[curSelected].animation.curAnim.curFrame = 0;
				case WINNING: iconArray[curSelected].animation.curAnim.curFrame = 1;
				default: iconArray[curSelected].animation.curAnim.curFrame = 0;
			}*/
		}

		for (item in grpSongs.members)
		{
			bullShit++;
			item.alpha = 0.4;
			if (item.targetY == curSelected)
				item.alpha = 1;
		}
		
		if (songs[curSelected] != null)
		{
			Mods.currentModDirectory = songs[curSelected].folder;
			PlayState.storyWeek = songs[curSelected].week;
			try {Difficulty.loadFromWeek();} catch(e:Dynamic) {}
		}
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		if (songs[curSelected].songName != 'SONG NOT FOUND') 
		{
			Mods.currentModDirectory = songs[curSelected].folder;
			PlayState.storyWeek = songs[curSelected].week;

			Difficulty.loadFromWeek();
			var savedDiff:String = songs[curSelected].lastDifficulty;
			var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
			if(songs[curSelected].songName != 'SONG NOT FOUND') savedDiff = WeekData.getCurrentWeek().difficulties.trim(); //Fuck you HTML5
			else savedDiff = 'SONG NOT FOUND!'; //and you too search bar
			if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
				curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
			else if(lastDiff > -1)
				curDifficulty = lastDiff;
			else if(Difficulty.list.contains(Difficulty.getDefault()))
				curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
			else
				curDifficulty = 0;
			
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		}
		else
		{
			Difficulty.list = ['SONG NOT FOUND'];
			curDifficulty = 0;
			addSong('SONG NOT FOUND', -999, 'face', FlxColor.fromRGB(255, 255, 255));
		}

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
	{
		if (songs[curSelected] != null) songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles)
		{
			if(grpSongs.members[i] != null) grpSongs.members[i].visible = grpSongs.members[i].active = false;
			if(iconArray[i] != null) iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			if (grpSongs.members[i] != null)
			{
				var item:Alphabet = grpSongs.members[i];
				item.visible = item.active = true;
				item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
				item.y = ((item.targetY - lerpSelected) * 1.3 * item.distancePerItem.y) + item.startPosition.y;

				var icon:HealthIcon = iconArray[i];
				icon.visible = icon.active = true;
				_lastVisibles.push(i);
			}
		}
	}

	override function beatHit()
	{
		camGame.zoom = zoomies;

		FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet / 1300, {
			ease: FlxEase.quadOut
		});

		super.beatHit();
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing && !stopMusicPlay)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}	
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}