package states.stages;

import states.stages.objects.*;

import flixel.math.FlxPoint;
import cutscenes.DialogueBoxPsych;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxObject;

class Portal extends BaseStage
{
	public var sh_r:Float = 60;
	var rotRateSh:Float;
	var portalBG:BGSprite;
	var portalrock:BGSprite;
	var portalDoor:BGSprite;
	var lightningLight:BGSprite;
	var darkness:BGSprite;
	var whiteScreen:FlxSprite;
	var cutSong:FlxSound;
	var wind:FlxSound;
	var powerEmitter:FlxEmitter;
	var randChan:String = '';
	override function create()
	{
		powerEmitter = new FlxEmitter(-1200, 2500);
		for (i in 0 ... 150)
		{
			var p = new FlxParticle();
			p.frames = Paths.getSparrowAtlas('noteskins/normal');
			p.animation.addByPrefix('0','A', 0, false);
			p.animation.addByPrefix('1','B', 0, false);
			p.animation.addByPrefix('2','C', 0, false);
			p.animation.addByPrefix('3','D', 0, false);
			p.animation.addByPrefix('4','E', 0, false);
			p.animation.addByPrefix('5','F', 0, false);
			p.animation.addByPrefix('6','G', 0, false);
			p.animation.addByPrefix('7','H', 0, false);
			p.animation.addByPrefix('8','I', 0, false);
			p.animation.addByPrefix('9','J', 0, false);
			p.animation.addByPrefix('10','K', 0, false);
			p.animation.addByPrefix('11','L', 0, false);
			p.animation.addByPrefix('12','M', 0, false);
			p.animation.addByPrefix('13','N', 0, false);
			p.animation.addByPrefix('14','O', 0, false);
			p.animation.addByPrefix('15','P', 0, false);
			p.animation.addByPrefix('16','Q', 0, false);
			p.animation.addByPrefix('17','R', 0, false);
			p.animation.play(Std.string(FlxG.random.int(0, 17)));
			p.exists = false;
			p.blend = ADD;
			powerEmitter.add(p);
		}
		powerEmitter.launchMode = FlxEmitterMode.SQUARE;
		powerEmitter.velocity.set(-50, -400, 50, -800, -100, 0, 100, -800);
		powerEmitter.scale.set(1, 1, 0.8, 0.8, 0, 0, 0, 0);
		powerEmitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
		powerEmitter.width = 4200.45;
		powerEmitter.alpha.set(1, 1);
		powerEmitter.lifespan.set(4, 4.5);
				
		powerEmitter.start(false, FlxG.random.float(0.3, 0.4), 100000);

		portalBG = new BGSprite('portal/SpacialDisturbanceBg_20230712203810', -200, -100);
		add(portalBG);
		portalBG.setGraphicSize(Std.int(portalBG.width * 1.8));
		if (!ClientPrefs.data.noParticles) add(powerEmitter);
		portalrock = new BGSprite('portal/SpacialDisturbanceBg_20230712203819', -200, -100);
		add(portalrock);
		portalrock.setGraphicSize(Std.int(portalrock.width * 1.8));
		portalDoor = new BGSprite('portal/SpacialDisturbanceBg_20230712203815', -200, -100);
		add(portalDoor);
		portalDoor.setGraphicSize(Std.int(portalDoor.width * 1.8));
	}
	
