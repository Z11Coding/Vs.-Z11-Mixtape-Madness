function onEvent(name)
	if name == "Trigger Attack" then
		removeLuaSprite('warn', true)
		cancelTimer('warn')
		makeAnimatedLuaSprite('warn', 'stages/personel/slash_warning_sheet', 0, 150)
		addAnimationByPrefix('warn', 'press', 'slash warning', 24, true)
		scaleObject('warn', 2, 2)
		screenCenter('warn', 'x')
		addLuaSprite('warn', true)
		setObjectCamera('warn', 'hud')
		setObjectOrder('warn', 2)
		playSound('slash-warn');
		runTimer('warn', 0.8)
		function onTimerCompleted(name)
			if name == 'warn' then
					triggerEvent('Play Animation', 'attack', 'FrontViewSl4sh')
					setProperty('health', getProperty('health') -0.75)
					playSound('slash-sfx');
					removeLuaSprite('warn', true)
					triggerEvent('Screen Shake', '0.25, 0.012', '0.1, 0.008')
					triggerEvent('Red Flashbang', '1')
				end
			end
		end
	end

function onUpdate()
	if keyboardJustPressed("SPACE") and getProperty('warn.x') ~= 'warn.x' then
		removeLuaSprite('warn',true);
		cancelTimer('warn');
		triggerEvent('Play Animation', 'attack', 'FrontViewSl4sh')
		triggerEvent('Play Animation', 'dodge', 'boyfriend')
		triggerEvent('Screen Shake', '0.25, 0.012', '0.1, 0.008')
		playSound('slash-sfx');
	end
end

--thanks mistful crimshart morgan