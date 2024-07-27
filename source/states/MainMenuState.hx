package states;

import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import flixel.FlxG;
import flixel.util.FlxAxes;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.ui.Mouse;
import flixel.FlxG;
import flixel.input.IFlxInputManager;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.system.FlxAssets;
import flixel.system.replay.MouseRecord;
import flixel.util.FlxDestroyUtil;
import flixel.addons.display.FlxExtendedSprite;
import backend.Achievements;
import objects.AchievementPopup;
import flixel.addons.plugin.FlxMouseControl;
import states.editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var fridayVersion:String = '0.2.7-Git + 0.2.8-NG';
	public static var mixtapeEngineVersion:String = '0.3.2'; // this is used for Discord RPC
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'mods', 'socials', 'credits', 'options'];

	public var iconBG:FlxSprite;

	public var icon:HealthIcon;
	var debugKeys:Array<FlxKey>;

	public static var lastRoll:String = "bf";

	var camFollow:FlxObject;

	var checker:FlxBackdrop;

	var gradientBar:FlxSprite;

	var bg:FlxSprite;

	var bgdiferent:FlxSprite;

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

		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.color = FlxColor.YELLOW;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		bgdiferent = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bgdiferent.scrollFactor.set(0, yScroll);
		bgdiferent.setGraphicSize(Std.int(bg.width * 1.175));
		bgdiferent.updateHitbox();
		bgdiferent.screenCenter();
		bgdiferent.alpha = 0;
		bgdiferent.color = FlxColor.MAGENTA;
		bgdiferent.antialiasing = ClientPrefs.data.globalAntialiasing;
		add(bgdiferent);

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

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(FlxG.width + 0, (i * 140) + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 3)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.data.globalAntialiasing;
			// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			FlxTween.tween(menuItem, {y: 30 + (i * 120)}, 1 + (i * 0.25), {ease: FlxEase.expoInOut});
			menuItem.updateHitbox();
			menuItem.scrollFactor.set(0, scr);
		}

		if (!ClientPrefs.data.lowQuality)
		{
			logoBl = new FlxSprite(-100, -100);

			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
			logoBl.scrollFactor.set();
			logoBl.antialiasing = ClientPrefs.data.globalAntialiasing;
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBl.setGraphicSize(Std.int(logoBl.width * 0.5));
			logoBl.animation.play('bump');
			logoBl.alpha = 0;
			logoBl.angle = -4;
			logoBl.updateHitbox();
			add(logoBl);
			FlxTween.tween(logoBl, {
				y: logoBl.y + 150,
				x: logoBl.x + 150,
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
			add(iconBG);

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
			icon.x = 70;
			icon.y = FlxG.height - 180;
			icon.scrollFactor.set();
			icon.updateHitbox();
			add(icon);

			charHitbox = new FlxExtendedSprite(icon.x - 50, icon.y - 40);
			charHitbox.loadGraphic(Paths.image('mainmenu/Main_Checker'));
			charHitbox.enableMouseClicks(true, false, 255);
			charHitbox.scrollFactor.set();
			charHitbox.updateHitbox();
			charHitbox.alpha = 0;
			add(charHitbox);
			charHitbox.clickable = true;
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

	var selectedSomethin:Bool = false;

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
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				TransitionState.transitionState(TitleState, null, []);
				// Main Menu Back Animations
				FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bgdiferent, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bgdiferent, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
				if (!ClientPrefs.data.lowQuality)
				{
					FlxTween.tween(logoBl, {
						alpha: 0,
						x: -100,
						y: -100,
						angle: 4
					}, 0.5, {ease: FlxEase.quadOut});
					FlxTween.tween(icon, {x: icon.x - 20, y: icon.y + 20}, 0.5, {ease: FlxEase.quadOut});
				}
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					// Main Menu Select Animations
					FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
					FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
					FlxTween.tween(bgdiferent, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
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
								goToState();
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

		if (!selectedSomethin)
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.screenCenter(X);
				spr.x += 240;
			});
		}
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

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
		FlxTween.tween(bgdiferent, {alpha: 0}, time, {ease: FlxEase.expoIn});
		if (!ClientPrefs.data.lowQuality)
		{
			FlxTween.tween(checker, {alpha: 0}, time, {ease: FlxEase.expoIn});
			FlxTween.tween(gradientBar, {alpha: 0}, time, {ease: FlxEase.expoIn});
		}
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();
		menuItems.members[curSelected].screenCenter(X);

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();
		menuItems.members[curSelected].screenCenter(X);

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
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
