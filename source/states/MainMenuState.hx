package states;

import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.addons.display.FlxExtendedSprite;
import backend.Achievements;
import flixel.addons.plugin.FlxMouseControl;
import states.editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.effects.FlxFlicker;

using StringTools;

enum MainMenuColumn {
	LEFT;
	CENTER;
	RIGHT;
}

class MainMenuState extends MusicBeatState
{
	public static var fridayVersion:String = '0.2.7-Git + 0.2.8-NG';
	public static var mixtapeEngineVersion:String = '0.3.2'; // this is used for Discord RPC
	public static var psychEngineVersion:String = '1.0-prerelease'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var curColumn:MainMenuColumn = CENTER;
	var allowMouse:Bool = true; //Turn this off to block mouse movement in menus

	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [
		'freeplay',
		'credits'
	];
	public var iconBG:FlxSprite;
	var leftItem:FlxSprite;
	var rightItem:FlxSprite;

	var leftOption:String = #if ACHIEVEMENTS_ALLOWED 'achievements' #else null #end;
	var rightOption:String = 'options';

	public var icon:HealthIcon;
	var debugKeys:Array<FlxKey>;

	public static var lastRoll:String = "bf";

	var camFollow:FlxObject;

	var checker:FlxBackdrop;

	var gradientBar:FlxSprite;

	var bg:FlxSprite;

	var date = Date.now();

	var logoBl:FlxSprite;

	var noname:Bool = false;

	var charHitbox:FlxExtendedSprite;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		checker = new FlxBackdrop(Paths.image('mainmenu/Main_Checker'), XY, Std.int(0.2), Std.int(0.2));

		debugKeys = ClientPrefs.keyBinds.get('debug_1').copy();

		FlxG.plugins.add(new FlxMouseControl());

		#if desktop
		trace(Sys.environment()["COMPUTERNAME"]); // sussy test for a next menu x1
		trace(Sys.environment()["USERNAME"]); // sussy test for a next menu x2
		#else
		trace(Sys.environment()["USER"]); // sussy test for a next menu x3
		#end

		persistentUpdate = persistentDraw = true;

