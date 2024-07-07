package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;

class DiffSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	public static var difficultyChoices = [];
	var curSelected:Int = 0;

	var pausebg:FlxSprite;
	var pausebg1:FlxSprite;
	var iconBG:FlxSprite;
	public static var flick:Bool = false;

	public static var transCamera:FlxCamera;

	public function new()
	{
		super();

		difficultyChoices.push('BACK');

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		if (!ClientPrefs.lowQuality)
		{
			pausebg = new FlxSprite().loadGraphic(Paths.image('pausemenubg'));
			pausebg.color = 0xFF1E1E1E;
			pausebg.scrollFactor.set();
			pausebg.updateHitbox();
			pausebg.screenCenter();
			pausebg.antialiasing = ClientPrefs.globalAntialiasing;
			add(pausebg);
			pausebg.x += 200;
			pausebg.y -= 200;
			pausebg.alpha = 0;
			FlxTween.tween(pausebg, {
				x: 0,
				y: 0,
				alpha: 1
			}, 1, {ease: FlxEase.quadOut});

			pausebg1 = new FlxSprite().loadGraphic(Paths.image('iconbackground'));
			pausebg1.color = 0xFF141414;
			pausebg1.scrollFactor.set();
			pausebg1.updateHitbox();
			pausebg1.screenCenter();
			pausebg1.antialiasing = ClientPrefs.globalAntialiasing;
			add(pausebg1);
			pausebg1.x -= 150;
			pausebg1.y += 150;
			pausebg1.alpha = 0;
			FlxTween.tween(pausebg1, {
				x: 0,
				y: 0,
				alpha: 1
			}, 0.9, {ease: FlxEase.quadOut});

			iconBG = new FlxSprite().loadGraphic(Paths.image('iconbackground'));
			iconBG.flipX = true;
			iconBG.scrollFactor.set();
			iconBG.updateHitbox();
			iconBG.screenCenter();
			iconBG.antialiasing = ClientPrefs.globalAntialiasing;
			add(iconBG);
			iconBG.x += 100;
			iconBG.y += 100;
			iconBG.alpha = 0;
			FlxTween.tween(iconBG, {
				x: 0,
				y: 0,
				alpha: 1
			}, 0.8, {ease: FlxEase.quadOut});
		}

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...difficultyChoices.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, difficultyChoices[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();
	}

	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = difficultyChoices[curSelected];

		if (accepted)
		{
			if (daSelected != 'BACK' && difficultyChoices.contains(daSelected))
			{
				flick = true;
				var name:String = PlayState.SONG.song.toLowerCase();
				var poop = Highscore.formatSong(name, curSelected);
				PlayState.SONG = Song.loadFromJson(poop, name);
				PlayState.storyDifficulty = curSelected;
				CustomFadeTransition.nextCamera = transCamera;
				new FlxTimer().start(1, function(tmr:FlxTimer)
                {
					openSubState(new LoadingsState());
					FlxTransitionableState.skipNextTransIn = true;
					var toSwitchToState = new PlayState();
					LoadingState.loadAndSwitchState(toSwitchToState, true,true);
					CharMenu.alreadySelected = false;
				});
				FlxG.sound.music.volume = 0;
				PlayState.chartingMode = false;
				close();
				return;
			}

			switch (daSelected)
			{
				case 'BACK':
					CharMenu.alreadySelected = false;
					close();
			}
		}
		if (flick)
		{
			for (item in grpMenuShit.members)
				{ 
					FlxFlicker.flicker(item, 0);
				}
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = difficultyChoices.length - 1;
		if (curSelected >= difficultyChoices.length)
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
