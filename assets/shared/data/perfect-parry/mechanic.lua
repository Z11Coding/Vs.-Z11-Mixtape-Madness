local swagCounter = 0

function onCreate()
	setHUDVisibility(false);

	if getProperty('deathCounter') > 0 then
		setProperty('FlxG.sound.music.time', 42950)
		setProperty('Conductor.songPosition', 42950)
	else
		setProperty('bg.color', '0xFFFFFFFF');
		setProperty('fire.color', '0xFFFFFFFF');
		setProperty('boyfriend.color', '0xFFFFFFFF');
		setProperty('dad.color', '0xFFFFFFFF');
	end

	setProperty('skipCountdown', true)
end

function onUpdate()
	if drainHealth then
		if getProperty('health') > 0.1 then
			setProperty('health', getProperty('health') - 0.1)
			playAnim('dad', 'singUP-alt', true);
		else
			drainHealth = false
		end
	end
end

function setHUDVisibility(theBool)
	setProperty('camHUD.visible', theBool)
end

function onStepHit()
	if curStep == 575 then 
		setHUDVisibility(true)
	end
end

function onBeatHit()
	if curBeat == 363 and curBeat == 716 then
		runHaxeCode([[
			game.camGame.shake(0.005, 1);
			game.camHUD.shake(0.007, 1);
		]])
		drainHealth = true;
	end

	if curBeat >= 146 and curBeat % 5 == 0 and math.random(10) == math.random(1, 20) then
		smashMechanic();
	else if curStep >= 1472 and curBeat % 5 == 0 and math.random(25) == math.random(1, 50) then
		smashMechanic();
	end
	end
end

function smashMechanic()
	swagCounter = 0;
	--runTimer('smashMouth', crochet / 1000, 3)
	addHaxeLibrary('FlxTimer', 'flixel.util')
	runTimer('countChecks', crochet / 1000, 3)
	runHaxeCode([[
		var daSwagCounter:Int = 0;
		var pressedIt:Bool = false;
		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (daSwagCounter < 3)
			{
				var warning = new FlxSprite(768, 164.5);
				warning.loadGraphic(Paths.image('mechanicShit/warning'));
				warning.cameras = [game.camHUD];
				game.add(warning);

				FlxG.sound.play(Paths.sound('alert'), 1);
				FlxTween.tween(warning, {alpha: 0}, Conductor.crochet / 1000, {
					onComplete: (twn) ->
					{
						game.remove(warning);
						warning.destroy();
					}
				});
			}

			daSwagCounter++;
			trace(daSwagCounter);
			pressedIt = false;

			if (daSwagCounter == 2)
			{
				FlxG.sound.play(Paths.sound('smash'), 1);
			}

			if (daSwagCounter == 4 && !FlxG.keys.pressed.SPACE && !game.cpuControlled)
			{
				new FlxTimer().start(0.05, function(tmr:FlxTimer)
				{
					if (!FlxG.keys.justPressed.SPACE && !pressedIt)
					{
						new FlxTimer().start(0.001, function(tmr:FlxTimer)
						{
							if (!FlxG.keys.justPressed.SPACE && !pressedIt)
								pressedIt = false;
							else if (FlxG.keys.justPressed.SPACE)
								pressedIt = true;
							if (!FlxG.keys.justPressed.SPACE && !pressedIt)
								game.health = 0;
							else
								game.health += 0.75;
								pressedIt = true;
						}, 1);
					}
					else
					{
						if (!FlxG.keys.justPressed.SPACE && !pressedIt)
							pressedIt = false;
						else if (FlxG.keys.justPressed.SPACE)
							pressedIt = true;
							game.health += 0.75;
					}
				}, 1);
			}
			else if (daSwagCounter == 4 && game.cpuControlled)
			{
				game.boyfriend.playAnim('dodge', true);
			}

		}, 4);
	]])
	if getProperty('daSwagCounter') == 2 or swagCounter == 2 then
		spacePressed = false 
		canPressSpace = true
		inMechanic = true
	end
end

function onTimerCompleted(i)
	if i == 'canIdle' then
		playAnim('boyfriend', 'idle', true);
		spacePressed = false;
	end

	if i == 'smashMouth' then
		makeLuaSprite('warning', 'mechanicShit/warning', 0, 0)
		setObjectCamera('warning', 'hud')
		screenCenter('warning')
		addLuaSprite('warning')

		playSound('alert')
		doTweenAlpha('warning', 'warning', 0, crochet / 1000)
		if getProperty('warning.alpha') == 0 then
			removeLuaSprite('warning')
		end
		swagCounter = swagCounter+1;

		if swagCounter == 2 then
			playSound('smash')
		end
	end

	if i == 'countChecks' then
		swagCounter = swagCounter+1;
	end
end