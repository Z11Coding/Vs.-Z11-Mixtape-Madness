package states;

class CategoryState extends MusicBeatState
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var grpLocks:FlxTypedGroup<FlxSprite>;

	public var menuItems:Array<String> = [
		"Oneshots", "Remixes", "Bonus", "Secrets"
	];
	public var menuLocks:Array<Bool> = [
		false, false
	];

	public static var loadWeekForce:String = 'Main';

	private static var curSelected:Int = 0;

	override function create()
	{
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
		if (accepted && menuLocks[curSelected])
		{
			FlxG.camera.shake(0.005, 0.5);
			FlxG.sound.play(Paths.sound("badnoise"+FlxG.random.int(1,3)), 1);
			grpMenuShit.forEach(function(item:FlxSprite)
			{
				if (item.ID == curSelected) FlxTween.color(item, 1, 0xffcc0002, 0xffffffff, {ease: FlxEase.sineIn});
			});
		}
		else if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			loadWeekForce = daSelected.toLowerCase();
			if (loadWeekForce == "secrets") {
				TransitionState.transitionState(FreeplayState, {
					transitionType: (function() {
						var transitions = ["fadeOut", "fadeColor", "slideLeft", "slideRight", "slideUp", "slideDown", "slideRandom", "fallRandom", "fallSequential", "stickers"];
						var options:Array<Chance> = [];
					
						for (transition in transitions) {
							var chance:Float;
							if (transition == "stickers") {
								// Assign a lower chance for "stickers"
								chance = 1 + Math.random() * 4; // 1% to 5%
							} else if (transition == "fallRandom" || transition == "fallSequential") {
								// Assign a higher chance for "fallRandom" and "fallSequential"
								chance = 50 + Math.random() * 50; // 50% to 100%
							} else {
								// Assign a moderate chance for other transitions
								chance = 10 + Math.random() * 40; // 10% to 50%
							}
							options.push({item: transition, chance: chance});
						}
					
						return ChanceSelector.selectOption(options);
					})()
				});
			} else {
				MusicBeatState.switchState(new FreeplayState());
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