		Cursor.show();

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.color = 0xff270138;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		if (!ClientPrefs.data.lowQuality)
		{
			gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55AE59E4, 0xAAFFA319], 1, 90, true);
			gradientBar.y = FlxG.height - gradientBar.height;
			add(gradientBar);
			gradientBar.scrollFactor.set(0, 0);

			add(checker);
			checker.scrollFactor.set(0, 0.07);
		}

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (num => option in optionShit)
		{
			var item:FlxSprite = createMenuItem(option, 0, (num * 140) + 180);
			item.y += (4 - optionShit.length) * 70; // Offsets for when you have anything other than 4 items
			item.screenCenter(X);
		}

		if (leftOption != null)
			leftItem = createMenuItem(leftOption, 60, 490);
		if (rightOption != null)
		{
			rightItem = createMenuItem(rightOption, FlxG.width - 60, 490);
			rightItem.x -= rightItem.width;
		}

		if (!ClientPrefs.data.lowQuality)
		{
			logoBl = new FlxSprite(-100, -100);

			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
			logoBl.scrollFactor.set();
			logoBl.antialiasing = ClientPrefs.data.globalAntialiasing;
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBl.setGraphicSize(Std.int(logoBl.width * 0.6));
			logoBl.animation.play('bump');
			logoBl.alpha = 0;
			logoBl.angle = -4;
			logoBl.updateHitbox();
			add(logoBl);
			FlxTween.tween(logoBl, {
				y: logoBl.y + 50,
				x: logoBl.x + 450,
				angle: -4,
				alpha: 1
			}, 1.4, {ease: FlxEase.expoInOut});
		}

		var funnytext:FlxText = new FlxText(12, FlxG.height - 104, 0, "", 12);
		funnytext.scrollFactor.set();
		funnytext.setFormat(Paths.font("FridayNightFunkin.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(funnytext);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("FridayNightFunkin.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShitpsych:FlxText = new FlxText(12, FlxG.height - 44, 0, "", 12);
		versionShitpsych.scrollFactor.set();
		versionShitpsych.setFormat(Paths.font("FridayNightFunkin.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShitpsych);
		#if !debug
		versionShit.text = "Mixtape Engine v" + mixtapeEngineVersion;
		#end
		#if debug
		versionShit.text = "Mixtape Engine v" + mixtapeEngineVersion + ' (debug)';
		#end
		if (ClientPrefs.data.username)
		{
			#if desktop
				funnytext.text = "HI " + Sys.environment()["USERNAME"] + " :)";
			#else
				funnytext.text = "HI " + Sys.environment()["USER"] + " :)";
			#end
		}
		else funnytext.text = "You're safe, for now...";
		versionShitpsych.text = "Psych Engine v" + psychEngineVersion;
		funnytext.screenCenter(X);
		versionShit.screenCenter(X);
		versionShitpsych.screenCenter(X);
		var versionShitFriday:FlxText = new FlxText(12, FlxG.height - 24, 0, "FNF v" + fridayVersion, 12);
		versionShitFriday.scrollFactor.set();
		versionShitFriday.setFormat(Paths.font("FridayNightFunkin.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShitFriday.screenCenter(X);
		add(versionShitFriday);

		if (!ClientPrefs.data.lowQuality)
		{
			iconBG = new FlxSprite().loadGraphic(Paths.image('pause/iconbackground'));
			iconBG.scrollFactor.set();
			iconBG.updateHitbox();
			iconBG.screenCenter();
			iconBG.antialiasing = ClientPrefs.data.globalAntialiasing;
			//add(iconBG);

			switch (FlxG.random.int(1, 15))
			{
				case 1:
					icon = new HealthIcon('bf');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.CYAN;
				case 2:
					icon = new HealthIcon('bf-old');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.LIME;
				case 3:
					icon = new HealthIcon('gf');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.RED;
				case 4:
					icon = new HealthIcon('dad');
					icon.setGraphicSize(Std.int(icon.width * 1.7));
					iconBG.color = FlxColor.PURPLE;
				case 5:
					icon = new HealthIcon('mom');
					icon.setGraphicSize(Std.int(icon.width * 1.8));
					iconBG.color = FlxColor.PURPLE;
				case 6:
					icon = new HealthIcon('spooky');
					icon.setGraphicSize(Std.int(icon.width * 2));
					switch (FlxG.random.int(1, 2))
					{
						case 1:
							iconBG.color = FlxColor.ORANGE;
						case 2:
							iconBG.color = FlxColor.WHITE;
					}
				case 7:
					icon = new HealthIcon('bf-pixel');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.CYAN;
				case 8:
					icon = new HealthIcon('face');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.GRAY;
				case 9:
					icon = new HealthIcon('monster');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.YELLOW;
				case 10:
					icon = new HealthIcon('parents');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.PURPLE;
				case 11:
					icon = new HealthIcon('pico');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.GREEN;
				case 12:
					icon = new HealthIcon('senpai-pixel');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.ORANGE;
				case 13:
					icon = new HealthIcon('spirit-pixel');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.RED;
				case 14:
					icon = new HealthIcon('tankman');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.BLACK;
				case 15:
					icon = new HealthIcon('z11-playable');
					icon.setGraphicSize(Std.int(icon.width * 2));
					switch (FlxG.random.int(1, 2))
					{
						case 1:
							iconBG.color = FlxColor.BLACK;
						case 2:
							iconBG.color = FlxColor.WHITE;
					}
			} // YES, I WILL PUT THE HAXE COLORS INSTEAD THE NORMAL ONES

			// icon = new HealthIcon('bf');
			// icon.setGraphicSize(Std.int(icon.width * 2));
			icon.antialiasing = ClientPrefs.data.globalAntialiasing;
			icon.x = FlxG.width - 70;
			icon.y = 180;
			icon.scrollFactor.set();
			icon.updateHitbox();
			//add(icon);
		}

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		FlxTransitionableState.skipNextTransOut = false;

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		super.create();

		FlxG.camera.follow(camFollow, null, 9);
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite(x, y);
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_$name');
		menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
		menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
		menuItem.animation.play('idle');
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.data.globalAntialiasing;
		menuItem.scrollFactor.set();
		menuItems.add(menuItem);
		return menuItem;
	}

	var selectedSomethin:Bool = false;
	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		Conductor.songPosition = FlxG.sound.music.time;

		if(FlxG.keys.justPressed.F11)
    		FlxG.fullscreen = !FlxG.fullscreen;

		if(FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		checker.x -= 0.45 / (ClientPrefs.data.framerate / 60);
		checker.y -= 0.16 / (ClientPrefs.data.framerate / 60);

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P) changeItem(-1);

			if (controls.UI_DOWN_P) changeItem(1);

			var allowMouse:Bool = allowMouse;
			if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
			{
				allowMouse = false;
				Cursor.show();
				timeNotMoving = 0;

				var selectedItem:FlxSprite;
				switch(curColumn)
				{
					case CENTER:
						selectedItem = menuItems.members[curSelected];
					case LEFT:
						selectedItem = leftItem;
					case RIGHT:
						selectedItem = rightItem;
				}

				if(leftItem != null && FlxG.mouse.overlaps(leftItem))
				{
					Cursor.cursorMode = Pointer;
					allowMouse = true;
					if(selectedItem != leftItem)
					{
						curColumn = LEFT;
						changeItem();
					}
				}
				else if(rightItem != null && FlxG.mouse.overlaps(rightItem))
				{
					Cursor.cursorMode = Pointer;
					allowMouse = true;
					if(selectedItem != rightItem)
					{
						curColumn = RIGHT;
						changeItem();
					}
				}
				else
				{
					var dist:Float = -1;
					var distItem:Int = -1;
					for (i in 0...optionShit.length)
					{
						var memb:FlxSprite = menuItems.members[i];
						if(FlxG.mouse.overlaps(memb))
						{
							Cursor.cursorMode = Pointer;
							var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
							if (dist < 0 || distance < dist)
							{
								dist = distance;
								distItem = i;
								allowMouse = true;
							}
						}
					}

					if(distItem != -1 && selectedItem != menuItems.members[distItem])
					{
						curColumn = CENTER;
						curSelected = distItem;
						changeItem();
					}
				}
			}
			else
			{

				timeNotMoving += elapsed;
				if(timeNotMoving > 2) Cursor.hide();
			}

			switch(curColumn)
			{
				case CENTER:
					if(controls.UI_LEFT_P && leftOption != null)
					{
						curColumn = LEFT;
						changeItem();
					}
					else if(controls.UI_RIGHT_P && rightOption != null)
					{
						curColumn = RIGHT;
						changeItem();
					}

				case LEFT:
					if(controls.UI_RIGHT_P)
					{
						curColumn = CENTER;
						changeItem();
					}

				case RIGHT:
					if(controls.UI_LEFT_P)
					{
						curColumn = CENTER;
						changeItem();
					}
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				TransitionState.transitionState(TitleState, null, []);
				// Main Menu Back Animations
				FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
				if (!ClientPrefs.data.lowQuality)
				{
					FlxTween.tween(logoBl, {
						alpha: 0,
						x: -100,
						y: -100,
						angle: 4
					}, 0.5, {ease: FlxEase.quadOut});
					FlxTween.tween(icon, {x: icon.x - 20, y: icon.y + 20}, 0.5, {ease: FlxEase.quadOut});
					FlxTween.tween(iconBG, {x: iconBG.x - 20, y: iconBG.y + 20}, 0.5, {ease: FlxEase.quadOut});
				}
			}

			if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse))
			{
				Cursor.hide();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if (optionShit[curSelected] != 'donate')
				{
					selectedSomethin = true;
					Cursor.hide();
					FlxG.sound.play(Paths.sound('confirmMenu'));

					var item:FlxSprite;
					var option:String;
					switch(curColumn)
					{
						case CENTER:
							option = optionShit[curSelected];
							item = menuItems.members[curSelected];

						case LEFT:
							option = leftOption;
							item = leftItem;

						case RIGHT:
							option = rightOption;
							item = rightItem;
					}

					// Main Menu Select Animations
					FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween)
					{
						FlxG.camera.zoom = 1;
					}});
					FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
					if (!ClientPrefs.data.lowQuality)
					{
						FlxTween.tween(checker, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(logoBl, {
							alpha: 0,
							x: logoBl.x - 30,
							y: logoBl.y - 30,
							angle: 4
						}, 0.8, {ease: FlxEase.quadOut});
						FlxTween.tween(icon, {x: icon.x - 10, y: icon.y + 10}, 0.8, {ease: FlxEase.quadOut});
					}

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						hideit(0.6);
					});

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						goToState(option);
					});

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0.1, x: 1500}, 1, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
							FlxTween.tween(spr, {x: 1500}, 1, {
								ease: FlxEase.quadOut
							});
						}
						else
						{
							spr.updateHitbox();
							// spr.x += -300;
							FlxTween.tween(spr, {x: spr.x - 240, y: 260}, 0.5, {ease: FlxEase.quadOut});
							FlxTween.tween(spr.scale, {x: 1.2, y: 1.2}, 0.8, {ease: FlxEase.quadOut});

							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								goToState(option);
							});
						}
					});
				}
			}
			#if desktop
			if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
			
		}

		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	function goToState(daChoice:String)
	{
		trace(daChoice);
		switch (daChoice)
		{
			case 'story_mode':
				MusicBeatState.switchState(new StoryMenuState());
			case 'freeplay':
				MusicBeatState.switchState(new CategoryState());
			case 'socials':
				MusicBeatState.switchState(new SocialsState());
			#if MODS_ALLOWED
			case 'mods':
				MusicBeatState.switchState(new ModsMenuState());
			#end
			case 'awards':
				MusicBeatState.switchState(new AchievementsMenuState());
			case 'credits':
				MusicBeatState.switchState(new CreditsState());
			case 'options':
				MusicBeatState.switchState(new options.OptionsState());
		}
	}

	function hideit(time:Float)
	{
		menuItems.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {alpha: 0.0}, time, {ease: FlxEase.quadOut});
		});
		FlxTween.tween(bg, {alpha: 0}, time, {ease: FlxEase.expoIn});
		if (!ClientPrefs.data.lowQuality)
		{
			FlxTween.tween(checker, {alpha: 0}, time, {ease: FlxEase.expoIn});
			FlxTween.tween(gradientBar, {alpha: 0}, time, {ease: FlxEase.expoIn});
		}
	}

	function changeItem(change:Int = 0)
	{
		if(change != 0) curColumn = CENTER;
		curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'));

		for (item in menuItems)
		{
			item.animation.play('idle');
			item.centerOffsets();
		}

		var selectedItem:FlxSprite;
		switch(curColumn)
		{
			case CENTER:
				selectedItem = menuItems.members[curSelected];
			case LEFT:
				selectedItem = leftItem;
			case RIGHT:
				selectedItem = rightItem;
		}
		selectedItem.animation.play('selected');
		selectedItem.centerOffsets();
		camFollow.y = selectedItem.getGraphicMidpoint().y;
	}

	override function beatHit()
	{
		super.beatHit();

		if (logoBl != null)
			logoBl.animation.play('bump', true);

		if (!selectedSomethin)
		{
			FlxG.camera.zoom = zoomies;

			FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1300, {
				ease: FlxEase.quadOut
			});
		}
	}
}
