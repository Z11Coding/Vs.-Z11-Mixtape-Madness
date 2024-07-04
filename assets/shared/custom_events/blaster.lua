curHealthValue = 0
newHealthValueStep = 0

function onCreate()
    precacheImage('SansEvent_Blaster');
	if not lowQuality then
		makeAnimatedLuaSprite('SansEvent_Blaster','mechanics/general/SansEvent_Blaster', -900, 522)
		addAnimationByPrefix('SansEvent_Blaster','fefe instance ','fefe instance ',24, false)
		scaleObject('SansEvent_Blaster', 0.55, 0.55);	
		setObjectCamera('SansEvent_Blaster', 'camHUD');
	end

	if difficultyName == 'Hard' and getModSetting("ultimaMode") then
		BlasterDamageDealt = 1
	elseif difficultyName == 'Dave' and not getModSetting("ultimaMode") then
		BlasterDamageDealt = 1.2
	elseif difficultyName == 'Dave' and getModSetting("ultimaMode") then
		BlasterDamageDealt = 1.50
	end
end

function onEvent(name, value1, value2)
	if name == 'blaster' then
		if value1 == 'Do' then
			runTimer('BlasterDoDealDamage', 0.6)
			runTimer('BlasterDoRemoveSprite', 1)
			addLuaSprite('SansEvent_Blaster', true)
			playSound('BlasterShoot', 1)
			objectPlayAnimation('SansEvent_Blaster','fefe instance ',true)
		end
	end	
end

function onTimerCompleted(tag)
	health = getProperty('health')
	if tag == 'BlasterDoDealDamage' then
		curHealthValue = health
		newHealthValueStep = curHealthValue - BlasterDamageDealt

		if newHealthValueStep < 0.01 then
			newHealthValueStep = 0.01
		end
		setProperty('health', newHealthValueStep)
	end

	if tag == 'BlasterDoRemoveSprite' then
		removeLuaSprite('SansEvent_Blaster', false)
	end
end