	override function createPost()
	{
		if (FlxG.random.bool(3))
		{
			randChan = 'alt';
		}
		
		trace(songName);
		switch (songName)
		{
			case 'resurgence':
				if (isStoryMode && !seenCutscene)
				{
					setStartCallback(openCutscene);
					setEndCallback(closeCutscene);
				}
		}

		whiteScreen = new FlxSprite().loadGraphic(Paths.image('white'));
		whiteScreen.setGraphicSize(Std.int(FlxG.width * 2400), Std.int(FlxG.height * 2400));
		whiteScreen.scrollFactor.set();
		whiteScreen.blend = ADD;
		whiteScreen.cameras = [camOther];
		whiteScreen.alpha = 0;
		whiteScreen.screenCenter();
		add(whiteScreen);

		// Use this function to layer things above characters!
		lightningLight = new BGSprite(null, -800, -400, 0, 0);
		lightningLight.makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 100), FlxColor.WHITE);
		lightningLight.alpha = 0;
		lightningLight.cameras = [camHUD];
		lightningLight.blend = ADD;
		lightningLight.screenCenter();
		add(lightningLight);

		darkness = new BGSprite(null, -800, -400, 0, 0);
		darkness.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		darkness.cameras = [camHUD];
		darkness.screenCenter();
		darkness.alpha = 1;
		//add(darkness);
	}

	override function update(elapsed:Float)
	{
		if (inCutscene)
		{
			FlxG.camera.zoom = cs_zoom;
			cutSong.volume = FlxG.sound.volume;
			wind.volume = FlxG.sound.volume;
		}
		rotRateSh = curStep / 9.5;
		var sh_toy = -Math.sin(rotRateSh * 2) * sh_r * 0.45;
		if (portalrock != null) portalrock.y += (sh_toy - portalrock.y) / 12;
		if (dialogueCount == 13)
		{
			FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
			whiteScreen.alpha = 1;
			FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
				startDelay: 0.1,
				ease: FlxEase.linear
			});
			dialogueCount++;
		}
		if (!inCutscene)
		{
			whiteScreen.cameras = [camHUD];
			if (isStoryMode)
			{
				cs_cam.x = game.camFollow.x;
				cs_cam.y = game.camFollow.y;
			}
		}
		else
		{
			whiteScreen.cameras = [camOther];
		}
	}

	public function startNextDialogue() {
		dialogueCount++;
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	override function beatHit()
	{
		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}
	override function onFocusLost()
	{
		if (cutSong != null) cutSong.pause();
		if (wind != null) wind.pause();
	}
	override function onFocus()
	{
		if (cutSong != null) cutSong.resume();
		if (wind != null) wind.resume();
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
			boyfriend.specialAnim = true;
		}

		if(dad.animOffsets.exists('scared')) {
			dad.playAnim('scared', true);
			dad.specialAnim = true;
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
			gf.specialAnim = true;
		}

		if(ClientPrefs.data.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!game.camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.data.flashing) {
			whiteScreen.alpha = 0.4;
			FlxTween.tween(whiteScreen, {alpha: 0.5}, 0.075);
			FlxTween.tween(whiteScreen, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function afterAction(daAction:String)
	{
		if (cs_reset)
		{
			cs_wait = false;
			cs_time ++;
		}
		else if (cs_reset2)
		{
			cs_wait = false;
			cs_time2 ++;
		}
		else
		{
			switch (daAction)
			{
				case 'countdown':
					startCountdown();
				case 'transform':
					superShaggy();
				case 'end song':
					endSong();
				case 'nothing':
					//do Nothing
					cs_wait = false;
					cs_time ++;
			}
		}
	}

	function superShaggy()
	{
		new FlxTimer().start(0.008, function(ct:FlxTimer)
		{
			switch (cutTime)
			{
				case 0:
					camFollow.x = dad.getMidpoint().x - 100;
					camFollow.y = dad.getMidpoint().y;
					camLerp = 2;
				case 15:
					dad.playAnim('powerup');
				case 48:
					dad.playAnim('idle_s');
					burst = new FlxSprite(-1110, 0);
					FlxG.sound.play(Paths.sound('burst'));
					remove(burst);
					burst = new FlxSprite(dad.getMidpoint().x - 1000, dad.getMidpoint().y - 100);
					burst.frames = Paths.getSparrowAtlas('characters/shaggy');
					burst.animation.addByPrefix('burst', "burst", 30);
					burst.animation.play('burst');
					//burst.setGraphicSize(Std.int(burst.width * 1.5));
					burst.antialiasing = true;
					add(burst);

					FlxG.sound.play(Paths.sound('powerup'), 1);
				case 62:
					burst.y = 0;
					remove(burst);
				case 95:
					FlxG.camera.angle = 0;
				case 200:
					endSong();
			}

			var ssh:Float = 45;
			var stime:Float = 30;
			var corneta:Float = (stime - (cutTime - ssh)) / stime;

			if (cutTime % 6 >= 3)
			{
				corneta *= -1;
			}
			if (cutTime >= ssh && cutTime <= ssh + stime)
			{
				FlxG.camera.angle = corneta * 5;
			}
			cutTime ++;
			ct.reset(0.008);
		});
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	public function startDialogue(dialogueFile:DialogueFile, ?afterAct:String = 'nothing', ?song:String = null):Void
	{
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.finishThing = function() {
				psychDialogue = null;
				afterAction(afterAct);
				cs_wait = false;
				cs_reset = false;
				dialogueCount = 0;
			}
			psychDialogue.cameras = [camOther];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			afterAction(afterAct);
		}
	}

	var dfS:Float = 1;
	var toDfS:Float = 1;
	public static var cs_reset:Bool = false;
	var cs_cam:FlxObject;
	public static var cs_wait:Bool = false;
	var cs_zoom:Float = 1;
	var cs_time:Int = 0;
	var cutTime = 0;
	var camLerp:Float = 1;
	var burst:FlxSprite;
	public function openCutscene()
	{
		inCutscene = true;
		camHUD.alpha = 0;
		defaultCamZoom = cs_zoom;
		cs_cam = new FlxObject(0, 0, 1, 1);
		cs_cam.x = gf.getGraphicMidpoint().x + 200;
		cs_cam.y = gf.getGraphicMidpoint().y - 300;
		add(cs_cam);
		FlxG.camera.follow(cs_cam, LOCKON, 0.01);
		cutSong = new FlxSound().loadEmbedded(Paths.music('brandnewmystery'));
		wind = new FlxSound().loadEmbedded(Paths.sound('wind'));
		boyfriend.alpha = 0;
		gf.alpha = 0;
		dad.alpha = 0;
		cutSong.looped = true;
		cutSong.volume = 0.9;
		cutSong.pause();
		wind.looped = true;
		wind.play();
		wind.volume = 0.5;

		new FlxTimer().start(0.002, function(tmr:FlxTimer)
		{
			switch (cs_time)
			{
				case 0:
					cutSong.stop();
					cs_zoom = 0.35;
					set_defaultCamZoom(cs_zoom);
				case 400:
					boyfriend.alpha = 1;
					gf.alpha = 1;
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('hurt', true);

					// white flash
					whiteScreen.alpha = 1;
					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear
					});
				case 500:
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);
					if (!cs_wait)
					{
						startDialogue(DialogueBoxPsych.parseDialogue(Paths.json('dialogue/whereAreWe')));
						cutSong.play();
						cs_wait = true;
						cs_reset = true;
					}
				case 600:
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('hurt', true);
					cs_cam.x -= 200;
					// white flash
					whiteScreen.alpha = 1;
					dad.alpha = 1;
					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
					});
				case 700:
					if (!cs_wait)
					{
						startDialogue(DialogueBoxPsych.parseDialogue(Paths.json('dialogue/hiimshaggy' + randChan)));
						cs_wait = true;
						cs_reset = true;
					}
				case 701:
					cutSong.fadeOut(1, 0);
					wind.fadeOut(1, 0);
				case 750:
					if (!ClientPrefs.data.starHidden) FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.linear});
					startCountdown();
					cutSong.stop();
					wind.stop();
			}
			if (!cs_wait)
			{
				cs_time ++;
			}

			tmr.reset(0.002);
		});
	}

	public static var cs_reset2:Bool = false;
	var cs_time2:Int = 0;
	public function closeCutscene()
	{
		inCutscene = true;
		canPause = false;
		FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.linear});
		defaultCamZoom = cs_zoom;
		cs_cam.x = gf.getGraphicMidpoint().x + 200;
		cs_cam.y = gf.getGraphicMidpoint().y - 300;
		FlxG.camera.follow(cs_cam, LOCKON, 0.01);

		new FlxTimer().start(0.002, function(tmr:FlxTimer)
		{
			switch (cs_time2)
			{
				case 0:
					cs_zoom = 0.35;
					set_defaultCamZoom(cs_zoom);
					if (!cs_wait)
					{
						startDialogue(DialogueBoxPsych.parseDialogue(Paths.json('dialogue/afterTheStorm')));
						cutSong.play();
						cs_wait = true;
						cs_reset2 = true;
						FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
						if(gf != null) gf.playAnim('scared', true);
						boyfriend.playAnim('hurt', true);
						whiteScreen.alpha = 1;
						FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
							startDelay: 0.1,
							ease: FlxEase.linear,
						});
					}
				case 200:
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('hurt', true);
					whiteScreen.alpha = 1;
					dad.alpha = 0;
					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear
					});
				case 300:
					lightningLight.cameras = [camOther];
					FlxTween.tween(boyfriend, {x: portalDoor.x + 1000}, 1, {ease: FlxEase.sineInOut});
					FlxTween.tween(boyfriend, {y: portalDoor.y + 700}, 1, {ease: FlxEase.sineInOut});
					FlxTween.tween(boyfriend, {angle: 5000}, 30, {ease: FlxEase.sineInOut});
					FlxTween.tween(gf, {x: portalDoor.x + 1000}, 1, {ease: FlxEase.sineInOut});
					FlxTween.tween(gf, {y: portalDoor.y + 700}, 1, {ease: FlxEase.sineInOut});
					FlxTween.tween(gf, {angle: 5000}, 30, {ease: FlxEase.sineInOut});
					FlxTween.tween(lightningLight, {alpha: 1}, 10, {ease: FlxEase.sineInOut});
					FlxTween.tween(camGame, {zoom: 0.1}, 10, {ease: FlxEase.sineInOut});
					cutSong.fadeOut(1, 0);
				case 1200:
					endSong();
					cutSong.stop();
					wind.stop();
			}
			if (!cs_wait)
			{
				cs_time2 ++;
			}

			tmr.reset(0.002);
		});
	}
}