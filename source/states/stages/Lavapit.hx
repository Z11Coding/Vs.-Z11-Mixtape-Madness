package states.stages;

import states.stages.objects.*;

import flixel.math.FlxPoint;
import cutscenes.DialogueBoxPsych;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.addons.display.FlxBackdrop;
import shaders.HeatwaveShader;
import openfl.filters.ShaderFilter;
import flixel.FlxObject;

class Lavapit extends BaseStage
{
	public var sh_r:Float = 60;
	var rotRateSh:Float;
	var sky:BGSprite;
	var mountains:BGSprite;
	var platform:BGSprite;
	var lava:BGSprite;
	var rocks:BGSprite;
	var whiteScreen:FlxSprite;
	var darkness:BGSprite;
	var cutSong:FlxSound;
	var sfx:FlxSound;
	var emberEmitter:FlxEmitter;
	public static var cameFromFreeplay:Bool = false;
	var isEndCut:Bool = false;
	var songFading:Bool = false;
	var lavaa:FlxBackdrop;
	var lavaaa:FlxBackdrop;
	var rockss:FlxBackdrop;
	var rocksss:FlxBackdrop;
	var emberEmitter2:FlxEmitter;
	var emberEmitter3:FlxEmitter;
	override function create()
	{
		emberEmitter = new FlxEmitter(-1200, 2000);
		for (i in 0 ... 150)
		{
			var p = new FlxParticle();
			p.loadGraphic(Paths.image('Stages/parts/Emberparticle'));
			p.scale.set(2000, 2000);
			p.exists = false;
			p.blend = ADD;
			p.color = FlxColor.ORANGE;
			emberEmitter.add(p);
		}
		emberEmitter.launchMode = FlxEmitterMode.SQUARE;
		emberEmitter.velocity.set(-50, -400, 50, -800, -100, 0, 100, -800);
		emberEmitter.scale.set(1, 1, 0.8, 0.8, 0, 0, 0, 0);
		emberEmitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
		emberEmitter.width = 4200.45;
		emberEmitter.alpha.set(1, 1);
		emberEmitter.lifespan.set(4, 4.5);
				
		emberEmitter.start(false, FlxG.random.float(0.3, 0.4), 100000);

		emberEmitter3 = new FlxEmitter(-1200, 2000);
		for (i in 0 ... 150)
		{
			var p = new FlxParticle();
			p.loadGraphic(Paths.image('Stages/parts/Emberparticle'));
			p.scale.set(2000, 2000);
			p.exists = false;
			p.blend = ADD;
			p.color = FlxColor.ORANGE;
			emberEmitter3.add(p);
		}
		emberEmitter3.launchMode = FlxEmitterMode.SQUARE;
		emberEmitter3.velocity.set(-50, -400, 50, -800, -100, 0, 100, -800);
		emberEmitter3.scale.set(1, 1, 0.8, 0.8, 0, 0, 0, 0);
		emberEmitter3.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
		emberEmitter3.width = 4200.45;
		emberEmitter3.alpha.set(1, 1);
		emberEmitter3.lifespan.set(4, 4.5);
				
		emberEmitter3.start(false, FlxG.random.float(0.3, 0.4), 100000);
		
		sky = new BGSprite('MattMatic_20230711233726', -830, -700);
		sky.scrollFactor.set(0.7, 0.7);
		add(sky);

		mountains = new BGSprite('MattMatic_20230711233733', -830, -700);
		mountains.scrollFactor.set(0.5, 0.5);
		add(mountains);

		if (!ClientPrefs.data.noParticles) add(emberEmitter);

		lavaaa = new FlxBackdrop(Paths.image('MattMatic_20230711233751'), XY, Std.int(0.2), Std.int(0.9));

		add(lavaaa);

		rocksss = new FlxBackdrop(Paths.image('MattMatic_20230711233755'), XY, Std.int(0.2), Std.int(0.9));

		add(rocksss);

		platform = new BGSprite('MattMatic_20230711233739', -700, -700);
		//platform.scrollFactor.set(0.5, 0.5);
		add(platform);

		lavaa = new FlxBackdrop(Paths.image('MattMatic_20230711233751'), XY, Std.int(0.2), Std.int(0.9));

		add(lavaa);

		lava = new BGSprite('MattMatic_20230711233751', -830, -700);
		lava.scrollFactor.set(0.5, 0.5);
		//add(lava);

		lavaa.x = lava.x + 800;
		lavaa.y = lava.y + 1800;

		lavaaa.x = lava.x + 400;
		lavaaa.y = lava.y + 1600;

		rockss = new FlxBackdrop(Paths.image('MattMatic_20230711233755'), XY, Std.int(0.2), Std.int(0.9));

		add(rockss);

		rocks = new BGSprite('MattMatic_20230711233755', -700, -700);
		rocks.scrollFactor.set(0.5, 0.5);
		//add(rocks);

		rockss.x = rocks.x + 400;
		rockss.y = rocks.y + 1700;

		rocksss.x = rocks.x + 400;
		rocksss.y = rocks.y + 1400;

		dadGroup.x += 400;
		boyfriendGroup.x += 500;
		gfGroup.x += 300;
	}
	
