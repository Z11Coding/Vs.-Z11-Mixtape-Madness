package states;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import backend.WeekData;
class CategoryState extends MusicBeatState
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var grpLocks:FlxTypedGroup<FlxSprite>;

	public static var menuItems:Array<String> = [
		"Oneshots", "Remixes", "Bonus", "Secrets"
	];

	public static var menuLocks:Array<Bool> = [
		false, false, false, true
	];

	public static var loadWeekForce:String = 'Oneshots';

	private static var curSelected:Int = 0;

	var easterEggKeys:Array<String> = [
		'CODES', 'SECRETS', 'GARGANTUANELEPHANT'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';

	override function create()
	{
		MemoryUtil.clearMajor();
		menuItems.remove("");
		menuItems.remove(" ");
		if (FlxG.save.data.enableCodes) menuItems.insert(99, 'Codes');
		FlxTransitionableState.skipNextTransOut = false;

		if (FlxG.save.data.menuLocks != null) menuLocks = FlxG.save.data.menuLocks;
		else FlxG.save.data.menuLocks = menuLocks; // just to be sure

		WeekData.reloadWeekFiles(false);
		var weeks:Array<WeekData> = [];
		for (i in 0...WeekData.weeksList.length) {
			weeks.push(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
		}
		var mods:Bool = false;
		for (i in 0...weeks.length) {
			//if(weekIsLocked(weeks[i].name)) continue;
			if (mods) break;

			var leWeek:WeekData = weeks[i];
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			if (leWeek.category == null) {
				mods = true;
				if (!menuItems.contains("Mods")) {
					menuItems.push("Mods");
				}
				break;
			}
		}

		// Check for missing categories
		var existingCategories:Array<String> = [];
		for (item in menuItems) {
			existingCategories.push(item.toLowerCase());
		}

		for (week in weeks) {
			if (week.category != null && !existingCategories.contains(week.category.toLowerCase())) {
				menuItems.push(week.category);
			}
		}

		// Remove duplicates from menuItems
		var filteredItems:Array<String> = [];
		for (item in menuItems) {
			if (!filteredItems.contains(item)) {
				filteredItems.push(item);
			}
		}
		menuItems = filteredItems;

		// Move "Main" to the front of menuItems
		if (menuItems.contains("Main")) {
			menuItems.remove("Main");				
			menuItems.insert(0, "Main");
		}


		// Main.simulateIntenseMaps();
		var hh:Array<Chance> = [
			{item: "h?", chance: 5}, // 5% chance to add "h?"
			{item: "no", chance: 95} // 95% chance to do nothing
		];
		
		
		var h:String = ChanceSelector.selectOption(hh);
		
		if (h == "h?") {
			menuItems.push("h?");
		}
		else if (h == 'no' && menuItems.contains("h?")) {
			menuItems.remove("h?");
		}
		Cursor.cursorMode = Cross;
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = FlxColor.PURPLE;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(20 * i, 320, menuItems[i], true);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.ID = i;
			grpMenuShit.add(songText);
			var isLocked:Bool = menuLocks[i];
			if (isLocked)
			{
				var lock:FlxSprite = new FlxSprite(songText.width + 10 + songText.x);
				lock.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = ClientPrefs.data.globalAntialiasing;
				grpLocks.add(lock);	
			}
		}
		changeSelection();

		super.create();
	}

	var inDialogue:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var back = controls.BACK;
		var controlsStrings:Array<String> = [];
		var shiftMult:Int = 1;
		if (!inDialogue)
		{
			if(FlxG.keys.pressed.SHIFT) shiftMult = 3;
			if (upP)
			{
				changeSelection(-shiftMult);
			}
			if (downP)
			{
				changeSelection(shiftMult);
			}

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if(allowedKeys.contains(keyName)) {
					easterEggKeysBuffer += keyName;
					if(easterEggKeysBuffer.length >= 32) easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
					//trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

					for (wordRaw in easterEggKeys)
					{
						var word:String = wordRaw.toUpperCase(); //just for being sure you're doing it right
						if (easterEggKeysBuffer.contains(word))
						{
							if (ClientPrefs.data.gotit)
							{
								//trace('YOOO! ' + word);
								FlxG.sound.play(Paths.sound('ToggleJingle'));

								/*if (word == 'CODES')
								{
									var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
									black.alpha = 0;
									add(black);

									FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
										function(twn:FlxTween) {
											FlxTransitionableState.skipNextTransIn = true;
											FlxTransitionableState.skipNextTransOut = true;
											MusicBeatState.switchState(new states.GodCode());
										}
									});
									FlxG.sound.music.fadeOut();
									if(FreeplayState.vocals != null)
									{
										FreeplayState.vocals.fadeOut();
									}
								}
								else */if (word == 'SECRETS')
								{
									grpMenuShit.forEach(function(item:FlxSprite)
									{
										if (item.ID == 3) FlxTween.color(item, 1, 0xff00cc1b, 0xffffffff, {ease: FlxEase.sineIn});
										menuLocks[3] = false;
										Achievements.unlock('secretsuntold');
										FlxG.save.data.menuLocks = menuLocks;
										FlxG.save.flush();
									});
								}
								if (word == 'GARGANTUANELEPHANT')
								{
									grpMenuShit.forEach(function(item:FlxSprite)
									{
										Achievements.unlock('what');
									});
								}
								easterEggKeysBuffer = '';
								break;
							}
							else
							{
								Window.alert('FIRST YOU MUST FIND ME WHEN OPENING THE GAME, ONLY THEN MAY YOU DO THAT.', 'TOO FAST, TOO SOON.');
							}
						}
					}
				}
			}

			var daSelected:String = menuItems[curSelected];
			loadWeekForce = daSelected.toLowerCase();
			if (accepted && menuLocks[curSelected])
			{
				accepted = false;
				FlxG.camera.shake(0.005, 0.5);
				FlxG.sound.play(Paths.sound("badnoise"+FlxG.random.int(1,3)), 1);
				grpMenuShit.forEach(function(item:FlxSprite)
				{
					if (item.ID == curSelected) FlxTween.color(item, 1, 0xffcc0002, 0xffffffff, {ease: FlxEase.sineIn});
				});
			}
			else if (accepted)
			{
				if (loadWeekForce == 'codes')
				{
					TransitionState.transitionState(CodeState, {transitionType: "stickers"});
				}
				else if (loadWeekForce == 'secrets')
				{
					if (Achievements.isUnlocked('secretsunveiled'))
					{
						TransitionState.transitionState(FreeplayState, {transitionType: "instant"});
					}
					else
					{
						Window.alert('First, you must find the songs that are hidden in the main menu\nOnly then can you enter here.', 'Not yet...');
					}
				}
				else if (loadWeekForce == 'h?')
				{
					Window.alert('h?', 'h?');
					throw "h?";
				}
				else
				{
					TransitionState.transitionState(FreeplayState, {transitionType: "instant"});
				}
			}
		}
		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpMenuShit.members[lock.ID].y;
			lock.x = grpMenuShit.members[lock.ID].width + 10 + grpMenuShit.members[lock.ID].x;
		});
	}

	override function beatHit()
	{
		FlxG.camera.zoom = zoomies;
		FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1300, {
			ease: FlxEase.quadOut
		});
		super.beatHit();
	}

	override function destroy()
	{
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;
		var bullShit:Int = 0;
		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));
			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
