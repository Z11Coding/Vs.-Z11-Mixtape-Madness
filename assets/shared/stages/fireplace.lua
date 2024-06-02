function onCreate()

	makeLuaSprite('bg', 'paste/bg', -140, -250)
	scaleObject('bg', 1.25, 1.25)
	addLuaSprite('bg')

	makeAnimatedLuaSprite('fire', 'paste/fire', 730, 150)
	addAnimationByPrefix('fire', 'fire', 'fire', 24, true)
	scaleObject('fire', 1.25, 1.25)
	addLuaSprite('fire')

	makeLuaSprite('portal', 'paste/portal', getProperty('bg.x') - (getProperty('bg.width') * .1) - 5500, getProperty('bg.y') - getProperty('bg.height') * .1 - 1200)
	scaleObject('portal', 6.77, 6.77)
	addLuaSprite('portal')
	setProperty('portal.visible', false)

	makeLuaSprite('hallow', 'paste/hallow', getProperty('portal.x') + 4000, getProperty('portal.y') + 2500)
	scaleObject('hallow', 2.85, 2.85)
	addLuaSprite('hallow')
	setProperty('hallow.visible', false)

	makeLuaSprite('hallowSCARY', 'paste/hallowScary', getProperty('portal.x') + 4000, getProperty('portal.y') + 2500)
	scaleObject('hallowSCARY', 2.85, 2.85)
	addLuaSprite('hallowSCARY')
	setProperty('hallowSCARY.visible', false)

	setProperty('boyfriend.x', getProperty('boyfriend.x') - 90)
	setProperty('boyfriend.y', getProperty('boyfriend.y') - 150)
	setProperty('gf.y', getProperty('gf.y') - 150)
end

function onSongStart()
	if getProperty('deathCounter') > 0 then
		runHaxeCode([[game.setSongTime(42950)]])
		setProperty('skipCountdown', true)
	end
end

function onCreatePost()
	setScrollFactor('dad', 1, 1);
	setScrollFactor('boyfriend', 1, 1);
	setScrollFactor('gf', 1, 1);
end

function changeBG()
	setProperty('bg.visible', false);
	setProperty('fire.visible', false);
	setProperty('hallow.visible', true);
	setProperty('hallowSCARY.visible', true);
	setProperty('hallowSCARY.alpha', 0);
	setProperty('portal.visible', true);
	setProperty('defaultCamZoom', 0.46);
	setProperty('camZooming', true);
	setProperty('boyfriendGroup.x', getProperty('boyfriendGroup.x') + 10)
	setProperty('boyfriendGroup.y', getProperty('boyfriendGroup.y') + 2350)
	setProperty('dadGroup.x', getProperty('dadGroup.x') - 550)
	setProperty('dadGroup.y', getProperty('dadGroup.y') + 2350)
end

function changeFinale()
	setProperty('defaultCamZoom', 0.66);
	doTweenY('hallow', 'hallow', -10000000, 5, 'elasticInOut')
	doTweenY('hallowSCARY', 'hallowSCARY', -10000000, 5, 'elasticInOut')
	doTweenAngle('hallowA', 'hallow', 360, 5, 'elasticInOut')
	doTweenAngle('hallowSCARYA', 'hallowSCARY', 360, 5, 'elasticInOut')
end

function onStepHit()
	if curStep == 1472 then doTweenAlpha('hallowSCARY', 'hallowSCARY', 1, 70, 'sineInOut') end
	if curStep == 575 then 
		runHaxeCode([[
			game.camZooming = true;
			game.dad.playAnim("singUP-alt", true);
			game.camGame.shake(0.045, 1.3);
			game.camGame.flash(0xFFFFFF, 0.85);
			game.defaultCamZoom = game.defaultCamZoom - 0.37;
		]])
		changeBG() 
	end
	if curStep == 2232 then
		runHaxeCode([[
			game.dad.playAnim("singUP-alt", true);
			game.camGame.shake(0.045, 1.3);
			game.camGame.flash(0xFFFFFF, 0.85);
		]])
		changeFinale()
	end
end

function onUpdate()
	setProperty('portal.angle', getProperty('portal.angle') + 0.5)
end

function opponentNoteHit()
	if getProperty('health') >= 0.1 then
		setProperty('health', getProperty('health') - 0.025)
	end
end