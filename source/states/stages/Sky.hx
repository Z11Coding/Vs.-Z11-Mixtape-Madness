package states.stages;

import states.stages.objects.*;

class Sky extends BaseStage
{
	// If you're moving your stage from PlayState to a stage file,
	// you might have to rename some variables if they're missing, for example: camZooming -> game.camZooming
	var mansionBG:BGSprite;
	var portalBG:BGSprite;
	var portalDoor:BGSprite;
	var nightSky:BGSprite;
	var castle:BGSprite;
	var torches:BGSprite;
	var water:BGSprite;
	var ground:BGSprite;
	var ground2:BGSprite;
	var lightningLight:BGSprite;
	var darkness:BGSprite;
	var stageSet:Int = 2;
	override function create()
	{
		// Spawn your stage sprites here.
		// Characters are not ready yet on this function, so you can't add things above them yet.
		// Use createPost() if that's what you want to do.
		
		switch (stageSet)
		{
			case 0:
				//Cutscene
				portalBG = new BGSprite('my_skill_fades_away_20221117194201', -200, -100);
				add(portalBG);
				portalBG.alpha = 0.0001;
				portalDoor = new BGSprite('my_skill_fades_away_20221117194210', -200, -100);
				add(portalDoor);
				portalDoor.alpha = 0.0001;
			case 1:
				//Actual Stage
				nightSky = new BGSprite('shigga_20221021112850', -200, -100);
				add(nightSky);
				castle = new BGSprite('shigga_20221021112907', -200, -100);
				add(castle);
				torches = new BGSprite('shigga_20221021112911', -200, -100);
				add(torches);
				water = new BGSprite('shigga_20221021112900', -200, -100);
				add(water);
				ground = new BGSprite('shigga_20221021112854', -200, -100);
				add(ground);
				ground2 = new BGSprite('shigga_20221021112904', -200, -100);
				add(ground2);
			case 2:	
				mansionBG = new BGSprite('mansion_20221021185624', -200, -100);
				add(mansionBG);
		}

		//Cutscene
		if (isStoryMode && !seenCutscene)
		{
			setStartCallback(doDial);
		}

		/*switch (sEnding)
		{
			case 'none':
				setEndCallback(endSong);
			default:
				setEndCallback(endSong);
		}*/
	}
	
	override function createPost()
	{
		// Use this function to layer things above characters!
		lightningLight = new BGSprite(null, -800, -400, 0, 0);
		lightningLight.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
		lightningLight.alpha = 0;
		lightningLight.blend = ADD;
		add(lightningLight);

		darkness = new BGSprite(null, -800, -400, 0, 0);
		darkness.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		darkness.alpha = 0;
		add(darkness);
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

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(dad.animOffsets.exists('scared')) {
			dad.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
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
			lightningLight.alpha = 0.4;
			FlxTween.tween(lightningLight, {alpha: 0.5}, 0.075);
			FlxTween.tween(lightningLight, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function doDial():Void
	{
		switch(songName.toLowerCase())
		{
			case 'back in action':
				doCut('bia');
				//sEnding = 'none';
		}
	}

	function doCut(theScene:String):Void
	{
		if (theScene == 'bia')
		{
			darkness.alpha = 1;
		}
	}
}