	override function createPost()
	{
		if (isStoryMode && !seenCutscene)
		{
			setStartCallback(openCutscene);
			setEndCallback(closeCutscene);
			
		}
		trace(songName);

		//if (!ClientPrefs.data.noParticles) add(emberEmitter3);

		//add(emberEmitter);

		whiteScreen = new FlxSprite().loadGraphic(Paths.image('white'));
		whiteScreen.setGraphicSize(Std.int(FlxG.width * 2400), Std.int(FlxG.height * 2400));
		whiteScreen.scrollFactor.set();
		whiteScreen.blend = ADD;
		whiteScreen.cameras = [camOther];
		whiteScreen.alpha = 0;
		whiteScreen.screenCenter();
		add(whiteScreen);

		darkness = new BGSprite(null, -800, -400, 0, 0);
		darkness.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		darkness.cameras = [camHUD];
		darkness.screenCenter();
		darkness.alpha = 1;
		//add(darkness);
	}

	override function update(elapsed:Float)
	{
		lavaa.x -= 0.45 / (ClientPrefs.data.framerate / 60);
		lavaaa.x -= 0.65 / (ClientPrefs.data.framerate / 60);
		rockss.x -= 0.85 / (ClientPrefs.data.framerate / 60);
		rocksss.x -= 1.05 / (ClientPrefs.data.framerate / 60);
		if (inCutscene)
		{
			FlxG.camera.zoom = cs_zoom;
			if (cutSong != null && !songFading) cutSong.volume = (FlxG.sound.volume - 0.2);
			//sfx.volume = FlxG.sound.volume;
		}
		rotRateSh = curStep / 9.5;
		var sh_toy = -Math.sin(rotRateSh * 2) * sh_r * 0.45;
		if (!inCutscene)
		{
			whiteScreen.cameras = [camHUD];
			/*if (!cameFromFreeplay)
			{	
				cs_cam.x = game.camFollow.x;
				cs_cam.y = game.camFollow.y;
			}*/
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	override function beatHit()
	{
		
	}
	override function onFocusLost()
	{
		if (cutSong != null) cutSong.pause();
		//if (sfx != null) sfx.pause();
	}
	override function onFocus()
	{
		if (cutSong != null) cutSong.resume();
		//if (sfx != null) sfx.play();
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

	public function startNextDialogue() {
		dialogueCount++;
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
				cs_reset2 = false;
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
		isEndCut = false;
		inCutscene = true;
		camHUD.alpha = 0;
		cs_zoom = defaultCamZoom;
		cs_cam = new FlxObject(0, 0, 1, 1);
		cs_cam.x = gf.getGraphicMidpoint().x + 200;
		cs_cam.y = gf.getGraphicMidpoint().y - 300;
		add(cs_cam);
		FlxG.camera.follow(cs_cam, LOCKON, 0.01);
		//cutSong = new FlxSound().loadEmbedded(Paths.music('brandnewmystery'));
		sfx = new FlxSound().loadEmbedded(Paths.sound('wind'));
		//cutSong.looped = true;
		//cutSong.volume = 0.7;
		//cutSong.pause();
		sfx.looped = true;
		//wind.play();
		sfx.volume = 0.5;

		switch (songName)
		{
			case 'template':
				new FlxTimer().start(0.002, function(tmr:FlxTimer)
				{
					switch (cs_time)
					{
						case 0:

						case 400:
							// white flash
							whiteScreen.alpha = 1;
							FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
								startDelay: 0.1,
								ease: FlxEase.linear
							});
						case 450:
							if (!cs_wait)
							{
								startDialogue(DialogueBoxPsych.parseDialogue(Paths.json('dialogue/OutsideTheMansionChat')), 'nothing', 'brandnewmystery');
								cs_wait = true;
								cs_reset = true;
							}
						case 451:
							if (!ClientPrefs.data.starHidden) FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.linear});
							startCountdown();
							FlxG.camera.follow(game.camFollow, LOCKON, 1);
					}
					if (!cs_wait)
					{
						cs_time ++;
					}

					tmr.reset(0.002);
				});
			default:
				startCountdown();
				camHUD.alpha = 1;
				FlxG.camera.follow(game.camFollow, LOCKON, 1);
		}
	}

	public static var cs_reset2:Bool = false;
	var cs_time2:Int = 0;
	public function closeCutscene()
	{
		isEndCut = true;
		inCutscene = true;
		canPause = false;
		FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.linear});
		cs_cam.x = gf.getGraphicMidpoint().x + 200;
		cs_cam.y = gf.getGraphicMidpoint().y - 300;
		FlxG.camera.follow(cs_cam, LOCKON, 0.01);
		//cutSong = new FlxSound().loadEmbedded(Paths.music('brandnewmystery'));
		//sfx = new FlxSound().loadEmbedded(Paths.sound('wind'));
		//cutSong.looped = true;
		//cutSong.volume = 0.7;
		//cutSong.pause();
		//sfx.looped = true;
		//wind.play();
		//sfx.volume = 0.5;

		switch (songName)
		{
			case 'template':
				new FlxTimer().start(0.002, function(tmr:FlxTimer)
				{
					switch (cs_time2)
					{
						case 0:
							if (!cs_wait)
							{
								startDialogue(DialogueBoxPsych.parseDialogue(Paths.json('dialogue/manImThirsty')));
								cs_wait = true;
								cs_reset2 = true;
							}
						case 1:
							endSong();
					}
					if (!cs_wait)
					{
						cs_time2 ++;
					}

					tmr.reset(0.002);
				});
			default:
				endSong();
		}
	}
}